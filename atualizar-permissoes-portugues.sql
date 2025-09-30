-- ✅ ATUALIZAR PERMISSÕES PARA PORTUGUÊS
-- Script para atualizar todos os nomes das permissões para português

-- DASHBOARD (73-77)
UPDATE permissoes SET nome_permissao = 'visualizar_dashboard' WHERE id = 73;
UPDATE permissoes SET nome_permissao = 'visualizar_dashboard_completo' WHERE id = 74;
UPDATE permissoes SET nome_permissao = 'exportar_dashboard' WHERE id = 75;
UPDATE permissoes SET nome_permissao = 'configurar_dashboard' WHERE id = 76;
UPDATE permissoes SET nome_permissao = 'administrar_dashboard' WHERE id = 77;

-- UPLOAD (78-87)
UPDATE permissoes SET nome_permissao = 'visualizar_upload' WHERE id = 78;
UPDATE permissoes SET nome_permissao = 'fazer_upload' WHERE id = 79;
UPDATE permissoes SET nome_permissao = 'gerenciar_upload' WHERE id = 80;
UPDATE permissoes SET nome_permissao = 'deletar_upload' WHERE id = 81;
UPDATE permissoes SET nome_permissao = 'processar_upload' WHERE id = 82;
UPDATE permissoes SET nome_permissao = 'validar_upload' WHERE id = 83;
UPDATE permissoes SET nome_permissao = 'exportar_upload' WHERE id = 84;
UPDATE permissoes SET nome_permissao = 'configurar_upload' WHERE id = 85;
UPDATE permissoes SET nome_permissao = 'visualizar_logs_upload' WHERE id = 86;
UPDATE permissoes SET nome_permissao = 'administrar_upload' WHERE id = 87;

-- AGENTE (88-95)
UPDATE permissoes SET nome_permissao = 'visualizar_agente' WHERE id = 88;
UPDATE permissoes SET nome_permissao = 'iniciar_agente' WHERE id = 89;
UPDATE permissoes SET nome_permissao = 'parar_agente' WHERE id = 90;
UPDATE permissoes SET nome_permissao = 'pausar_agente' WHERE id = 91;
UPDATE permissoes SET nome_permissao = 'retomar_agente' WHERE id = 92;
UPDATE permissoes SET nome_permissao = 'configurar_agente' WHERE id = 93;
UPDATE permissoes SET nome_permissao = 'visualizar_logs_agente' WHERE id = 94;
UPDATE permissoes SET nome_permissao = 'administrar_agente' WHERE id = 95;

-- USUÁRIOS (96-102)
UPDATE permissoes SET nome_permissao = 'visualizar_usuarios' WHERE id = 96;
UPDATE permissoes SET nome_permissao = 'criar_usuarios' WHERE id = 97;
UPDATE permissoes SET nome_permissao = 'editar_usuarios' WHERE id = 98;
UPDATE permissoes SET nome_permissao = 'deletar_usuarios' WHERE id = 99;
UPDATE permissoes SET nome_permissao = 'visualizar_todos_usuarios' WHERE id = 100;
UPDATE permissoes SET nome_permissao = 'gerenciar_usuarios' WHERE id = 101;
UPDATE permissoes SET nome_permissao = 'administrar_usuarios' WHERE id = 102;

-- CONFIGURAÇÕES (103-108)
UPDATE permissoes SET nome_permissao = 'editar_configuracoes' WHERE id = 103;
UPDATE permissoes SET nome_permissao = 'configurar_sistema' WHERE id = 104;
UPDATE permissoes SET nome_permissao = 'configurar_webhooks' WHERE id = 105;
UPDATE permissoes SET nome_permissao = 'gerenciar_backups' WHERE id = 106;
UPDATE permissoes SET nome_permissao = 'visualizar_logs_sistema' WHERE id = 107;
UPDATE permissoes SET nome_permissao = 'administrar_configuracoes' WHERE id = 108;

-- WEBHOOKS (109-114)
UPDATE permissoes SET nome_permissao = 'visualizar_webhooks' WHERE id = 109;
UPDATE permissoes SET nome_permissao = 'criar_webhooks' WHERE id = 110;
UPDATE permissoes SET nome_permissao = 'editar_webhooks' WHERE id = 111;
UPDATE permissoes SET nome_permissao = 'deletar_webhooks' WHERE id = 112;
UPDATE permissoes SET nome_permissao = 'testar_webhooks' WHERE id = 113;
UPDATE permissoes SET nome_permissao = 'visualizar_logs_webhooks' WHERE id = 114;

-- PROSPECÇÃO (53-58)
UPDATE permissoes SET nome_permissao = 'executar_prospeccao' WHERE id = 53;
UPDATE permissoes SET nome_permissao = 'visualizar_saudacoes' WHERE id = 54;
UPDATE permissoes SET nome_permissao = 'editar_saudacao' WHERE id = 55;
UPDATE permissoes SET nome_permissao = 'deletar_saudacao' WHERE id = 56;
UPDATE permissoes SET nome_permissao = 'selecionar_saudacao' WHERE id = 57;

-- EMPRESAS (58-62)
UPDATE permissoes SET nome_permissao = 'visualizar_empresas' WHERE id = 58;
UPDATE permissoes SET nome_permissao = 'criar_empresas' WHERE id = 59;
UPDATE permissoes SET nome_permissao = 'editar_empresas' WHERE id = 60;
UPDATE permissoes SET nome_permissao = 'deletar_empresas' WHERE id = 61;
UPDATE permissoes SET nome_permissao = 'acessar_empresas' WHERE id = 62;

-- PERFIS (63-67)
UPDATE permissoes SET nome_permissao = 'visualizar_perfis' WHERE id = 63;
UPDATE permissoes SET nome_permissao = 'criar_perfis' WHERE id = 64;
UPDATE permissoes SET nome_permissao = 'editar_perfis' WHERE id = 65;
UPDATE permissoes SET nome_permissao = 'deletar_perfis' WHERE id = 66;
UPDATE permissoes SET nome_permissao = 'visualizar_configuracoes' WHERE id = 67;

-- Verificar atualizações
SELECT 
  id, 
  nome_permissao, 
  descricao
FROM permissoes 
WHERE id IN (53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 142, 143)
ORDER BY id;
