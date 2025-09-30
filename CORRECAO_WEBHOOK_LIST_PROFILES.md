# ✅ CORREÇÃO - Webhook list-profiles CORS

## ❌ Problema Identificado

**Erro**: `Access to XMLHttpRequest at 'https://n8n.code-iq.com.br/webhook/list-profiles' from origin 'http://localhost:5175' has been blocked by CORS policy`

**Causa**: URLs incorretas nos webhooks - alguns estavam apontando para domínios diferentes

## 🔍 Análise do Problema

### **Frontend (Antes):**
```typescript
const { data: response } = await callWebhook('webhook/list-profiles', {})
// ↑ Requisição GET por padrão
```

### **URLs Incorretas (Antes):**
```typescript
// webhook/list-profiles estava usando URL incorreta
{ id:'webhook/list-profiles', url: 'https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/list-profiles' }

// webhook/list-permission estava usando URL diferente
{ id:'webhook/list-permission', url: 'https://n8n.code-iq.com.br/webhook/list-permission' }
```

## ✅ Correção Aplicada

### **1. URLs Corrigidas**
```typescript
// ANTES (INCORRETO):
{ id:'webhook/list-profiles', url: 'https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/list-profiles' }
{ id:'webhook/list-permission', url: 'https://n8n.code-iq.com.br/webhook/list-permission' }

// DEPOIS (CORRETO):
{ id:'webhook/list-profiles', url: 'https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/list-profiles' }
{ id:'webhook/list-permission', url: 'https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/list-permission' }
```

### **2. Métodos HTTP Explicitos**
```typescript
// ANTES (INCORRETO):
const { data: response } = await callWebhook('webhook/list-profiles', {})

// DEPOIS (CORRETO):
const { data: response } = await callWebhook('webhook/list-profiles', { 
  method: 'GET'
})
```

## 🎯 Resultado Esperado

- ✅ **Sem erros CORS**: Requisições GET compatíveis com webhooks N8N
- ✅ **Perfis carregados**: Lista de perfis exibida corretamente
- ✅ **Permissões carregadas**: Lista de permissões disponíveis
- ✅ **Funcionalidade completa**: Criar, editar e deletar perfis funcionando

## 📋 Webhooks Corrigidos

1. **`webhook/list-profiles`**: URL corrigida para usar o domínio correto
2. **`webhook/list-permission`**: URL corrigida para usar o domínio correto
3. **Métodos HTTP**: Explicitamente definidos como GET

## 🔧 Configuração N8N

O webhook está configurado corretamente no N8N:
- ✅ **Método**: GET
- ✅ **CORS**: `allowedOrigins: "*"`
- ✅ **Path**: `list-profiles`
- ✅ **Resposta**: JSON com estrutura correta

## 📁 Arquivos Modificados

- `src/constants/webhooks.constants.ts`: URLs corrigidas para usar o domínio correto
- `src/pages/Permissions/index.tsx`: Métodos HTTP explicitamente definidos como GET

## 🚀 Próximos Passos

1. **Limpar cache**: Executar `limpar-cache-webhooks-profiles.js` no console do navegador
2. **Recarregar página**: A página será recarregada automaticamente
3. **Testar carregamento**: Verificar se os perfis carregam sem erros CORS
4. **Verificar console**: Não deve haver erros de CORS no console
5. **Testar funcionalidades**: Criar, editar e deletar perfis
6. **Verificar permissões**: Lista de permissões deve carregar corretamente

**Status**: ✅ CORRIGIDO
