-- Query corrigida para sempre retornar dados, mesmo sem resultados
-- Esta query deve ser usada no node PostgreSQL do n8n

-- Opção 1: Query que sempre retorna pelo menos uma linha
SELECT
    id,
    execution_id,
    workflow_id,
    usuario_id,
    status,
    iniciado_em,
    parado_em,
    payload_inicial,
    payload_parada,
    CASE
        WHEN status = 'running' THEN 'Agente em execução'
        WHEN status = 'stopped' THEN 'Agente parado'
        WHEN status = 'error' THEN 'Agente com erro'
        WHEN status = 'completed' THEN 'Agente concluído'
        ELSE 'Status desconhecido'
    END as message,
    EXTRACT(EPOCH FROM (NOW() - iniciado_em)) as tempo_execucao_segundos
FROM agente_execucoes
WHERE usuario_id = $1
AND workflow_id = $2
AND ($3 IS NULL OR status = $3)
ORDER BY iniciado_em DESC
LIMIT 10

UNION ALL

-- Se não houver resultados, retorna uma linha vazia
SELECT
    NULL as id,
    NULL as execution_id,
    $2 as workflow_id,
    $1 as usuario_id,
    'disconnected' as status,
    NULL as iniciado_em,
    NULL as parado_em,
    NULL as payload_inicial,
    NULL as payload_parada,
    'Agente não iniciado' as message,
    0 as tempo_execucao_segundos
WHERE NOT EXISTS (
    SELECT 1 FROM agente_execucoes 
    WHERE usuario_id = $1 
    AND workflow_id = $2
    AND ($3 IS NULL OR status = $3)
);

-- Opção 2: Query mais simples que sempre retorna dados
-- Use esta se a Opção 1 não funcionar
/*
SELECT
    COALESCE(
        (SELECT id FROM agente_execucoes 
         WHERE usuario_id = $1 AND workflow_id = $2 
         AND ($3 IS NULL OR status = $3)
         ORDER BY iniciado_em DESC LIMIT 1),
        0
    ) as id,
    COALESCE(
        (SELECT execution_id FROM agente_execucoes 
         WHERE usuario_id = $1 AND workflow_id = $2 
         AND ($3 IS NULL OR status = $3)
         ORDER BY iniciado_em DESC LIMIT 1),
        NULL
    ) as execution_id,
    $2 as workflow_id,
    $1 as usuario_id,
    COALESCE(
        (SELECT status FROM agente_execucoes 
         WHERE usuario_id = $1 AND workflow_id = $2 
         AND ($3 IS NULL OR status = $3)
         ORDER BY iniciado_em DESC LIMIT 1),
        'disconnected'
    ) as status,
    COALESCE(
        (SELECT iniciado_em FROM agente_execucoes 
         WHERE usuario_id = $1 AND workflow_id = $2 
         AND ($3 IS NULL OR status = $3)
         ORDER BY iniciado_em DESC LIMIT 1),
        NULL
    ) as iniciado_em,
    COALESCE(
        (SELECT parado_em FROM agente_execucoes 
         WHERE usuario_id = $1 AND workflow_id = $2 
         AND ($3 IS NULL OR status = $3)
         ORDER BY iniciado_em DESC LIMIT 1),
        NULL
    ) as parado_em,
    COALESCE(
        (SELECT payload_inicial FROM agente_execucoes 
         WHERE usuario_id = $1 AND workflow_id = $2 
         AND ($3 IS NULL OR status = $3)
         ORDER BY iniciado_em DESC LIMIT 1),
        NULL
    ) as payload_inicial,
    COALESCE(
        (SELECT payload_parada FROM agente_execucoes 
         WHERE usuario_id = $1 AND workflow_id = $2 
         AND ($3 IS NULL OR status = $3)
         ORDER BY iniciado_em DESC LIMIT 1),
        NULL
    ) as payload_parada,
    CASE
        WHEN COALESCE(
            (SELECT status FROM agente_execucoes 
             WHERE usuario_id = $1 AND workflow_id = $2 
             AND ($3 IS NULL OR status = $3)
             ORDER BY iniciado_em DESC LIMIT 1),
            'disconnected'
        ) = 'running' THEN 'Agente em execução'
        WHEN COALESCE(
            (SELECT status FROM agente_execucoes 
             WHERE usuario_id = $1 AND workflow_id = $2 
             AND ($3 IS NULL OR status = $3)
             ORDER BY iniciado_em DESC LIMIT 1),
            'disconnected'
        ) = 'stopped' THEN 'Agente parado'
        WHEN COALESCE(
            (SELECT status FROM agente_execucoes 
             WHERE usuario_id = $1 AND workflow_id = $2 
             AND ($3 IS NULL OR status = $3)
             ORDER BY iniciado_em DESC LIMIT 1),
            'disconnected'
        ) = 'error' THEN 'Agente com erro'
        WHEN COALESCE(
            (SELECT status FROM agente_execucoes 
             WHERE usuario_id = $1 AND workflow_id = $2 
             AND ($3 IS NULL OR status = $3)
             ORDER BY iniciado_em DESC LIMIT 1),
            'disconnected'
        ) = 'completed' THEN 'Agente concluído'
        ELSE 'Agente não iniciado'
    END as message,
    COALESCE(
        (SELECT EXTRACT(EPOCH FROM (NOW() - iniciado_em)) FROM agente_execucoes 
         WHERE usuario_id = $1 AND workflow_id = $2 
         AND ($3 IS NULL OR status = $3)
         ORDER BY iniciado_em DESC LIMIT 1),
        0
    ) as tempo_execucao_segundos;
*/
