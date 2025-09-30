-- Script 1: Apenas criar a tabela agentes_config
-- Execute este script primeiro

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
