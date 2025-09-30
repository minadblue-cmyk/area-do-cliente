-- ✅ QUERIES N8N ATUALIZADAS COM PERMISSÕES DE ACESSO

-- 1. QUERY DE RESERVA DE LOTES (Atualizada)
-- Esta query reserva leads e define permissões de acesso
WITH pegar AS (
  SELECT id
  FROM public.lead
  WHERE contatado IS NOT TRUE
    AND (reservado_lote IS NULL
         OR COALESCE(reservado_em, NOW() - INTERVAL '100 years')
            < NOW() - INTERVAL '30 minutes')
  ORDER BY COALESCE(data_ultima_interacao, data_criacao) ASC, id ASC
  LIMIT 20
  FOR UPDATE SKIP LOCKED
)
UPDATE public.lead l
SET reservado_por  = $1,         -- {{$workflow.id}}
    reservado_em   = NOW(),
    reservado_lote = $2,         -- {{$execution.id}}
    agente_id      = $3,         -- {{$json.usuario_id}}
    permissoes_acesso = $4       -- JSONB com permissões
FROM pegar p
WHERE l.id = p.id
RETURNING
  l.id,
  l.reservado_lote,
  l.reservado_por,
  l.reservado_em,
  l.agente_id,
  l.permissoes_acesso;

-- 2. PARÂMETROS PARA RESERVA DE LOTES
/*
{{$workflow.id}}, 
{{$execution.id}}, 
{{$json.usuario_id}}, 
{{JSON.stringify({
  "agente_id": $json.usuario_id,
  "reservado_por": "usuario_" + $json.usuario_id,
  "reservado_em": $now.toISO(),
  "perfis_permitidos": $json.perfis_permitidos || [],
  "usuarios_permitidos": $json.usuarios_permitidos || [$json.usuario_id],
  "permissoes_especiais": {
    "pode_editar": true,
    "pode_deletar": false,
    "pode_exportar": true
  }
})}}
*/

-- 3. QUERY DE LISTA DE PROSPECÇÃO (Atualizada)
-- Esta query verifica permissões de acesso antes de retornar leads
SELECT
  l.id, l.client_id, l.nome, l.telefone, l.status, l.contatado,
  l.data_ultima_interacao, l.data_criacao, l.agente_id,
  l.permissoes_acesso
FROM lead l
WHERE l.agente_id = $3
  AND l.status IN ('prospectando', 'concluido')
  AND COALESCE(l.data_ultima_interacao, l.data_criacao) >= $1::timestamp
  AND COALESCE(l.data_ultima_interacao, l.data_criacao) < $2::timestamp
  -- Verificar permissões de acesso
  AND (
    -- Usuário específico tem permissão
    l.permissoes_acesso->'usuarios_permitidos' @> $4::jsonb
    OR
    -- Perfil do usuário tem permissão
    l.permissoes_acesso->'perfis_permitidos' @> $5::jsonb
    OR
    -- Usuário é o próprio agente
    l.agente_id = $6
  )
ORDER BY COALESCE(l.data_ultima_interacao, l.data_criacao) DESC,
  l.id DESC;

-- 4. PARÂMETROS PARA LISTA DE PROSPECÇÃO
/*
{{$1}},  -- data_inicio
{{$2}},  -- data_fim
{{$3}},  -- agente_id
{{JSON.stringify([$json.usuario_id])}},  -- usuarios_permitidos
{{JSON.stringify([$json.perfil_id])}},  -- perfis_permitidos
{{$json.usuario_id}}  -- usuario_id (para verificar se é o próprio agente)
*/

-- 5. QUERY DE BUSCA DE LEADS RESERVADOS (Atualizada)
-- Esta query busca leads reservados por um agente específico
SELECT
  l.id, l.client_id, l.nome_cliente, l.telefone, l.canal,
  l.status, l.data_ultima_interacao, l.reservado_por, l.reservado_lote,
  l.agente_id, l.permissoes_acesso
FROM public.lead l
WHERE l.reservado_lote = $1
  -- Verificar se usuário tem permissão para ver estes leads
  AND (
    l.permissoes_acesso->'usuarios_permitidos' @> $2::jsonb
    OR
    l.permissoes_acesso->'perfis_permitidos' @> $3::jsonb
    OR
    l.agente_id = $4
  )
ORDER BY COALESCE(l.data_ultima_interacao, l.data_criacao) ASC,
  l.id ASC;

-- 6. QUERY DE VERIFICAÇÃO DE PERMISSÕES
-- Esta query verifica se um usuário tem permissão para acessar um agente
SELECT
  ac.id as agente_id,
  ac.nome as agente_nome,
  ac.ativo as agente_ativo,
  aua.usuario_id,
  u.perfil_id,
  CASE 
    WHEN aua.usuario_id = $1 THEN 'usuario_atribuido'
    WHEN l.permissoes_acesso->'usuarios_permitidos' @> $2::jsonb THEN 'usuario_permitido'
    WHEN l.permissoes_acesso->'perfis_permitidos' @> $3::jsonb THEN 'perfil_permitido'
    ELSE 'sem_permissao'
  END as tipo_permissao
FROM agentes_config ac
LEFT JOIN agente_usuario_atribuicoes aua ON ac.id = aua.agente_id
LEFT JOIN usuarios u ON aua.usuario_id = u.id
LEFT JOIN lead l ON ac.id = l.agente_id
WHERE ac.id = $4
  AND ac.ativo = true
GROUP BY ac.id, ac.nome, ac.ativo, aua.usuario_id, u.perfil_id, l.permissoes_acesso;
