-- Análise completa da tabela lead para reorganização
-- Execute este script e me retorne o resultado

-- =====================================================
-- 1. ESTRUTURA ATUAL DA TABELA
-- =====================================================

-- Informações gerais
SELECT 
    'ESTRUTURA_GERAL' as categoria,
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
    'COLUNAS_DETALHADAS' as categoria,
    column_name,
    ordinal_position,
    column_default,
    is_nullable,
    data_type,
    character_maximum_length,
    numeric_precision,
    numeric_scale,
    udt_name
FROM information_schema.columns 
WHERE table_name = 'lead' 
ORDER BY ordinal_position;

-- =====================================================
-- 3. ANÁLISE DE REDUNDÂNCIA
-- =====================================================

-- Verificar se nome e nome_cliente são diferentes
SELECT 
    'REDUNDANCIA_NOME' as categoria,
    COUNT(*) as total_registros,
    COUNT(CASE WHEN nome = nome_cliente THEN 1 END) as iguais,
    COUNT(CASE WHEN nome != nome_cliente THEN 1 END) as diferentes,
    COUNT(CASE WHEN nome IS NULL OR nome_cliente IS NULL THEN 1 END) as com_nulos,
    ROUND(COUNT(CASE WHEN nome = nome_cliente THEN 1 END)::DECIMAL / COUNT(*) * 100, 2) as percentual_iguais
FROM lead;

-- Verificar se data_criacao e data_insercao são diferentes
SELECT 
    'REDUNDANCIA_DATA' as categoria,
    COUNT(*) as total_registros,
    COUNT(CASE WHEN data_criacao = data_insercao THEN 1 END) as iguais,
    COUNT(CASE WHEN data_criacao != data_insercao THEN 1 END) as diferentes,
    COUNT(CASE WHEN data_criacao IS NULL OR data_insercao IS NULL THEN 1 END) as com_nulos,
    ROUND(COUNT(CASE WHEN data_criacao = data_insercao THEN 1 END)::DECIMAL / COUNT(*) * 100, 2) as percentual_iguais
FROM lead;

-- =====================================================
-- 4. USO DOS CAMPOS (PERCENTUAL PREENCHIDO)
-- =====================================================

-- Análise de preenchimento dos campos
WITH campo_usage AS (
    SELECT 
        'nome' as campo, COUNT(nome) as preenchidos, COUNT(*) as total
    FROM lead
    UNION ALL
    SELECT 'nome_cliente', COUNT(nome_cliente), COUNT(*) FROM lead
    UNION ALL
    SELECT 'telefone', COUNT(telefone), COUNT(*) FROM lead
    UNION ALL
    SELECT 'email', COUNT(email), COUNT(*) FROM lead
    UNION ALL
    SELECT 'status', COUNT(status), COUNT(*) FROM lead
    UNION ALL
    SELECT 'empresa_id', COUNT(empresa_id), COUNT(*) FROM lead
    UNION ALL
    SELECT 'agente_id', COUNT(agente_id), COUNT(*) FROM lead
    UNION ALL
    SELECT 'perfil_id', COUNT(perfil_id), COUNT(*) FROM lead
    UNION ALL
    SELECT 'contatado', COUNT(contatado), COUNT(*) FROM lead
    UNION ALL
    SELECT 'client_id', COUNT(client_id), COUNT(*) FROM lead
    UNION ALL
    SELECT 'fonte_prospec', COUNT(fonte_prospec), COUNT(*) FROM lead
    UNION ALL
    SELECT 'idade', COUNT(idade), COUNT(*) FROM lead
    UNION ALL
    SELECT 'profissao', COUNT(profissao), COUNT(*) FROM lead
    UNION ALL
    SELECT 'estado_civil', COUNT(estado_civil), COUNT(*) FROM lead
    UNION ALL
    SELECT 'filhos', COUNT(filhos), COUNT(*) FROM lead
    UNION ALL
    SELECT 'qtd_filhos', COUNT(qtd_filhos), COUNT(*) FROM lead
    UNION ALL
    SELECT 'reservado_por', COUNT(reservado_por), COUNT(*) FROM lead
    UNION ALL
    SELECT 'reservado_em', COUNT(reservado_em), COUNT(*) FROM lead
    UNION ALL
    SELECT 'reservado_lote', COUNT(reservado_lote), COUNT(*) FROM lead
    UNION ALL
    SELECT 'permissoes_acesso', COUNT(permissoes_acesso), COUNT(*) FROM lead
    UNION ALL
    SELECT 'proximo_contato_em', COUNT(proximo_contato_em), COUNT(*) FROM lead
    UNION ALL
    SELECT 'canal', COUNT(canal), COUNT(*) FROM lead
    UNION ALL
    SELECT 'estagio_funnel', COUNT(estagio_funnel), COUNT(*) FROM lead
    UNION ALL
    SELECT 'pergunta_index', COUNT(pergunta_index), COUNT(*) FROM lead
    UNION ALL
    SELECT 'ultima_pergunta', COUNT(ultima_pergunta), COUNT(*) FROM lead
    UNION ALL
    SELECT 'ultima_resposta', COUNT(ultima_resposta), COUNT(*) FROM lead
    UNION ALL
    SELECT 'respostas', COUNT(respostas), COUNT(*) FROM lead
    UNION ALL
    SELECT 'data_criacao', COUNT(data_criacao), COUNT(*) FROM lead
    UNION ALL
    SELECT 'data_insercao', COUNT(data_insercao), COUNT(*) FROM lead
    UNION ALL
    SELECT 'data_ultima_interacao', COUNT(data_ultima_interacao), COUNT(*) FROM lead
)
SELECT 
    'USO_CAMPOS' as categoria,
    campo,
    preenchidos,
    total,
    ROUND(preenchidos::DECIMAL / total * 100, 2) as percentual_preenchido
FROM campo_usage
ORDER BY percentual_preenchido DESC;

-- =====================================================
-- 5. ANÁLISE DE VALORES ÚNICOS
-- =====================================================

-- Valores únicos em campos importantes
SELECT 
    'VALORES_UNICOS' as categoria,
    'status' as campo,
    COUNT(DISTINCT status) as valores_unicos,
    STRING_AGG(DISTINCT status, ', ' ORDER BY status) as valores
FROM lead
WHERE status IS NOT NULL

UNION ALL

SELECT 
    'VALORES_UNICOS' as categoria,
    'estagio_funnel' as campo,
    COUNT(DISTINCT estagio_funnel) as valores_unicos,
    STRING_AGG(DISTINCT estagio_funnel, ', ' ORDER BY estagio_funnel) as valores
FROM lead
WHERE estagio_funnel IS NOT NULL

UNION ALL

SELECT 
    'VALORES_UNICOS' as categoria,
    'canal' as campo,
    COUNT(DISTINCT canal) as valores_unicos,
    STRING_AGG(DISTINCT canal, ', ' ORDER BY canal) as valores
FROM lead
WHERE canal IS NOT NULL;

-- =====================================================
-- 6. ANÁLISE DE DADOS DE RECONTATO
-- =====================================================

-- Verificar se campos de recontato existem
SELECT 
    'CAMPOS_RECONTATO' as categoria,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'lead' 
    AND column_name IN (
        'pode_recontatar',
        'observacoes_recontato', 
        'prioridade_recontato',
        'agendado_por_usuario_id',
        'data_agendamento'
    )
ORDER BY column_name;

-- =====================================================
-- 7. ESTATÍSTICAS GERAIS
-- =====================================================

-- Estatísticas gerais da tabela
SELECT 
    'ESTATISTICAS_GERAIS' as categoria,
    COUNT(*) as total_registros,
    COUNT(DISTINCT empresa_id) as empresas_diferentes,
    COUNT(DISTINCT agente_id) as agentes_diferentes,
    COUNT(DISTINCT status) as status_diferentes,
    MIN(created_at) as registro_mais_antigo,
    MAX(created_at) as registro_mais_recente
FROM lead;

-- =====================================================
-- 8. ANÁLISE DE ÍNDICES
-- =====================================================

-- Índices existentes
SELECT 
    'INDICES' as categoria,
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename = 'lead';

-- =====================================================
-- 9. ANÁLISE DE CHAVES ESTRANGEIRAS
-- =====================================================

-- Chaves estrangeiras
SELECT 
    'CHAVES_ESTRANGEIRAS' as categoria,
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

-- =====================================================
-- 10. RECOMENDAÇÕES DE REORGANIZAÇÃO
-- =====================================================

-- Campos recomendados para remoção (baseado em uso baixo)
SELECT 
    'RECOMENDACOES' as categoria,
    'CAMPOS_PARA_REMOVER' as tipo,
    campo,
    percentual_preenchido,
    'Baixo uso - considerar remoção' as justificativa
FROM (
    WITH campo_usage AS (
        SELECT 'canal' as campo, COUNT(canal) as preenchidos, COUNT(*) as total FROM lead
        UNION ALL
        SELECT 'estagio_funnel', COUNT(estagio_funnel), COUNT(*) FROM lead
        UNION ALL
        SELECT 'pergunta_index', COUNT(pergunta_index), COUNT(*) FROM lead
        UNION ALL
        SELECT 'ultima_pergunta', COUNT(ultima_pergunta), COUNT(*) FROM lead
        UNION ALL
        SELECT 'ultima_resposta', COUNT(ultima_resposta), COUNT(*) FROM lead
        UNION ALL
        SELECT 'respostas', COUNT(respostas), COUNT(*) FROM lead
        UNION ALL
        SELECT 'client_id', COUNT(client_id), COUNT(*) FROM lead
    )
    SELECT 
        campo,
        ROUND(preenchidos::DECIMAL / total * 100, 2) as percentual_preenchido
    FROM campo_usage
    WHERE ROUND(preenchidos::DECIMAL / total * 100, 2) < 10
) subq;

-- Campos redundantes identificados
SELECT 
    'RECOMENDACOES' as categoria,
    'CAMPOS_REDUNDANTES' as tipo,
    'nome_cliente' as campo,
    'Redundante com nome' as justificativa
UNION ALL
SELECT 
    'RECOMENDACOES' as categoria,
    'CAMPOS_REDUNDANTES' as tipo,
    'data_insercao' as campo,
    'Redundante com data_criacao' as justificativa;

RAISE NOTICE 'Análise completa da tabela lead executada com sucesso!';
