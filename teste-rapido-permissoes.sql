-- =====================================================
-- TESTE RÁPIDO DE PERMISSÕES
-- =====================================================

-- 1. VERIFICAR SE USUÁRIO 6 TEM PERMISSÕES
SELECT '1. PERMISSÕES DO USUÁRIO 6' as teste;
SELECT 
  aua.agente_id,
  COUNT(l.id) as total_leads
FROM agente_usuario_atribuicoes aua
LEFT JOIN lead l ON aua.agente_id = l.agente_id
WHERE aua.usuario_id = 6
GROUP BY aua.agente_id;

-- 2. VERIFICAR SE EXISTEM LEADS COM STATUS 'prospectando' OU 'concluido'
SELECT '2. LEADS COM STATUS VÁLIDO' as teste;
SELECT 
  agente_id,
  status,
  COUNT(*) as quantidade
FROM lead 
WHERE status IN ('prospectando', 'concluido')
GROUP BY agente_id, status
ORDER BY agente_id, status;

-- 3. TESTAR QUERY SIMPLES SEM JOIN
SELECT '3. TODOS OS LEADS' as teste;
SELECT 
  id, client_id, agente_id, nome, telefone, status,
  data_ultima_interacao, data_criacao
FROM lead 
WHERE status IN ('prospectando', 'concluido')
ORDER BY COALESCE(data_ultima_interacao, data_criacao) DESC, id DESC
LIMIT 10;

-- 4. VERIFICAR SE O PROBLEMA É O PERÍODO
SELECT '4. LEADS NO PERÍODO MANHÃ' as teste;
SELECT 
  id, client_id, agente_id, nome, telefone, status,
  data_ultima_interacao, data_criacao
FROM lead 
WHERE status IN ('prospectando', 'concluido')
  AND COALESCE(data_ultima_interacao, data_criacao) >= '2025-09-25 06:00:00'::timestamp
  AND COALESCE(data_ultima_interacao, l.data_criacao) < '2025-09-25 11:59:59'::timestamp
ORDER BY COALESCE(data_ultima_interacao, data_criacao) DESC, id DESC;
