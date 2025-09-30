# Configuração CORS para n8n

## Problema
O frontend está sendo bloqueado pelo CORS ao tentar acessar o webhook do n8n.

## Solução 1: Configurar CORS no n8n

### 1. Acesse as configurações do n8n
- Vá para Settings > Security
- Procure por "CORS" ou "Cross-Origin Resource Sharing"

### 2. Adicione os domínios permitidos
```
http://localhost:5173
http://localhost:5174
http://localhost:5175
http://localhost:5176
http://localhost:5177
http://localhost:5178
http://localhost:5179
http://localhost:5180
http://localhost:5181
```

### 3. Ou configure para aceitar todos os domínios (apenas para desenvolvimento)
```
*
```

## Solução 2: Usar proxy no Vite

### 1. Configure o proxy no vite.config.ts
```typescript
export default defineConfig({
  // ... outras configurações
  server: {
    proxy: {
      '/api/n8n': {
        target: 'https://n8n-lavo-n8n.15gxno.easypanel.host',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api\/n8n/, '')
      }
    }
  }
})
```

### 2. Atualize as URLs dos webhooks
```typescript
// Em vez de:
'https://n8n-lavo-n8n.15gxno.easypanel.host/webhook-test/agente-prospeccao-quente'

// Use:
'/api/n8n/webhook-test/agente-prospeccao-quente'
```

## Solução 3: Usar servidor proxy simples

### 1. Crie um arquivo proxy-server.js
```javascript
const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');

const app = express();
app.use(cors());

app.use('/n8n', createProxyMiddleware({
  target: 'https://n8n-lavo-n8n.15gxno.easypanel.host',
  changeOrigin: true,
  pathRewrite: {
    '^/n8n': ''
  }
}));

app.listen(3001, () => {
  console.log('Proxy server running on port 3001');
});
```

### 2. Execute o proxy
```bash
npm install express http-proxy-middleware cors
node proxy-server.js
```

### 3. Atualize as URLs dos webhooks
```typescript
// Em vez de:
'https://n8n-lavo-n8n.15gxno.easypanel.host/webhook-test/agente-prospeccao-quente'

// Use:
'http://localhost:3001/n8n/webhook-test/agente-prospeccao-quente'
```

## Recomendação
Use a **Solução 1** (configurar CORS no n8n) pois é a mais simples e eficiente.
