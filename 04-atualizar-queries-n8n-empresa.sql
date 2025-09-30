-- Script 4: Queries atualizadas para n8n com isolamento por empresa
-- Queries que devem ser usadas nos workflows do n8n

-- =====================================================
-- 1. QUERY DE UPLOAD (INSERT) - ATUALIZADA
-- =====================================================

-- Query para inserir leads com empresa_id
-- Usar no nó "Insert Lead" do workflow de upload
INSERT INTO lead (
    nome,
    telefone,
    email,
    status,
    nome_cliente,
    fonte_prospec,
    idade,
    profissao,
    estado_civil,
    filhos,
    qtd_filhos,
    data_insercao,
    empresa_id,  -- NOVO: ID da empresa do usuário
    usuario_id,  -- ID do usuário que fez o upload
    created_at,
    updated_at
) VALUES (
    $1,  -- nome
    $2,  -- telefone
    $3,  -- email
    'novo',  -- status padrão
    $4,  -- nome_cliente
    $5,  -- fonte_prospec
    $6,  -- idade
    $7,  -- profissao
    $8,  -- estado_civil
    $9,  -- filhos
    $10, -- qtd_filhos
    NOW(), -- data_insercao
    $11, -- empresa_id (do usuário logado)
    $12, -- usuario_id (do usuário logado)
    NOW(), -- created_at
    NOW()  -- updated_at
)
ON CONFLICT (telefone) DO UPDATE SET
    nome = EXCLUDED.nome,
    email = EXCLUDED.email,
    nome_cliente = EXCLUDED.nome_cliente,
    fonte_prospec = EXCLUDED.fonte_prospec,
    idade = EXCLUDED.idade,
    profissao = EXCLUDED.profissao,
    estado_civil = EXCLUDED.estado_civil,
    filhos = EXCLUDED.filhos,
    qtd_filhos = EXCLUDED.qtd_filhos,
    data_insercao = EXCLUDED.data_insercao,
    empresa_id = EXCLUDED.empresa_id,  -- NOVO: Atualizar empresa_id
    updated_at = NOW()
RETURNING id, empresa_id;

-- =====================================================
-- 2. QUERY DE BUSCA DE LEADS NÃO CONTATADOS - ATUALIZADA
-- =====================================================

-- Query para buscar leads não contatados (filtrado por empresa)
-- Usar no nó "Busca leads não contatados" do workflow de start
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
    WHERE l.status = 'novo'
        AND l.empresa_id = $1  -- empresa_id do usuário logado
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
-- 3. QUERY DE BUSCA DO LOTE RESERVADO - ATUALIZADA
-- =====================================================

-- Query para buscar o lote reservado pelo agente (filtrado por empresa)
-- Usar no nó "Buscar o lote reservado" do workflow de lista
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
WHERE l.agente_id = $1  -- agente_id
    AND l.empresa_id = $2  -- empresa_id do usuário logado
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
        OR $4::INTEGER = ANY(
            SELECT jsonb_array_elements_text(l.permissoes_acesso->'usuarios_permitidos')::INTEGER
        )
    )
ORDER BY l.created_at ASC;

-- =====================================================
-- 4. QUERY DE ATUALIZAÇÃO DE STATUS - ATUALIZADA
-- =====================================================

-- Query para atualizar status do lead (com verificação de empresa)
-- Usar nos nós de atualização de status
UPDATE lead 
SET 
    status = $1,  -- novo status
    data_ultima_interacao = NOW(),
    updated_at = NOW()
WHERE id = $2  -- lead_id
    AND empresa_id = $3  -- empresa_id do usuário logado
    AND agente_id = $4  -- agente_id
RETURNING id, status, empresa_id, agente_id;

-- =====================================================
-- 5. QUERY DE ESTATÍSTICAS POR EMPRESA - NOVA
-- =====================================================

-- Query para estatísticas de leads por empresa
-- Usar em dashboards ou relatórios
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
WHERE e.id = $1  -- empresa_id do usuário logado
GROUP BY e.id, e.nome_empresa;

-- =====================================================
-- 6. QUERY DE VALIDAÇÃO DE ACESSO - NOVA
-- =====================================================

-- Query para validar se usuário pode acessar lead
-- Usar antes de qualquer operação com lead
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
WHERE l.id = $1  -- lead_id
    AND u.id = $2;  -- usuario_id

-- =====================================================
-- 7. QUERY DE BUSCA DE LEADS POR FILTROS - ATUALIZADA
-- =====================================================

-- Query para buscar leads com filtros (filtrado por empresa)
-- Usar em funcionalidades de busca/filtro
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
WHERE l.empresa_id = $1  -- empresa_id do usuário logado
    AND ($2::TEXT IS NULL OR l.status = $2)  -- filtro por status
    AND ($3::TEXT IS NULL OR l.nome ILIKE '%' || $3 || '%')  -- filtro por nome
    AND ($4::TEXT IS NULL OR l.telefone ILIKE '%' || $4 || '%')  -- filtro por telefone
    AND ($5::INTEGER IS NULL OR l.agente_id = $5)  -- filtro por agente
    AND ($6::DATE IS NULL OR DATE(l.created_at) >= $6)  -- filtro por data início
    AND ($7::DATE IS NULL OR DATE(l.created_at) <= $7)  -- filtro por data fim
ORDER BY l.created_at DESC
LIMIT $8 OFFSET $9;  -- paginação

-- =====================================================
-- 8. DOCUMENTAÇÃO DAS QUERIES
-- =====================================================

-- Criar tabela de documentação das queries
CREATE TABLE IF NOT EXISTS queries_empresa_documentacao (
    id SERIAL PRIMARY KEY,
    query_nome TEXT NOT NULL,
    descricao TEXT NOT NULL,
    parametros TEXT NOT NULL,
    uso TEXT NOT NULL,
    criada_em TIMESTAMP DEFAULT NOW()
);

-- Inserir documentação das queries
INSERT INTO queries_empresa_documentacao (query_nome, descricao, parametros, uso)
VALUES 
    ('INSERT_LEAD_EMPRESA', 'Inserir lead com empresa_id', 'nome, telefone, email, nome_cliente, fonte_prospec, idade, profissao, estado_civil, filhos, qtd_filhos, empresa_id, usuario_id', 'Workflow de upload'),
    ('BUSCAR_LEADS_NAO_CONTATADOS_EMPRESA', 'Buscar leads não contatados filtrado por empresa', 'empresa_id, quantidade, agente_id, perfil_id, nome_usuario, lote_id, permissoes_json', 'Workflow de start'),
    ('BUSCAR_LOTE_RESERVADO_EMPRESA', 'Buscar lote reservado filtrado por empresa', 'agente_id, empresa_id, perfil_id, usuario_id', 'Workflow de lista'),
    ('ATUALIZAR_STATUS_LEAD_EMPRESA', 'Atualizar status com verificação de empresa', 'novo_status, lead_id, empresa_id, agente_id', 'Workflows de atualização'),
    ('ESTATISTICAS_EMPRESA', 'Estatísticas de leads por empresa', 'empresa_id', 'Dashboards e relatórios'),
    ('VALIDAR_ACESSO_LEAD', 'Validar acesso a lead por empresa', 'lead_id, usuario_id', 'Validações de segurança'),
    ('BUSCAR_LEADS_FILTROS_EMPRESA', 'Buscar leads com filtros por empresa', 'empresa_id, status, nome, telefone, agente_id, data_inicio, data_fim, limit, offset', 'Funcionalidades de busca');

RAISE NOTICE 'Script 4 executado com sucesso! Queries atualizadas para n8n com isolamento por empresa.';
