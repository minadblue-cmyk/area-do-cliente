-- SCRIPT SEGURO PARA REMOVER COLUNAS ANTIGAS
-- Execute passo a passo para maior segurança

-- PASSO 1: Verificar dados antes da remoção
SELECT 
    'ANTES DA REMOÇÃO' as status,
    id,
    nome,
    workflow_id as 'workflow_id_antigo',
    workflow_start_id as 'workflow_start_novo',
    webhook_url as 'webhook_url_antigo',
    webhook_start_url as 'webhook_start_novo'
FROM agentes_config 
ORDER BY id;

-- PASSO 2: Verificar se todos os dados foram migrados
SELECT 
    'VERIFICAÇÃO DE MIGRAÇÃO' as status,
    COUNT(*) as total_agentes,
    COUNT(workflow_id) as com_workflow_id_antigo,
    COUNT(workflow_start_id) as com_workflow_start_novo,
    COUNT(webhook_url) as com_webhook_url_antigo,
    COUNT(webhook_start_url) as com_webhook_start_novo
FROM agentes_config;

-- PASSO 3: Remover coluna workflow_id (execute apenas se a verificação estiver OK)
-- ALTER TABLE agentes_config DROP COLUMN workflow_id;

-- PASSO 4: Remover coluna webhook_url (execute apenas se a verificação estiver OK)
-- ALTER TABLE agentes_config DROP COLUMN webhook_url;

-- PASSO 5: Verificar estrutura final (execute após remover as colunas)
-- SELECT column_name, data_type, is_nullable
-- FROM information_schema.columns 
-- WHERE table_name = 'agentes_config' 
-- ORDER BY ordinal_position;

-- PASSO 6: Verificar dados finais (execute após remover as colunas)
-- SELECT 
--     id,
--     nome,
--     workflow_start_id,
--     webhook_start_url,
--     descricao,
--     ativo
-- FROM agentes_config 
-- ORDER BY id;
