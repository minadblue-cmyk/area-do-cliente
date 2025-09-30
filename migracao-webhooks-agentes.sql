-- Script de migração para webhooks de agentes
-- Migra webhook_url existente para webhook_start_url

-- 1. Atualizar webhook_start_url com os valores existentes de webhook_url
UPDATE agentes_config 
SET webhook_start_url = webhook_url 
WHERE webhook_url IS NOT NULL 
AND webhook_start_url IS NULL;

-- 2. Atualizar workflow_start_id com os valores existentes de workflow_id
UPDATE agentes_config 
SET workflow_start_id = workflow_id 
WHERE workflow_id IS NOT NULL 
AND workflow_start_id IS NULL;

-- 3. Verificar a migração
SELECT 
    id,
    nome,
    workflow_id as 'workflow_id_original',
    workflow_start_id as 'workflow_start_id_novo',
    webhook_url as 'webhook_url_original',
    webhook_start_url as 'webhook_start_url_novo',
    ativo
FROM agentes_config 
ORDER BY id;

-- 4. Opcional: Remover colunas antigas após confirmar que a migração foi bem-sucedida
-- (Descomente as linhas abaixo apenas após verificar que tudo está correto)
-- ALTER TABLE agentes_config DROP COLUMN workflow_id;
-- ALTER TABLE agentes_config DROP COLUMN webhook_url;
