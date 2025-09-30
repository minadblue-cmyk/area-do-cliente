-- =====================================================
-- PARTE 5: PERMISSÕES DE USUÁRIOS
-- =====================================================

-- Adicionar permissões de usuários
INSERT INTO permissoes (nome_permissao, descricao) VALUES
('usuario_view', 'Visualizar usuários'),
('usuario_create', 'Criar usuários'),
('usuario_update', 'Editar usuários'),
('usuario_delete', 'Deletar usuários'),
('usuario_view_all', 'Visualizar todos os usuários'),
('usuario_manage', 'Gerenciar usuários'),
('usuario_admin', 'Administrar usuários de outros usuários');

-- Verificar resultado
SELECT 'Permissões de usuários adicionadas:' as info;
SELECT id, nome_permissao, descricao FROM permissoes WHERE nome_permissao LIKE 'usuario_%' ORDER BY id;

SELECT 'Total de permissões após parte 5:' as info;
SELECT COUNT(*) as total_permissoes FROM permissoes;
