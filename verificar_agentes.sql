-- Verificar se a tabela existe e tem dados
SELECT * FROM agentes_config;

-- Verificar estrutura da tabela
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'agentes_config';
