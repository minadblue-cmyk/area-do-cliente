-- ✅ QUERY CORRIGIDA PARA UPLOAD DE LEADS
-- Inclui agente_id no INSERT e UPDATE

INSERT INTO public.lead (
  telefone, nome, canal, estagio_funnel, pergunta_index,
  data_criacao, data_ultima_interacao, client_id,
  nome_cliente, fonte_prospec, idade, profissao, estado_civil,
  filhos, qtd_filhos, data_insercao, status, agente_id  -- ✅ ADICIONADO
)
VALUES (
  $1,                               -- telefone
  $2,                               -- nome
  COALESCE($3,'whatsapp'),          -- canal
  COALESCE($4,'topo'),              -- estagio_funnel
  COALESCE($5,0),                   -- pergunta_index
  COALESCE($6::timestamp, now()),   -- data_criacao       (CAST)
  COALESCE($7::timestamp, now()),   -- data_ultima_interacao (CAST)
  $8,                               -- client_id
  $9,                               -- nome_cliente
  $10,                              -- fonte_prospec
  $11,                              -- idade
  $12,                              -- profissao
  $13,                              -- estado_civil
  $14,                              -- filhos
  $15,                              -- qtd_filhos
  COALESCE($16::timestamp, $6::timestamp, now()), -- data_insercao (CAST)
  COALESCE($17, 'novo'),            -- status
  $18                               -- agente_id          -- ✅ ADICIONADO
)
ON CONFLICT (telefone, client_id) DO UPDATE
SET
  nome                  = COALESCE(EXCLUDED.nome,                  lead.nome),
  canal                 = COALESCE(EXCLUDED.canal,                 lead.canal),
  estagio_funnel        = COALESCE(EXCLUDED.estagio_funnel,        lead.estagio_funnel),
  pergunta_index        = COALESCE(EXCLUDED.pergunta_index,        lead.pergunta_index),
  data_ultima_interacao = GREATEST(
                            lead.data_ultima_interacao,
                            COALESCE(EXCLUDED.data_ultima_interacao, lead.data_ultima_interacao)
                          ),
  client_id             = COALESCE(EXCLUDED.client_id,             lead.client_id),
  nome_cliente          = COALESCE(EXCLUDED.nome_cliente,          lead.nome_cliente),
  fonte_prospec         = COALESCE(EXCLUDED.fonte_prospec,         lead.fonte_prospec),
  idade                 = COALESCE(EXCLUDED.idade,                 lead.idade),
  profissao             = COALESCE(EXCLUDED.profissao,             lead.profissao),
  estado_civil          = COALESCE(EXCLUDED.estado_civil,          lead.estado_civil),
  filhos                = COALESCE(EXCLUDED.filhos,                lead.filhos),
  qtd_filhos            = COALESCE(EXCLUDED.qtd_filhos,            lead.qtd_filhos),
  data_insercao         = COALESCE(EXCLUDED.data_insercao,         lead.data_insercao),
  status                = COALESCE(EXCLUDED.status,                lead.status),
  agente_id             = COALESCE(EXCLUDED.agente_id,             lead.agente_id)  -- ✅ ADICIONADO
RETURNING *;
