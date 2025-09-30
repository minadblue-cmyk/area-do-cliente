-- =====================================================
# VERIFICAR LEADS RESERVADOS APÓS TESTES
-- =====================================================

-- 1. Verificar leads reservados por cada agente
SELECT 
    agente_id,
    reservado_por,
    reservado_lote,
    COUNT(*) as quantidade_leads,
    MIN(reservado_em) as primeiro_reservado,
    MAX(reservado_em) as ultimo_reservado,
    COUNT(CASE WHEN contatado = true THEN 1 END) as leads_contatados,
    COUNT(CASE WHEN contatado IS NOT true THEN 1 END) as leads_nao_contatados
FROM public.lead 
WHERE reservado_lote IS NOT NULL
GROUP BY agente_id, reservado_por, reservado_lote
ORDER BY agente_id, reservado_em;

-- 2. Verificar permissões de acesso nos leads reservados
SELECT 
    agente_id,
    reservado_por,
    COUNT(*) as total_leads,
    COUNT(CASE WHEN permissoes_acesso IS NOT NULL AND permissoes_acesso != '{}'::jsonb THEN 1 END) as leads_com_permissoes,
    COUNT(CASE WHEN permissoes_acesso IS NULL OR permissoes_acesso = '{}'::jsonb THEN 1 END) as leads_sem_permissoes
FROM public.lead 
WHERE agente_id IS NOT NULL AND reservado_lote IS NOT NULL
GROUP BY agente_id, reservado_por
ORDER BY agente_id;

-- 3. Verificar leads disponíveis para novos agentes
SELECT 
    COUNT(*) as leads_disponiveis,
    COUNT(CASE WHEN contatado = true THEN 1 END) as leads_contatados_disponiveis,
    COUNT(CASE WHEN contatado IS NOT true THEN 1 END) as leads_nao_contatados_disponiveis
FROM public.lead 
WHERE (reservado_lote IS NULL 
       OR COALESCE(reservado_em, NOW() - INTERVAL '100 years') < NOW() - INTERVAL '30 minutes');

-- 4. Verificar isolamento entre agentes (leads não devem aparecer para outros agentes)
SELECT 
    'Leads do Agente 5' as agente,
    COUNT(*) as total,
    COUNT(CASE WHEN agente_id = 5 THEN 1 END) as leads_corretos,
    COUNT(CASE WHEN agente_id != 5 THEN 1 END) as leads_incorretos
FROM public.lead 
WHERE reservado_por = 'wf36261'  -- Substitua pelo reservado_por do agente 5

UNION ALL

SELECT 
    'Leads do Agente 6' as agente,
    COUNT(*) as total,
    COUNT(CASE WHEN agente_id = 6 THEN 1 END) as leads_corretos,
    COUNT(CASE WHEN agente_id != 6 THEN 1 END) as leads_incorretos
FROM public.lead 
WHERE reservado_por = 'wf36262';  -- Substitua pelo reservado_por do agente 6
