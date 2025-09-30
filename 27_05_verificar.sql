-- Script 5: Verificar se a tabela foi criada corretamente
-- Execute este script para confirmar que tudo está funcionando

-- Verificar estrutura da tabela
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'agentes_config' 
ORDER BY ordinal_position;

-- Contar registros
SELECT COUNT(*) as total_agentes FROM agentes_config;

-- Listar agentes criados
SELECT 
    id,
    nome,
    workflow_id,
    webhook_url,
    descricao,
    icone,
    cor,
    ativo
FROM agentes_config 
ORDER BY nome;
