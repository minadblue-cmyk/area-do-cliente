-- Script 3: Criar índices para melhor performance
-- Execute este script após criar a tabela

CREATE INDEX idx_agentes_config_nome ON agentes_config(nome);
CREATE INDEX idx_agentes_config_workflow_id ON agentes_config(workflow_id);
CREATE INDEX idx_agentes_config_ativo ON agentes_config(ativo);
