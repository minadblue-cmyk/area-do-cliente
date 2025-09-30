-- Script para adicionar campo updated_at na tabela empresas
-- Execute este script no PostgreSQL

-- 1. Adicionar campo updated_at se não existir
ALTER TABLE empresas ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

-- 2. Criar trigger para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 3. Criar trigger na tabela empresas
DROP TRIGGER IF EXISTS update_empresas_updated_at ON empresas;
CREATE TRIGGER update_empresas_updated_at
    BEFORE UPDATE ON empresas
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 4. Verificar se foi adicionado
SELECT column_name, data_type, column_default
FROM information_schema.columns 
WHERE table_name = 'empresas' 
AND column_name = 'updated_at';
