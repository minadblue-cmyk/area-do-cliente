# ✅ Correção do Upload de Leads - Incluir agente_id

## 🎯 **Problema Identificado:**

### **❌ agente_id: null nos leads uploadados:**
- Leads uploadados via webhook `/webhook/upload` estavam com `agente_id: null`
- Query INSERT não incluía a coluna `agente_id`
- Parâmetros não incluíam o `agente_id`

## 🔧 **Correção Aplicada:**

### **✅ 1. Query SQL Corrigida:**

```sql
INSERT INTO public.lead (
  telefone, nome, canal, estagio_funnel, pergunta_index,
  data_criacao, data_ultima_interacao, client_id,
  nome_cliente, fonte_prospec, idade, profissao, estado_civil,
  filhos, qtd_filhos, data_insercao, status, agente_id  -- ✅ ADICIONADO
)
VALUES (
  $1,                               -- telefone
  $2,                               -- nome
  COALESCE($3,'whatsapp'),          -- canal
  COALESCE($4,'topo'),              -- estagio_funnel
  COALESCE($5,0),                   -- pergunta_index
  COALESCE($6::timestamp, now()),   -- data_criacao
  COALESCE($7::timestamp, now()),   -- data_ultima_interacao
  $8,                               -- client_id
  $9,                               -- nome_cliente
  $10,                              -- fonte_prospec
  $11,                              -- idade
  $12,                              -- profissao
  $13,                              -- estado_civil
  $14,                              -- filhos
  $15,                              -- qtd_filhos
  COALESCE($16::timestamp, $6::timestamp, now()), -- data_insercao
  COALESCE($17, 'novo'),            -- status
  $18                               -- agente_id ✅ ADICIONADO
)
ON CONFLICT (telefone, client_id) DO UPDATE
SET
  -- ... outros campos ...
  agente_id = COALESCE(EXCLUDED.agente_id, lead.agente_id)  -- ✅ ADICIONADO
RETURNING *;
```

### **✅ 2. Parâmetros Corrigidos:**

```
{{$json.telefone}}, 
{{$json.nome}}, 
{{$json.canal || 'whatsapp'}}, 
{{$json.estagio_funnel || 'topo'}}, 
{{$json.pergunta_index !== undefined && $json.pergunta_index !== null ? $json.pergunta_index : 0}}, 
{{$json.data_processamento || $now.toISO()}}, 
{{$json.data_processamento || $now.toISO()}}, 
{{$json.client_id}}, 
{{$json.nome_cliente || $json.nome}}, 
{{$json.fonte_prospec}}, 
{{$json.idade}}, 
{{$json.profissao}}, 
{{$json.estado_civil}}, 
{{$json.filhos}}, 
{{$json.qtd_filhos}}, 
{{$json.data_processamento}}, 
{{$json.status || 'novo'}}, 
{{$json.agente_id || 81}}  -- ✅ ADICIONADO
```

## 🎉 **Resultado:**

### **✅ Antes (Problemático):**
```json
{
  "id": 16015,
  "nome": "Roger Macedo da Silva",
  "telefone": "5551984033242",
  "client_id": 6,
  "status": "new",
  "agente_id": null  // ❌ PROBLEMA
}
```

### **✅ Depois (Correto):**
```json
{
  "id": 16015,
  "nome": "Roger Macedo da Silva", 
  "telefone": "5551984033242",
  "client_id": 6,
  "status": "new",
  "agente_id": 81  // ✅ CORRIGIDO
}
```

## 🚀 **Como Aplicar:**

### **✅ 1. No n8n - Node PostgreSQL:**
1. **Query:** Substitua pela query corrigida acima
2. **Parâmetros:** Substitua pelos parâmetros corrigidos acima
3. **Teste:** Faça upload de um lead e verifique se `agente_id` não é mais `null`

### **✅ 2. Verificação:**
```sql
-- Verificar se agente_id está sendo inserido
SELECT id, nome, telefone, client_id, agente_id, status 
FROM lead 
WHERE agente_id IS NOT NULL 
ORDER BY id DESC 
LIMIT 5;
```

## 🎯 **Benefícios:**

1. **✅ Leads com agente_id:** Agora todos os leads terão `agente_id` definido
2. **✅ Compatibilidade com start flow:** O fluxo "start" conseguirá processar os leads
3. **✅ Flexibilidade:** `agente_id` pode vir do JSON ou usar padrão (81)
4. **✅ Atualização em conflito:** Se lead já existe, `agente_id` é atualizado

**Agora o `agente_id` será inserido corretamente! 🚀**
