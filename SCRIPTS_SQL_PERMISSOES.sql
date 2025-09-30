-- =====================================================
-- SCRIPTS SQL PARA ATUALIZAR TABELA DE PERMISSÕES
-- =====================================================

-- ===== UPLOAD =====
UPDATE permissoes SET 
  nome_permissao = 'upload_view',
  descricao = 'Acessar a aba upload'
WHERE id = 4;

UPDATE permissoes SET 
  nome_permissao = 'upload_create',
  descricao = 'Fazer upload de arquivos'
WHERE id = 6;

UPDATE permissoes SET 
  nome_permissao = 'upload_manage',
  descricao = 'Gerenciar uploads da empresa'
WHERE id = 5;

-- ===== DASHBOARD =====
UPDATE permissoes SET 
  nome_permissao = 'dashboard_view_all',
  descricao = 'Acesso a todos os dados do dashboard'
WHERE id = 1;

UPDATE permissoes SET 
  nome_permissao = 'dashboard_view_company',
  descricao = 'Acesso apenas aos dados da própria empresa'
WHERE id = 2;

UPDATE permissoes SET 
  nome_permissao = 'dashboard_view_personal',
  descricao = 'Acesso apenas aos próprios dados'
WHERE id = 3;

-- ===== SAUDAÇÃO =====
UPDATE permissoes SET 
  nome_permissao = 'saudacao_create',
  descricao = 'Criação de saudação personalizada'
WHERE id = 7;

-- ===== WEBHOOKS =====
UPDATE permissoes SET 
  nome_permissao = 'config_update',
  descricao = 'Configurações gerais do sistema, aba webhooks'
WHERE id = 8;

UPDATE permissoes SET 
  nome_permissao = 'webhook_manage',
  descricao = 'Configurar webhooks da empresa'
WHERE id = 9;

UPDATE permissoes SET 
  nome_permissao = 'webhook_view_all',
  descricao = 'Visualizar webhooks de todas as empresas'
WHERE id = 10;

-- ===== USUÁRIOS =====
UPDATE permissoes SET 
  nome_permissao = 'usuario_view',
  descricao = 'Visualizar usuários'
WHERE id = 11;

UPDATE permissoes SET 
  nome_permissao = 'usuario_create',
  descricao = 'Criação de usuários do sistema'
WHERE id = 12;

UPDATE permissoes SET 
  nome_permissao = 'usuario_update',
  descricao = 'Edição de usuários do sistema'
WHERE id = 13;

UPDATE permissoes SET 
  nome_permissao = 'usuario_delete',
  descricao = 'Deleção de usuários do sistema'
WHERE id = 14;

UPDATE permissoes SET 
  nome_permissao = 'usuario_view_all',
  descricao = 'Visualizar usuários de todas as empresas'
WHERE id = 15;

UPDATE permissoes SET 
  nome_permissao = 'usuario_view_company',
  descricao = 'Visualizar apenas usuários da própria empresa'
WHERE id = 16;

-- ===== PERFIS =====
UPDATE permissoes SET 
  nome_permissao = 'perfil_manage',
  descricao = 'Gerenciar perfis e permissões'
WHERE id = 17;

-- =====================================================
-- PERMISSÕES ADICIONAIS NECESSÁRIAS
-- =====================================================

-- Agente de prospecção
INSERT INTO permissoes (nome_permissao, descricao) VALUES 
('agente_execute', 'Iniciar agente de prospecção');

-- Saudação (ações adicionais)
INSERT INTO permissoes (nome_permissao, descricao) VALUES 
('saudacao_view', 'Visualizar saudações'),
('saudacao_update', 'Editar saudação'),
('saudacao_delete', 'Deletar saudação'),
('saudacao_select', 'Selecionar saudação para agente');

-- Empresas
INSERT INTO permissoes (nome_permissao, descricao) VALUES 
('empresa_view', 'Visualizar empresas'),
('empresa_create', 'Criar empresas'),
('empresa_update', 'Editar empresas'),
('empresa_delete', 'Deletar empresas'),
('nav_empresas', 'Acesso ao gerenciamento de empresas');

-- Perfis (ações adicionais)
INSERT INTO permissoes (nome_permissao, descricao) VALUES 
('perfil_view', 'Visualizar perfis'),
('perfil_create', 'Criar perfis'),
('perfil_update', 'Editar perfis'),
('perfil_delete', 'Deletar perfis');

-- Configurações
INSERT INTO permissoes (nome_permissao, descricao) VALUES 
('config_view', 'Visualizar configurações');

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================

-- Verificar todas as permissões atualizadas
SELECT id, nome_permissao, descricao 
FROM permissoes 
ORDER BY id;

-- Contar total de permissões
SELECT COUNT(*) as total_permissoes FROM permissoes;
