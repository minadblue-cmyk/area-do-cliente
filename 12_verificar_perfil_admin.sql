-- =====================================================
-- VERIFICAÇÃO DO PERFIL ADMINISTRADOR
-- =====================================================

-- Verificar se o perfil Administrador existe
SELECT 'Verificando perfil Administrador:' as info;
SELECT 
  id, 
  nome_perfil, 
  descricao, 
  array_length(permissoes, 1) as total_permissoes
FROM perfis 
WHERE nome_perfil = 'Administrador';

-- Se não existir, criar o perfil Administrador
INSERT INTO perfis (nome_perfil, descricao, permissoes)
SELECT 'Administrador', 'Acesso total ao sistema', ARRAY[
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
WHERE NOT EXISTS (SELECT 1 FROM perfis WHERE nome_perfil = 'Administrador');

-- Verificar perfil Administrador após criação/atualização
SELECT 'Perfil Administrador final:' as info;
SELECT 
  id, 
  nome_perfil, 
  descricao, 
  array_length(permissoes, 1) as total_permissoes
FROM perfis 
WHERE nome_perfil = 'Administrador';

-- Listar todas as permissões do perfil Administrador
SELECT 'Permissões do perfil Administrador:' as info;
SELECT 
  p.nome_permissao,
  p.descricao
FROM permissoes p
WHERE p.id = ANY(
  SELECT unnest(permissoes) 
  FROM perfis 
  WHERE nome_perfil = 'Administrador'
)
ORDER BY p.nome_permissao;

SELECT 'Verificação do perfil Administrador concluída!' as status;
