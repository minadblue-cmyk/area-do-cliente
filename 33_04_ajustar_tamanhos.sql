-- Script 4: Ajustar tamanhos dos campos VARCHAR
-- Execute este script para corrigir os tamanhos dos campos

-- Ajustar campo estado (crítico para o erro VARCHAR(2))
ALTER TABLE empresas ALTER COLUMN estado TYPE VARCHAR(2);

-- Ajustar outros campos importantes
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

-- Verificar se os ajustes foram aplicados
SELECT 
    column_name,
    data_type,
    character_maximum_length
FROM information_schema.columns 
WHERE table_name = 'empresas' 
AND column_name IN ('estado', 'cep', 'telefone', 'celular', 'numero', 'complemento', 'bairro', 'cidade')
ORDER BY column_name;
