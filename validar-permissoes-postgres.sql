-- ✅ VALIDAR PERMISSÕES DE ACESSO NO POSTGRESQL
-- Script para verificar se as permissões estão sendo criadas corretamente

-- 1. Verificar se a coluna permissoes_acesso existe
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'lead' 
  AND table_schema = 'public'
  AND column_name = 'permissoes_acesso';

-- 2. Verificar leads reservados recentemente (últimos 10 minutos)
SELECT 
  id,
  agente_id,
  reservado_por,
  reservado_em,
  reservado_lote,
  permissoes_acesso
FROM public.lead 
WHERE reservado_em >= NOW() - INTERVAL '10 minutes'
  AND agente_id IS NOT NULL
ORDER BY reservado_em DESC
LIMIT 5;

-- 3. Verificar estrutura do JSONB permissoes_acesso
SELECT 
  id,
  agente_id,
  reservado_por,
  permissoes_acesso,
  -- Extrair campos específicos do JSONB
  permissoes_acesso->>'agente_id' as agente_id_json,
  permissoes_acesso->>'reservado_por' as reservado_por_json,
  permissoes_acesso->>'reservado_em' as reservado_em_json,
  permissoes_acesso->'perfis_permitidos' as perfis_permitidos,
  permissoes_acesso->'usuarios_permitidos' as usuarios_permitidos,
  permissoes_acesso->'permissoes_especiais' as permissoes_especiais
FROM public.lead 
WHERE reservado_em >= NOW() - INTERVAL '10 minutes'
  AND agente_id IS NOT NULL
  AND permissoes_acesso IS NOT NULL
  AND permissoes_acesso != '{}'::jsonb
ORDER BY reservado_em DESC
LIMIT 3;

-- 4. Verificar leads do agente 81 especificamente
SELECT 
  id,
  agente_id,
  reservado_por,
  reservado_em,
  permissoes_acesso,
  -- Verificar se as permissões estão corretas
  CASE 
    WHEN permissoes_acesso->>'agente_id' = '81' THEN '✅ Agente ID correto'
    ELSE '❌ Agente ID incorreto'
  END as validacao_agente_id,
  CASE 
    WHEN permissoes_acesso->'usuarios_permitidos' @> '[6]'::jsonb THEN '✅ Usuário 6 permitido'
    ELSE '❌ Usuário 6 não permitido'
  END as validacao_usuario_6,
  CASE 
    WHEN permissoes_acesso->'perfis_permitidos' @> '[3]'::jsonb THEN '✅ Perfil 3 permitido'
    ELSE '❌ Perfil 3 não permitido'
  END as validacao_perfil_3
FROM public.lead 
WHERE agente_id = 81
  AND reservado_em >= NOW() - INTERVAL '10 minutes'
ORDER BY reservado_em DESC
LIMIT 3;

-- 5. Contar leads com permissões válidas
SELECT 
  COUNT(*) as total_leads,
  COUNT(CASE WHEN permissoes_acesso IS NOT NULL AND permissoes_acesso != '{}'::jsonb THEN 1 END) as leads_com_permissoes,
  COUNT(CASE WHEN permissoes_acesso->>'agente_id' IS NOT NULL THEN 1 END) as leads_com_agente_id,
  COUNT(CASE WHEN permissoes_acesso->'usuarios_permitidos' IS NOT NULL THEN 1 END) as leads_com_usuarios_permitidos,
  COUNT(CASE WHEN permissoes_acesso->'perfis_permitidos' IS NOT NULL THEN 1 END) as leads_com_perfis_permitidos
FROM public.lead 
WHERE reservado_em >= NOW() - INTERVAL '10 minutes'
  AND agente_id IS NOT NULL;

-- 6. Verificar exemplo de permissões completas
SELECT 
  id,
  agente_id,
  permissoes_acesso,
  -- Validar estrutura completa
  jsonb_pretty(permissoes_acesso) as permissoes_formatadas
FROM public.lead 
WHERE permissoes_acesso IS NOT NULL
  AND permissoes_acesso != '{}'::jsonb
  AND permissoes_acesso ? 'agente_id'
  AND permissoes_acesso ? 'usuarios_permitidos'
  AND permissoes_acesso ? 'perfis_permitidos'
ORDER BY reservado_em DESC
LIMIT 1;
