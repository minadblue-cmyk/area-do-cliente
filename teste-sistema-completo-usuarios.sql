-- =====================================================
-- TESTE COMPLETO DO SISTEMA COM DIFERENTES USUÁRIOS
-- =====================================================

-- 1. Verificar usuários e agentes disponíveis
SELECT 
    u.id as usuario_id,
    u.nome as usuario_nome,
    u.email,
    a.id as agente_id,
    a.nome as agente_nome,
    p.id as perfil_id,
    p.descricao as perfil_nome
FROM usuarios u
LEFT JOIN agentes a ON a.usuario_id = u.id
LEFT JOIN usuario_perfis up ON up.usuario_id = u.id
LEFT JOIN perfis p ON p.id = up.perfil_id
ORDER BY u.id, a.id;

-- 2. Verificar leads disponíveis para teste
SELECT 
    COUNT(*) as total_leads,
    COUNT(CASE WHEN contatado = true THEN 1 END) as leads_contatados,
    COUNT(CASE WHEN contatado IS NOT true THEN 1 END) as leads_nao_contatados,
    COUNT(CASE WHEN agente_id IS NOT NULL THEN 1 END) as leads_com_agente,
    COUNT(CASE WHEN agente_id IS NULL THEN 1 END) as leads_sem_agente
FROM public.lead;

-- 3. Verificar leads reservados atualmente
SELECT 
    agente_id,
    reservado_por,
    reservado_lote,
    COUNT(*) as quantidade_leads,
    MIN(reservado_em) as primeiro_reservado,
    MAX(reservado_em) as ultimo_reservado
FROM public.lead 
WHERE reservado_lote IS NOT NULL
GROUP BY agente_id, reservado_por, reservado_lote
ORDER BY agente_id;

-- 4. Verificar permissões de acesso nos leads
SELECT 
    agente_id,
    COUNT(*) as total_leads,
    COUNT(CASE WHEN permissoes_acesso IS NOT NULL AND permissoes_acesso != '{}'::jsonb THEN 1 END) as leads_com_permissoes,
    COUNT(CASE WHEN permissoes_acesso IS NULL OR permissoes_acesso = '{}'::jsonb THEN 1 END) as leads_sem_permissoes
FROM public.lead 
WHERE agente_id IS NOT NULL
GROUP BY agente_id
ORDER BY agente_id;
