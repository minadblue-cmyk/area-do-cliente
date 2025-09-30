-- =====================================================
-- SCRIPT DE CRIAÇÃO DE PERFIS PADRÃO
-- Sistema de Gerenciamento de Perfis e Permissões
-- =====================================================

-- =====================================================
-- 1. PERFIL USUÁRIO BÁSICO
-- =====================================================
INSERT INTO perfis (nome_perfil, descricao, permissoes) VALUES
('Usuario Basico', 'Usuário com acesso básico ao sistema', ARRAY[
  -- Navegação
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_dashboard'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_upload'),
  
  -- Dashboard
  (SELECT id FROM permissoes WHERE nome_permissao = 'dashboard_view'),
  
  -- Upload
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_create'),
  
  -- Agente
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_view')
]);

-- =====================================================
-- 2. PERFIL USUÁRIO AVANÇADO
-- =====================================================
INSERT INTO perfis (nome_perfil, descricao, permissoes) VALUES
('Usuario Avancado', 'Usuário com acesso avançado ao sistema', ARRAY[
  -- Navegação
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_dashboard'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_upload'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_saudacao'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_agente'),
  
  -- Dashboard
  (SELECT id FROM permissoes WHERE nome_permissao = 'dashboard_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'dashboard_view_all'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'dashboard_export'),
  
  -- Upload
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_create'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_manage'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_export'),
  
  -- Agente
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_start'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_stop'),
  
  -- Saudações
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_create'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_update'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_select')
]);

-- =====================================================
-- 3. PERFIL GESTOR
-- =====================================================
INSERT INTO perfis (nome_perfil, descricao, permissoes) VALUES
('Gestor', 'Gestor com acesso para gerenciar usuários e empresas', ARRAY[
  -- Navegação (todas)
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_dashboard'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_upload'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_saudacao'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_usuarios'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_empresas'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_agente'),
  
  -- Dashboard (completo)
  (SELECT id FROM permissoes WHERE nome_permissao = 'dashboard_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'dashboard_view_all'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'dashboard_export'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'dashboard_config'),
  
  -- Upload (completo)
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_create'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_manage'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_delete'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_process'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_export'),
  
  -- Agente (completo)
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_start'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_stop'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_pause'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_resume'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_config'),
  
  -- Saudações (completo)
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_create'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_update'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_delete'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_select'),
  
  -- Usuários
  (SELECT id FROM permissoes WHERE nome_permissao = 'usuario_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'usuario_create'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'usuario_update'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'usuario_view_all'),
  
  -- Empresas
  (SELECT id FROM permissoes WHERE nome_permissao = 'empresa_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'empresa_create'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'empresa_update'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_empresas')
]);

-- =====================================================
-- 4. PERFIL ADMINISTRADOR
-- =====================================================
INSERT INTO perfis (nome_perfil, descricao, permissoes) VALUES
('Administrador', 'Administrador com acesso total ao sistema', ARRAY[
  -- TODAS as permissões
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_dashboard'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_upload'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_saudacao'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_usuarios'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_empresas'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_perfis'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_agente'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_config'),
  
  (SELECT id FROM permissoes WHERE nome_permissao = 'dashboard_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'dashboard_view_all'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'dashboard_export'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'dashboard_config'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'dashboard_admin'),
  
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_create'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_manage'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_delete'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_process'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_validate'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_export'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_config'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_logs'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_admin'),
  
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_execute'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_start'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_stop'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_pause'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_resume'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_config'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_logs'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_admin'),
  
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_create'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_update'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_delete'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_select'),
  
  (SELECT id FROM permissoes WHERE nome_permissao = 'empresa_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'empresa_create'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'empresa_update'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'empresa_delete'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_empresas'),
  
  (SELECT id FROM permissoes WHERE nome_permissao = 'perfil_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'perfil_create'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'perfil_update'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'perfil_delete'),
  
  (SELECT id FROM permissoes WHERE nome_permissao = 'usuario_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'usuario_create'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'usuario_update'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'usuario_delete'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'usuario_view_all'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'usuario_manage'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'usuario_admin'),
  
  (SELECT id FROM permissoes WHERE nome_permissao = 'config_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'config_edit'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'config_system'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'config_webhooks'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'config_backup'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'config_logs'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'config_admin'),
  
  (SELECT id FROM permissoes WHERE nome_permissao = 'webhook_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'webhook_create'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'webhook_edit'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'webhook_delete'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'webhook_test'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'webhook_logs')
]);

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================
SELECT 'Perfis criados:' as info;
SELECT id, nome_perfil, descricao, array_length(permissoes, 1) as total_permissoes 
FROM perfis 
ORDER BY id;

SELECT 'Script de criação de perfis concluído!' as status;
