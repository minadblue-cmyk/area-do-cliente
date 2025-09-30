-- Análise da estrutura atual das tabelas para isolamento por empresa
-- Verificar relacionamentos entre leads, empresas, usuários e permissões

-- 1. Estrutura da tabela leads
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'lead' 
ORDER BY ordinal_position;

-- 2. Estrutura da tabela empresas
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'empresas' 
ORDER BY ordinal_position;

-- 3. Estrutura da tabela usuarios
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'usuarios' 
ORDER BY ordinal_position;

-- 4. Estrutura da tabela perfil
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'perfil' 
ORDER BY ordinal_position;

-- 5. Verificar se já existe relacionamento entre usuarios e empresas
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'usuarios' 
AND column_name LIKE '%empresa%'
ORDER BY ordinal_position;

-- 6. Verificar se já existe relacionamento entre leads e empresas
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'lead' 
AND column_name LIKE '%empresa%'
ORDER BY ordinal_position;
