-- Script SQL para criar webhook de status de agente
-- Este script deve ser executado no n8n como um node PostgreSQL

-- Consulta para buscar status do agente
SELECT 
    execution_id,
    workflow_id,
    usuario_id,
    usuario_nome,
    usuario_email,
    status,
    iniciado_em,
    parado_em,
    payload_inicial,
    payload_parada,
    created_at,
    updated_at,
    finalizado_em,
    erro_em,
    mensagem_erro,
    duracao_segundos
FROM agente_execucoes 
WHERE workflow_id = '{{ $json.workflow_id }}' 
  AND usuario_id = {{ $json.usuario_id }}
ORDER BY created_at DESC 
LIMIT 1;
