# 🔧 Sistema de Webhooks Dinâmicos - Exemplo de Uso

## 📋 **Visão Geral**

O sistema de webhooks dinâmicos permite que o frontend busque automaticamente o webhook correto baseado no agente selecionado, sem precisar hardcodar URLs específicas.

## 🚀 **Como Funciona**

### **1. Registro Automático de Webhooks**

Quando um agente é carregado, o sistema automaticamente registra todos os webhooks necessários:

```typescript
// Em loadAgentConfigs()
dataField.forEach((item: any) => {
  const agent = item.json
  if (agent.ativo) {
    const agentId = agent.workflow_id
    const agentName = agent.nome
    
    // Registrar webhooks dinamicamente para este agente
    registerAllAgentWebhooks(agentId, agentName)
  }
})
```

### **2. Construção Dinâmica de URLs**

O sistema constrói URLs baseadas no padrão:
- **Start**: `https://n8n.code-iq.com.br/webhook/start-{agentId}`
- **Stop**: `https://n8n.code-iq.com.br/webhook/stop-{agentId}`
- **Status**: `https://n8n.code-iq.com.br/webhook/status-{agentId}`
- **Prospects**: `https://n8n.code-iq.com.br/webhook/lista-prospeccao-{agentId}`

### **3. Fallback Inteligente**

Se o webhook específico não existir, o sistema usa fallbacks:

```typescript
const fallbackWebhooks = {
  'start': 'webhook/agente1',
  'stop': 'webhook/parar-agente',
  'status': 'webhook/status-agente1',
  'prospects': 'webhook/lista-prospeccao-agente1'
}
```

## 💻 **Exemplos de Uso**

### **Exemplo 1: Usando o Hook Personalizado**

```typescript
import { useDynamicWebhooks } from '../hooks/useDynamicWebhooks'

function AgentComponent({ agentId, agentName }) {
  const {
    webhooks,
    loading,
    error,
    callWebhook,
    testWebhook,
    isWebhookRegistered
  } = useDynamicWebhooks({
    agentId,
    agentName,
    autoRegister: true
  })

  // Chamar webhook de prospects
  const loadProspects = async () => {
    try {
      const response = await callWebhook('prospects', {
        method: 'GET',
        params: { usuario_id: userData.id }
      })
      console.log('Prospects carregados:', response.data)
    } catch (error) {
      console.error('Erro ao carregar prospects:', error)
    }
  }

  // Testar webhook de status
  const checkStatus = async () => {
    const result = await testWebhook('status')
    if (result.success) {
      console.log('Agente está funcionando!')
    }
  }

  return (
    <div>
      <h3>{agentName}</h3>
      <button onClick={loadProspects}>Carregar Prospects</button>
      <button onClick={checkStatus}>Verificar Status</button>
      
      {webhooks.map(webhook => (
        <div key={webhook.id}>
          <span>{webhook.name}</span>
          <span>{webhook.registered ? '✅' : '❌'}</span>
        </div>
      ))}
    </div>
  )
}
```

### **Exemplo 2: Usando a Função Direta**

```typescript
import { callAgentWebhook } from '../utils/agent-webhook-client'

// Carregar prospects para um agente específico
const loadProspects = async (agentId: string, agentName: string) => {
  try {
    const response = await callAgentWebhook('prospects', agentId, {
      method: 'GET',
      params: {
        usuario_id: userData.id,
        agent_type: agentId
      }
    }, agentName)
    
    return response.data
  } catch (error) {
    console.error('Erro ao carregar prospects:', error)
    throw error
  }
}

// Iniciar um agente
const startAgent = async (agentId: string, agentName: string) => {
  try {
    const response = await callAgentWebhook('start', agentId, {
      method: 'POST',
      data: {
        usuario_id: userData.id,
        workflow_id: agentId
      }
    }, agentName)
    
    return response.execution_id
  } catch (error) {
    console.error('Erro ao iniciar agente:', error)
    throw error
  }
}
```

### **Exemplo 3: Gerenciamento Completo de Webhooks**

```typescript
import { DynamicWebhookManager } from '../components/DynamicWebhookManager'

function AgentManagement({ agentId, agentName }) {
  const handleWebhookRegistered = (webhookId: string, url: string) => {
    console.log(`Webhook registrado: ${webhookId} -> ${url}`)
    // Atualizar UI ou fazer outras ações
  }

  return (
    <div>
      <h2>Gerenciamento de Agente: {agentName}</h2>
      
      <DynamicWebhookManager
        agentId={agentId}
        agentName={agentName}
        onWebhookRegistered={handleWebhookRegistered}
      />
    </div>
  )
}
```

## 🔄 **Fluxo Completo**

1. **Carregamento de Agentes**: Sistema busca lista de agentes via `webhook/list-agentes`
2. **Registro Automático**: Para cada agente ativo, registra webhooks dinamicamente
3. **Construção de URLs**: URLs são construídas baseadas no `workflow_id` do agente
4. **Chamadas Dinâmicas**: Frontend usa `callAgentWebhook` com tipo e ID do agente
5. **Fallback**: Se webhook específico falhar, usa webhooks genéricos existentes

## 🎯 **Vantagens**

- ✅ **Dinâmico**: Funciona com qualquer agente sem hardcode
- ✅ **Flexível**: Fácil de adicionar novos tipos de webhook
- ✅ **Robusto**: Fallback automático se webhook específico não existir
- ✅ **Rastreável**: Logs detalhados para debug
- ✅ **Reutilizável**: Hook e componentes reutilizáveis

## 🚨 **Considerações**

- **Performance**: Webhooks são registrados apenas uma vez por agente
- **Cache**: Store de webhooks mantém URLs em cache
- **Erro**: Sistema gracioso com fallbacks automáticos
- **Debug**: Logs detalhados para facilitar troubleshooting
