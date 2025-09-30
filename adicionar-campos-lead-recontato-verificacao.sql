-- =====================================================
-- ADICIONAR CAMPOS DE RECONTATO NA TABELA LEAD (COM VERIFICAÇÃO)
-- =====================================================

-- Este script adiciona apenas os campos que ainda não existem
-- Execute primeiro: verificar-campos-lead-existentes.sql

-- 1. Adicionar campo proximo_contato_em (se não existir)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'lead' 
          AND table_schema = 'public' 
          AND column_name = 'proximo_contato_em'
    ) THEN
        ALTER TABLE public.lead ADD COLUMN proximo_contato_em TIMESTAMP NULL;
        RAISE NOTICE 'Campo proximo_contato_em adicionado';
    ELSE
        RAISE NOTICE 'Campo proximo_contato_em já existe';
    END IF;
END $$;

-- 2. Adicionar campo pode_recontatar (se não existir)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'lead' 
          AND table_schema = 'public' 
          AND column_name = 'pode_recontatar'
    ) THEN
        ALTER TABLE public.lead ADD COLUMN pode_recontatar BOOLEAN DEFAULT true;
        RAISE NOTICE 'Campo pode_recontatar adicionado';
    ELSE
        RAISE NOTICE 'Campo pode_recontatar já existe';
    END IF;
END $$;

-- 3. Adicionar campo observacoes_recontato (se não existir)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'lead' 
          AND table_schema = 'public' 
          AND column_name = 'observacoes_recontato'
    ) THEN
        ALTER TABLE public.lead ADD COLUMN observacoes_recontato TEXT;
        RAISE NOTICE 'Campo observacoes_recontato adicionado';
    ELSE
        RAISE NOTICE 'Campo observacoes_recontato já existe';
    END IF;
END $$;

-- 4. Adicionar campo prioridade_recontato (se não existir)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'lead' 
          AND table_schema = 'public' 
          AND column_name = 'prioridade_recontato'
    ) THEN
        ALTER TABLE public.lead ADD COLUMN prioridade_recontato INTEGER DEFAULT 1 CHECK (prioridade_recontato IN (1, 2, 3));
        RAISE NOTICE 'Campo prioridade_recontato adicionado';
    ELSE
        RAISE NOTICE 'Campo prioridade_recontato já existe';
    END IF;
END $$;

-- 5. Adicionar campo agendado_por_usuario_id (se não existir)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'lead' 
          AND table_schema = 'public' 
          AND column_name = 'agendado_por_usuario_id'
    ) THEN
        ALTER TABLE public.lead ADD COLUMN agendado_por_usuario_id INTEGER;
        RAISE NOTICE 'Campo agendado_por_usuario_id adicionado';
    ELSE
        RAISE NOTICE 'Campo agendado_por_usuario_id já existe';
    END IF;
END $$;

-- 6. Adicionar campo data_agendamento (se não existir)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'lead' 
          AND table_schema = 'public' 
          AND column_name = 'data_agendamento'
    ) THEN
        ALTER TABLE public.lead ADD COLUMN data_agendamento TIMESTAMP;
        RAISE NOTICE 'Campo data_agendamento adicionado';
    ELSE
        RAISE NOTICE 'Campo data_agendamento já existe';
    END IF;
END $$;
