-- Script 3: Remover campo 'endereco' genérico
-- Execute este script para remover o campo conflitante

-- Verificar se o campo 'endereco' existe
SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'empresas' 
AND column_name = 'endereco';

-- Remover o campo 'endereco' se existir
ALTER TABLE empresas DROP COLUMN IF EXISTS endereco;

-- Verificar se foi removido
SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'empresas' 
AND column_name = 'endereco';
