# ✅ Solução Correta: agente_id em Lotes (Não no Upload)

## 🎯 **Problema Identificado:**

### **❌ Abordagem Incorreta:**
- Upload não deve escolher `agente_id` específico
- Todos os agentes compartilham a **mesma base de leads**
- Sistema de lotes evita que agentes peguem o mesmo lead

### **✅ Abordagem Correta:**
1. **Upload:** Inserir leads na base comum (sem `agente_id`)
2. **Lotes:** Cada agente pega um lote de leads disponíveis
3. **Reserva:** Sistema reserva leads para evitar duplicação

## 🔧 **Solução Corrigida:**

### **✅ 1. Upload - Inserir Leads na Base Comum:**

```sql
-- ✅ QUERY CORRIGIDA: Upload sem agente_id específico
INSERT INTO public.lead (
  telefone, nome, canal, estagio_funnel, pergunta_index,
  data_criacao, data_ultima_interacao, client_id,
  nome_cliente, fonte_prospec, idade, profissao, estado_civil,
  filhos, qtd_filhos, data_insercao, status
  -- ❌ REMOVIDO: agente_id (será definido no lote)
)
VALUES (
  $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17
  -- ❌ REMOVIDO: $18 (agente_id)
)
ON CONFLICT (telefone, client_id) DO UPDATE
SET
  -- ... outros campos ...
  -- ❌ REMOVIDO: agente_id (será definido no lote)
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
{{$json.status || 'novo'}}
-- ❌ REMOVIDO: {{$json.agente_id}}
```

### **✅ 3. Frontend - Remover Seleção de Agente:**

```typescript
// ✅ UPLOAD SIMPLIFICADO - Sem seleção de agente
async function handleUpload(e: React.FormEvent) {
  e.preventDefault()
  if (!file || !userData || extractedData.length === 0) return
  
  setUploading(true)
  try {
    // Payload simples - sem agente_id
    const payload = {
      logged_user: {
        id: userData.id,
        name: userData.name,
        email: userData.mail
      },
      data: extractedData,
      // ❌ REMOVIDO: agente_id (será definido no lote)
      file_info: {
        name: file.name,
        size: file.size,
        type: file.type,
        lastModified: file.lastModified
      }
    }

    console.log('📦 Payload de upload (base comum):', payload)
    // ... resto da função
  }
}
```

### **✅ 4. Sistema de Lotes - Onde o agente_id é Definido:**

```sql
-- ✅ QUERY DE LOTE: Aqui sim define agente_id
WITH pegar AS (
  SELECT id
  FROM public.lead
  WHERE contatado IS NOT TRUE
    AND (reservado_lote IS NULL
         OR COALESCE(reservado_em, NOW() - INTERVAL '100 years')
            < NOW() - INTERVAL '30 minutes')
  ORDER BY COALESCE(data_ultima_interacao, data_criacao) ASC, id ASC
  LIMIT 20
  FOR UPDATE SKIP LOCKED
)
UPDATE public.lead l
SET reservado_por  = $1,         -- {{$workflow.id}}
    reservado_em   = NOW(),
    reservado_lote = $2,         -- {{$execution.id}}
    agente_id      = $3          -- ✅ AQUI: agente_id do usuário que iniciou
FROM pegar p
WHERE l.id = p.id
RETURNING
  l.id,
  l.reservado_lote,
  l.reservado_por,
  l.reservado_em,
  l.agente_id;  -- ✅ AQUI: agente_id é definido
```

## 🎉 **Fluxo Correto:**

### **✅ 1. Upload (Base Comum):**
```json
{
  "logged_user": { "id": "6", "name": "Usuário", "email": "user@email.com" },
  "data": [
    { "nome": "João", "telefone": "11999999999", "profissao": "Engenheiro" },
    { "nome": "Maria", "telefone": "11888888888", "profissao": "Médica" }
  ],
  "file_info": { "name": "leads.xlsx" }
}
```

### **✅ 2. Leads Inseridos (Sem agente_id):**
```json
[
  { "id": 16015, "nome": "João", "telefone": "11999999999", "agente_id": null, "status": "new" },
  { "id": 16016, "nome": "Maria", "telefone": "11888888888", "agente_id": null, "status": "new" }
]
```

### **✅ 3. Agente Pega Lote (agente_id Definido):**
```json
[
  { "id": 16015, "nome": "João", "telefone": "11999999999", "agente_id": 81, "status": "prospectando" },
  { "id": 16016, "nome": "Maria", "telefone": "11888888888", "agente_id": 81, "status": "prospectando" }
]
```

## 🚀 **Vantagens da Solução Correta:**

1. **✅ Base Comum:** Todos os agentes acessam a mesma base
2. **✅ Sem Duplicação:** Sistema de lotes evita conflitos
3. **✅ Flexível:** Qualquer agente pode pegar leads disponíveis
4. **✅ Simples:** Upload não precisa escolher agente
5. **✅ Eficiente:** Leads são distribuídos conforme disponibilidade

## 🔧 **Implementação:**

1. **Frontend:** Remover seleção de agente do upload
2. **n8n Upload:** Remover `agente_id` do INSERT
3. **n8n Lotes:** Manter `agente_id` na reserva de lotes
4. **Teste:** Verificar que leads são inseridos sem `agente_id`

**Solução correta implementada! 🚀**
