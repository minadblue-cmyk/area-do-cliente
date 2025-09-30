-- Script para verificar se a tabela agentes_config existe
-- Execute este script para diagnosticar problemas

-- 1. Verificar se a tabela existe
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name = 'agentes_config'
        ) 
        THEN 'Tabela agentes_config EXISTE' 
        ELSE 'Tabela agentes_config NÃO EXISTE' 
    END as status_tabela;

-- 2. Se existir, mostrar estrutura
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'agentes_config' 
ORDER BY ordinal_position;

-- 3. Se existir, contar registros
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name = 'agentes_config'
        ) 
        THEN (SELECT COUNT(*) FROM agentes_config)
        ELSE 0 
    END as total_registros;

-- 4. Listar todas as tabelas do schema public
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
