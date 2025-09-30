-- =====================================================
-- QUERY PARA BUSCAR LEADS AGENDADOS PARA RECONTATO
-- =====================================================

-- Query para buscar leads agendados para recontato
-- Esta query deve ser usada no n8n para substituir a query atual de "Buscar o lote reservado"
-- quando estiver executando uma campanha de recontato

SELECT
  l.id, 
  l.client_id, 
  l.nome_cliente, 
  l.telefone, 
  l.canal,
  l.status, 
  l.data_ultima_interacao, 
  l.reservado_por, 
  l.reservado_lote,
  l.agente_id, 
  l.contatado,
  l.proximo_contato_em,
  l.observacoes_recontato,
  l.prioridade_recontato,
  l.agendado_por_usuario_id,
  l.permissoes_acesso
FROM public.lead l
WHERE l.contatado = true
  AND l.pode_recontatar = true
  AND l.proximo_contato_em IS NOT NULL
  AND l.proximo_contato_em <= NOW()
  AND (
    l.permissoes_acesso->'usuarios_permitidos' @> $1::jsonb
    OR
    l.permissoes_acesso->'perfis_permitidos' @> $2::jsonb
    OR
    l.agente_id = $3
  )
ORDER BY 
  l.prioridade_recontato DESC,  -- Prioridade alta primeiro
  l.proximo_contato_em ASC,     -- Mais antigo primeiro
  l.id ASC
LIMIT 20;

-- Parâmetros esperados:
-- $1: JSON array com IDs dos usuários permitidos
-- $2: JSON array com IDs dos perfis permitidos  
-- $3: ID do agente atual
