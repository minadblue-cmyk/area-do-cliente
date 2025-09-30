-- Script corrigido para criar tabela de agentes
-- Este script trata possíveis erros e conflitos

-- 1. Remover tabela se existir (CUIDADO: apaga dados existentes!)
DROP TABLE IF EXISTS agentes_config CASCADE;

-- 2. Criar tabela do zero
CREATE TABLE agentes_config (
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

-- 3. Criar índices
CREATE INDEX idx_agentes_config_nome ON agentes_config(nome);
CREATE INDEX idx_agentes_config_workflow_id ON agentes_config(workflow_id);
CREATE INDEX idx_agentes_config_ativo ON agentes_config(ativo);

-- 4. Inserir dados iniciais
INSERT INTO agentes_config (nome, workflow_id, webhook_url, descricao, icone, cor) VALUES
('prospeccao-quente', 'eBcColwirndBaFZX', 'webhook/agente1', 'Agente para prospecção de leads quentes', '🔥', 'bg-red-500'),
('prospeccao-fria', 'YiEudLRKWBBRzm3b', 'webhook/agente-fria', 'Agente para prospecção de leads frios', '❄️', 'bg-blue-500'),
('follow-up', 'follow-up', 'webhook/agente-followup', 'Agente para follow-up de clientes', '📞', 'bg-green-500'),
('suporte', 'suporte', 'webhook/agente-suporte', 'Agente para atendimento ao cliente', '🎧', 'bg-purple-500');

-- 5. Verificar criação
SELECT 'SUCCESS: Tabela agentes_config criada com sucesso!' as resultado;
SELECT COUNT(*) as total_agentes FROM agentes_config;
SELECT nome, workflow_id, webhook_url FROM agentes_config ORDER BY nome;
