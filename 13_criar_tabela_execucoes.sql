-- Script para criar tabela de execuções do agente
-- Este script deve ser executado no PostgreSQL

-- Criar tabela para armazenar execuções do agente
CREATE TABLE IF NOT EXISTS agente_execucoes (
    id SERIAL PRIMARY KEY,
    execution_id VARCHAR(50) UNIQUE NOT NULL,
    workflow_id VARCHAR(50) NOT NULL,
    usuario_id INTEGER NOT NULL,
    usuario_nome VARCHAR(255),
    usuario_email VARCHAR(255),
    status VARCHAR(20) DEFAULT 'running' CHECK (status IN ('running', 'stopped', 'completed', 'error')),
    iniciado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    parado_em TIMESTAMP NULL,
    payload_inicial JSONB,
    payload_parada JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_agente_execucoes_execution_id ON agente_execucoes(execution_id);
CREATE INDEX IF NOT EXISTS idx_agente_execucoes_usuario_id ON agente_execucoes(usuario_id);
CREATE INDEX IF NOT EXISTS idx_agente_execucoes_status ON agente_execucoes(status);
CREATE INDEX IF NOT EXISTS idx_agente_execucoes_iniciado_em ON agente_execucoes(iniciado_em);

-- Comentários para documentação
COMMENT ON TABLE agente_execucoes IS 'Tabela para controlar execuções do agente de prospecção';
COMMENT ON COLUMN agente_execucoes.execution_id IS 'ID único da execução no n8n';
COMMENT ON COLUMN agente_execucoes.workflow_id IS 'ID do workflow no n8n';
COMMENT ON COLUMN agente_execucoes.usuario_id IS 'ID do usuário que iniciou a execução';
COMMENT ON COLUMN agente_execucoes.status IS 'Status atual da execução: running, stopped, completed, error';
COMMENT ON COLUMN agente_execucoes.payload_inicial IS 'Payload enviado ao iniciar o agente';
COMMENT ON COLUMN agente_execucoes.payload_parada IS 'Payload enviado ao parar o agente';

-- Trigger para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_agente_execucoes_updated_at 
    BEFORE UPDATE ON agente_execucoes 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Inserir dados de exemplo (opcional)
-- INSERT INTO agente_execucoes (execution_id, workflow_id, usuario_id, usuario_nome, usuario_email, payload_inicial) 
-- VALUES ('44106', 'eBcColwirndBaFZX', 5, 'Administrator Code-IQ', 'admin@code-iq.com.br', '{"action": "start", "timestamp": "2025-01-11T12:56:52.219Z"}');

-- Verificar se a tabela foi criada corretamente
SELECT 
    table_name, 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'agente_execucoes' 
ORDER BY ordinal_position;
