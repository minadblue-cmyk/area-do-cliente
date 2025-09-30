-- Script simplificado para criar tabela de agentes
-- Execute este script no PostgreSQL

-- 1. Criar tabela básica
CREATE TABLE agentes_config (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    workflow_id VARCHAR(100) NOT NULL,
    webhook_url VARCHAR(255) NOT NULL,
    descricao TEXT,
    icone VARCHAR(10) DEFAULT '🤖',
    cor VARCHAR(20) DEFAULT 'bg-blue-500',
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Inserir dados básicos
INSERT INTO agentes_config (nome, workflow_id, webhook_url, descricao, icone, cor) VALUES
('prospeccao-quente', 'eBcColwirndBaFZX', 'webhook/agente1', 'Agente para prospecção de leads quentes', '🔥', 'bg-red-500'),
('prospeccao-fria', 'YiEudLRKWBBRzm3b', 'webhook/agente-fria', 'Agente para prospecção de leads frios', '❄️', 'bg-blue-500'),
('follow-up', 'follow-up', 'webhook/agente-followup', 'Agente para follow-up de clientes', '📞', 'bg-green-500'),
('suporte', 'suporte', 'webhook/agente-suporte', 'Agente para atendimento ao cliente', '🎧', 'bg-purple-500');

-- 3. Verificar se foi criado
SELECT 'Tabela criada com sucesso!' as status;
SELECT COUNT(*) as total_agentes FROM agentes_config;
