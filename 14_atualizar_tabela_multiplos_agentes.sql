-- Script para atualizar tabela de execuções para suportar múltiplos agentes
-- Este script deve ser executado no PostgreSQL

-- Adicionar colunas para suporte a múltiplos agentes
ALTER TABLE agente_execucoes 
ADD COLUMN IF NOT EXISTS agent_type VARCHAR(50) DEFAULT 'prospeccao-quente',
ADD COLUMN IF NOT EXISTS progress INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS message TEXT;

-- Adicionar comentários para melhor documentação
COMMENT ON COLUMN agente_execucoes.agent_type IS 'Tipo do agente (prospeccao-quente, prospeccao-fria, follow-up, suporte)';
COMMENT ON COLUMN agente_execucoes.progress IS 'Progresso da execução (0-100)';
COMMENT ON COLUMN agente_execucoes.message IS 'Mensagem de status atual do agente';

-- Criar índice para otimizar buscas por tipo de agente
CREATE INDEX IF NOT EXISTS idx_agente_execucoes_agent_type ON agente_execucoes (agent_type);

-- Criar índice composto para otimizar buscas por usuário e tipo de agente
CREATE INDEX IF NOT EXISTS idx_agente_execucoes_usuario_agent_type ON agente_execucoes (usuario_id, agent_type);

-- Atualizar registros existentes para ter agent_type padrão
UPDATE agente_execucoes 
SET agent_type = 'prospeccao-quente' 
WHERE agent_type IS NULL;

-- Verificar se a atualização foi bem-sucedida
SELECT 
    agent_type,
    COUNT(*) as total_execucoes,
    COUNT(CASE WHEN status = 'running' THEN 1 END) as executando,
    COUNT(CASE WHEN status = 'stopped' THEN 1 END) as paradas,
    COUNT(CASE WHEN status = 'completed' THEN 1 END) as concluidas,
    COUNT(CASE WHEN status = 'error' THEN 1 END) as com_erro
FROM agente_execucoes 
GROUP BY agent_type
ORDER BY agent_type;
