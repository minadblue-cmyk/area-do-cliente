# Configuração do Webhook Status Unificado

## 📋 **CONFIGURAÇÃO NO N8N:**

### **1. Webhook Trigger Node:**
- **HTTP Method:** GET
- **Path:** `/webhook/status-agente1`
- **Response Mode:** "Respond to Webhook"

### **2. Set Node (Parâmetros):**
```json
{
  "usuario_id": "{{ $json.query.usuario_id || '5' }}",
  "action": "{{ $json.query.action || 'get_all_status' }}",
  "agent_types": "{{ $json.query.agent_types || '[]' }}"
}
```

### **3. PostgreSQL Node (Consulta Unificada):**
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
WHERE usuario_id = {{ $json.usuario_id }}
  AND status IN ('running', 'stopped', 'completed', 'error')
ORDER BY created_at DESC;
```

### **4. Set Node (Formatação):**
```json
{
  "success": true,
  "total": "{{ $input.all().length }}",
  "data": "{{ $input.all() }}",
  "message": "Status de todos os agentes encontrado",
  "timestamp": "{{ $now }}"
}
```

### **5. Respond to Webhook Node:**
- **Response Code:** 200
- **Response Body:** `{{ $json }}`

## 🎯 **TESTE:**

### **URL de teste:**
```
GET https://n8n.code-iq.com.br/webhook/status-agente1?usuario_id=5&action=get_all_status
```

### **Resposta esperada:**
```json
{
  "success": true,
  "total": "2",
  "data": [
    {
      "execution_id": "45688",
      "workflow_id": "eBcColwirndBaFZX",
      "usuario_id": 5,
      "status": "running",
      "iniciado_em": "2025-09-17T17:58:05.358Z",
      "parado_em": null,
      ...
    },
    {
      "execution_id": "45689",
      "workflow_id": "outro_workflow_id",
      "usuario_id": 5,
      "status": "stopped",
      "iniciado_em": "2025-09-17T17:50:00.000Z",
      "parado_em": "2025-09-17T17:55:00.000Z",
      ...
    }
  ],
  "message": "Status de todos os agentes encontrado",
  "timestamp": "2025-09-17T18:00:00.000Z"
}
```

## 🚀 **VANTAGENS:**

1. **✅ Uma única requisição** para todos os agentes
2. **✅ Melhor performance** - menos chamadas ao banco
3. **✅ Mais escalável** - funciona com N agentes
4. **✅ Frontend inteligente** - processa dados localmente
5. **✅ Fallback robusto** - usa localStorage se webhook falhar
