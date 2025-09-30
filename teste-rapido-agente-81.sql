-- =====================================================
-- TESTE RÁPIDO: LEADS DO AGENTE 81
-- =====================================================

-- 1. VERIFICAR SE EXISTEM LEADS DO AGENTE 81
SELECT '1. TOTAL DE LEADS DO AGENTE 81' as teste;
SELECT COUNT(*) as total_leads_agente_81 
FROM lead 
WHERE agente_id = 81;

-- 2. VERIFICAR QUAIS AGENTES EXISTEM
SELECT '2. AGENTES EXISTENTES' as teste;
SELECT DISTINCT agente_id, COUNT(*) as quantidade_leads
FROM lead 
GROUP BY agente_id
ORDER BY agente_id;

-- 3. VERIFICAR QUAIS STATUS EXISTEM NO AGENTE 81
SELECT '3. STATUS DO AGENTE 81' as teste;
SELECT DISTINCT status, COUNT(*) as quantidade
FROM lead 
WHERE agente_id = 81
GROUP BY status
ORDER BY quantidade DESC;

-- 4. VERIFICAR RANGE DE DATAS DOS LEADS DO AGENTE 81
SELECT '4. RANGE DE DATAS - AGENTE 81' as teste;
SELECT 
  MIN(COALESCE(data_ultima_interacao, data_criacao)) as data_mais_antiga,
  MAX(COALESCE(data_ultima_interacao, data_criacao)) as data_mais_recente,
  COUNT(*) as total_leads
FROM lead 
WHERE agente_id = 81;

-- 5. TESTAR QUERY EXATA DO N8N (PERÍODO MANHÃ)
SELECT '5. QUERY N8N - PERÍODO MANHÃ' as teste;
SELECT 
  l.id, l.client_id, l.nome, l.telefone, l.status, l.contatado,
  l.data_ultima_interacao, l.data_criacao
FROM lead l
WHERE l.agente_id = 81
  AND l.status IN ('prospectando', 'concluido')
  AND COALESCE(l.data_ultima_interacao, l.data_criacao) >= '2025-09-25 06:00:00'::timestamp
  AND COALESCE(l.data_ultima_interacao, l.data_criacao) < '2025-09-25 11:59:59'::timestamp
ORDER BY COALESCE(l.data_ultima_interacao, l.data_criacao) DESC,
  l.id DESC;

-- 6. TESTAR QUERY SEM FILTRO DE PERÍODO
SELECT '6. QUERY SEM FILTRO DE PERÍODO' as teste;
SELECT 
  l.id, l.client_id, l.nome, l.telefone, l.status, l.contatado,
  l.data_ultima_interacao, l.data_criacao
FROM lead l
WHERE l.agente_id = 81
  AND l.status IN ('prospectando', 'concluido')
ORDER BY COALESCE(l.data_ultima_interacao, l.data_criacao) DESC,
  l.id DESC
LIMIT 10;

-- 7. VERIFICAR LEADS RECENTES (ÚLTIMOS 7 DIAS)
SELECT '7. LEADS RECENTES (7 DIAS)' as teste;
SELECT 
  l.id, l.client_id, l.nome, l.telefone, l.status, l.contatado,
  l.data_ultima_interacao, l.data_criacao
FROM lead l
WHERE l.agente_id = 81
  AND COALESCE(l.data_ultima_interacao, l.data_criacao) >= NOW() - INTERVAL '7 days'
ORDER BY COALESCE(l.data_ultima_interacao, l.data_criacao) DESC,
  l.id DESC
LIMIT 20;
