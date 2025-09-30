-- =====================================================
-- CRIAR ÍNDICES PARA CAMPOS DE RECONTATO (COM VERIFICAÇÃO)
-- =====================================================

-- Criar índices apenas se os campos existirem e os índices não existirem

-- 1. Índice para proximo_contato_em
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'lead' 
          AND table_schema = 'public' 
          AND column_name = 'proximo_contato_em'
    ) AND NOT EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE tablename = 'lead' 
          AND schemaname = 'public' 
          AND indexname = 'idx_lead_proximo_contato'
    ) THEN
        CREATE INDEX idx_lead_proximo_contato ON public.lead(proximo_contato_em);
        RAISE NOTICE 'Índice idx_lead_proximo_contato criado';
    ELSE
        RAISE NOTICE 'Índice idx_lead_proximo_contato já existe ou campo não existe';
    END IF;
END $$;

-- 2. Índice para pode_recontatar
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'lead' 
          AND table_schema = 'public' 
          AND column_name = 'pode_recontatar'
    ) AND NOT EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE tablename = 'lead' 
          AND schemaname = 'public' 
          AND indexname = 'idx_lead_pode_recontatar'
    ) THEN
        CREATE INDEX idx_lead_pode_recontatar ON public.lead(pode_recontatar);
        RAISE NOTICE 'Índice idx_lead_pode_recontatar criado';
    ELSE
        RAISE NOTICE 'Índice idx_lead_pode_recontatar já existe ou campo não existe';
    END IF;
END $$;

-- 3. Índice para prioridade_recontato
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'lead' 
          AND table_schema = 'public' 
          AND column_name = 'prioridade_recontato'
    ) AND NOT EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE tablename = 'lead' 
          AND schemaname = 'public' 
          AND indexname = 'idx_lead_prioridade_recontato'
    ) THEN
        CREATE INDEX idx_lead_prioridade_recontato ON public.lead(prioridade_recontato);
        RAISE NOTICE 'Índice idx_lead_prioridade_recontato criado';
    ELSE
        RAISE NOTICE 'Índice idx_lead_prioridade_recontato já existe ou campo não existe';
    END IF;
END $$;
