-- Script para atualizar apenas o agente Elleven Agente1
-- Execute este script para manter apenas um agente configurado

-- Limpar tabela se necessário
DELETE FROM agentes_config;

-- Inserir apenas o agente Elleven Agente1
INSERT INTO agentes_config (nome, workflow_id, webhook_url, descricao, icone, cor, ativo) VALUES
('Elleven Agente1', 'eBcColwirndBaFZX', 'webhook/agente1', 'Agente para prospecção de leads.', '🔥', 'bg-red-500', true);

-- Verificar resultado
SELECT 
    'Agente configurado' as status,
    COUNT(*) as total
FROM agentes_config;

-- Listar agente configurado
SELECT 
    id,
    nome,
    workflow_id,
    webhook_url,
    descricao,
    icone,
    cor,
    ativo
FROM agentes_config 
ORDER BY nome;
