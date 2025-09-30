-- Query simplificada para agentes com informações de webhook
-- Versão mais prática para o N8N - AJUSTADA PARA TABELA LEAD

SELECT 
    -- Campos básicos
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
    
    -- Webhook URLs
    ac.webhook_start_url,
    ac.webhook_status_url,
    ac.webhook_lista_url,
    ac.webhook_stop_url,
    
    -- Informações de leads (usando tabela LEAD)
    COALESCE(
        (SELECT COUNT(*) FROM lead WHERE reservado_por = ac.nome AND contatado = false),
        0
    ) as leads_reservados_pendentes,
    
    COALESCE(
        (SELECT COUNT(*) FROM lead WHERE reservado_por = ac.nome),
        0
    ) as leads_reservados_total,
    
    COALESCE(
        (SELECT COUNT(*) FROM lead WHERE reservado_por = ac.nome AND contatado = true),
        0
    ) as leads_contatados,
    
    -- Último lote reservado
    (
        SELECT reservado_lote 
        FROM lead 
        WHERE reservado_por = ac.nome 
        ORDER BY reservado_em DESC 
        LIMIT 1
    ) as ultimo_lote_reservado,
    
    -- Status da última execução
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
    
    -- Estatísticas de leads disponíveis
    COALESCE(
        (SELECT COUNT(*) FROM lead WHERE reservado_por IS NULL AND contatado = false),
        0
    ) as leads_disponiveis_geral

FROM agentes_config ac
WHERE ac.ativo = true
ORDER BY ac.nome;
