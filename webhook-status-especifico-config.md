# Configuração do Webhook Status Específico por Agente

## 📋 **CONFIGURAÇÃO NO N8N:**

### **1. Webhook Trigger Node:**
- **HTTP Method:** GET
- **Path:** `/webhook/status-{workflow_id}` (Ex: `/webhook/status-eBcColwirndBaFZX`)
- **Response Mode:** "Respond to Webhook"

### **2. Set Node (Parâmetros):**
```json
{
  "usuario_id": "{{ $json.query.usuario_id || '5' }}",
  "workflow_id": "{{ $json.query.workflow_id }}",
  "action": "{{ $json.query.action || 'get_status' }}"
}
```

### **3. PostgreSQL Node (Consulta Específica):**
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

## 🎯 **EXEMPLO PARA O AGENTE ATUAL:**

### **Webhook:** `webhook/status-eBcColwirndBaFZX`

### **URL de teste:**
```
GET https://n8n.code-iq.com.br/webhook/status-eBcColwirndBaFZX?usuario_id=5&workflow_id=eBcColwirndBaFZX&action=get_status
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
      "parado_em": null,
      ...
    }
  ],
  "message": "Status do agente encontrado",
  "timestamp": "2025-09-17T18:00:00.000Z"
}
```

## 🚀 **VANTAGENS DA ABORDAGEM ESPECÍFICA:**

1. **🔒 Segurança** - Cada agente tem seu próprio endpoint
2. **🎯 Precisão** - Busca específica por `workflow_id`
3. **🛡️ Isolamento** - Falha de um agente não afeta outros
4. **📊 Controle granular** - Status individual de cada agente
5. **🔧 Manutenção** - Mais fácil debugar problemas específicos
6. **⚡ Performance** - Consulta otimizada para um agente específico
7. **🔄 Escalabilidade** - Fácil adicionar novos agentes

## 📝 **IMPLEMENTAÇÃO:**

### **Para cada agente, criar um webhook:**
- `webhook/status-eBcColwirndBaFZX` (para Elleven Agente 1)
- `webhook/status-outroWorkflowId` (para outros agentes)
- etc.

### **Frontend automaticamente:**
- Usa `webhook/status-${agentType}` para cada agente
- Trata erros individualmente
- Mantém status do localStorage como fallback
