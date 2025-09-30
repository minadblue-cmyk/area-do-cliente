-- Script para verificar leads disponíveis para reserva
-- Diagnóstico do problema de output vazio

-- 1. Verificar total de leads por empresa
SELECT 
    empresa_id, 
    COUNT(*) as total_leads,
    COUNT(CASE WHEN contatado = false THEN 1 END) as nao_contatados,
    COUNT(CASE WHEN contatado = true THEN 1 END) as contatados,
    COUNT(CASE WHEN status = 'novo' THEN 1 END) as status_novo,
    COUNT(CASE WHEN status = 'prospectando' THEN 1 END) as status_prospectando,
    COUNT(CASE WHEN status = 'concluido' THEN 1 END) as status_concluido
FROM public.lead 
GROUP BY empresa_id 
ORDER BY empresa_id;

-- 2. Verificar leads da empresa 2 especificamente
SELECT 
    id, 
    nome, 
    telefone, 
    status, 
    contatado,
    empresa_id,
    agente_id,
    reservado_por,
    reservado_lote,
    reservado_em,
    data_ultima_interacao,
    created_at
FROM public.lead 
WHERE empresa_id = 2 
ORDER BY created_at DESC;

-- 3. Verificar leads que atendem aos critérios de reserva
SELECT 
    id, 
    nome, 
    telefone, 
    status, 
    contatado,
    empresa_id,
    agente_id,
    reservado_por,
    reservado_lote,
    reservado_em,
    data_ultima_interacao,
    created_at,
    CASE 
        WHEN contatado = true THEN 'JÁ CONTATADO'
        WHEN reservado_lote IS NOT NULL AND COALESCE(reservado_em, NOW() - INTERVAL '100 years') >= NOW() - INTERVAL '30 minutes' THEN 'RESERVADO RECENTEMENTE'
        ELSE 'DISPONÍVEL PARA RESERVA'
    END as status_reserva
FROM public.lead 
WHERE empresa_id = 2 
ORDER BY 
    CASE 
        WHEN contatado = true THEN 1
        WHEN reservado_lote IS NOT NULL AND COALESCE(reservado_em, NOW() - INTERVAL '100 years') >= NOW() - INTERVAL '30 minutes' THEN 2
        ELSE 3
    END,
    COALESCE(data_ultima_interacao, created_at) ASC;

-- 4. Contar leads disponíveis para reserva (mesma lógica da query)
SELECT 
    COUNT(*) as leads_disponiveis_para_reserva
FROM public.lead
WHERE contatado IS NOT TRUE
  AND empresa_id = 2
  AND (reservado_lote IS NULL
       OR COALESCE(reservado_em, NOW() - INTERVAL '100 years')
          < NOW() - INTERVAL '30 minutes');

-- 5. Verificar se há leads com empresa_id diferente de 2
SELECT 
    empresa_id, 
    COUNT(*) as total,
    COUNT(CASE WHEN contatado = false THEN 1 END) as nao_contatados
FROM public.lead 
WHERE contatado = false
GROUP BY empresa_id 
ORDER BY empresa_id;