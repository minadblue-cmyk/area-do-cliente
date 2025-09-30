-- Query SQL ajustada para o n8n após correção da tabela empresas
-- Use esta query no node PostgreSQL do n8n

INSERT INTO empresas (
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
    created_at
)
VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14,
    $15, $16, $17, $18, $19, $20, $21, CURRENT_TIMESTAMP
)
RETURNING 
    id, nome_empresa, cnpj, email, telefone, celular,
    logradouro, numero, complemento, bairro, cidade, estado, cep,
    inscricao_estadual, inscricao_municipal, regime_tributario, cnae,
    banco, agencia, conta_corrente, descricao, endereco_completo, created_at;

-- Parâmetros para o n8n:
-- $1 = {{ $json.body.nome }}
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
