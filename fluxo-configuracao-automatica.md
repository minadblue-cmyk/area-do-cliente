# 🔄 Fluxo de Configuração Automática do Frontend

## 📋 Como o Frontend Recebe e Configura Agentes Automaticamente

### **1. 🚀 Inicialização do Sistema**

Quando o usuário acessa a aba "Uploads", o sistema:

```typescript
// src/pages/Upload/index.tsx
const { agents, getAgentWebhooks, hasSpecificWebhooks } = useAgentSyncWebhooks({
  autoSync: true,
  syncInterval: 30000,
  onAgentAdded: (agentId, agentData) => {
    console.log(`✅ Agente ${agentData.nome} detectado e configurado automaticamente`)
    // Sistema registra webhooks específicos automaticamente
  }
})
```

### **2. 🔍 Detecção do Agente "Zeca"**

O sistema faz uma requisição para `webhook/list-agentes` e recebe:

```json
{
  "success": true,
  "data": [
    {
      "id": 59,
      "nome": "Zeca",
      "webhook_start_url": "webhook/start3-zeca",
      "webhook_stop_url": "webhook/stop3-zeca", 
      "webhook_status_url": "webhook/status3-zeca",
      "webhook_lista_url": "webhook/lista3-zeca",
      "status_atual": "stopped"
    }
  ]
}
```

### **3. 🎯 Registro Automático de Webhooks**

O sistema registra automaticamente os webhooks específicos:

```typescript
// useAgentSyncWebhooks.ts - Função registerSpecificWebhooks
const webhookMappings = [
  { type: 'start', url: 'webhook/start3-zeca' },
  { type: 'stop', url: 'webhook/stop3-zeca' },
  { type: 'status', url: 'webhook/status3-zeca' },
  { type: 'lista', url: 'webhook/lista3-zeca' }
]

// Registra cada webhook no store
webhookMappings.forEach(({ type, url }) => {
  const webhookId = `webhook/${type}-59` // webhook/start-59
  const fullUrl = `https://n8n.code-iq.com.br/${url}`
  addWebhook(webhookId, fullUrl)
})
```

### **4. 🖥️ Renderização Automática na Interface**

O frontend renderiza automaticamente a seção do agente:

```typescript
// src/pages/Upload/index.tsx
{Object.entries(agents).map(([agentId, agent]) => (
  <div key={agentId} className="agent-section">
    <h3>{agent.nome} {agent.icone}</h3>
    
    {/* Status do Agente */}
    <div className="status">
      Status: {agent.status_atual}
    </div>
    
    {/* Botões de Controle */}
    <div className="controls">
      <button onClick={() => handleStartAgent(agentId)}>
        ▶️ Iniciar
      </button>
      <button onClick={() => handleStopAgent(agentId)}>
        ⏹️ Parar
      </button>
      <button onClick={() => handleCheckStatus(agentId)}>
        🔄 Status
      </button>
    </div>
    
    {/* Lista de Prospects */}
    <div className="prospects">
      {/* Carregado via webhook lista específico */}
    </div>
  </div>
))}
```

## 🎮 Funcionalidades Configuradas Automaticamente

### **1. ▶️ Botão START**
```typescript
const handleStartAgent = async (agentId: string) => {
  const webhooks = getAgentWebhooks(agentId)
  // Usa webhook específico: webhook/start-59 -> https://n8n.code-iq.com.br/webhook/start3-zeca
  await callAgentWebhook(agentId, 'start', { action: 'start' })
}
```

### **2. ⏹️ Botão STOP**
```typescript
const handleStopAgent = async (agentId: string) => {
  const webhooks = getAgentWebhooks(agentId)
  // Usa webhook específico: webhook/stop-59 -> https://n8n.code-iq.com.br/webhook/stop3-zeca
  await callAgentWebhook(agentId, 'stop', { action: 'stop' })
}
```

### **3. 🔄 Verificação de STATUS**
```typescript
const handleCheckStatus = async (agentId: string) => {
  const webhooks = getAgentWebhooks(agentId)
  // Usa webhook específico: webhook/status-59 -> https://n8n.code-iq.com.br/webhook/status3-zeca
  const status = await callAgentWebhook(agentId, 'status', { action: 'get_status' })
  // Atualiza interface em tempo real
}
```

### **4. 📋 Lista de PROSPECTS**
```typescript
const loadProspects = async (agentId: string) => {
  const webhooks = getAgentWebhooks(agentId)
  // Usa webhook específico: webhook/lista-59 -> https://n8n.code-iq.com.br/webhook/lista3-zeca
  const prospects = await callAgentWebhook(agentId, 'lista', { action: 'get_prospects' })
  // Exibe lista de prospects do agente
}
```

## 🔄 Sincronização Automática

### **1. ⏰ Atualização Periódica**
```typescript
// A cada 30 segundos, o sistema:
useEffect(() => {
  const interval = setInterval(() => {
    // 1. Verifica se há novos agentes
    syncAgents()
    
    // 2. Atualiza status de agentes ativos
    Object.keys(agents).forEach(agentId => {
      if (agents[agentId].status_atual === 'running') {
        handleCheckStatus(agentId)
      }
    })
    
    // 3. Atualiza prospects de agentes ativos
    Object.keys(agents).forEach(agentId => {
      if (agents[agentId].status_atual === 'running') {
        loadProspects(agentId)
      }
    })
  }, 30000)
  
  return () => clearInterval(interval)
}, [agents])
```

### **2. 🔄 Detecção de Mudanças**
```typescript
// Quando um agente muda de status
onAgentStatusChanged: (agentId, newStatus) => {
  // Atualiza interface automaticamente
  setAgents(prev => ({
    ...prev,
    [agentId]: { ...prev[agentId], status_atual: newStatus }
  }))
  
  // Se parou, para atualizações
  if (newStatus === 'stopped') {
    stopPolling(agentId)
  }
}
```

## 🎯 Resposta à Sua Pergunta

### **✅ SIM, TODAS AS FUNÇÕES SÃO CONFIGURADAS AUTOMATICAMENTE:**

1. **🔍 Detecção Automática**: O sistema detecta novos agentes via webhook
2. **🔗 Webhooks Específicos**: Cada agente usa seus webhooks únicos
3. **🎮 Botões Funcionais**: Start, Stop, Status são configurados automaticamente
4. **📊 Interface Dinâmica**: A aba Upload mostra o agente com todas as funcionalidades
5. **🔄 Sincronização**: Status e prospects são atualizados automaticamente
6. **⚡ Zero Configuração**: Usuário não precisa configurar nada manualmente

### **🎉 Resultado Final:**

Quando o usuário acessa a aba "Uploads", ele verá automaticamente:

```
┌─────────────────────────────────────┐
│ 🤖 Zeca (Agente de prospecção)      │
├─────────────────────────────────────┤
│ Status: 🟢 Running                  │
│ Prospects: 15 ativos                │
├─────────────────────────────────────┤
│ [▶️ Iniciar] [⏹️ Parar] [🔄 Status] │
├─────────────────────────────────────┤
│ 📋 Lista de Prospects:              │
│ • João Silva - (11) 99999-9999      │
│ • Maria Santos - (11) 88888-8888    │
│ • Pedro Costa - (11) 77777-7777     │
└─────────────────────────────────────┘
```

**Tudo funcionando automaticamente, sem intervenção manual!** 🚀
