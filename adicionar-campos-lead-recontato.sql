-- =====================================================
-- ADICIONAR CAMPOS DE RECONTATO NA TABELA LEAD
-- =====================================================

-- 1. Adicionar campos para controle de recontato na tabela lead
ALTER TABLE public.lead 
ADD COLUMN proximo_contato_em TIMESTAMP NULL,
ADD COLUMN pode_recontatar BOOLEAN DEFAULT true,
ADD COLUMN observacoes_recontato TEXT,
ADD COLUMN prioridade_recontato INTEGER DEFAULT 1 CHECK (prioridade_recontato IN (1, 2, 3)),
ADD COLUMN agendado_por_usuario_id INTEGER,
ADD COLUMN data_agendamento TIMESTAMP;

-- 2. Criar índices para melhor performance
CREATE INDEX idx_lead_proximo_contato ON public.lead(proximo_contato_em);
CREATE INDEX idx_lead_pode_recontatar ON public.lead(pode_recontatar);
CREATE INDEX idx_lead_prioridade_recontato ON public.lead(prioridade_recontato);

-- 3. Comentários para documentação
COMMENT ON COLUMN public.lead.proximo_contato_em IS 'Data e hora agendada para o próximo contato';
COMMENT ON COLUMN public.lead.pode_recontatar IS 'Se o lead pode ser recontatado';
COMMENT ON COLUMN public.lead.observacoes_recontato IS 'Observações sobre o recontato';
COMMENT ON COLUMN public.lead.prioridade_recontato IS 'Prioridade do recontato: 1=baixa, 2=média, 3=alta';
COMMENT ON COLUMN public.lead.agendado_por_usuario_id IS 'ID do usuário que agendou o recontato';
COMMENT ON COLUMN public.lead.data_agendamento IS 'Data em que o recontato foi agendado';
