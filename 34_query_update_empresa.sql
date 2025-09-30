-- Query SQL para atualização de empresas no n8n
-- Use esta query no node PostgreSQL do n8n para edição

UPDATE empresas SET
    nome_empresa = $1,
    cnpj = $2,
    email = $3,
    telefone = $4,
    celular = $5,
    logradouro = $6,
    numero = $7,
    complemento = $8,
    bairro = $9,
    cidade = $10,
    estado = $11,
    cep = $12,
    inscricao_estadual = $13,
    inscricao_municipal = $14,
    regime_tributario = $15,
    cnae = $16,
    banco = $17,
    agencia = $18,
    conta_corrente = $19,
    descricao = $20,
    endereco_completo = $21,
    updated_at = CURRENT_TIMESTAMP
WHERE id = $22
RETURNING 
    id, nome_empresa, cnpj, email, telefone, celular,
    logradouro, numero, complemento, bairro, cidade, estado, cep,
    inscricao_estadual, inscricao_municipal, regime_tributario, cnae,
    banco, agencia, conta_corrente, descricao, endereco_completo, 
    created_at, updated_at;

-- Parâmetros para o n8n:
-- $1 = {{ $json.body.nome_empresa }}
-- $2 = {{ $json.body.cnpj }}
-- $3 = {{ $json.body.email }}
-- $4 = {{ $json.body.telefone }}
-- $5 = {{ $json.body.celular }}
-- $6 = {{ $json.body.logradouro }}
-- $7 = {{ $json.body.numero }}
-- $8 = {{ $json.body.complemento }}
-- $9 = {{ $json.body.bairro }}
-- $10 = {{ $json.body.cidade }}
-- $11 = {{ $json.body.estado }}
-- $12 = {{ $json.body.cep }}
-- $13 = {{ $json.body.inscricao_estadual }}
-- $14 = {{ $json.body.inscricao_municipal }}
-- $15 = {{ $json.body.regime_tributario }}
-- $16 = {{ $json.body.cnae }}
-- $17 = {{ $json.body.banco }}
-- $18 = {{ $json.body.agencia }}
-- $19 = {{ $json.body.conta_corrente }}
-- $20 = {{ $json.body.descricao }}
-- $21 = {{ $json.body.logradouro }}, {{ $json.body.numero }}{{ $json.body.complemento ? ', ' + $json.body.complemento : '' }} - {{ $json.body.bairro }}, {{ $json.body.cidade }}/{{ $json.body.estado }} - CEP: {{ $json.body.cep }}
-- $22 = {{ $json.body.id }}
