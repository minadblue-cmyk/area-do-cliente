-- Script para obter estrutura completa da tabela lead
-- Execute este script e me retorne o resultado para análise

-- =====================================================
-- 1. ESTRUTURA DETALHADA DA TABELA LEAD
-- =====================================================

-- Informações gerais da tabela
SELECT 
    'INFORMACOES_GERAIS' as tipo,
    schemaname,
    tablename,
    tableowner,
    hasindexes,
    hasrules,
    hastriggers,
    rowsecurity as rls_ativo
FROM pg_tables 
WHERE tablename = 'lead';

-- =====================================================
-- 2. COLUNAS DETALHADAS
-- =====================================================

-- Estrutura completa das colunas
SELECT 
    'COLUNAS' as tipo,
    column_name,
    ordinal_position,
    column_default,
    is_nullable,
    data_type,
    character_maximum_length,
    numeric_precision,
    numeric_scale,
    datetime_precision,
    udt_name,
    is_identity,
    identity_generation,
    identity_start,
    identity_increment,
    identity_maximum,
    identity_minimum,
    identity_cycle
FROM information_schema.columns 
WHERE table_name = 'lead' 
ORDER BY ordinal_position;

-- =====================================================
-- 3. CHAVES E ÍNDICES
-- =====================================================

-- Chaves primárias
SELECT 
    'CHAVE_PRIMARIA' as tipo,
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    kcu.ordinal_position
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.constraint_type = 'PRIMARY KEY'
    AND tc.table_name = 'lead';

-- Chaves estrangeiras
SELECT 
    'CHAVE_ESTRANGEIRA' as tipo,
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_name = 'lead';

-- Índices
SELECT 
    'INDICES' as tipo,
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename = 'lead';

-- =====================================================
-- 4. COMENTÁRIOS E DOCUMENTAÇÃO
-- =====================================================

-- Comentários das colunas
SELECT 
    'COMENTARIOS' as tipo,
    c.column_name,
    obj_description(c.ordinal_position, 'pg_class') as comentario_coluna
FROM information_schema.columns c
JOIN pg_class pgc ON pgc.relname = c.table_name
WHERE c.table_name = 'lead'
ORDER BY c.ordinal_position;

-- =====================================================
-- 5. ESTATÍSTICAS DE DADOS
-- =====================================================

-- Contagem de registros
SELECT 
    'ESTATISTICAS' as tipo,
    'total_registros' as metrica,
    COUNT(*) as valor
FROM lead;

-- Campos com valores nulos
SELECT 
    'CAMPOS_NULOS' as tipo,
    column_name,
    COUNT(*) as total_nulos
FROM information_schema.columns c
CROSS JOIN LATERAL (
    SELECT COUNT(*) as null_count
    FROM lead l
    WHERE CASE 
        WHEN c.column_name = 'nome' THEN l.nome IS NULL
        WHEN c.column_name = 'nome_cliente' THEN l.nome_cliente IS NULL
        WHEN c.column_name = 'telefone' THEN l.telefone IS NULL
        WHEN c.column_name = 'email' THEN l.email IS NULL
        WHEN c.column_name = 'status' THEN l.status IS NULL
        WHEN c.column_name = 'empresa_id' THEN l.empresa_id IS NULL
        WHEN c.column_name = 'agente_id' THEN l.agente_id IS NULL
        WHEN c.column_name = 'perfil_id' THEN l.perfil_id IS NULL
        WHEN c.column_name = 'contatado' THEN l.contatado IS NULL
        WHEN c.column_name = 'client_id' THEN l.client_id IS NULL
        WHEN c.column_name = 'fonte_prospec' THEN l.fonte_prospec IS NULL
        WHEN c.column_name = 'idade' THEN l.idade IS NULL
        WHEN c.column_name = 'profissao' THEN l.profissao IS NULL
        WHEN c.column_name = 'estado_civil' THEN l.estado_civil IS NULL
        WHEN c.column_name = 'filhos' THEN l.filhos IS NULL
        WHEN c.column_name = 'qtd_filhos' THEN l.qtd_filhos IS NULL
        WHEN c.column_name = 'reservado_por' THEN l.reservado_por IS NULL
        WHEN c.column_name = 'reservado_em' THEN l.reservado_em IS NULL
        WHEN c.column_name = 'reservado_lote' THEN l.reservado_lote IS NULL
        WHEN c.column_name = 'permissoes_acesso' THEN l.permissoes_acesso IS NULL
        WHEN c.column_name = 'proximo_contato_em' THEN l.proximo_contato_em IS NULL
        WHEN c.column_name = 'pode_recontatar' THEN l.pode_recontatar IS NULL
        WHEN c.column_name = 'observacoes_recontato' THEN l.observacoes_recontato IS NULL
        WHEN c.column_name = 'prioridade_recontato' THEN l.prioridade_recontato IS NULL
        WHEN c.column_name = 'agendado_por_usuario_id' THEN l.agendado_por_usuario_id IS NULL
        WHEN c.column_name = 'data_agendamento' THEN l.data_agendamento IS NULL
        WHEN c.column_name = 'data_insercao' THEN l.data_insercao IS NULL
        WHEN c.column_name = 'data_criacao' THEN l.data_criacao IS NULL
        WHEN c.column_name = 'data_ultima_interacao' THEN l.data_ultima_interacao IS NULL
        WHEN c.column_name = 'canal' THEN l.canal IS NULL
        WHEN c.column_name = 'estagio_funnel' THEN l.estagio_funnel IS NULL
        WHEN c.column_name = 'pergunta_index' THEN l.pergunta_index IS NULL
        WHEN c.column_name = 'ultima_pergunta' THEN l.ultima_pergunta IS NULL
        WHEN c.column_name = 'ultima_resposta' THEN l.ultima_resposta IS NULL
        WHEN c.column_name = 'respostas' THEN l.respostas IS NULL
        ELSE false
    END
) stats
WHERE c.table_name = 'lead'
GROUP BY c.column_name
ORDER BY total_nulos DESC;

-- =====================================================
-- 6. ANÁLISE DE REDUNDÂNCIA
-- =====================================================

-- Verificar se nome e nome_cliente são diferentes
SELECT 
    'ANALISE_REDUNDANCIA' as tipo,
    'nome_vs_nome_cliente' as comparacao,
    COUNT(*) as total_registros,
    COUNT(CASE WHEN nome = nome_cliente THEN 1 END) as iguais,
    COUNT(CASE WHEN nome != nome_cliente THEN 1 END) as diferentes,
    COUNT(CASE WHEN nome IS NULL OR nome_cliente IS NULL THEN 1 END) as com_nulos
FROM lead;

-- Verificar se data_criacao e data_insercao são diferentes
SELECT 
    'ANALISE_REDUNDANCIA' as tipo,
    'data_criacao_vs_data_insercao' as comparacao,
    COUNT(*) as total_registros,
    COUNT(CASE WHEN data_criacao = data_insercao THEN 1 END) as iguais,
    COUNT(CASE WHEN data_criacao != data_insercao THEN 1 END) as diferentes,
    COUNT(CASE WHEN data_criacao IS NULL OR data_insercao IS NULL THEN 1 END) as com_nulos
FROM lead;

-- =====================================================
-- 7. USO DOS CAMPOS
-- =====================================================

-- Verificar quais campos são mais utilizados
SELECT 
    'USO_CAMPOS' as tipo,
    'nome' as campo,
    COUNT(*) as total,
    COUNT(nome) as preenchidos,
    ROUND(COUNT(nome)::DECIMAL / COUNT(*) * 100, 2) as percentual_preenchido
FROM lead

UNION ALL

SELECT 
    'USO_CAMPOS' as tipo,
    'nome_cliente' as campo,
    COUNT(*) as total,
    COUNT(nome_cliente) as preenchidos,
    ROUND(COUNT(nome_cliente)::DECIMAL / COUNT(*) * 100, 2) as percentual_preenchido
FROM lead

UNION ALL

SELECT 
    'USO_CAMPOS' as tipo,
    'telefone' as campo,
    COUNT(*) as total,
    COUNT(telefone) as preenchidos,
    ROUND(COUNT(telefone)::DECIMAL / COUNT(*) * 100, 2) as percentual_preenchido
FROM lead

UNION ALL

SELECT 
    'USO_CAMPOS' as tipo,
    'email' as campo,
    COUNT(*) as total,
    COUNT(email) as preenchidos,
    ROUND(COUNT(email)::DECIMAL / COUNT(*) * 100, 2) as percentual_preenchido
FROM lead

UNION ALL

SELECT 
    'USO_CAMPOS' as tipo,
    'status' as campo,
    COUNT(*) as total,
    COUNT(status) as preenchidos,
    ROUND(COUNT(status)::DECIMAL / COUNT(*) * 100, 2) as percentual_preenchido
FROM lead

ORDER BY percentual_preenchido DESC;

RAISE NOTICE 'Script de análise da tabela lead executado com sucesso!';
