-- =====================================================
-- PARTE 2: PERMISSÕES DE DASHBOARD
-- =====================================================

-- Adicionar permissões de dashboard
INSERT INTO permissoes (nome_permissao, descricao) VALUES
('dashboard_view', 'Visualizar dashboard'),
('dashboard_view_all', 'Visualizar dashboard completo'),
('dashboard_export', 'Exportar dados do dashboard'),
('dashboard_config', 'Configurar widgets do dashboard'),
('dashboard_admin', 'Administrar dashboard de outros usuários');

-- Verificar resultado
SELECT 'Permissões de dashboard adicionadas:' as info;
SELECT id, nome_permissao, descricao FROM permissoes WHERE nome_permissao LIKE 'dashboard_%' ORDER BY id;

SELECT 'Total de permissões após parte 2:' as info;
SELECT COUNT(*) as total_permissoes FROM permissoes;
