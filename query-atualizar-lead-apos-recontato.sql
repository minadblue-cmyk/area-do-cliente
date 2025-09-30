-- =====================================================
-- QUERY PARA ATUALIZAR LEAD APÓS RECONTATO
-- =====================================================

-- Query para atualizar o lead após um recontato
-- Esta query deve ser usada no n8n para atualizar o status após o recontato

WITH upd AS (
  UPDATE public.lead AS l
  SET
    status                = 'prospectando',
    data_ultima_interacao = NOW(),
    agente_id             = $5,
    proximo_contato_em    = NULL,  -- Limpa o agendamento
    observacoes_recontato = $6,    -- Observações do recontato
    agendado_por_usuario_id = NULL -- Limpa quem agendou
  WHERE l.id = $1
    AND l.reservado_por  = $2
    AND l.reservado_lote = $3
  RETURNING
    l.id, l.client_id, l.nome_cliente, l.telefone, l.canal,
    l.status, l.data_ultima_interacao, l.reservado_por, l.reservado_lote,
    l.agente_id, l.contatado, l.proximo_contato_em, l.observacoes_recontato
),
fb AS (
  SELECT
    l.id, l.client_id, l.nome_cliente, l.telefone, l.canal,
    l.status, l.data_ultima_interacao, l.reservado_por, l.reservado_lote,
    l.agente_id, l.contatado, l.proximo_contato_em, l.observacoes_recontato
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
  row_out.contatado,
  row_out.proximo_contato_em,
  row_out.observacoes_recontato,
  p.mensagem,
  COALESCE(p.turno, 'indefinido') AS turno
FROM row_out
CROSS JOIN LATERAL jsonb_to_record($4::jsonb) AS p(
  mensagem text,
  turno     text
);

-- Parâmetros esperados:
-- $1: ID do lead
-- $2: reservado_por
-- $3: reservado_lote  
-- $4: JSON com mensagem e turno
-- $5: agente_id
-- $6: observações do recontato
