-- Script para criar tabela de configuração de agentes
-- Este script deve ser executado no PostgreSQL

-- Criar tabela para configurar agentes dinamicamente
CREATE TABLE IF NOT EXISTS agentes_config (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    workflow_id VARCHAR(100) NOT NULL,
    webhook_url VARCHAR(255) NOT NULL,
    descricao TEXT,
    icone VARCHAR(10) DEFAULT '🤖',
    cor VARCHAR(20) DEFAULT 'bg-blue-500',
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_agentes_config_nome ON agentes_config(nome);
CREATE INDEX IF NOT EXISTS idx_agentes_config_workflow_id ON agentes_config(workflow_id);
CREATE INDEX IF NOT EXISTS idx_agentes_config_ativo ON agentes_config(ativo);

-- Inserir agentes existentes
INSERT INTO agentes_config (nome, workflow_id, webhook_url, descricao, icone, cor) VALUES
('prospeccao-quente', 'eBcColwirndBaFZX', 'webhook/agente1', 'Agente para prospecção de leads quentes', '🔥', 'bg-red-500'),
('prospeccao-fria', 'YiEudLRKWBBRzm3b', 'webhook/agente-fria', 'Agente para prospecção de leads frios', '❄️', 'bg-blue-500'),
('follow-up', 'follow-up', 'webhook/agente-followup', 'Agente para follow-up de clientes', '📞', 'bg-green-500'),
('suporte', 'suporte', 'webhook/agente-suporte', 'Agente para atendimento ao cliente', '🎧', 'bg-purple-500')
ON CONFLICT (nome) DO NOTHING;

-- Criar função para atualizar updated_at
CREATE OR REPLACE FUNCTION update_agentes_config_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger para updated_at
DROP TRIGGER IF EXISTS update_agentes_config_updated_at ON agentes_config;
CREATE TRIGGER update_agentes_config_updated_at
    BEFORE UPDATE ON agentes_config
    FOR EACH ROW
    EXECUTE FUNCTION update_agentes_config_updated_at();

-- Verificar dados inseridos
SELECT 
    'Agentes configurados' as info,
    COUNT(*) as total
FROM agentes_config;

-- Listar agentes configurados
SELECT 
    id,
    nome,
    workflow_id,
    webhook_url,
    descricao,
    icone,
    cor,
    ativo,
    created_at
FROM agentes_config 
ORDER BY nome;
