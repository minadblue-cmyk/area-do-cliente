# 🔧 Query Parameters para Insert Lead no n8n

## 📋 **Configuração dos Parâmetros**

### **1. Clique em "Add option" na seção "Query Parameters"**

### **2. Adicione os seguintes parâmetros na ordem exata:**

#### **Parâmetro 1: usuario_id**
- **Name:** `usuario_id`
- **Value:** `={{ $json.agente_id }}`
- **Description:** ID do usuário que está fazendo o upload

#### **Parâmetro 2: nome**
- **Name:** `nome`
- **Value:** `={{ $json.nome }}`
- **Description:** Nome do lead

#### **Parâmetro 3: telefone**
- **Name:** `telefone`
- **Value:** `={{ $json.telefone }}`
- **Description:** Telefone do lead

#### **Parâmetro 4: email**
- **Name:** `email`
- **Value:** `={{ $json.email || '' }}`
- **Description:** Email do lead (opcional)

#### **Parâmetro 5: profissao**
- **Name:** `profissao`
- **Value:** `={{ $json.profissao }}`
- **Description:** Profissão do lead

#### **Parâmetro 6: idade**
- **Name:** `idade`
- **Value:** `={{ $json.idade }}`
- **Description:** Idade do lead

#### **Parâmetro 7: estado_civil**
- **Name:** `estado_civil`
- **Value:** `={{ $json.estado_civil }}`
- **Description:** Estado civil do lead

#### **Parâmetro 8: filhos**
- **Name:** `filhos`
- **Value:** `={{ $json.filhos }}`
- **Description:** Se tem filhos (boolean)

#### **Parâmetro 9: qtd_filhos**
- **Name:** `qtd_filhos`
- **Value:** `={{ $json.qtd_filhos }}`
- **Description:** Quantidade de filhos

#### **Parâmetro 10: fonte_prospec**
- **Name:** `fonte_prospec`
- **Value:** `={{ $json.fonte_prospec }}`
- **Description:** Fonte da prospecção

## 📝 **Query SQL Completa:**

```sql
-- Query para inserir leads com isolamento por empresa
-- Usar no nó "Insert Lead" do workflow de upload
-- IMPORTANTE: Definir usuário atual antes da query
SELECT set_current_user_id($1); -- $1 = usuario_id

INSERT INTO lead (
    nome,
    telefone,
    email,
    status,
    profissao,
    idade,
    estado_civil,
    filhos,
    qtd_filhos,
    fonte_prospec,
    empresa_id,
    usuario_id,
    contatado,
    created_at,
    updated_at
) VALUES (
    $2,  -- nome
    $3,  -- telefone
    $4,  -- email
    'novo',  -- status padrão
    $5,  -- profissao
    $6,  -- idade
    $7,  -- estado_civil
    $8,  -- filhos
    $9,  -- qtd_filhos
    $10, -- fonte_prospec
    (SELECT empresa_id FROM usuarios WHERE id = $1), -- empresa_id do usuário
    $1,  -- usuario_id
    false, -- contatado
    NOW(), -- created_at
    NOW()  -- updated_at
)
ON CONFLICT (empresa_id, telefone) DO UPDATE SET
    nome = EXCLUDED.nome,
    email = EXCLUDED.email,
    profissao = EXCLUDED.profissao,
    idade = EXCLUDED.idade,
    estado_civil = EXCLUDED.estado_civil,
    filhos = EXCLUDED.filhos,
    qtd_filhos = EXCLUDED.qtd_filhos,
    fonte_prospec = EXCLUDED.fonte_prospec,
    updated_at = NOW()
RETURNING id, empresa_id;
```

## 🧪 **Dados de Teste:**

```json
{
  "agente_id": 81,
  "nome": "Roger Macedo da Silva",
  "telefone": "5551984033242",
  "email": "roger@exemplo.com",
  "profissao": "Analista de Suporte",
  "idade": 40,
  "estado_civil": "Casado",
  "filhos": true,
  "qtd_filhos": 2,
  "fonte_prospec": "Márcio André"
}
```

## ⚠️ **Importante:**

1. **Ordem dos parâmetros** deve ser exatamente como mostrado
2. **usuario_id** deve ser o primeiro parâmetro (usado para definir usuário atual)
3. **Email** é opcional, por isso usamos `|| ''` para evitar erros
4. **empresa_id** é obtido automaticamente do usuário
5. **status** é sempre 'novo' para novos leads
6. **contatado** é sempre false para novos leads

## ✅ **Resultado Esperado:**

- Lead inserido com sucesso
- `empresa_id` definido automaticamente baseado no `usuario_id`
- Isolamento por empresa funcionando
- Mesmo telefone permitido em empresas diferentes
- Retorno do `id` e `empresa_id` do lead criado

## 🔍 **Mapeamento dos Parâmetros:**

| Parâmetro | Valor n8n | Campo SQL | Descrição |
|-----------|------------|-----------|-----------|
| $1 | `{{ $json.agente_id }}` | usuario_id | ID do usuário |
| $2 | `{{ $json.nome }}` | nome | Nome do lead |
| $3 | `{{ $json.telefone }}` | telefone | Telefone do lead |
| $4 | `{{ $json.email \|\| '' }}` | email | Email do lead |
| $5 | `{{ $json.profissao }}` | profissao | Profissão do lead |
| $6 | `{{ $json.idade }}` | idade | Idade do lead |
| $7 | `{{ $json.estado_civil }}` | estado_civil | Estado civil |
| $8 | `{{ $json.filhos }}` | filhos | Tem filhos |
| $9 | `{{ $json.qtd_filhos }}` | qtd_filhos | Quantidade de filhos |
| $10 | `{{ $json.fonte_prospec }}` | fonte_prospec | Fonte da prospecção |
