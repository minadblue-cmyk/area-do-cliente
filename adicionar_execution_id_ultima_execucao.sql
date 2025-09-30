-- Adicionar coluna execution_id_da_ultima_execucao na tabela agente_execucoes
-- Esta coluna vai armazenar o execution_id da última execução ativa do agente

-- 1. Adicionar a nova coluna
ALTER TABLE agente_execucoes 
ADD COLUMN execution_id_da_ultima_execucao VARCHAR(50);

-- 2. Adicionar comentário para documentar a coluna
COMMENT ON COLUMN agente_execucoes.execution_id_da_ultima_execucao IS 'Execution ID da última execução ativa do agente';

-- 3. Criar índice para melhor performance nas consultas
CREATE INDEX idx_agente_execucoes_execution_id_ultima 
ON agente_execucoes(execution_id_da_ultima_execucao);

-- 4. Atualizar registros existentes (opcional)
-- Se houver registros existentes, você pode querer popular esta coluna
-- UPDATE agente_execucoes 
-- SET execution_id_da_ultima_execucao = execution_id 
-- WHERE status = 'running' 
-- AND execution_id IS NOT NULL;

-- 5. Verificar a estrutura da tabela
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'agente_execucoes' 
ORDER BY ordinal_position;
