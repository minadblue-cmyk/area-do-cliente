-- Script 10: Inserir apenas os dois agentes com workflow_id reais
-- Execute este script para configurar apenas os agentes funcionais

INSERT INTO agentes_config (nome, workflow_id, webhook_url, descricao, icone, cor) VALUES
('Elleven Agente1', 'eBcColwirndBaFZX', 'webhook/agente1', 'Agente para prospecção de leads.', '🔥', 'bg-red-500'),
('Elleven Agente 2', 'YiEudLRKWBBRzm3b', 'webhook/agente-fria', 'Agente para prospecção de leads.', '❄️', 'bg-blue-500')
ON CONFLICT (nome) DO NOTHING;
