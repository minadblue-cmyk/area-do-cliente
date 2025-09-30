-- Query completa para trazer todas as informações dos agentes
-- Incluindo webhooks específicos e informações relacionadas

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
    
    -- IDs dos workflows
    ac.workflow_start_id,
    ac.workflow_status_id,
    ac.workflow_lista_id,
    ac.workflow_stop_id,
    
    -- URLs dos webhooks específicos
    ac.webhook_start_url,
    ac.webhook_status_url,
    ac.webhook_lista_url,
    ac.webhook_stop_url,
    
    -- Subquery para contar prospects ativos
    (
        SELECT COUNT(*)
        FROM prospects p
        WHERE p.agente_id = ac.id
        AND p.ativo = true
        AND p.contatado = false
    ) as prospects_ativos,
    
    -- Subquery para contar prospects totais
    (
        SELECT COUNT(*)
        FROM prospects p
        WHERE p.agente_id = ac.id
        AND p.ativo = true
    ) as prospects_total,
    
    -- Subquery para última execução
    (
        SELECT MAX(e.created_at)
        FROM execucoes e
        WHERE e.agente_id = ac.id
        AND e.status = 'completed'
    ) as ultima_execucao,
    
    -- Subquery para status atual da execução
    (
        SELECT e.status
        FROM execucoes e
        WHERE e.agente_id = ac.id
        ORDER BY e.created_at DESC
        LIMIT 1
    ) as status_atual,
    
    -- Subquery para execution_id ativo
    (
        SELECT e.execution_id
        FROM execucoes e
        WHERE e.agente_id = ac.id
        AND e.status = 'running'
        ORDER BY e.created_at DESC
        LIMIT 1
    ) as execution_id_ativo,
    
    -- Informações de configuração adicional
    (
        SELECT json_agg(
            json_build_object(
                'tipo', 'webhook',
                'nome', 'start',
                'url', ac.webhook_start_url,
                'workflow_id', ac.workflow_start_id
            )
        )
        FROM (SELECT 1) t
        WHERE ac.webhook_start_url IS NOT NULL
    ) || 
    (
        SELECT json_agg(
            json_build_object(
                'tipo', 'webhook',
                'nome', 'stop', 
                'url', ac.webhook_stop_url,
                'workflow_id', ac.workflow_stop_id
            )
        )
        FROM (SELECT 1) t
        WHERE ac.webhook_stop_url IS NOT NULL
    ) ||
    (
        SELECT json_agg(
            json_build_object(
                'tipo', 'webhook',
                'nome', 'status',
                'url', ac.webhook_status_url,
                'workflow_id', ac.workflow_status_id
            )
        )
        FROM (SELECT 1) t
        WHERE ac.webhook_status_url IS NOT NULL
    ) ||
    (
        SELECT json_agg(
            json_build_object(
                'tipo', 'webhook',
                'nome', 'lista',
                'url', ac.webhook_lista_url,
                'workflow_id', ac.workflow_lista_id
            )
        )
        FROM (SELECT 1) t
        WHERE ac.webhook_lista_url IS NOT NULL
    ) as webhooks_configurados

FROM agentes_config ac
WHERE ac.ativo = true
ORDER BY ac.nome;
