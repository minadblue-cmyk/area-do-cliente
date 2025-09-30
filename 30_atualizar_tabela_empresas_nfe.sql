-- Script para atualizar tabela empresas com campos necessários para NF-e
-- Execute este script no PostgreSQL para adicionar os campos faltantes

-- 1. Adicionar colunas de contato
ALTER TABLE empresas ADD COLUMN IF NOT EXISTS celular VARCHAR(20);

-- 2. Adicionar colunas de endereço completo
ALTER TABLE empresas ADD COLUMN IF NOT EXISTS logradouro VARCHAR(255);
ALTER TABLE empresas ADD COLUMN IF NOT EXISTS numero VARCHAR(20);
ALTER TABLE empresas ADD COLUMN IF NOT EXISTS complemento VARCHAR(100);
ALTER TABLE empresas ADD COLUMN IF NOT EXISTS bairro VARCHAR(100);
ALTER TABLE empresas ADD COLUMN IF NOT EXISTS cidade VARCHAR(100);
ALTER TABLE empresas ADD COLUMN IF NOT EXISTS estado VARCHAR(2);
ALTER TABLE empresas ADD COLUMN IF NOT EXISTS cep VARCHAR(10);

-- 3. Adicionar colunas fiscais
ALTER TABLE empresas ADD COLUMN IF NOT EXISTS inscricao_estadual VARCHAR(20);
ALTER TABLE empresas ADD COLUMN IF NOT EXISTS inscricao_municipal VARCHAR(20);
ALTER TABLE empresas ADD COLUMN IF NOT EXISTS regime_tributario VARCHAR(50);
ALTER TABLE empresas ADD COLUMN IF NOT EXISTS cnae VARCHAR(20);

-- 4. Adicionar colunas bancárias
ALTER TABLE empresas ADD COLUMN IF NOT EXISTS banco VARCHAR(100);
ALTER TABLE empresas ADD COLUMN IF NOT EXISTS agencia VARCHAR(20);
ALTER TABLE empresas ADD COLUMN IF NOT EXISTS conta_corrente VARCHAR(20);

-- 5. Adicionar comentários para documentação
COMMENT ON COLUMN empresas.celular IS 'Número de celular da empresa';
COMMENT ON COLUMN empresas.logradouro IS 'Logradouro (rua, avenida, etc.)';
COMMENT ON COLUMN empresas.numero IS 'Número do endereço';
COMMENT ON COLUMN empresas.complemento IS 'Complemento do endereço (sala, andar, etc.)';
COMMENT ON COLUMN empresas.bairro IS 'Bairro da empresa';
COMMENT ON COLUMN empresas.cidade IS 'Cidade da empresa';
COMMENT ON COLUMN empresas.estado IS 'Estado (UF) da empresa';
COMMENT ON COLUMN empresas.cep IS 'CEP da empresa';
COMMENT ON COLUMN empresas.inscricao_estadual IS 'Inscrição Estadual (IE)';
COMMENT ON COLUMN empresas.inscricao_municipal IS 'Inscrição Municipal (IM)';
COMMENT ON COLUMN empresas.regime_tributario IS 'Regime Tributário';
COMMENT ON COLUMN empresas.cnae IS 'Código de Atividade Econômica';
COMMENT ON COLUMN empresas.banco IS 'Nome do banco';
COMMENT ON COLUMN empresas.agencia IS 'Número da agência';
COMMENT ON COLUMN empresas.conta_corrente IS 'Número da conta corrente';

-- 6. Verificar se as colunas foram criadas
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'empresas' 
ORDER BY ordinal_position;
