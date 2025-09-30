# 🔧 Correção do Webhook Dinâmico - Lista de Prospecção

## 🚨 **Problema Identificado**

O sistema estava tentando usar um webhook dinâmico que não existe:
```
GET https://n8n.code-iq.com.br/webhook/lista-prospeccao-eBcColwirndBaFZX?usuario_id=5&agent_type=eBcColwirndBaFZX net::ERR_FAILED
```

## 🔍 **Causa Raiz**

1. **Webhook Dinâmico Inexistente**: O sistema estava construindo URLs como `lista-prospeccao-{agentId}` que não existem no N8N
2. **Fallback Não Funcionando**: O fallback estava configurado corretamente, mas o sistema tentava usar o webhook dinâmico primeiro
3. **Pooling Automático**: O pooling de prospects a cada 5 segundos estava chamando o webhook incorreto

## ✅ **Solução Implementada**

### **1. Correção no `agent-webhook-client.ts`**

```typescript
// Para webhooks de lista/prospects, usar diretamente o webhook genérico existente
if (webhookType === 'lista' || webhookType === 'prospects') {
  console.log(`🔄 Usando webhook genérico para ${webhookType}`)
  return await callWebhook('webhook/lista-prospeccao-agente1', options)
}
```

### **2. Webhook Correto**

- **❌ Incorreto**: `webhook/lista-prospeccao-eBcColwirndBaFZX`
- **✅ Correto**: `webhook/lista-prospeccao-agente1`

### **3. Padrão de URLs**

```typescript
const webhookPatterns = {
  'start': `/webhook/start-${agentId}`,           // Dinâmico
  'stop': `/webhook/stop-${agentId}`,             // Dinâmico  
  'status': `/webhook/status-${agentId}`,         // Dinâmico
  'lista': `/webhook/lista-prospeccao-agente1`,   // Genérico existente
  'prospects': `/webhook/lista-prospeccao-agente1` // Genérico existente
}
```

## 🔄 **Fluxo Corrigido**

1. **Chamada**: `callAgentWebhook('prospects', 'eBcColwirndBaFZX', options)`
2. **Verificação**: Tipo é 'prospects' → usar webhook genérico
3. **Webhook**: `webhook/lista-prospeccao-agente1`
4. **URL Final**: `https://n8n.code-iq.com.br/webhook/lista-prospeccao-agente1`
5. **Sucesso**: ✅ Dados carregados corretamente

## 📊 **Resultado**

### **Antes (Com Erro)**
```
❌ GET https://n8n.code-iq.com.br/webhook/lista-prospeccao-eBcColwirndBaFZX
   net::ERR_FAILED
```

### **Depois (Funcionando)**
```
✅ GET https://n8n.code-iq.com.br/webhook/lista-prospeccao-agente1
   Status: 200, Data: Array(1)
```

## 🎯 **Webhooks Disponíveis**

### **Webhooks Dinâmicos (Por Agente)**
- `start-{agentId}` - Iniciar agente específico
- `stop-{agentId}` - Parar agente específico  
- `status-{agentId}` - Status do agente específico

### **Webhooks Genéricos (Compartilhados)**
- `lista-prospeccao-agente1` - Lista de prospects (todos os agentes)
- `agente1` - Iniciar agente genérico
- `parar-agente` - Parar agente genérico
- `status-agente1` - Status do agente genérico

## 🚀 **Benefícios da Correção**

- ✅ **Pooling Funcionando**: Prospects são carregados a cada 5 segundos
- ✅ **Sem Erros 404**: Webhook correto é chamado
- ✅ **Dados Atualizados**: Lista de prospects é atualizada automaticamente
- ✅ **Fallback Robusto**: Sistema usa webhook genérico quando específico não existe
- ✅ **Logs Claros**: Console mostra qual webhook está sendo usado

## 🔧 **Configuração Atual**

```typescript
// Para prospects/lista, sempre usar webhook genérico
if (webhookType === 'lista' || webhookType === 'prospects') {
  return await callWebhook('webhook/lista-prospeccao-agente1', options)
}

// Para outros tipos, tentar dinâmico primeiro, depois fallback
const fallbackWebhooks = {
  'start': 'webhook/agente1',
  'stop': 'webhook/parar-agente', 
  'status': 'webhook/status-agente1',
  'lista': 'webhook/lista-prospeccao-agente1',
  'prospects': 'webhook/lista-prospeccao-agente1'
}
```

## 📝 **Notas Importantes**

1. **Webhook de Lista**: Sempre usa o genérico `lista-prospeccao-agente1`
2. **Outros Webhooks**: Podem ser dinâmicos se existirem no N8N
3. **Pooling**: Funciona corretamente com webhook genérico
4. **Fallback**: Sistema robusto com fallbacks automáticos
5. **Logs**: Console mostra claramente qual webhook está sendo usado

O sistema agora está funcionando corretamente e carregando prospects sem erros!
