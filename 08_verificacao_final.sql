-- =====================================================
-- PARTE 8: VERIFICAÇÃO FINAL
-- =====================================================

-- Resumo completo
SELECT 'VERIFICAÇÃO FINAL - TODAS AS PERMISSÕES:' as info;
SELECT COUNT(*) as total_permissoes FROM permissoes;

-- Lista completa ordenada por ID
SELECT 'Lista completa de permissões:' as info;
SELECT id, nome_permissao, descricao FROM permissoes ORDER BY id;

-- Resumo por categoria
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

-- Verificar se todas as permissões esperadas foram criadas
SELECT 'Verificação de permissões críticas:' as info;
SELECT 
  CASE WHEN EXISTS(SELECT 1 FROM permissoes WHERE nome_permissao = 'nav_dashboard') THEN '✅' ELSE '❌' END as nav_dashboard,
  CASE WHEN EXISTS(SELECT 1 FROM permissoes WHERE nome_permissao = 'nav_upload') THEN '✅' ELSE '❌' END as nav_upload,
  CASE WHEN EXISTS(SELECT 1 FROM permissoes WHERE nome_permissao = 'upload_view') THEN '✅' ELSE '❌' END as upload_view,
  CASE WHEN EXISTS(SELECT 1 FROM permissoes WHERE nome_permissao = 'agente_start') THEN '✅' ELSE '❌' END as agente_start,
  CASE WHEN EXISTS(SELECT 1 FROM permissoes WHERE nome_permissao = 'agente_stop') THEN '✅' ELSE '❌' END as agente_stop;

SELECT 'Script de permissões concluído com sucesso!' as status;
