-- =====================================================
-- ATUALIZAÇÃO DOS PERFIS EXISTENTES
-- =====================================================

-- Verificar perfis atuais
SELECT 'Perfis atuais:' as info;
SELECT id, nome_perfil, descricao, array_length(permissoes, 1) as total_permissoes FROM perfis ORDER BY id;

-- =====================================================
-- 1. ATUALIZAR "Somente Visualização" (ID: 24)
-- =====================================================
UPDATE perfis 
SET permissoes = ARRAY[
  -- Navegação básica
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_dashboard'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_upload'),
  
  -- Visualização apenas
  (SELECT id FROM permissoes WHERE nome_permissao = 'dashboard_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_view'),
  
  -- Saudações (apenas visualizar)
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_view'),
  
  -- Empresas (apenas visualizar)
  (SELECT id FROM permissoes WHERE nome_permissao = 'empresa_view')
]
WHERE id = 24;

-- =====================================================
-- 2. ATUALIZAR "Dashboard Completo" (ID: 25)
-- =====================================================
UPDATE perfis 
SET permissoes = ARRAY[
  -- Navegação
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_dashboard'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_saudacao'),
  
  -- Dashboard completo
  (SELECT id FROM permissoes WHERE nome_permissao = 'dashboard_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'dashboard_view_all'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'dashboard_export'),
  
  -- Saudações
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_create'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_update'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_select')
]
WHERE id = 25;

-- =====================================================
-- 3. ATUALIZAR "Upload e Agentes" (ID: 26)
-- =====================================================
UPDATE perfis 
SET permissoes = ARRAY[
  -- Navegação
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_upload'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_agente'),
  
  -- Upload
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_create'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_manage'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_process'),
  
  -- Agente
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_execute'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_start'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_stop')
]
WHERE id = 26;

-- =====================================================
-- 4. ATUALIZAR "Gestor de Empresas" (ID: 27)
-- =====================================================
UPDATE perfis 
SET permissoes = ARRAY[
  -- Navegação
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_dashboard'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_upload'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_usuarios'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_empresas'),
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
  
  -- Usuários
  (SELECT id FROM permissoes WHERE nome_permissao = 'usuario_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'usuario_create'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'usuario_update'),
  
  -- Empresas (completo)
  (SELECT id FROM permissoes WHERE nome_permissao = 'empresa_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'empresa_create'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'empresa_update'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'empresa_delete'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_empresas'),
  
  -- Agente
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_start'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_stop'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_config')
]
WHERE id = 27;

-- =====================================================
-- 5. ATUALIZAR "Administrador" (ID: 28)
-- =====================================================
UPDATE perfis 
SET permissoes = ARRAY[
  -- TODAS as permissões de navegação
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_dashboard'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_upload'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_saudacao'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_usuarios'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_empresas'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_perfis'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_agente'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_config'),
  
  -- TODAS as permissões de dashboard
  (SELECT id FROM permissoes WHERE nome_permissao = 'dashboard_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'dashboard_view_all'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'dashboard_export'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'dashboard_config'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'dashboard_admin'),
  
  -- TODAS as permissões de upload
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
  
  -- TODAS as permissões de agente
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_execute'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_start'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_stop'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_pause'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_resume'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_config'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_logs'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_admin'),
  
  -- TODAS as permissões de saudações
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_create'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_update'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_delete'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_select'),
  
  -- TODAS as permissões de empresas
  (SELECT id FROM permissoes WHERE nome_permissao = 'empresa_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'empresa_create'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'empresa_update'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'empresa_delete'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_empresas'),
  
  -- TODAS as permissões de perfis
  (SELECT id FROM permissoes WHERE nome_permissao = 'perfil_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'perfil_create'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'perfil_update'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'perfil_delete'),
  
  -- TODAS as permissões de usuários
  (SELECT id FROM permissoes WHERE nome_permissao = 'usuario_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'usuario_create'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'usuario_update'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'usuario_delete'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'usuario_view_all'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'usuario_manage'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'usuario_admin'),
  
  -- TODAS as permissões de configurações
  (SELECT id FROM permissoes WHERE nome_permissao = 'config_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'config_edit'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'config_system'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'config_webhooks'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'config_backup'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'config_logs'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'config_admin'),
  
  -- TODAS as permissões de webhooks
  (SELECT id FROM permissoes WHERE nome_permissao = 'webhook_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'webhook_create'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'webhook_edit'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'webhook_delete'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'webhook_test'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'webhook_logs')
]
WHERE id = 28;

-- =====================================================
-- 6. ATUALIZAR "User Elleve Consorsios 1" (ID: 32)
-- =====================================================
UPDATE perfis 
SET permissoes = ARRAY[
  -- Navegação básica
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_upload'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_agente'),
  
  -- Upload básico
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_create'),
  
  -- Agente básico
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_start'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_stop')
]
WHERE id = 32;

-- =====================================================
-- VERIFICAÇÃO FINAL DOS PERFIS
-- =====================================================
SELECT 'Perfis após atualização:' as info;
SELECT 
  id, 
  nome_perfil, 
  descricao, 
  array_length(permissoes, 1) as total_permissoes,
  permissoes
FROM perfis 
ORDER BY id;

SELECT 'Atualização de perfis concluída!' as status;
