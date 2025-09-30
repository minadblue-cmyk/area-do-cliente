-- Script para validar isolamento por empresa
-- Verificar se empresas não estão vendo leads uma da outra

-- 1. Verificar leads por empresa (antes da reserva)
SELECT 
    empresa_id,
    COUNT(*) as total_leads,
    COUNT(CASE WHEN contatado = false THEN 1 END) as nao_contatados,
    COUNT(CASE WHEN agente_id IS NOT NULL THEN 1 END) as com_agente,
    COUNT(CASE WHEN reservado_lote IS NOT NULL THEN 1 END) as reservados
FROM public.lead 
GROUP BY empresa_id 
ORDER BY empresa_id;

-- 2. Verificar leads reservados por empresa e agente
SELECT 
    empresa_id,
    agente_id,
    COUNT(*) as leads_reservados,
    MIN(reservado_em) as primeira_reserva,
    MAX(reservado_em) as ultima_reserva,
    STRING_AGG(DISTINCT reservado_lote, ', ') as lotes_reservados
FROM public.lead 
WHERE agente_id IS NOT NULL 
  AND reservado_lote IS NOT NULL
GROUP BY empresa_id, agente_id
ORDER BY empresa_id, agente_id;

-- 3. Verificar se há leads "vazando" entre empresas
-- (leads de uma empresa sendo processados por agente de outra)
SELECT 
    l.empresa_id as lead_empresa,
    l.agente_id,
    l.reservado_por,
    l.reservado_lote,
    l.nome,
    l.telefone,
    l.status,
    l.reservado_em
FROM public.lead l
WHERE l.agente_id IS NOT NULL 
  AND l.reservado_lote IS NOT NULL
ORDER BY l.empresa_id, l.agente_id, l.reservado_em;

-- 4. Verificar telefones duplicados entre empresas
SELECT 
    telefone,
    COUNT(DISTINCT empresa_id) as empresas_com_telefone,
    STRING_AGG(DISTINCT empresa_id::text, ', ') as empresas,
    STRING_AGG(DISTINCT nome, ' | ') as nomes
FROM public.lead 
WHERE telefone IS NOT NULL
GROUP BY telefone
HAVING COUNT(DISTINCT empresa_id) > 1
ORDER BY empresas_com_telefone DESC, telefone;

-- 5. Verificar leads ativos por empresa (prospectando)
SELECT 
    empresa_id,
    agente_id,
    COUNT(*) as leads_prospectando,
    STRING_AGG(nome, ', ') as nomes_leads
FROM public.lead 
WHERE status = 'prospectando'
  AND agente_id IS NOT NULL
GROUP BY empresa_id, agente_id
ORDER BY empresa_id, agente_id;

-- 6. Verificar se há conflitos de reserva entre empresas
SELECT 
    telefone,
    empresa_id,
    agente_id,
    reservado_por,
    reservado_lote,
    status,
    reservado_em
FROM public.lead 
WHERE telefone IN (
    SELECT telefone 
    FROM public.lead 
    WHERE agente_id IS NOT NULL 
    GROUP BY telefone 
    HAVING COUNT(DISTINCT empresa_id) > 1
)
AND agente_id IS NOT NULL
ORDER BY telefone, empresa_id;

-- 7. Resumo de isolamento
SELECT 
    'TOTAL LEADS' as metrica,
    COUNT(*) as valor
FROM public.lead
UNION ALL
SELECT 
    'LEADS EMPRESA 1' as metrica,
    COUNT(*) as valor
FROM public.lead WHERE empresa_id = 1
UNION ALL
SELECT 
    'LEADS EMPRESA 2' as metrica,
    COUNT(*) as valor
FROM public.lead WHERE empresa_id = 2
UNION ALL
SELECT 
    'LEADS RESERVADOS EMPRESA 1' as metrica,
    COUNT(*) as valor
FROM public.lead WHERE empresa_id = 1 AND agente_id IS NOT NULL
UNION ALL
SELECT 
    'LEADS RESERVADOS EMPRESA 2' as metrica,
    COUNT(*) as valor
FROM public.lead WHERE empresa_id = 2 AND agente_id IS NOT NULL
UNION ALL
SELECT 
    'TELEFONES DUPLICADOS' as metrica,
    COUNT(DISTINCT telefone) as valor
FROM (
    SELECT telefone 
    FROM public.lead 
    GROUP BY telefone 
    HAVING COUNT(DISTINCT empresa_id) > 1
) as duplicados;
