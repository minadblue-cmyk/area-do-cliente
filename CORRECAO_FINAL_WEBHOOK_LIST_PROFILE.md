# ✅ CORREÇÃO DEFINITIVA - Webhook list-profile

## ❌ Problema Real Identificado

**Erro**: `net::ERR_FAILED` na requisição para `list-profiles`

**Causa Real**: 
1. Webhook configurado como `list-profile` (singular), não `list-profiles` (plural)
2. Webhook está em modo **teste** (`webhook-test`), não produção (`webhook`)

## 🔍 Configuração Real do N8N

```
URL: https://n8n.code-iq.com.br/webhook-test/list-profile
Método: GET
CORS: * (todos os domínios permitidos)
```

## ✅ Correção Aplicada

### **1. URL Corrigida**
```typescript
// ANTES (INCORRETO):
{ id:'webhook/list-profiles', url: 'https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/list-profiles' }

// DEPOIS (CORRETO):
{ id:'webhook/list-profile', url: 'https://n8n.code-iq.com.br/webhook-test/list-profile' }
```

### **2. Frontend Corrigido**
```typescript
// ANTES (INCORRETO):
const { data: response } = await callWebhook('webhook/list-profiles', { method: 'GET' })

// DEPOIS (CORRETO):
const { data: response } = await callWebhook('webhook/list-profile', { method: 'GET' })
```

## 🎯 Resultado Esperado

- ✅ **Requisição bem-sucedida**: GET para `https://n8n.code-iq.com.br/webhook-test/list-profile`
- ✅ **Sem erros CORS**: CORS configurado como `*`
- ✅ **Perfis carregados**: Lista de perfis exibida corretamente
- ✅ **Console limpo**: Sem erros `net::ERR_FAILED`

## 📁 Arquivos Modificados

- `src/constants/webhooks.constants.ts`: URL corrigida para webhook-test/list-profile
- `src/pages/Permissions/index.tsx`: ID do webhook corrigido para list-profile

## 🚀 Teste Imediato

1. **Recarregue a página** - as novas configurações serão aplicadas
2. **Verifique o console** - deve mostrar requisição bem-sucedida
3. **Confirme os perfis** - lista deve carregar sem erros

**Status**: ✅ CORREÇÃO DEFINITIVA APLICADA
