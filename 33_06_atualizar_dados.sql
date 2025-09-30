-- Script 6: Atualizar campo endereco_completo com dados existentes
-- Execute este script para popular o campo endereco_completo

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

-- Verificar quantos registros foram atualizados
SELECT COUNT(*) as registros_atualizados FROM empresas WHERE endereco_completo IS NOT NULL;
