-- Script para remover colunas antigas após migração
-- Remove workflow_id e webhook_url da tabela agentes_config

-- 1. Verificar dados antes da remoção
SELECT 
    id,
    nome,
    workflow_id as 'workflow_id_antigo',
    workflow_start_id as 'workflow_start_novo',
    webhook_url as 'webhook_url_antigo',
    webhook_start_url as 'webhook_start_novo'
FROM agentes_config 
ORDER BY id;

-- 2. Verificar se todos os dados foram migrados corretamente
SELECT 
    COUNT(*) as total_agentes,
    COUNT(workflow_id) as com_workflow_id_antigo,
    COUNT(workflow_start_id) as com_workflow_start_novo,
    COUNT(webhook_url) as com_webhook_url_antigo,
    COUNT(webhook_start_url) as com_webhook_start_novo
FROM agentes_config;

-- 3. Remover coluna workflow_id
ALTER TABLE agentes_config DROP COLUMN workflow_id;

-- 4. Remover coluna webhook_url
ALTER TABLE agentes_config DROP COLUMN webhook_url;

-- 5. Verificar estrutura final da tabela
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'agentes_config' 
ORDER BY ordinal_position;

-- 6. Verificar dados finais
SELECT 
    id,
    nome,
    workflow_start_id,
    webhook_start_url,
    descricao,
    ativo
FROM agentes_config 
ORDER BY id;
