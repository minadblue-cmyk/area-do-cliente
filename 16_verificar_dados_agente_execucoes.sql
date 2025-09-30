-- Script para verificar dados na tabela agente_execucoes
-- Execute este script no PostgreSQL para diagnosticar o problema

-- 1. Verificar se a tabela existe e tem dados
SELECT 
    'Total de registros na tabela' as info,
    COUNT(*) as total
FROM agente_execucoes;

-- 2. Verificar registros para usuario_id = 5
SELECT 
    'Registros para usuario_id = 5' as info,
    COUNT(*) as total
FROM agente_execucoes 
WHERE usuario_id = 5;

-- 3. Verificar registros para workflow_id = 'agente-prospeccao-quente'
SELECT 
    'Registros para workflow_id = agente-prospeccao-quente' as info,
    COUNT(*) as total
FROM agente_execucoes 
WHERE workflow_id = 'agente-prospeccao-quente';

-- 4. Verificar registros para usuario_id = 5 AND workflow_id = 'agente-prospeccao-quente'
SELECT 
    'Registros para usuario_id=5 AND workflow_id=agente-prospeccao-quente' as info,
    COUNT(*) as total
FROM agente_execucoes 
WHERE usuario_id = 5 
AND workflow_id = 'agente-prospeccao-quente';

-- 5. Ver todos os registros da tabela (últimos 10)
SELECT 
    id,
    execution_id,
    workflow_id,
    usuario_id,
    status,
    iniciado_em,
    parado_em
FROM agente_execucoes 
ORDER BY iniciado_em DESC 
LIMIT 10;

-- 6. Verificar valores únicos de workflow_id
SELECT 
    'Valores únicos de workflow_id' as info,
    workflow_id,
    COUNT(*) as total
FROM agente_execucoes 
GROUP BY workflow_id
ORDER BY total DESC;

-- 7. Verificar valores únicos de usuario_id
SELECT 
    'Valores únicos de usuario_id' as info,
    usuario_id,
    COUNT(*) as total
FROM agente_execucoes 
GROUP BY usuario_id
ORDER BY total DESC;

-- 8. Verificar valores únicos de status
SELECT 
    'Valores únicos de status' as info,
    status,
    COUNT(*) as total
FROM agente_execucoes 
GROUP BY status
ORDER BY total DESC;
