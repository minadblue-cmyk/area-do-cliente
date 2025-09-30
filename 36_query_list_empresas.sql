-- Query SQL para listar empresas no n8n
-- Use esta query no node PostgreSQL do n8n para listagem

SELECT 
    id,
    nome_empresa,
    cnpj,
    email,
    telefone,
    celular,
    logradouro,
    numero,
    complemento,
    bairro,
    cidade,
    estado,
    cep,
    inscricao_estadual,
    inscricao_municipal,
    regime_tributario,
    cnae,
    banco,
    agencia,
    conta_corrente,
    descricao,
    endereco_completo,
    created_at,
    updated_at
FROM empresas 
ORDER BY nome_empresa ASC;

-- Para buscar empresa específica por ID:
-- WHERE id = $1
-- Parâmetro: $1 = {{ $json.body.id }}
