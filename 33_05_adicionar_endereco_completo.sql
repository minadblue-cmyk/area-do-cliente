-- Script 5: Adicionar campo 'endereco_completo'
-- Execute este script para adicionar o campo de endereço formatado

-- Adicionar campo endereco_completo
ALTER TABLE empresas ADD COLUMN IF NOT EXISTS endereco_completo TEXT;

-- Verificar se foi adicionado
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'empresas' 
AND column_name = 'endereco_completo';
