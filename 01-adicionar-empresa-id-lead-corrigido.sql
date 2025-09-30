-- Script 1 CORRIGIDO: Adicionar empresa_id na tabela lead
-- Baseado na estrutura real das tabelas fornecida pelo usuário

-- =====================================================
-- ANÁLISE DA ESTRUTURA ATUAL
-- =====================================================

-- ✅ usuarios já tem empresa_id
-- ❌ lead NÃO tem empresa_id (precisa adicionar)
-- ✅ empresas existe com id e nome_empresa

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
-- 2. CRIAR ÍNDICE PARA PERFORMANCE
-- =====================================================

-- Índice para lead.empresa_id
CREATE INDEX IF NOT EXISTS idx_lead_empresa_id ON lead(empresa_id);

-- =====================================================
-- 3. ADICIONAR CHAVE ESTRANGEIRA
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

-- =====================================================
-- 4. VERIFICAR ESTRUTURA FINAL
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
    AND tc.table_name = 'lead'
    AND tc.constraint_name LIKE '%empresa%';

-- =====================================================
-- 5. VERIFICAR DADOS EXISTENTES
-- =====================================================

-- Contar leads existentes
SELECT 
    COUNT(*) as total_leads,
    COUNT(empresa_id) as leads_com_empresa,
    COUNT(*) - COUNT(empresa_id) as leads_sem_empresa
FROM lead;

-- Contar usuarios por empresa
SELECT 
    e.id as empresa_id,
    e.nome_empresa,
    COUNT(u.id) as total_usuarios
FROM empresas e
LEFT JOIN usuarios u ON e.id = u.empresa_id
GROUP BY e.id, e.nome_empresa
ORDER BY total_usuarios DESC;

RAISE NOTICE 'Script 1 CORRIGIDO executado com sucesso! Estrutura básica adicionada.';
