-- Query completa para agentes com sistema de reserva por lotes
-- Otimizada para tabela LEAD com controle de concorrência

SELECT 
    -- Campos básicos do agente
    ac.id,
    ac.nome,
    ac.descricao,
    ac.icone,
    ac.cor,
    ac.ativo,
    ac.created_at,
    ac.updated_at,
    
    -- Workflow IDs
    ac.workflow_start_id,
    ac.workflow_status_id,
    ac.workflow_lista_id,
    ac.workflow_stop_id,
    
    -- Webhook URLs específicos
    ac.webhook_start_url,
    ac.webhook_status_url,
    ac.webhook_lista_url,
    ac.webhook_stop_url,
    
    -- === ESTATÍSTICAS DE LEADS ===
    
    -- Leads reservados pelo agente (pendentes de contato)
    COALESCE(
        (SELECT COUNT(*) FROM lead WHERE reservado_por = ac.nome AND contatado = false),
        0
    ) as leads_pendentes,
    
    -- Leads reservados pelo agente (total)
    COALESCE(
        (SELECT COUNT(*) FROM lead WHERE reservado_por = ac.nome),
        0
    ) as leads_reservados_total,
    
    -- Leads já contatados pelo agente
    COALESCE(
        (SELECT COUNT(*) FROM lead WHERE reservado_por = ac.nome AND contatado = true),
        0
    ) as leads_contatados,
    
    -- === CONTROLE DE LOTES ===
    
    -- Último lote reservado pelo agente
    (
        SELECT reservado_lote 
        FROM lead 
        WHERE reservado_por = ac.nome 
        ORDER BY reservado_em DESC 
        LIMIT 1
    ) as ultimo_lote,
    
    -- Data da última reserva
    (
        SELECT MAX(reservado_em) 
        FROM lead 
        WHERE reservado_por = ac.nome
    ) as ultima_reserva,
    
    -- Quantidade de leads no último lote
    COALESCE(
        (SELECT COUNT(*) 
         FROM lead 
         WHERE reservado_por = ac.nome 
         AND reservado_lote = (
             SELECT reservado_lote 
             FROM lead 
             WHERE reservado_por = ac.nome 
             ORDER BY reservado_em DESC 
             LIMIT 1
         )),
        0
    ) as leads_no_ultimo_lote,
    
    -- === ESTATÍSTICAS GERAIS ===
    
    -- Leads disponíveis para reserva (não reservados e não contatados)
    COALESCE(
        (SELECT COUNT(*) FROM lead WHERE reservado_por IS NULL AND contatado = false),
        0
    ) as leads_disponiveis,
    
    -- Leads disponíveis por estágio de funil
    COALESCE(
        (SELECT COUNT(*) FROM lead WHERE reservado_por IS NULL AND contatado = false AND estagio_funnel = 'prospeccao'),
        0
    ) as leads_prospeccao_disponiveis,
    
    -- === STATUS DE EXECUÇÃO ===
    
    -- Status atual do agente
    COALESCE(
        (SELECT status FROM execucoes WHERE agente_id = ac.id ORDER BY created_at DESC LIMIT 1),
        'stopped'
    ) as status_atual,
    
    -- Execution ID ativo
    (
        SELECT execution_id 
        FROM execucoes 
        WHERE agente_id = ac.id 
        AND status = 'running'
        ORDER BY created_at DESC 
        LIMIT 1
    ) as execution_id_ativo,
    
    -- Última execução
    (
        SELECT MAX(created_at) 
        FROM execucoes 
        WHERE agente_id = ac.id
    ) as ultima_execucao,
    
    -- === INFORMAÇÕES DE PERFORMANCE ===
    
    -- Taxa de conversão (contatados / reservados)
    CASE 
        WHEN (
            SELECT COUNT(*) FROM lead WHERE reservado_por = ac.nome
        ) > 0 THEN
            ROUND(
                (
                    SELECT COUNT(*) FROM lead WHERE reservado_por = ac.nome AND contatado = true
                )::DECIMAL / 
                (
                    SELECT COUNT(*) FROM lead WHERE reservado_por = ac.nome
                )::DECIMAL * 100, 2
            )
        ELSE 0
    END as taxa_conversao,
    
    -- Leads processados hoje
    COALESCE(
        (SELECT COUNT(*) FROM lead 
         WHERE reservado_por = ac.nome 
         AND DATE(reservado_em) = CURRENT_DATE),
        0
    ) as leads_processados_hoje

FROM agentes_config ac
WHERE ac.ativo = true
ORDER BY ac.nome;
