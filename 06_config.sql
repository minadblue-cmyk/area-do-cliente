-- =====================================================
-- PARTE 6: PERMISSÕES DE CONFIGURAÇÕES
-- =====================================================

-- Adicionar permissões de configurações
INSERT INTO permissoes (nome_permissao, descricao) VALUES
('config_edit', 'Editar configurações'),
('config_system', 'Configurações do sistema'),
('config_webhooks', 'Configurar webhooks'),
('config_backup', 'Gerenciar backups'),
('config_logs', 'Visualizar logs do sistema'),
('config_admin', 'Administrar configurações de outros usuários');

-- Verificar resultado
SELECT 'Permissões de configurações adicionadas:' as info;
SELECT id, nome_permissao, descricao FROM permissoes WHERE nome_permissao LIKE 'config_%' ORDER BY id;

SELECT 'Total de permissões após parte 6:' as info;
SELECT COUNT(*) as total_permissoes FROM permissoes;
