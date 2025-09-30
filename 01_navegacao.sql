-- =====================================================
-- PARTE 1: PERMISSÕES DE NAVEGAÇÃO
-- =====================================================

-- Verificar permissões atuais
SELECT 'Permissões atuais:' as info;
SELECT COUNT(*) as total_permissoes FROM permissoes;

-- Adicionar permissões de navegação
INSERT INTO permissoes (nome_permissao, descricao) VALUES
('nav_dashboard', 'Acesso ao menu Dashboard'),
('nav_upload', 'Acesso ao menu Upload de Arquivos'),
('nav_saudacao', 'Acesso ao menu Saudações'),
('nav_usuarios', 'Acesso ao menu Usuários'),
('nav_empresas', 'Acesso ao menu Empresas'),
('nav_perfis', 'Acesso ao menu Perfis'),
('nav_agente', 'Acesso ao menu Agente'),
('nav_config', 'Acesso ao menu Configurações');

-- Verificar resultado
SELECT 'Permissões de navegação adicionadas:' as info;
SELECT id, nome_permissao, descricao FROM permissoes WHERE nome_permissao LIKE 'nav_%' ORDER BY id;

SELECT 'Total de permissões após parte 1:' as info;
SELECT COUNT(*) as total_permissoes FROM permissoes;
