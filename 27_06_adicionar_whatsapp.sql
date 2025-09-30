-- Script 6: Adicionar agente WhatsApp à tabela existente
-- Execute este script se a tabela já existir e você quiser apenas adicionar o WhatsApp

INSERT INTO agentes_config (nome, workflow_id, webhook_url, descricao, icone, cor) VALUES
('whatsapp', 'whatsapp', 'webhook/agente-whatsapp', 'Agente para comunicação via WhatsApp', '💬', 'bg-green-600')
ON CONFLICT (nome) DO NOTHING;
