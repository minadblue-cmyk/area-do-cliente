-- =====================================================
-- CORRIGIR TABELA LEAD - ADICIONAR CHAVE PRIMÁRIA
-- =====================================================

-- 1. Primeiro, verificar se a tabela lead já tem chave primária
-- SELECT constraint_name, constraint_type 
-- FROM information_schema.table_constraints 
-- WHERE table_name = 'lead' AND constraint_type = 'PRIMARY KEY';

-- 2. Se não tiver chave primária, adicionar uma
-- Opção 1: Se a coluna 'id' já existe e é única
ALTER TABLE public.lead ADD CONSTRAINT pk_lead PRIMARY KEY (id);

-- 3. Se a coluna 'id' não existir, criar uma
-- ALTER TABLE public.lead ADD COLUMN id SERIAL PRIMARY KEY;

-- 4. Verificar se a chave primária foi criada
-- SELECT constraint_name, constraint_type 
-- FROM information_schema.table_constraints 
-- WHERE table_name = 'lead' AND constraint_type = 'PRIMARY KEY';