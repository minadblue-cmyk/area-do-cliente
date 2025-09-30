# 🔧 Correção: Webhooks Específicos do Agente

## 💡 Problema Identificado

O sistema estava detectando o agente corretamente, mas os webhooks específicos não estavam funcionando devido a dois problemas:

1. **URL incorreta**: Sistema construía `start3-59` em vez de `start3-zeca`
2. **Hook incorreto**: Estava usando `useAgentSync` em vez de `useAgentSyncWebhooks`

## ✅ Correções Aplicadas

### **1. Corrigida Função `buildAgentWebhookUrl`**

**Antes:**
```typescript
function buildAgentWebhookUrl(agentId: string, webhookType: string, baseUrl?: string): string {
  // Usava agentId ("59") para construir URL
  'start': `/webhook/start3-${agentId}`, // start3-59 ❌
}
```

**Depois:**
```typescript
function buildAgentWebhookUrl(agentId: string, webhookType: string, agentName?: string, baseUrl?: string): string {
  // Usa nome do agente ("zeca") para construir URL
  const agentNameForUrl = agentName ? agentName.toLowerCase() : agentId
  'start': `/webhook/start3-${agentNameForUrl}`, // start3-zeca ✅
}
```

### **2. Corrigido Hook no UploadPage**

**Antes:**
```typescript
import { useAgentSync } from '../../hooks/useAgentSync' // ❌ Hook antigo
```

**Depois:**
```typescript
import { useAgentSyncWebhooks } from '../../hooks/useAgentSyncWebhooks' // ✅ Hook correto
```

### **3. Hook Atualizado com Funcionalidades**

```typescript
const { 
  agents: syncedAgents, 
  syncAgents, 
  getAgentWebhooks,      // ✅ Nova funcionalidade
  hasSpecificWebhooks    // ✅ Nova funcionalidade
} = useAgentSyncWebhooks({
  // ... configurações
})
```

## 🔄 Fluxo Corrigido

### **1. Detecção do Agente:**
```json
{
  "id": 59,
  "nome": "Zeca",
  "webhook_start_url": "webhook/start3-zeca",
  "webhook_stop_url": "webhook/stop3-zeca",
  "webhook_status_url": "webhook/status3-zeca",
  "webhook_lista_url": "webhook/lista3-zeca"
}
```

### **2. Registro Automático de Webhooks:**
```typescript
// useAgentSyncWebhooks registra automaticamente:
addWebhook('webhook/start-59', 'https://n8n.code-iq.com.br/webhook/start3-zeca')
addWebhook('webhook/stop-59', 'https://n8n.code-iq.com.br/webhook/stop3-zeca')
addWebhook('webhook/status-59', 'https://n8n.code-iq.com.br/webhook/status3-zeca')
addWebhook('webhook/lista-59', 'https://n8n.code-iq.com.br/webhook/lista3-zeca')
```

### **3. Chamada dos Webhooks:**
```typescript
// Quando usuário clica "Iniciar":
await callAgentWebhook('start', '59', payload, 'Zeca')

// Sistema procura: webhook/start-59
// Encontra: https://n8n.code-iq.com.br/webhook/start3-zeca
// Chama: POST https://n8n.code-iq.com.br/webhook/start3-zeca
```

## 🎯 Resultado Esperado

### **✅ Logs Corretos:**
```
✅ [WEBHOOKS] Webhook específico registrado: webhook/start-59 -> https://n8n.code-iq.com.br/webhook/start3-zeca
✅ Webhook específico encontrado no store: https://n8n.code-iq.com.br/webhook/start3-zeca
🚀 Chamando webhook específico: https://n8n.code-iq.com.br/webhook/start3-zeca
```

### **✅ URLs Corretas:**
- **Start**: `https://n8n.code-iq.com.br/webhook/start3-zeca` ✅
- **Stop**: `https://n8n.code-iq.com.br/webhook/stop3-zeca` ✅
- **Status**: `https://n8n.code-iq.com.br/webhook/status3-zeca` ✅
- **Lista**: `https://n8n.code-iq.com.br/webhook/lista3-zeca` ✅

### **✅ Funcionalidades:**
- **Botão Iniciar**: Usa webhook específico do Zeca
- **Botão Parar**: Usa webhook específico do Zeca
- **Verificação Status**: Usa webhook específico do Zeca
- **Lista Prospects**: Usa webhook específico do Zeca

## 🚀 Próximos Passos

1. **Testar botão "Iniciar"** - Deve usar `webhook/start3-zeca`
2. **Verificar logs** - Deve mostrar webhooks específicos
3. **Confirmar funcionamento** - Sem erros CORS
4. **Testar outros botões** - Stop, Status, Lista

## 📁 Arquivos Modificados

- ✅ `src/utils/agent-webhook-client.ts` - Corrigida construção de URL
- ✅ `src/pages/Upload/index.tsx` - Corrigido hook usado
- ✅ `src/hooks/useAgentSyncWebhooks.ts` - Hook com webhooks específicos

**Status**: ✅ CORREÇÕES APLICADAS - PRONTO PARA TESTE
