# 🔧 Configuração de Query Parameters no n8n

## 📋 Query Parameters para Insert Lead

### **Configuração no n8n:**

1. **Clique em "Add option"** na seção "Query Parameters"
2. **Adicione os seguintes parâmetros** um por um:

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

## 🔍 **Explicação dos Valores:**

### **Expressões n8n utilizadas:**
- `{{ $json.agente_id }}` - Pega o valor do campo `agente_id` do item atual
- `{{ $json.nome }}` - Pega o valor do campo `nome` do item atual
- `{{ $json.telefone }}` - Pega o valor do campo `telefone` do item atual
- `{{ $json.email || '' }}` - Pega o valor do campo `email` ou string vazia se não existir
- `{{ $json.profissao }}` - Pega o valor do campo `profissao` do item atual
- `{{ $json.idade }}` - Pega o valor do campo `idade` do item atual
- `{{ $json.estado_civil }}` - Pega o valor do campo `estado_civil` do item atual
- `{{ $json.filhos }}` - Pega o valor do campo `filhos` do item atual
- `{{ $json.qtd_filhos }}` - Pega o valor do campo `qtd_filhos` do item atual
- `{{ $json.fonte_prospec }}` - Pega o valor do campo `fonte_prospec` do item atual

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

## ⚠️ **Importante:**

1. **Ordem dos parâmetros** deve ser exatamente como mostrado
2. **usuario_id** deve ser o primeiro parâmetro (usado para definir usuário atual)
3. **Email** é opcional, por isso usamos `|| ''` para evitar erros
4. **empresa_id** é obtido automaticamente do usuário
5. **status** é sempre 'novo' para novos leads
6. **contatado** é sempre false para novos leads

## 🧪 **Teste da Configuração:**

Após configurar os parâmetros, teste com um item de exemplo:

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

## ✅ **Resultado Esperado:**

- Lead inserido com sucesso
- `empresa_id` definido automaticamente baseado no `usuario_id`
- Isolamento por empresa funcionando
- Mesmo telefone permitido em empresas diferentes
- Retorno do `id` e `empresa_id` do lead criado
