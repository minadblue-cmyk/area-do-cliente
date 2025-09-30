# ✅ CORREÇÃO FINAL - URL do Webhook

## ❌ Problema Identificado

**Erro**: `net::ERR_FAILED` na requisição para `webhook-test/list-profile`

**Causa**: URL incorreta - estava usando `webhook-test` em vez de `webhook`

## ✅ Correção Aplicada

### **URL Corrigida**
```typescript
// ANTES (INCORRETO):
{ id:'webhook/list-profile', url: 'https://n8n.code-iq.com.br/webhook-test/list-profile' }

// DEPOIS (CORRETO):
{ id:'webhook/list-profile', url: 'https://n8n.code-iq.com.br/webhook/list-profile' }
```

## 🎯 Resultado Esperado

- ✅ **URL correta**: `https://n8n.code-iq.com.br/webhook/list-profile`
- ✅ **Sem erros de rede**: `net::ERR_FAILED` deve desaparecer
- ✅ **Perfis carregados**: Lista de perfis exibida corretamente
- ✅ **Console limpo**: Sem erros de requisição

## 📁 Arquivo Modificado

- `src/constants/webhooks.constants.ts`: URL corrigida para webhook/list-profile

## 🚀 Para Aplicar

1. **Recarregue a página** - as novas configurações serão aplicadas
2. **Verifique o console** - deve mostrar requisição bem-sucedida
3. **Confirme os perfis** - lista deve carregar sem erros

**Status**: ✅ CORREÇÃO FINAL APLICADA
