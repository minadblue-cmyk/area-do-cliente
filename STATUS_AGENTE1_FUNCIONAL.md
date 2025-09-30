# ✅ Status Agente 1 - Workflow Funcional

## 📋 **ARQUIVO SALVO:**
- **`status-agente-1-workflow-funcional.json`** - Workflow que está funcionando no n8n

## 🔍 **DIFERENÇAS IMPORTANTES:**

### **1. Nome da Tabela:**
- **❌ Errado:** `agente_execution`
- **✅ Correto:** `agente_execucoes` (com 's' no final)

### **2. Configuração PostgreSQL:**
- **❌ Errado:** `queryParameters` dentro de `options`
- **✅ Correto:** `queryReplacement` com quebras de linha

### **3. Sintaxe queryReplacement:**
```json
"queryReplacement": "=={{ $json.workflowId }}\n={{ $json.usuarioId }}"
```

## 🎯 **CONFIGURAÇÃO CORRETA:**

### **Node PostgreSQL:**
```json
{
  "operation": "executeQuery",
  "query": "SELECT ... FROM agente_execucoes WHERE workflow_id = $1 AND usuario_id = $2",
  "options": {
    "queryReplacement": "=={{ $json.workflowId }}\n={{ $json.usuarioId }}"
  }
}
```

## 🧪 **TESTE:**
```bash
GET https://n8n.code-iq.com.br/webhook/status-agente1?usuario_id=5&workflow_id=eBcColwirndBaFZX
```

## 📊 **RESPOSTA ESPERADA:**
```json
{
  "status": "running|stopped",
  "message": "Agente rodando|Agente parado",
  "executionId": "...",
  "workflowId": "eBcColwirndBaFZX",
  "iniciadoEm": "2025-09-20T...",
  "paradoEm": "2025-09-20T...",
  "usuarioNome": "Administrator Code-IQ",
  "usuarioEmail": "admin@code-iq.com.br",
  "timestamp": "2025-09-20T..."
}
```

## 🚀 **PARA REIMPLEMENTAR:**
1. **Importe** o arquivo `status-agente-1-workflow-funcional.json` no n8n
2. **Configure** as credenciais PostgreSQL
3. **Ative** o workflow
4. **Teste** com a URL acima

## ⚠️ **PONTOS CRÍTICOS:**
- **Tabela:** `agente_execucoes` (não `agente_execution`)
- **queryReplacement:** Com quebras de linha (`\n`)
- **Método:** `GET` (não POST)
- **Parâmetros:** Via query string (`?usuario_id=5&workflow_id=...`)
