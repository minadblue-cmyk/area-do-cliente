-- Script para atualizar workflow_id na tabela agente_execucoes
-- Este script mapeia os IDs reais do n8n para nomes mais legíveis

-- 1. Verificar dados atuais
SELECT 
    'Dados atuais' as info,
    workflow_id,
    COUNT(*) as total
FROM agente_execucoes 
GROUP BY workflow_id
ORDER BY total DESC;

-- 2. Atualizar workflow_id para nomes mais legíveis
-- Mapear 'eBcColwirndBaFZX' para 'prospeccao-quente'
UPDATE agente_execucoes 
SET workflow_id = 'prospeccao-quente'
WHERE workflow_id = 'eBcColwirndBaFZX';

-- Mapear 'YiEudLRKWBBRzm3b' para 'prospeccao-fria'
UPDATE agente_execucoes 
SET workflow_id = 'prospeccao-fria'
WHERE workflow_id = 'YiEudLRKWBBRzm3b';

-- 3. Verificar dados após atualização
SELECT 
    'Dados após atualização' as info,
    workflow_id,
    COUNT(*) as total
FROM agente_execucoes 
GROUP BY workflow_id
ORDER BY total DESC;

-- 4. Verificar se agora temos dados para usuario_id=5 AND workflow_id='prospeccao-quente'
SELECT 
    'Registros para usuario_id=5 AND workflow_id=prospeccao-quente' as info,
    COUNT(*) as total
FROM agente_execucoes 
WHERE usuario_id = 5 
AND workflow_id = 'prospeccao-quente';

-- 5. Listar alguns registros para verificação
SELECT 
    id,
    execution_id,
    workflow_id,
    usuario_id,
    status,
    iniciado_em
FROM agente_execucoes 
WHERE usuario_id = 5 
AND workflow_id IN ('prospeccao-quente', 'prospeccao-fria')
ORDER BY iniciado_em DESC
LIMIT 5;
