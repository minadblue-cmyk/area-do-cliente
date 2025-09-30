-- =====================================================
-- CRIAÇÃO DE PERFIS PADRÃO ADICIONAIS
-- =====================================================

-- =====================================================
-- 1. PERFIL "USUÁRIO BÁSICO"
-- =====================================================
INSERT INTO perfis (nome_perfil, descricao, permissoes) VALUES
('Usuario Basico', 'Usuário com acesso básico ao sistema', ARRAY[
  -- Navegação básica
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_dashboard'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_upload'),
  
  -- Dashboard básico
  (SELECT id FROM permissoes WHERE nome_permissao = 'dashboard_view'),
  
  -- Upload básico
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_create'),
  
  -- Agente básico
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_view')
]);

-- =====================================================
-- 2. PERFIL "USUÁRIO AVANÇADO"
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
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_pause'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_resume'),
  
  -- Saudações
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_create'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_update'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_select')
]);

-- =====================================================
-- 3. PERFIL "SUPERVISOR"
-- =====================================================
INSERT INTO perfis (nome_perfil, descricao, permissoes) VALUES
('Supervisor', 'Supervisor com acesso para gerenciar equipe', ARRAY[
  -- Navegação
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_dashboard'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_upload'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_saudacao'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_usuarios'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'nav_agente'),
  
  -- Dashboard completo
  (SELECT id FROM permissoes WHERE nome_permissao = 'dashboard_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'dashboard_view_all'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'dashboard_export'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'dashboard_config'),
  
  -- Upload completo
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_create'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_manage'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_delete'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_process'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'upload_export'),
  
  -- Agente completo
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_start'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_stop'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_pause'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_resume'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'agente_config'),
  
  -- Saudações completo
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_create'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_update'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_delete'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'saudacao_select'),
  
  -- Usuários (limitado)
  (SELECT id FROM permissoes WHERE nome_permissao = 'usuario_view'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'usuario_create'),
  (SELECT id FROM permissoes WHERE nome_permissao = 'usuario_update')
]);

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================
SELECT 'Todos os perfis após criação:' as info;
SELECT 
  id, 
  nome_perfil, 
  descricao, 
  array_length(permissoes, 1) as total_permissoes
FROM perfis 
ORDER BY id;

-- Resumo por perfil
SELECT 'Resumo de permissões por perfil:' as info;
SELECT 
  nome_perfil,
  array_length(permissoes, 1) as total_permissoes,
  CASE 
    WHEN array_length(permissoes, 1) <= 10 THEN 'Básico'
    WHEN array_length(permissoes, 1) <= 25 THEN 'Intermediário'
    WHEN array_length(permissoes, 1) <= 50 THEN 'Avançado'
    ELSE 'Completo'
  END as nivel_acesso
FROM perfis 
ORDER BY array_length(permissoes, 1) DESC;

SELECT 'Criação de perfis padrão concluída!' as status;
