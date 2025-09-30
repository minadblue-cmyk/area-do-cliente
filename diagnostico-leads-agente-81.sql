-- =====================================================
-- DIAGNÓSTICO COMPLETO: LEADS DO AGENTE 81
-- =====================================================

-- 1. VERIFICAR SE A TABELA LEAD EXISTE E TEM DADOS
SELECT '1. TOTAL DE LEADS NA TABELA' as teste;
SELECT COUNT(*) as total_leads FROM lead;

-- 2. VERIFICAR ESTRUTURA DA TABELA LEAD
SELECT '2. ESTRUTURA DA TABELA LEAD' as teste;
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'lead' 
ORDER BY ordinal_position;

-- 3. VERIFICAR SE EXISTEM LEADS DO AGENTE 81
SELECT '3. LEADS DO AGENTE 81' as teste;
SELECT COUNT(*) as total_leads_agente_81 
FROM lead 
WHERE agente_id = 81;

-- 4. VERIFICAR QUAIS AGENTES EXISTEM
SELECT '4. AGENTES EXISTENTES' as teste;
SELECT DISTINCT agente_id, COUNT(*) as quantidade_leads
FROM lead 
GROUP BY agente_id
ORDER BY agente_id;

-- 5. VERIFICAR QUAIS STATUS EXISTEM NO AGENTE 81
SELECT '5. STATUS DO AGENTE 81' as teste;
SELECT DISTINCT status, COUNT(*) as quantidade
FROM lead 
WHERE agente_id = 81
GROUP BY status
ORDER BY quantidade DESC;

-- 6. VERIFICAR RANGE DE DATAS DOS LEADS DO AGENTE 81
SELECT '6. RANGE DE DATAS - AGENTE 81' as teste;
SELECT 
  MIN(COALESCE(data_ultima_interacao, data_criacao)) as data_mais_antiga,
  MAX(COALESCE(data_ultima_interacao, data_criacao)) as data_mais_recente,
  COUNT(*) as total_leads
FROM lead 
WHERE agente_id = 81;

-- 7. TESTAR QUERY EXATA DO N8N (PERÍODO MANHÃ)
SELECT '7. QUERY N8N - PERÍODO MANHÃ' as teste;
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

-- 8. TESTAR QUERY SEM FILTRO DE PERÍODO
SELECT '8. QUERY SEM FILTRO DE PERÍODO' as teste;
SELECT 
  l.id, l.client_id, l.nome, l.telefone, l.status, l.contatado,
  l.data_ultima_interacao, l.data_criacao
FROM lead l
WHERE l.agente_id = 81
  AND l.status IN ('prospectando', 'concluido')
ORDER BY COALESCE(l.data_ultima_interacao, l.data_criacao) DESC,
  l.id DESC
LIMIT 10;

-- 9. VERIFICAR LEADS RECENTES (ÚLTIMOS 7 DIAS)
SELECT '9. LEADS RECENTES (7 DIAS)' as teste;
SELECT 
  l.id, l.client_id, l.nome, l.telefone, l.status, l.contatado,
  l.data_ultima_interacao, l.data_criacao
FROM lead l
WHERE l.agente_id = 81
  AND COALESCE(l.data_ultima_interacao, l.data_criacao) >= NOW() - INTERVAL '7 days'
ORDER BY COALESCE(l.data_ultima_interacao, l.data_criacao) DESC,
  l.id DESC
LIMIT 20;

-- 10. VERIFICAR SE EXISTEM LEADS COM STATUS DIFERENTES
SELECT '10. TODOS OS STATUS DO AGENTE 81' as teste;
SELECT 
  status,
  COUNT(*) as quantidade,
  MIN(COALESCE(data_ultima_interacao, data_criacao)) as data_mais_antiga,
  MAX(COALESCE(data_ultima_interacao, l.data_criacao)) as data_mais_recente
FROM lead 
WHERE agente_id = 81
GROUP BY status
ORDER BY quantidade DESC;

-- 11. VERIFICAR CLIENT_ID DOS LEADS DO AGENTE 81
SELECT '11. CLIENT_ID DOS LEADS DO AGENTE 81' as teste;
SELECT DISTINCT client_id, COUNT(*) as quantidade_leads
FROM lead 
WHERE agente_id = 81
GROUP BY client_id
ORDER BY client_id;

-- 12. QUERY SIMPLES PARA COPIA/COLA
SELECT '12. RESULTADO SIMPLES PARA ANÁLISE' as teste;
SELECT 
  'ID: ' || l.id || 
  ' | Nome: ' || COALESCE(l.nome, 'NULL') || 
  ' | Status: ' || COALESCE(l.status, 'NULL') || 
  ' | Contatado: ' || COALESCE(l.contatado::text, 'NULL') || 
  ' | Data: ' || COALESCE(l.data_ultima_interacao::text, l.data_criacao::text, 'NULL') as resultado
FROM lead l
WHERE l.agente_id = 81
ORDER BY COALESCE(l.data_ultima_interacao, l.data_criacao) DESC,
  l.id DESC
LIMIT 20;
