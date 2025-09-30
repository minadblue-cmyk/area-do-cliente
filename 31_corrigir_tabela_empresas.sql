-- Script para corrigir campos duplicados e conflitantes na tabela empresas
-- Execute este script no PostgreSQL para reorganizar a estrutura

-- 1. Verificar estrutura atual da tabela
SELECT 
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'empresas' 
ORDER BY ordinal_position;

-- 2. Backup dos dados existentes (opcional)
-- CREATE TABLE empresas_backup AS SELECT * FROM empresas;

-- 3. Remover campo 'endereco' genérico (se existir)
-- ALTER TABLE empresas DROP COLUMN IF EXISTS endereco;

-- 4. Ajustar tamanhos dos campos para evitar erros de VARCHAR
ALTER TABLE empresas ALTER COLUMN estado TYPE VARCHAR(2);
ALTER TABLE empresas ALTER COLUMN cep TYPE VARCHAR(10);
ALTER TABLE empresas ALTER COLUMN telefone TYPE VARCHAR(20);
ALTER TABLE empresas ALTER COLUMN celular TYPE VARCHAR(20);
ALTER TABLE empresas ALTER COLUMN numero TYPE VARCHAR(20);
ALTER TABLE empresas ALTER COLUMN complemento TYPE VARCHAR(100);
ALTER TABLE empresas ALTER COLUMN bairro TYPE VARCHAR(100);
ALTER TABLE empresas ALTER COLUMN cidade TYPE VARCHAR(100);
ALTER TABLE empresas ALTER COLUMN inscricao_estadual TYPE VARCHAR(20);
ALTER TABLE empresas ALTER COLUMN inscricao_municipal TYPE VARCHAR(20);
ALTER TABLE empresas ALTER COLUMN regime_tributario TYPE VARCHAR(50);
ALTER TABLE empresas ALTER COLUMN cnae TYPE VARCHAR(20);
ALTER TABLE empresas ALTER COLUMN banco TYPE VARCHAR(100);
ALTER TABLE empresas ALTER COLUMN agencia TYPE VARCHAR(20);
ALTER TABLE empresas ALTER COLUMN conta_corrente TYPE VARCHAR(20);

-- 5. Adicionar campo 'endereco_completo' para armazenar endereço formatado
ALTER TABLE empresas ADD COLUMN IF NOT EXISTS endereco_completo TEXT;

-- 6. Atualizar campo 'endereco_completo' com dados existentes
UPDATE empresas SET endereco_completo = 
    CASE 
        WHEN logradouro IS NOT NULL AND numero IS NOT NULL THEN
            CONCAT(
                COALESCE(logradouro, ''),
                CASE WHEN numero IS NOT NULL THEN CONCAT(', ', numero) ELSE '' END,
                CASE WHEN complemento IS NOT NULL THEN CONCAT(', ', complemento) ELSE '' END,
                CASE WHEN bairro IS NOT NULL THEN CONCAT(' - ', bairro) ELSE '' END,
                CASE WHEN cidade IS NOT NULL THEN CONCAT(', ', cidade) ELSE '' END,
                CASE WHEN estado IS NOT NULL THEN CONCAT('/', estado) ELSE '' END,
                CASE WHEN cep IS NOT NULL THEN CONCAT(' - CEP: ', cep) ELSE '' END
            )
        ELSE NULL
    END
WHERE endereco_completo IS NULL;

-- 7. Adicionar comentários para documentação
COMMENT ON COLUMN empresas.endereco_completo IS 'Endereço completo formatado para exibição';
COMMENT ON COLUMN empresas.logradouro IS 'Nome da rua/avenida (sem número)';
COMMENT ON COLUMN empresas.numero IS 'Número do endereço';
COMMENT ON COLUMN empresas.complemento IS 'Complemento do endereço (sala, andar, etc.)';
COMMENT ON COLUMN empresas.bairro IS 'Bairro da empresa';
COMMENT ON COLUMN empresas.cidade IS 'Cidade da empresa';
COMMENT ON COLUMN empresas.estado IS 'Estado (UF) - máximo 2 caracteres';
COMMENT ON COLUMN empresas.cep IS 'CEP da empresa';

-- 8. Verificar estrutura final da tabela
SELECT 
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'empresas' 
ORDER BY ordinal_position;

-- 9. Verificar dados atualizados
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
