# 🚀 Solução de Proxy para CORS

## ❌ Problema
O n8n está configurado para aceitar apenas `http://localhost:8080`, mas o frontend roda em `http://localhost:5175`, causando erro de CORS.

## ✅ Solução: Proxy Local

### **1. Executar o Proxy**

```bash
# Opção 1: Apenas o proxy
npm run proxy

# Opção 2: Proxy + Frontend juntos
npm run dev:proxy
```

### **2. Como Funciona**

- **Proxy roda em:** `http://localhost:8080`
- **Frontend roda em:** `http://localhost:5175` (ou 5173/5174)
- **Proxy redireciona:** `http://localhost:8080/webhook/*` → `https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/*`

### **3. Configuração Automática**

O arquivo `src/constants/webhooks.constants.ts` já está configurado para usar o proxy:

```typescript
const USE_PROXY = true  // ✅ Ativado
const PROXY_URL = 'http://localhost:8080'
```

### **4. Verificação**

1. **Execute:** `npm run dev:proxy`
2. **Acesse:** `http://localhost:5175/permissions`
3. **Verifique:** Console deve mostrar logs do proxy
4. **Confirme:** Dados reais do n8n carregados (não mais dados mock)

### **5. Logs do Proxy**

```
🚀 Proxy server running on http://localhost:8080
📡 Proxying requests to: https://n8n-lavo-n8n.15gxno.easypanel.host
🔄 Proxying GET /webhook/list-profile -> n8n
✅ Response 200 for /webhook/list-profile
```

### **6. Desativar Proxy**

Se quiser voltar ao n8n direto, altere em `src/constants/webhooks.constants.ts`:

```typescript
const USE_PROXY = false  // ❌ Desativado
```

### **7. Troubleshooting**

**Erro: "Cannot find module 'express'"**
```bash
npm install express http-proxy-middleware cors concurrently --save-dev
```

**Erro: "Port 8080 already in use"**
```bash
# Matar processo na porta 8080
npx kill-port 8080
# Ou alterar porta no proxy-server.mjs
```

**Proxy não conecta ao n8n**
- Verifique se o n8n está online
- Teste: `curl https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/list-profile`

## 🎯 Benefícios

- ✅ **Resolve CORS** automaticamente
- ✅ **Não precisa configurar n8n**
- ✅ **Funciona em desenvolvimento**
- ✅ **Logs detalhados** para debug
- ✅ **Fácil de ativar/desativar**

## 📝 Notas

- **Produção:** Configure CORS no n8n, não use proxy
- **Desenvolvimento:** Proxy é a solução mais rápida
- **Segurança:** Proxy só aceita origens específicas
