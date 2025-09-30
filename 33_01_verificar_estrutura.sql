-- Script 1: Verificar estrutura atual da tabela empresas
-- Execute este script primeiro para ver o estado atual

SELECT 
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'empresas' 
ORDER BY ordinal_position;
