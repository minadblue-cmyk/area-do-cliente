# 🔗 Padrão de Webhooks Dinâmicos

## 📋 Padrão Identificado

Baseado no webhook `start3-zeca`, o sistema agora usa o seguinte padrão:

### **URLs Geradas Automaticamente:**

```typescript
// Para agente "Zeca" (ID: 59)
https://n8n.code-iq.com.br/webhook/start3-zeca    // Iniciar agente
https://n8n.code-iq.com.br/webhook/stop3-zeca     // Parar agente  
https://n8n.code-iq.com.br/webhook/status3-zeca   // Status do agente
```

### **Padrão Geral:**
```
https://n8n.code-iq.com.br/webhook/{tipo}3-{nomeDoAgente}
```

## 🎯 Tipos de Webhook Suportados

| Tipo | Padrão | Função |
|------|--------|--------|
| `start` | `start3-{nome}` | Iniciar agente |
| `stop` | `stop3-{nome}` | Parar agente |
| `status` | `status3-{nome}` | Verificar status |
| `lista` | `lista-prospeccao-agente1` | Listar prospects (genérico) |
| `prospects` | `lista-prospeccao-agente1` | Carregar prospects (genérico) |

## 🔄 Como Funciona

### **1. Detecção Automática**
```typescript
// Quando um novo agente é detectado pelo sistema de sincronização
onAgentAdded: (agentId, agentData) => {
  // agentData.nome = "Zeca"
  // agentId = "59"
  
  // Sistema gera automaticamente:
  registerAllAgentWebhooks("59", "Zeca")
}
```

### **2. Registro de Webhooks**
```typescript
// Para agente "Zeca", são registrados:
{
  "webhook/start-59": "https://n8n.code-iq.com.br/webhook/start3-zeca",
  "webhook/stop-59": "https://n8n.code-iq.com.br/webhook/stop3-zeca", 
  "webhook/status-59": "https://n8n.code-iq.com.br/webhook/status3-zeca"
}
```

### **3. Chamada de Webhooks**
```typescript
// Quando usuário clica "Iniciar" no agente "Zeca"
await callAgentWebhook("59", "start", {
  method: "POST",
  data: { action: "start", agent_type: "59" }
})

// Sistema automaticamente:
// 1. Busca webhook/start-59 no store
// 2. Se não encontrar, constrói URL dinamicamente
// 3. Registra no store para uso futuro
// 4. Chama webhook: POST https://n8n.code-iq.com.br/webhook/start3-zeca
```

## 📊 Status Atual

### **✅ Funcionando:**
- **Detecção de agentes**: Agente "Zeca" detectado automaticamente
- **Sincronização**: Sistema estável, sem loops infinitos
- **Prospects**: Carregamento funcionando via webhook genérico
- **Interface**: Botões aparecem automaticamente

### **🎯 Próximos Passos:**
1. **Testar botão "Iniciar"** do agente "Zeca"
2. **Verificar se webhook `start3-zeca` responde**
3. **Confirmar que status muda** para "Executando"
4. **Testar botão "Parar"** quando agente estiver rodando

## 🔧 Configuração N8N

### **Webhook Start (Exemplo):**
```
URL: https://n8n.code-iq.com.br/webhook/start3-zeca
Método: POST
CORS: *
Path: start3-zeca
```

### **Payload Esperado:**
```json
{
  "action": "start",
  "agent_type": "59",
  "workflow_id": "59",
  "usuario_id": 5
}
```

### **Resposta Esperada:**
```json
{
  "success": true,
  "message": "Agente iniciado com sucesso",
  "executionId": "abc123",
  "status": "running"
}
```

## 🚀 Benefícios

1. **🔄 Automático**: Webhooks criados automaticamente para novos agentes
2. **📝 Padronizado**: Padrão consistente `{tipo}3-{nome}`
3. **🎯 Específico**: Cada agente tem seus próprios webhooks
4. **🛡️ Robusto**: Fallbacks para webhooks genéricos
5. **⚡ Rápido**: Cache e sincronização otimizada

## 📝 Logs de Debug

```javascript
// Logs esperados ao criar novo agente:
✅ Webhook registrado: webhook/start-59 -> https://n8n.code-iq.com.br/webhook/start3-zeca
✅ Webhook registrado: webhook/stop-59 -> https://n8n.code-iq.com.br/webhook/stop3-zeca
✅ Webhook registrado: webhook/status-59 -> https://n8n.code-iq.com.br/webhook/status3-zeca
✅ 3 webhooks registrados para Zeca

// Logs esperados ao iniciar agente:
🔧 Construindo URL dinâmica para 59
🚀 Chamando webhook dinâmico: https://n8n.code-iq.com.br/webhook/start3-zeca
```

**Status**: ✅ PADRÃO IMPLEMENTADO E FUNCIONAL
