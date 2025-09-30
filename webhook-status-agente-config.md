# Configuração do Webhook status-agente1

## 📋 **CONFIGURAÇÃO NO N8N:**

### **1. Webhook Trigger Node:**
- **HTTP Method:** GET
- **Path:** `/webhook/status-agente1`
- **Response Mode:** "Respond to Webhook"

### **2. Set Node (Parâmetros):**
```json
{
  "usuario_id": "{{ $json.query.usuario_id || '5' }}",
  "workflow_id": "{{ $json.query.workflow_id || 'eBcColwirndBaFZX' }}",
  "status": "{{ $json.query.status || 'running' }}"
}
```

### **3. PostgreSQL Node (Consulta):**
```sql
SELECT 
    execution_id,
    workflow_id,
    usuario_id,
    usuario_nome,
    usuario_email,
    status,
    iniciado_em,
    parado_em,
    payload_inicial,
    payload_parada,
    created_at,
    updated_at,
    finalizado_em,
    erro_em,
    mensagem_erro,
    duracao_segundos
FROM agente_execucoes 
WHERE workflow_id = '{{ $json.workflow_id }}' 
  AND usuario_id = {{ $json.usuario_id }}
ORDER BY created_at DESC 
LIMIT 1;
```

### **4. Set Node (Formatação):**
```json
{
  "success": true,
  "total": "{{ $input.all().length }}",
  "data": "{{ $input.all() }}",
  "message": "Status do agente encontrado",
  "timestamp": "{{ $now }}"
}
```

### **5. Respond to Webhook Node:**
- **Response Code:** 200
- **Response Body:** `{{ $json }}`

## 🎯 **TESTE:**

### **URL de teste:**
```
GET https://n8n.code-iq.com.br/webhook/status-agente1?usuario_id=5&workflow_id=eBcColwirndBaFZX&status=running
```

### **Resposta esperada:**
```json
{
  "success": true,
  "total": "1",
  "data": [
    {
      "execution_id": "45688",
      "workflow_id": "eBcColwirndBaFZX",
      "usuario_id": 5,
      "status": "running",
      "iniciado_em": "2025-09-17T17:58:05.358Z",
      ...
    }
  ],
  "message": "Status do agente encontrado",
  "timestamp": "2025-09-17T18:00:00.000Z"
}
```
