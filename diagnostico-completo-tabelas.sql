-- =====================================================
-- DIAGNÓSTICO COMPLETO DAS TABELAS
-- =====================================================

-- 1. VERIFICAR ESTRUTURA DA TABELA LEAD
SELECT '1. ESTRUTURA DA TABELA LEAD' as teste;
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'lead' 
ORDER BY ordinal_position;

-- 2. VERIFICAR TODOS OS LEADS COM AGENTE_ID
SELECT '2. LEADS COM AGENTE_ID' as teste;
SELECT 
  id, client_id, agente_id, nome, telefone, status, 
  data_ultima_interacao, data_criacao
FROM lead 
WHERE agente_id IS NOT NULL
ORDER BY agente_id, id DESC
LIMIT 20;

-- 3. VERIFICAR AGENTE_USUARIO_ATRIBUICOES
SELECT '3. ATRIBUIÇÕES DE AGENTES' as teste;
SELECT 
  aua.id, aua.agente_id, aua.usuario_id, aua.atribuido_por,
  u.nome as usuario_nome, u.email as usuario_email
FROM agente_usuario_atribuicoes aua
LEFT JOIN usuarios u ON aua.usuario_id = u.id
ORDER BY aua.agente_id, aua.usuario_id;

-- 4. VERIFICAR USUÁRIOS E SEUS PERFIS
SELECT '4. USUÁRIOS E PERFIS' as teste;
SELECT 
  u.id, u.nome, u.email, u.perfil_id,
  p.descricao as perfil_nome
FROM usuarios u
LEFT JOIN perfis p ON u.perfil_id = p.id
ORDER BY u.id;

-- 5. VERIFICAR PERFIS E PERMISSÕES
SELECT '5. PERFIS E PERMISSÕES' as teste;
SELECT 
  p.id, p.descricao, p.permissoes
FROM perfis p
ORDER BY p.id;

-- 6. TESTAR QUERY EXATA DO N8N COM USUÁRIO 6
SELECT '6. QUERY N8N - USUÁRIO 6' as teste;
SELECT 
  l.id, l.client_id, l.nome, l.telefone, l.status, l.contatado,
  l.data_ultima_interacao, l.data_criacao, l.agente_id
FROM lead l
INNER JOIN agente_usuario_atribuicoes aua ON l.agente_id = aua.agente_id
WHERE aua.usuario_id = 6
  AND l.status IN ('prospectando', 'concluido')
  AND COALESCE(l.data_ultima_interacao, l.data_criacao) >= '2025-09-25 06:00:00'::timestamp
  AND COALESCE(l.data_ultima_interacao, l.data_criacao) < '2025-09-25 11:59:59'::timestamp
ORDER BY COALESCE(l.data_ultima_interacao, l.data_criacao) DESC, l.id DESC;

-- 7. TESTAR QUERY SEM FILTRO DE PERÍODO - USUÁRIO 6
SELECT '7. QUERY SEM PERÍODO - USUÁRIO 6' as teste;
SELECT 
  l.id, l.client_id, l.nome, l.telefone, l.status, l.contatado,
  l.data_ultima_interacao, l.data_criacao, l.agente_id
FROM lead l
INNER JOIN agente_usuario_atribuicoes aua ON l.agente_id = aua.agente_id
WHERE aua.usuario_id = 6
  AND l.status IN ('prospectando', 'concluido')
ORDER BY COALESCE(l.data_ultima_interacao, l.data_criacao) DESC, l.id DESC;

-- 8. VERIFICAR QUAIS AGENTES O USUÁRIO 6 PODE VER
SELECT '8. AGENTES DO USUÁRIO 6' as teste;
SELECT 
  aua.agente_id, 
  COUNT(l.id) as total_leads,
  COUNT(CASE WHEN l.status = 'prospectando' THEN 1 END) as leads_prospectando,
  COUNT(CASE WHEN l.status = 'concluido' THEN 1 END) as leads_concluido
FROM agente_usuario_atribuicoes aua
LEFT JOIN lead l ON aua.agente_id = l.agente_id
WHERE aua.usuario_id = 6
GROUP BY aua.agente_id
ORDER BY aua.agente_id;

-- 9. VERIFICAR LEADS RECENTES (ÚLTIMOS 7 DIAS)
SELECT '9. LEADS RECENTES (7 DIAS)' as teste;
SELECT 
  l.id, l.client_id, l.nome, l.telefone, l.status, l.contatado,
  l.data_ultima_interacao, l.data_criacao, l.agente_id
FROM lead l
WHERE COALESCE(l.data_ultima_interacao, l.data_criacao) >= NOW() - INTERVAL '7 days'
ORDER BY COALESCE(l.data_ultima_interacao, l.data_criacao) DESC, l.id DESC
LIMIT 20;

-- 10. VERIFICAR SE EXISTEM LEADS COM STATUS DIFERENTES
SELECT '10. TODOS OS STATUS DE LEADS' as teste;
SELECT 
  status,
  COUNT(*) as quantidade,
  MIN(COALESCE(data_ultima_interacao, data_criacao)) as data_mais_antiga,
  MAX(COALESCE(data_ultima_interacao, data_criacao)) as data_mais_recente
FROM lead 
GROUP BY status
ORDER BY quantidade DESC;
