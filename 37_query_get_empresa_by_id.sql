-- Query SQL para buscar empresa por ID no n8n
-- Use esta query no node PostgreSQL do n8n para buscar empresa específica

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
WHERE id = $1;

-- Parâmetro: $1 = {{ $json.body.id }}
