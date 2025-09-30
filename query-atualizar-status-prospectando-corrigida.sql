-- Query corrigida para o node "Atualizar status - prospectando"
-- Adiciona campo contatado = true quando lead entra em prospecção

WITH upd AS (
  UPDATE public.lead AS l
  SET
    status                = 'prospectando',
    data_ultima_interacao = NOW(),
    agente_id             = $5,
    contatado             = true  -- ✅ NOVO: Marca como contatado
  WHERE l.id = $1
    AND l.reservado_por  = $2
    AND l.reservado_lote = $3
  RETURNING
    l.id, l.client_id, l.nome_cliente, l.telefone, l.canal,
    l.status, l.data_ultima_interacao, l.reservado_por, l.reservado_lote,
    l.agente_id, l.contatado  -- ✅ NOVO: Incluir contatado no RETURNING
),
fb AS (
  SELECT
    l.id, l.client_id, l.nome_cliente, l.telefone, l.canal,
    l.status, l.data_ultima_interacao, l.reservado_por, l.reservado_lote,
    l.agente_id, l.contatado  -- ✅ NOVO: Incluir contatado no SELECT
  FROM public.lead l
  WHERE l.id = $1
  LIMIT 1
),
row_out AS (
  SELECT * FROM upd
  UNION ALL
  SELECT * FROM fb WHERE NOT EXISTS (SELECT 1 FROM upd)
)
SELECT
  row_out.id,
  row_out.client_id,
  row_out.nome_cliente,
  row_out.telefone,
  row_out.canal,
  row_out.status,
  row_out.data_ultima_interacao,
  row_out.reservado_por,
  row_out.reservado_lote,
  row_out.agente_id,
  row_out.contatado,  -- ✅ NOVO: Retornar campo contatado
  p.mensagem,
  COALESCE(p.turno, 'indefinido') AS turno
FROM row_out
CROSS JOIN LATERAL jsonb_to_record($4::jsonb) AS p(
  mensagem text,
  turno     text
);
