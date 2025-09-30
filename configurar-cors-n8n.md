# 🔧 Configurar CORS no n8n

## 🚨 Problema Identificado
```
Access to XMLHttpRequest at 'https://n8n.code-iq.com.br/webhook/start12-ze' 
from origin 'http://localhost:5173' has been blocked by CORS policy: 
Response to preflight request doesn't pass access control check: 
No 'Access-Control-Allow-Origin' header is present on the requested resource.
```

## ✅ Solução: Configurar CORS no n8n

### **1. No n8n, adicionar headers CORS nos webhooks:**

#### **Webhook Start:**
```javascript
// No node do webhook start, adicionar:
return {
  headers: {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Content-Type': 'application/json'
  },
  body: {
    // ... dados da resposta
  }
}
```

#### **Webhook List User Profiles:**
```javascript
// No node do webhook list-user-profiles, adicionar:
return {
  headers: {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Content-Type': 'application/json'
  },
  body: [
    { id: 2, descricao: 'Agente' },
    { id: 3, descricao: 'Supervisor' }
  ]
}
```

### **2. Configurar Response Mode nos webhooks:**
- **Response Mode:** "On Received"
- **Response Data:** "All Incoming Items"

### **3. Adicionar node "Respond to Webhook" no final:**
```javascript
// Node: Respond to Webhook
{
  "respondWith": "json",
  "responseBody": "={{ $json }}",
  "options": {
    "responseHeaders": {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type, Authorization"
    }
  }
}
```

## 🚀 Solução 2: Proxy Local (Alternativa)

Se não conseguir configurar CORS no n8n, criar um proxy local:

### **1. Criar proxy.js:**
```javascript
const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');

const app = express();
app.use(cors());

app.use('/api/n8n', createProxyMiddleware({
  target: 'https://n8n.code-iq.com.br',
  changeOrigin: true,
  pathRewrite: {
    '^/api/n8n': ''
  }
}));

app.listen(3001, () => {
  console.log('Proxy rodando na porta 3001');
});
```

### **2. Atualizar frontend para usar proxy:**
```typescript
// Em webhook-client.ts, mudar URL base:
const N8N_PROXY_URL = 'http://localhost:3001/api/n8n'
```

## 🎯 Recomendação

**Use a Solução 1** - Configurar CORS diretamente no n8n é mais simples e eficiente.
