-- Script para verificar execuções de agentes
-- Execute este script para ver se há dados na tabela agente_execucoes

-- Verificar se a tabela existe
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name = 'agente_execucoes'
        ) 
        THEN 'Tabela agente_execucoes EXISTE' 
        ELSE 'Tabela agente_execucoes NÃO EXISTE' 
    END as status_tabela;

-- Se existir, contar registros
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name = 'agente_execucoes'
        ) 
        THEN (SELECT COUNT(*) FROM agente_execucoes)
        ELSE 0 
    END as total_execucoes;

-- Listar execuções por workflow_id
SELECT 
    workflow_id,
    COUNT(*) as total_execucoes,
    MAX(iniciado_em) as ultima_execucao
FROM agente_execucoes 
GROUP BY workflow_id
ORDER BY workflow_id;

-- Listar todas as execuções
SELECT 
    id,
    workflow_id,
    usuario_id,
    status,
    iniciado_em,
    parado_em,
    message
FROM agente_execucoes 
ORDER BY iniciado_em DESC
LIMIT 10;
