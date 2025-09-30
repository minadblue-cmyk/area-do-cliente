-- Script para zerar todas as reservas e resetar leads para teste
-- ATENÇÃO: Este script vai resetar TODOS os leads da empresa 2

-- 1. Zerar todas as reservas dos leads da empresa 2
UPDATE public.lead 
SET 
    agente_id = NULL,
    reservado_por = NULL,
    reservado_lote = NULL,
    reservado_em = NULL,
    status = 'novo',
    contatado = false,
    data_ultima_interacao = NULL
WHERE empresa_id = 2;

-- 2. Verificar resultado
SELECT 
    empresa_id,
    COUNT(*) as total_leads,
    COUNT(CASE WHEN contatado = false THEN 1 END) as nao_contatados,
    COUNT(CASE WHEN agente_id IS NULL THEN 1 END) as sem_agente,
    COUNT(CASE WHEN reservado_lote IS NULL THEN 1 END) as sem_reserva,
    COUNT(CASE WHEN status = 'novo' THEN 1 END) as status_novo
FROM public.lead 
WHERE empresa_id = 2
GROUP BY empresa_id;

-- 3. Mostrar alguns leads para confirmar
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
    reservado_em
FROM public.lead 
WHERE empresa_id = 2 
ORDER BY id 
LIMIT 10;
