-- =====================================================
-- ADICIONAR COMENTÁRIOS PARA CAMPOS DE RECONTATO
-- =====================================================

-- Adicionar comentários apenas se os campos existirem

-- Comentário para proximo_contato_em
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'lead' 
          AND table_schema = 'public' 
          AND column_name = 'proximo_contato_em'
    ) THEN
        COMMENT ON COLUMN public.lead.proximo_contato_em IS 'Data e hora agendada para o próximo contato';
        RAISE NOTICE 'Comentário adicionado para proximo_contato_em';
    END IF;
END $$;

-- Comentário para pode_recontatar
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'lead' 
          AND table_schema = 'public' 
          AND column_name = 'pode_recontatar'
    ) THEN
        COMMENT ON COLUMN public.lead.pode_recontatar IS 'Se o lead pode ser recontatado';
        RAISE NOTICE 'Comentário adicionado para pode_recontatar';
    END IF;
END $$;

-- Comentário para observacoes_recontato
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'lead' 
          AND table_schema = 'public' 
          AND column_name = 'observacoes_recontato'
    ) THEN
        COMMENT ON COLUMN public.lead.observacoes_recontato IS 'Observações sobre o recontato';
        RAISE NOTICE 'Comentário adicionado para observacoes_recontato';
    END IF;
END $$;

-- Comentário para prioridade_recontato
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'lead' 
          AND table_schema = 'public' 
          AND column_name = 'prioridade_recontato'
    ) THEN
        COMMENT ON COLUMN public.lead.prioridade_recontato IS 'Prioridade do recontato: 1=baixa, 2=média, 3=alta';
        RAISE NOTICE 'Comentário adicionado para prioridade_recontato';
    END IF;
END $$;

-- Comentário para agendado_por_usuario_id
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'lead' 
          AND table_schema = 'public' 
          AND column_name = 'agendado_por_usuario_id'
    ) THEN
        COMMENT ON COLUMN public.lead.agendado_por_usuario_id IS 'ID do usuário que agendou o recontato';
        RAISE NOTICE 'Comentário adicionado para agendado_por_usuario_id';
    END IF;
END $$;

-- Comentário para data_agendamento
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'lead' 
          AND table_schema = 'public' 
          AND column_name = 'data_agendamento'
    ) THEN
        COMMENT ON COLUMN public.lead.data_agendamento IS 'Data em que o recontato foi agendado';
        RAISE NOTICE 'Comentário adicionado para data_agendamento';
    END IF;
END $$;
