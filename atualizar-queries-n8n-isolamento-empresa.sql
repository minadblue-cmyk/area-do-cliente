-- Queries atualizadas para n8n com isolamento por empresa
-- Use estas queries nos workflows do n8n

-- =====================================================
-- 1. QUERY DE UPLOAD (INSERT) - COM ISOLAMENTO
-- =====================================================

-- Query para inserir leads com isolamento por empresa
-- Usar no nó "Insert Lead" do workflow de upload
-- IMPORTANTE: Definir usuário atual antes da query
SELECT set_current_user_id($1); -- $1 = usuario_id

INSERT INTO lead (
    nome,
    telefone,
    email,
    status,
    profissao,
    idade,
    estado_civil,
    filhos,
    qtd_filhos,
    fonte_prospec,
    empresa_id,
    usuario_id,
    contatado,
    created_at,
    updated_at
) VALUES (
    $2,  -- nome
    $3,  -- telefone
    $4,  -- email
    'novo',  -- status padrão
    $5,  -- profissao
    $6,  -- idade
    $7,  -- estado_civil
    $8,  -- filhos
    $9,  -- qtd_filhos
    $10, -- fonte_prospec
    (SELECT empresa_id FROM usuarios WHERE id = $1), -- empresa_id do usuário
    $1,  -- usuario_id
    false, -- contatado
    NOW(), -- created_at
    NOW()  -- updated_at
)
ON CONFLICT (empresa_id, telefone) DO UPDATE SET
    nome = EXCLUDED.nome,
    email = EXCLUDED.email,
    profissao = EXCLUDED.profissao,
    idade = EXCLUDED.idade,
    estado_civil = EXCLUDED.estado_civil,
    filhos = EXCLUDED.filhos,
    qtd_filhos = EXCLUDED.qtd_filhos,
    fonte_prospec = EXCLUDED.fonte_prospec,
    updated_at = NOW()
RETURNING id, empresa_id;

-- =====================================================
-- 2. QUERY DE BUSCA DE LEADS NÃO CONTATADOS - COM ISOLAMENTO
-- =====================================================

-- Query para buscar leads não contatados (filtrado por empresa)
-- Usar no nó "Busca leads não contatados" do workflow de start
-- IMPORTANTE: Definir usuário atual antes da query
SELECT set_current_user_id($1); -- $1 = usuario_id

WITH leads_disponiveis AS (
    SELECT 
        l.id,
        l.nome,
        l.telefone,
        l.email,
        l.status,
        l.empresa_id,
        l.usuario_id,
        l.created_at
    FROM lead l
    WHERE l.empresa_id = (SELECT empresa_id FROM usuarios WHERE id = $1) -- empresa_id do usuário
        AND l.status = 'novo'
        AND l.agente_id IS NULL
    ORDER BY l.created_at ASC
    LIMIT $2  -- quantidade de leads a reservar
),
leads_reservados AS (
    UPDATE lead 
    SET 
        status = 'prospectando',
        agente_id = $3,  -- agente_id
        perfil_id = $4,  -- perfil_id
        reservado_por = $5,  -- nome do usuário
        reservado_em = NOW(),
        reservado_lote = $6,  -- identificador do lote
        permissoes_acesso = $7,  -- JSON com permissões
        data_ultima_interacao = NOW(),
        contatado = true,
        updated_at = NOW()
    WHERE id IN (SELECT id FROM leads_disponiveis)
    RETURNING *
)
SELECT 
    lr.id,
    lr.nome,
    lr.telefone,
    lr.email,
    lr.status,
    lr.empresa_id,
    lr.agente_id,
    lr.perfil_id,
    lr.reservado_por,
    lr.reservado_em,
    lr.reservado_lote,
    lr.permissoes_acesso,
    lr.contatado,
    lr.created_at,
    lr.updated_at
FROM leads_reservados lr
ORDER BY lr.created_at ASC;

-- =====================================================
-- 3. QUERY DE BUSCA DO LOTE RESERVADO - COM ISOLAMENTO
-- =====================================================

-- Query para buscar o lote reservado pelo agente (filtrado por empresa)
-- Usar no nó "Buscar o lote reservado" do workflow de lista
-- IMPORTANTE: Definir usuário atual antes da query
SELECT set_current_user_id($1); -- $1 = usuario_id

SELECT 
    l.id,
    l.nome,
    l.telefone,
    l.email,
    l.status,
    l.empresa_id,
    l.agente_id,
    l.perfil_id,
    l.reservado_por,
    l.reservado_em,
    l.reservado_lote,
    l.permissoes_acesso,
    l.contatado,
    l.data_ultima_interacao,
    l.created_at,
    l.updated_at,
    e.nome_empresa,
    u.nome as usuario_nome
FROM lead l
JOIN empresas e ON l.empresa_id = e.id
LEFT JOIN usuarios u ON l.usuario_id = u.id
WHERE l.empresa_id = (SELECT empresa_id FROM usuarios WHERE id = $1) -- empresa_id do usuário
    AND l.agente_id = $2  -- agente_id
    AND l.status = 'prospectando'
    AND (
        -- Verificar permissões baseadas no JSONB
        l.permissoes_acesso->>'perfis_permitidos' IS NULL 
        OR $3::INTEGER = ANY(
            SELECT jsonb_array_elements_text(l.permissoes_acesso->'perfis_permitidos')::INTEGER
        )
    )
    AND (
        l.permissoes_acesso->>'usuarios_permitidos' IS NULL 
        OR $1::INTEGER = ANY(
            SELECT jsonb_array_elements_text(l.permissoes_acesso->'usuarios_permitidos')::INTEGER
        )
    )
ORDER BY l.created_at ASC;

-- =====================================================
-- 4. QUERY DE ATUALIZAÇÃO DE STATUS - COM ISOLAMENTO
-- =====================================================

-- Query para atualizar status do lead (com verificação de empresa)
-- Usar nos nós de atualização de status
-- IMPORTANTE: Definir usuário atual antes da query
SELECT set_current_user_id($1); -- $1 = usuario_id

UPDATE lead 
SET 
    status = $2,  -- novo status
    data_ultima_interacao = NOW(),
    updated_at = NOW()
WHERE id = $3  -- lead_id
    AND empresa_id = (SELECT empresa_id FROM usuarios WHERE id = $1) -- empresa_id do usuário
    AND agente_id = $4  -- agente_id
RETURNING id, status, empresa_id, agente_id;

-- =====================================================
-- 5. QUERY DE ESTATÍSTICAS POR EMPRESA - COM ISOLAMENTO
-- =====================================================

-- Query para estatísticas de leads por empresa
-- Usar em dashboards ou relatórios
-- IMPORTANTE: Definir usuário atual antes da query
SELECT set_current_user_id($1); -- $1 = usuario_id

SELECT 
    e.id as empresa_id,
    e.nome_empresa,
    COUNT(l.id) as total_leads,
    COUNT(CASE WHEN l.status = 'novo' THEN 1 END) as leads_novos,
    COUNT(CASE WHEN l.status = 'prospectando' THEN 1 END) as leads_prospectando,
    COUNT(CASE WHEN l.status = 'concluido' THEN 1 END) as leads_concluidos,
    COUNT(CASE WHEN l.contatado = true THEN 1 END) as leads_contatados,
    COUNT(DISTINCT l.agente_id) as agentes_ativos
FROM empresas e
LEFT JOIN lead l ON e.id = l.empresa_id
WHERE e.id = (SELECT empresa_id FROM usuarios WHERE id = $1) -- empresa_id do usuário
GROUP BY e.id, e.nome_empresa;

-- =====================================================
-- 6. QUERY DE VALIDAÇÃO DE ACESSO - COM ISOLAMENTO
-- =====================================================

-- Query para validar se usuário pode acessar lead
-- Usar antes de qualquer operação com lead
-- IMPORTANTE: Definir usuário atual antes da query
SELECT set_current_user_id($1); -- $1 = usuario_id

SELECT 
    CASE 
        WHEN l.empresa_id = u.empresa_id THEN true
        ELSE false
    END as pode_acessar,
    l.empresa_id as lead_empresa_id,
    u.empresa_id as usuario_empresa_id,
    e_lead.nome_empresa as empresa_lead,
    e_user.nome_empresa as empresa_usuario
FROM lead l
CROSS JOIN usuarios u
LEFT JOIN empresas e_lead ON l.empresa_id = e_lead.id
LEFT JOIN empresas e_user ON u.empresa_id = e_user.id
WHERE l.id = $2  -- lead_id
    AND u.id = $1;  -- usuario_id

-- =====================================================
-- 7. QUERY DE BUSCA DE LEADS POR FILTROS - COM ISOLAMENTO
-- =====================================================

-- Query para buscar leads com filtros (filtrado por empresa)
-- Usar em funcionalidades de busca/filtro
-- IMPORTANTE: Definir usuário atual antes da query
SELECT set_current_user_id($1); -- $1 = usuario_id

SELECT 
    l.id,
    l.nome,
    l.telefone,
    l.email,
    l.status,
    l.empresa_id,
    l.agente_id,
    l.contatado,
    l.data_ultima_interacao,
    l.created_at,
    e.nome_empresa
FROM lead l
JOIN empresas e ON l.empresa_id = e.id
WHERE l.empresa_id = (SELECT empresa_id FROM usuarios WHERE id = $1) -- empresa_id do usuário
    AND ($2::TEXT IS NULL OR l.status = $2)  -- filtro por status
    AND ($3::TEXT IS NULL OR l.nome ILIKE '%' || $3 || '%')  -- filtro por nome
    AND ($4::TEXT IS NULL OR l.telefone ILIKE '%' || $4 || '%')  -- filtro por telefone
    AND ($5::INTEGER IS NULL OR l.agente_id = $5)  -- filtro por agente
    AND ($6::DATE IS NULL OR DATE(l.created_at) >= $6)  -- filtro por data início
    AND ($7::DATE IS NULL OR DATE(l.created_at) <= $7)  -- filtro por data fim
ORDER BY l.created_at DESC
LIMIT $8 OFFSET $9;  -- paginação

-- =====================================================
-- 8. QUERY DE BUSCA DE LEADS DUPLICADOS - COM ISOLAMENTO
-- =====================================================

-- Query para buscar leads duplicados dentro da mesma empresa
-- Usar para verificar duplicatas antes do upload
-- IMPORTANTE: Definir usuário atual antes da query
SELECT set_current_user_id($1); -- $1 = usuario_id

SELECT 
    telefone,
    COUNT(*) as quantidade,
    STRING_AGG(nome, ', ') as nomes,
    STRING_AGG(id::TEXT, ', ') as ids
FROM lead
WHERE empresa_id = (SELECT empresa_id FROM usuarios WHERE id = $1) -- empresa_id do usuário
    AND telefone IS NOT NULL
GROUP BY telefone
HAVING COUNT(*) > 1
ORDER BY quantidade DESC;

-- =====================================================
-- 9. QUERY DE LIMPEZA DE LEADS DUPLICADOS - COM ISOLAMENTO
-- =====================================================

-- Query para limpar leads duplicados dentro da mesma empresa
-- Usar para remover duplicatas mantendo o mais recente
-- IMPORTANTE: Definir usuário atual antes da query
SELECT set_current_user_id($1); -- $1 = usuario_id

WITH leads_duplicados AS (
    SELECT 
        id,
        ROW_NUMBER() OVER (PARTITION BY telefone ORDER BY created_at DESC) as rn
    FROM lead
    WHERE empresa_id = (SELECT empresa_id FROM usuarios WHERE id = $1) -- empresa_id do usuário
        AND telefone IS NOT NULL
        AND telefone IN (
            SELECT telefone
            FROM lead
            WHERE empresa_id = (SELECT empresa_id FROM usuarios WHERE id = $1)
            GROUP BY telefone
            HAVING COUNT(*) > 1
        )
)
DELETE FROM lead
WHERE id IN (
    SELECT id 
    FROM leads_duplicados 
    WHERE rn > 1
);

-- =====================================================
-- 10. QUERY DE RELATÓRIO DE ISOLAMENTO - COM ISOLAMENTO
-- =====================================================

-- Query para relatório de isolamento entre empresas
-- Usar para verificar se o isolamento está funcionando
-- IMPORTANTE: Definir usuário atual antes da query
SELECT set_current_user_id($1); -- $1 = usuario_id

SELECT 
    'RELATORIO_ISOLAMENTO' as categoria,
    e.nome_empresa,
    COUNT(l.id) as total_leads,
    COUNT(DISTINCT l.telefone) as telefones_unicos,
    COUNT(l.id) - COUNT(DISTINCT l.telefone) as telefones_duplicados,
    MIN(l.created_at) as lead_mais_antigo,
    MAX(l.created_at) as lead_mais_recente
FROM empresas e
LEFT JOIN lead l ON e.id = l.empresa_id
WHERE e.id = (SELECT empresa_id FROM usuarios WHERE id = $1) -- empresa_id do usuário
GROUP BY e.id, e.nome_empresa;

-- =====================================================
-- 11. DOCUMENTAÇÃO DAS QUERIES
-- =====================================================

-- Criar tabela de documentação das queries
CREATE TABLE IF NOT EXISTS queries_isolamento_empresa_documentacao (
    id SERIAL PRIMARY KEY,
    query_nome TEXT NOT NULL,
    descricao TEXT NOT NULL,
    parametros TEXT NOT NULL,
    uso TEXT NOT NULL,
    isolamento_empresa BOOLEAN DEFAULT true,
    criada_em TIMESTAMP DEFAULT NOW()
);

-- Inserir documentação das queries
INSERT INTO queries_isolamento_empresa_documentacao (query_nome, descricao, parametros, uso, isolamento_empresa)
VALUES 
    ('INSERT_LEAD_ISOLAMENTO', 'Inserir lead com isolamento por empresa', 'usuario_id, nome, telefone, email, profissao, idade, estado_civil, filhos, qtd_filhos, fonte_prospec', 'Workflow de upload', true),
    ('BUSCAR_LEADS_NAO_CONTATADOS_ISOLAMENTO', 'Buscar leads não contatados com isolamento', 'usuario_id, quantidade, agente_id, perfil_id, nome_usuario, lote_id, permissoes_json', 'Workflow de start', true),
    ('BUSCAR_LOTE_RESERVADO_ISOLAMENTO', 'Buscar lote reservado com isolamento', 'usuario_id, agente_id, perfil_id', 'Workflow de lista', true),
    ('ATUALIZAR_STATUS_LEAD_ISOLAMENTO', 'Atualizar status com isolamento', 'usuario_id, novo_status, lead_id, agente_id', 'Workflows de atualização', true),
    ('ESTATISTICAS_EMPRESA_ISOLAMENTO', 'Estatísticas com isolamento', 'usuario_id', 'Dashboards e relatórios', true),
    ('VALIDAR_ACESSO_LEAD_ISOLAMENTO', 'Validar acesso com isolamento', 'usuario_id, lead_id', 'Validações de segurança', true),
    ('BUSCAR_LEADS_FILTROS_ISOLAMENTO', 'Buscar leads com filtros e isolamento', 'usuario_id, status, nome, telefone, agente_id, data_inicio, data_fim, limit, offset', 'Funcionalidades de busca', true),
    ('BUSCAR_LEADS_DUPLICADOS_ISOLAMENTO', 'Buscar leads duplicados com isolamento', 'usuario_id', 'Verificação de duplicatas', true),
    ('LIMPAR_LEADS_DUPLICADOS_ISOLAMENTO', 'Limpar leads duplicados com isolamento', 'usuario_id', 'Limpeza de duplicatas', true),
    ('RELATORIO_ISOLAMENTO', 'Relatório de isolamento', 'usuario_id', 'Verificação de isolamento', true);

RAISE NOTICE 'Queries atualizadas para n8n com isolamento por empresa criadas com sucesso!';
RAISE NOTICE 'IMPORTANTE: Sempre definir usuário atual com set_current_user_id() antes das queries';
RAISE NOTICE 'Isolamento garantido: usuários só veem leads da própria empresa';
RAISE NOTICE 'Chaves únicas: mesmo telefone pode existir em empresas diferentes';
