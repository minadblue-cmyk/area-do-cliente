-- Script 1: Adicionar empresa_id nas tabelas leads e usuarios
-- Executar este script primeiro para adicionar a estrutura básica

-- =====================================================
-- 1. ADICIONAR EMPRESA_ID NA TABELA LEAD
-- =====================================================

-- Verificar se a coluna já existe
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'lead' AND column_name = 'empresa_id'
    ) THEN
        -- Adicionar coluna empresa_id
        ALTER TABLE lead ADD COLUMN empresa_id INTEGER;
        
        -- Adicionar comentário
        COMMENT ON COLUMN lead.empresa_id IS 'ID da empresa proprietária do lead';
        
        RAISE NOTICE 'Coluna empresa_id adicionada na tabela lead';
    ELSE
        RAISE NOTICE 'Coluna empresa_id já existe na tabela lead';
    END IF;
END $$;

-- =====================================================
-- 2. ADICIONAR EMPRESA_ID NA TABELA USUARIOS
-- =====================================================

-- Verificar se a coluna já existe
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'usuarios' AND column_name = 'empresa_id'
    ) THEN
        -- Adicionar coluna empresa_id
        ALTER TABLE usuarios ADD COLUMN empresa_id INTEGER;
        
        -- Adicionar comentário
        COMMENT ON COLUMN usuarios.empresa_id IS 'ID da empresa do usuário';
        
        RAISE NOTICE 'Coluna empresa_id adicionada na tabela usuarios';
    ELSE
        RAISE NOTICE 'Coluna empresa_id já existe na tabela usuarios';
    END IF;
END $$;

-- =====================================================
-- 3. CRIAR ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índice para lead.empresa_id
CREATE INDEX IF NOT EXISTS idx_lead_empresa_id ON lead(empresa_id);

-- Índice para usuarios.empresa_id
CREATE INDEX IF NOT EXISTS idx_usuarios_empresa_id ON usuarios(empresa_id);

-- =====================================================
-- 4. ADICIONAR CHAVES ESTRANGEIRAS
-- =====================================================

-- Chave estrangeira para lead.empresa_id
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'fk_lead_empresa'
    ) THEN
        ALTER TABLE lead ADD CONSTRAINT fk_lead_empresa 
        FOREIGN KEY (empresa_id) REFERENCES empresas(id);
        
        RAISE NOTICE 'Chave estrangeira fk_lead_empresa adicionada';
    ELSE
        RAISE NOTICE 'Chave estrangeira fk_lead_empresa já existe';
    END IF;
END $$;

-- Chave estrangeira para usuarios.empresa_id
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'fk_usuarios_empresa'
    ) THEN
        ALTER TABLE usuarios ADD CONSTRAINT fk_usuarios_empresa 
        FOREIGN KEY (empresa_id) REFERENCES empresas(id);
        
        RAISE NOTICE 'Chave estrangeira fk_usuarios_empresa adicionada';
    ELSE
        RAISE NOTICE 'Chave estrangeira fk_usuarios_empresa já existe';
    END IF;
END $$;

-- =====================================================
-- 5. VERIFICAR ESTRUTURA FINAL
-- =====================================================

-- Mostrar estrutura da tabela lead
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'lead' 
ORDER BY ordinal_position;

-- Mostrar estrutura da tabela usuarios
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'usuarios' 
ORDER BY ordinal_position;

-- Mostrar chaves estrangeiras criadas
SELECT 
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_name IN ('lead', 'usuarios')
    AND tc.constraint_name LIKE '%empresa%';

RAISE NOTICE 'Script 1 executado com sucesso! Estrutura básica adicionada.';
