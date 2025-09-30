-- =====================================================
-- SCRIPT DE ROLLBACK - REVERTER MUDANÇAS
-- Sistema de Gerenciamento de Perfis e Permissões
-- =====================================================

-- ATENÇÃO: Este script irá remover todas as permissões adicionadas
-- Execute apenas se precisar reverter as mudanças

-- =====================================================
-- 1. REMOVER PERFIS CRIADOS
-- =====================================================
DELETE FROM perfis WHERE nome_perfil IN (
  'Usuario Basico',
  'Usuario Avancado', 
  'Gestor',
  'Administrador'
);

-- =====================================================
-- 2. REMOVER PERMISSÕES ADICIONADAS
-- =====================================================

-- Navegação
DELETE FROM permissoes WHERE nome_permissao IN (
  'nav_dashboard', 'nav_upload', 'nav_saudacao', 'nav_usuarios',
  'nav_empresas', 'nav_perfis', 'nav_agente', 'nav_config'
);

-- Dashboard
DELETE FROM permissoes WHERE nome_permissao IN (
  'dashboard_view', 'dashboard_view_all', 'dashboard_export',
  'dashboard_config', 'dashboard_admin'
);

-- Upload
DELETE FROM permissoes WHERE nome_permissao IN (
  'upload_view', 'upload_create', 'upload_manage', 'upload_delete',
  'upload_process', 'upload_validate', 'upload_export', 'upload_config',
  'upload_logs', 'upload_admin'
);

-- Agente
DELETE FROM permissoes WHERE nome_permissao IN (
  'agente_view', 'agente_start', 'agente_stop', 'agente_pause',
  'agente_resume', 'agente_config', 'agente_logs', 'agente_admin'
);

-- Usuários
DELETE FROM permissoes WHERE nome_permissao IN (
  'usuario_view', 'usuario_create', 'usuario_update', 'usuario_delete',
  'usuario_view_all', 'usuario_manage', 'usuario_admin'
);

-- Configurações
DELETE FROM permissoes WHERE nome_permissao IN (
  'config_edit', 'config_system', 'config_webhooks', 'config_backup',
  'config_logs', 'config_admin'
);

-- Webhooks
DELETE FROM permissoes WHERE nome_permissao IN (
  'webhook_view', 'webhook_create', 'webhook_edit', 'webhook_delete',
  'webhook_test', 'webhook_logs'
);

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================
SELECT 'Permissões após rollback:' as info;
SELECT COUNT(*) as total_permissoes FROM permissoes;

SELECT 'Perfis após rollback:' as info;
SELECT COUNT(*) as total_perfis FROM perfis;

SELECT 'Rollback concluído!' as status;
