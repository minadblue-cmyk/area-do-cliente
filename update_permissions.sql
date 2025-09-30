-- =====================================================
-- SCRIPT DE ATUALIZAÇÃO DA TABELA PERMISSÕES
-- Sistema de Gerenciamento de Perfis e Permissões
-- =====================================================

-- Verificar se a tabela existe
SELECT 'Verificando estrutura da tabela permissoes...' as status;

-- Mostrar permissões atuais
SELECT 'Permissões atuais:' as info;
SELECT id, nome_permissao, descricao FROM permissoes ORDER BY id;

-- =====================================================
-- 1. NAVEGAÇÃO (Acesso às Abas)
-- =====================================================
INSERT INTO permissoes (nome_permissao, descricao) VALUES
('nav_dashboard', 'Acesso ao menu Dashboard'),
('nav_upload', 'Acesso ao menu Upload de Arquivos'),
('nav_saudacao', 'Acesso ao menu Saudações'),
('nav_usuarios', 'Acesso ao menu Usuários'),
('nav_empresas', 'Acesso ao menu Empresas'),
('nav_perfis', 'Acesso ao menu Perfis'),
('nav_agente', 'Acesso ao menu Agente'),
('nav_config', 'Acesso ao menu Configurações');

-- =====================================================
-- 2. DASHBOARD
-- =====================================================
INSERT INTO permissoes (nome_permissao, descricao) VALUES
('dashboard_view', 'Visualizar dashboard'),
('dashboard_view_all', 'Visualizar dashboard completo'),
('dashboard_export', 'Exportar dados do dashboard'),
('dashboard_config', 'Configurar widgets do dashboard'),
('dashboard_admin', 'Administrar dashboard de outros usuários');

-- =====================================================
-- 3. UPLOAD DE ARQUIVOS
-- =====================================================
INSERT INTO permissoes (nome_permissao, descricao) VALUES
('upload_view', 'Visualizar página de upload'),
('upload_create', 'Fazer upload de arquivos'),
('upload_manage', 'Gerenciar arquivos enviados'),
('upload_delete', 'Deletar arquivos enviados'),
('upload_process', 'Processar arquivos enviados'),
('upload_validate', 'Validar formato dos arquivos'),
('upload_export', 'Exportar dados processados'),
('upload_config', 'Configurar parâmetros de upload'),
('upload_logs', 'Visualizar logs de upload'),
('upload_admin', 'Administrar uploads de outros usuários');

-- =====================================================
-- 4. AGENTE DE PROSPECÇÃO
-- =====================================================
INSERT INTO permissoes (nome_permissao, descricao) VALUES
('agente_view', 'Visualizar status do agente'),
('agente_start', 'Iniciar agente'),
('agente_stop', 'Parar agente'),
('agente_pause', 'Pausar agente'),
('agente_resume', 'Retomar agente'),
('agente_config', 'Configurar parâmetros do agente'),
('agente_logs', 'Visualizar logs do agente'),
('agente_admin', 'Administrar agente de outros usuários');

-- =====================================================
-- 5. USUÁRIOS
-- =====================================================
INSERT INTO permissoes (nome_permissao, descricao) VALUES
('usuario_view', 'Visualizar usuários'),
('usuario_create', 'Criar usuários'),
('usuario_update', 'Editar usuários'),
('usuario_delete', 'Deletar usuários'),
('usuario_view_all', 'Visualizar todos os usuários'),
('usuario_manage', 'Gerenciar usuários'),
('usuario_admin', 'Administrar usuários de outros usuários');

-- =====================================================
-- 6. CONFIGURAÇÕES DO SISTEMA
-- =====================================================
INSERT INTO permissoes (nome_permissao, descricao) VALUES
('config_edit', 'Editar configurações'),
('config_system', 'Configurações do sistema'),
('config_webhooks', 'Configurar webhooks'),
('config_backup', 'Gerenciar backups'),
('config_logs', 'Visualizar logs do sistema'),
('config_admin', 'Administrar configurações de outros usuários');

-- =====================================================
-- 7. WEBHOOKS
-- =====================================================
INSERT INTO permissoes (nome_permissao, descricao) VALUES
('webhook_view', 'Visualizar webhooks'),
('webhook_create', 'Criar webhooks'),
('webhook_edit', 'Editar webhooks'),
('webhook_delete', 'Deletar webhooks'),
('webhook_test', 'Testar webhooks'),
('webhook_logs', 'Visualizar logs de webhooks');

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================
SELECT 'Permissões após atualização:' as info;
SELECT COUNT(*) as total_permissoes FROM permissoes;

SELECT 'Lista completa de permissões:' as info;
SELECT id, nome_permissao, descricao FROM permissoes ORDER BY id;

-- =====================================================
-- RESUMO POR CATEGORIA
-- =====================================================
SELECT 'Resumo por categoria:' as info;

SELECT 
  CASE 
    WHEN nome_permissao LIKE 'nav_%' THEN 'Navegação'
    WHEN nome_permissao LIKE 'dashboard_%' THEN 'Dashboard'
    WHEN nome_permissao LIKE 'upload_%' THEN 'Upload'
    WHEN nome_permissao LIKE 'agente_%' THEN 'Agente'
    WHEN nome_permissao LIKE 'saudacao_%' THEN 'Saudações'
    WHEN nome_permissao LIKE 'empresa_%' THEN 'Empresas'
    WHEN nome_permissao LIKE 'perfil_%' THEN 'Perfis'
    WHEN nome_permissao LIKE 'usuario_%' THEN 'Usuários'
    WHEN nome_permissao LIKE 'config_%' THEN 'Configurações'
    WHEN nome_permissao LIKE 'webhook_%' THEN 'Webhooks'
    ELSE 'Outros'
  END as categoria,
  COUNT(*) as quantidade
FROM permissoes 
GROUP BY categoria
ORDER BY categoria;

-- =====================================================
-- SCRIPT CONCLUÍDO
-- =====================================================
SELECT 'Script de atualização concluído com sucesso!' as status;
