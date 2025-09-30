-- Script 7: Verificar estrutura final da tabela
-- Execute este script para confirmar que tudo foi corrigido

-- Verificar estrutura completa da tabela
SELECT 
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'empresas' 
ORDER BY ordinal_position;

-- Verificar dados de exemplo
SELECT 
    id,
    nome_empresa,
    logradouro,
    numero,
    complemento,
    bairro,
    cidade,
    estado,
    cep,
    endereco_completo
FROM empresas 
LIMIT 5;
