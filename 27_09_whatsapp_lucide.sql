-- Script 9: Inserir agente WhatsApp com ícone Lucide React
-- Execute este script se quiser usar ícone da biblioteca Lucide

INSERT INTO agentes_config (nome, workflow_id, webhook_url, descricao, icone, cor) VALUES
('whatsapp', 'whatsapp', 'webhook/agente-whatsapp', 'Agente para comunicação via WhatsApp', 'MessageSquare', 'bg-green-600')
ON CONFLICT (nome) DO NOTHING;
