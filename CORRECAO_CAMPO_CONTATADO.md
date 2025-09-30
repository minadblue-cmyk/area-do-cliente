# ✅ Correção do Campo `contatado` - Query Atualizada

## 🎯 **Problema Identificado:**
Campo `contatado` aparecendo como `null` na lista de prospecção.

## 🔧 **Solução Implementada:**

### **✅ Query Corrigida para Node "Atualizar status - prospectando":**

```sql
WITH upd AS (
  UPDATE public.lead AS l
  SET
    status                = 'prospectando',
    data_ultima_interacao = NOW(),
    agente_id             = $5,
    contatado             = true  -- ✅ NOVO: Marca como contatado
  WHERE l.id = $1
    AND l.reservado_por  = $2
    AND l.reservado_lote = $3
  RETURNING
    l.id, l.client_id, l.nome_cliente, l.telefone, l.canal,
    l.status, l.data_ultima_interacao, l.reservado_por, l.reservado_lote,
    l.agente_id, l.contatado  -- ✅ NOVO: Incluir contatado no RETURNING
),
fb AS (
  SELECT
    l.id, l.client_id, l.nome_cliente, l.telefone, l.canal,
    l.status, l.data_ultima_interacao, l.reservado_por, l.reservado_lote,
    l.agente_id, l.contatado  -- ✅ NOVO: Incluir contatado no SELECT
  FROM public.lead l
  WHERE l.id = $1
  LIMIT 1
),
row_out AS (
  SELECT * FROM upd
  UNION ALL
  SELECT * FROM fb WHERE NOT EXISTS (SELECT 1 FROM upd)
)
SELECT
  row_out.id,
  row_out.client_id,
  row_out.nome_cliente,
  row_out.telefone,
  row_out.canal,
  row_out.status,
  row_out.data_ultima_interacao,
  row_out.reservado_por,
  row_out.reservado_lote,
  row_out.agente_id,
  row_out.contatado,  -- ✅ NOVO: Retornar campo contatado
  p.mensagem,
  COALESCE(p.turno, 'indefinido') AS turno
FROM row_out
CROSS JOIN LATERAL jsonb_to_record($4::jsonb) AS p(
  mensagem text,
  turno     text
);
```

## 🔍 **Mudanças Implementadas:**

### **1. ✅ Adicionado `contatado = true` no UPDATE:**
```sql
SET
  status                = 'prospectando',
  data_ultima_interacao = NOW(),
  agente_id             = $5,
  contatado             = true  -- ✅ NOVO
```

### **2. ✅ Incluído `contatado` no RETURNING do UPDATE:**
```sql
RETURNING
  l.id, l.client_id, l.nome_cliente, l.telefone, l.canal,
  l.status, l.data_ultima_interacao, l.reservado_por, l.reservado_lote,
  l.agente_id, l.contatado  -- ✅ NOVO
```

### **3. ✅ Incluído `contatado` no SELECT do fallback:**
```sql
SELECT
  l.id, l.client_id, l.nome_cliente, l.telefone, l.canal,
  l.status, l.data_ultima_interacao, l.reservado_por, l.reservado_lote,
  l.agente_id, l.contatado  -- ✅ NOVO
```

### **4. ✅ Incluído `contatado` no SELECT final:**
```sql
SELECT
  row_out.id,
  row_out.client_id,
  row_out.nome_cliente,
  row_out.telefone,
  row_out.canal,
  row_out.status,
  row_out.data_ultima_interacao,
  row_out.reservado_por,
  row_out.reservado_lote,
  row_out.agente_id,
  row_out.contatado,  -- ✅ NOVO
  p.mensagem,
  COALESCE(p.turno, 'indefinido') AS turno
```

## 🎯 **Resultado Esperado:**

### **✅ Antes da Correção:**
- Lead ID 18017: `contatado: null` (status: "prospectando")
- Lead ID 18117: `contatado: null` (status: "concluído")

### **✅ Depois da Correção:**
- Lead ID 18017: `contatado: true` (status: "prospectando")
- Lead ID 18117: `contatado: true` (status: "concluído")

## 🚀 **Como Implementar:**

### **1. ✅ No n8n:**
1. Abrir o node "Atualizar status - prospectando"
2. Substituir a query atual pela query corrigida
3. Salvar e testar

### **2. ✅ Testar:**
1. Executar o workflow start novamente
2. Verificar se campo `contatado` aparece como `true`
3. Confirmar que lista de prospecção mostra leads como contatados

## 🎉 **Benefícios:**

### **✅ Consistência de Dados:**
- Todos os leads em prospecção aparecem como contatados
- Campo `contatado` reflete corretamente o status do lead

### **✅ Melhor UX:**
- Usuários veem claramente quais leads foram contatados
- Interface mais informativa e precisa

### **✅ Auditoria:**
- Rastreamento correto de leads contatados
- Dados consistentes para relatórios

## 🏁 **Conclusão:**

**A query corrigida resolve o problema do campo `contatado` aparecendo como `null`.**

**Implementação:** Substituir a query atual do node "Atualizar status - prospectando" pela versão corrigida.

**Resultado:** Campo `contatado` aparecerá como `true` para todos os leads em prospecção!
