-- Query focada apenas em informações do agente e webhooks específicos
-- Sem misturar status de leads (que tem webhook próprio)

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
    
    -- Workflow IDs (para referência)
    ac.workflow_start_id,
    ac.workflow_status_id,
    ac.workflow_lista_id,
    ac.workflow_stop_id,
    
    -- Webhook URLs específicos (o que realmente importa)
    ac.webhook_start_url,
    ac.webhook_status_url,
    ac.webhook_lista_url,
    ac.webhook_stop_url,
    
    -- Status de execução (usando tabela agente_execucoes)
    COALESCE(
        (SELECT status FROM agente_execucoes WHERE id = ac.id ORDER BY created_at DESC LIMIT 1),
        'stopped'
    ) as status_atual,
    
    -- Execution ID ativo (usando tabela agente_execucoes)
    (
        SELECT execution_id 
        FROM agente_execucoes 
        WHERE id = ac.id 
        AND status = 'running'
        ORDER BY created_at DESC 
        LIMIT 1
    ) as execution_id_ativo

FROM agentes_config ac
WHERE ac.ativo = true
ORDER BY ac.nome;
