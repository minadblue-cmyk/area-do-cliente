-- Script para verificar leads da empresa 2
-- Verificar se o agente está processando os leads

-- 1. Contar leads por empresa
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

-- 2. Verificar leads da empresa 2 (detalhado)
SELECT 
    id, 
    nome, 
    telefone, 
    email, 
    profissao, 
    status, 
    contatado,
    agente_id,
    reservado_por,
    reservado_lote,
    reservado_em,
    data_ultima_interacao,
    created_at
FROM public.lead 
WHERE empresa_id = 2 
ORDER BY 
    CASE 
        WHEN status = 'prospectando' THEN 1
        WHEN status = 'novo' THEN 2
        WHEN status = 'concluido' THEN 3
        ELSE 4
    END,
    created_at DESC;

-- 3. Verificar leads reservados pelo agente
SELECT 
    id, 
    nome, 
    telefone, 
    status, 
    agente_id,
    reservado_por,
    reservado_lote,
    reservado_em
FROM public.lead 
WHERE empresa_id = 2 
  AND agente_id IS NOT NULL
  AND reservado_lote IS NOT NULL
ORDER BY reservado_em DESC;

-- 4. Verificar leads não contatados disponíveis
SELECT 
    COUNT(*) as leads_disponiveis
FROM public.lead 
WHERE empresa_id = 2 
  AND contatado = false
  AND (reservado_lote IS NULL 
       OR COALESCE(reservado_em, NOW() - INTERVAL '100 years') 
          < NOW() - INTERVAL '30 minutes');
