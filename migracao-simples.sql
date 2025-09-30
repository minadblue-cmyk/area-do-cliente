-- MIGRAÇÃO SIMPLES DE WEBHOOKS DE AGENTES
-- Execute este script no seu banco PostgreSQL

-- 1. Migrar webhook_url para webhook_start_url
UPDATE agentes_config 
SET webhook_start_url = webhook_url 
WHERE webhook_url IS NOT NULL;

-- 2. Migrar workflow_id para workflow_start_id  
UPDATE agentes_config 
SET workflow_start_id = workflow_id 
WHERE workflow_id IS NOT NULL;

-- 3. Verificar resultado da migração
SELECT 
    id,
    nome,
    workflow_id as 'workflow_original',
    workflow_start_id as 'workflow_start_novo',
    webhook_url as 'webhook_original', 
    webhook_start_url as 'webhook_start_novo'
FROM agentes_config 
ORDER BY id;

-- 4. Mostrar estatísticas
SELECT 
    COUNT(*) as total_agentes,
    COUNT(webhook_start_url) as com_webhook_start,
    COUNT(workflow_start_id) as com_workflow_start
FROM agentes_config;
