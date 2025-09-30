-- =====================================================
-- PARTE 4: PERMISSÕES DE AGENTE
-- =====================================================

-- Adicionar permissões de agente
INSERT INTO permissoes (nome_permissao, descricao) VALUES
('agente_view', 'Visualizar status do agente'),
('agente_start', 'Iniciar agente'),
('agente_stop', 'Parar agente'),
('agente_pause', 'Pausar agente'),
('agente_resume', 'Retomar agente'),
('agente_config', 'Configurar parâmetros do agente'),
('agente_logs', 'Visualizar logs do agente'),
('agente_admin', 'Administrar agente de outros usuários');

-- Verificar resultado
SELECT 'Permissões de agente adicionadas:' as info;
SELECT id, nome_permissao, descricao FROM permissoes WHERE nome_permissao LIKE 'agente_%' ORDER BY id;

SELECT 'Total de permissões após parte 4:' as info;
SELECT COUNT(*) as total_permissoes FROM permissoes;
