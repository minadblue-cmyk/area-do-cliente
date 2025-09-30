# Correções para o Workflow Atual - Adicionar Redis

## 1. Adicionar Nó Redis GET Counter

**Posição:** Entre "Normalização1" e os nós "Busca Informações"

```json
{
  "parameters": {
    "method": "POST",
    "url": "http://localhost:3001/api/counter/next",
    "sendBody": true,
    "specifyBody": "json",
    "jsonBody": "={{ {\n  \"agentType\": $('Normalização').item.json.agentType,\n  \"webhookType\": \"{{ $json.webhookType || 'start' }}\"\n} }}",
    "options": {
      "response": {
        "response": {
          "neverError": true,
          "responseFormat": "json"
        }
      }
    }
  },
  "type": "n8n-nodes-base.httpRequest",
  "typeVersion": 4.2,
  "position": [0, 432],
  "id": "redis-get-counter",
  "name": "Redis GET Counter"
}
```

## 2. Corrigir Nós "PREPARAR WORKFLOW CLONADO"

### Para Start (posição -64):
```javascript
// Obter contador do Redis
const counterData = $('Redis GET Counter').item.json;
const counter = counterData.counter;

const originalWorkflow = $json.originalWorkflow;
const agentData = $('Normalização').item.json;

const clonedWorkflow = {
  name: `Agente SDR - Start-${counter}`,
  settings: originalWorkflow.settings || {},
  nodes: originalWorkflow.nodes.map(node => {
    if (node.type === 'n8n-nodes-base.webhook') {
      return {
        ...node,
        parameters: {
          ...node.parameters,
          path: `start${counter}-${agentData.agentType}`
        }
      };
    }
    return node;
  }),
  connections: originalWorkflow.connections || {}
};

return { workflowData: clonedWorkflow, counter: counter };
```

### Para Status (posição 224):
```javascript
// Obter contador do Redis
const counterData = $('Redis GET Counter').item.json;
const counter = counterData.counter;

const originalWorkflow = $json.originalWorkflow;
const agentData = $('Normalização').item.json;

const clonedWorkflow = {
  name: `Agente SDR - Status-${counter}`,
  settings: originalWorkflow.settings || {},
  nodes: originalWorkflow.nodes.map(node => {
    if (node.type === 'n8n-nodes-base.webhook') {
      return {
        ...node,
        parameters: {
          ...node.parameters,
          path: `status${counter}-${agentData.agentType}`
        }
      };
    }
    return node;
  }),
  connections: originalWorkflow.connections || {}
};

return { workflowData: clonedWorkflow, counter: counter };
```

### Para Lista (posição 464):
```javascript
// Obter contador do Redis
const counterData = $('Redis GET Counter').item.json;
const counter = counterData.counter;

const originalWorkflow = $json.originalWorkflow;
const agentData = $('Normalização').item.json;

const clonedWorkflow = {
  name: `Agente SDR - Lista-${counter}`,
  settings: originalWorkflow.settings || {},
  nodes: originalWorkflow.nodes.map(node => {
    if (node.type === 'n8n-nodes-base.webhook') {
      return {
        ...node,
        parameters: {
          ...node.parameters,
          path: `lista${counter}-${agentData.agentType}`
        }
      };
    }
    return node;
  }),
  connections: originalWorkflow.connections || {}
};

return { workflowData: clonedWorkflow, counter: counter };
```

### Para Stop (posição 704):
```javascript
// Obter contador do Redis
const counterData = $('Redis GET Counter').item.json;
const counter = counterData.counter;

const originalWorkflow = $json.originalWorkflow;
const agentData = $('Normalização').item.json;

const clonedWorkflow = {
  name: `Agente SDR - Stop-${counter}`,
  settings: originalWorkflow.settings || {},
  nodes: originalWorkflow.nodes.map(node => {
    if (node.type === 'n8n-nodes-base.webhook') {
      return {
        ...node,
        parameters: {
          ...node.parameters,
          path: `stop${counter}-${agentData.agentType}`
        }
      };
    }
    return node;
  }),
  connections: originalWorkflow.connections || {}
};

return { workflowData: clonedWorkflow, counter: counter };
```

## 3. Corrigir Nó "Prepara Json"

```javascript
// Consolidar resultados de todos os workflows
const allResults = $input.all();
const agentData = $('Webhook Create Fixed').item.json.body;

const workflows = [];

// Coletar informações de cada workflow criado
allResults.forEach((result, index) => {
  if (result.json && result.json.id) {
    const workflowTypes = ['start', 'status', 'lista', 'stop'];
    const webhookType = workflowTypes[index] || 'unknown';
    const counter = result.counter || (index + 1);
    
    workflows.push({
      id: result.json.id,
      name: result.json.name,
      webhookType: webhookType,
      counter: counter,
      webhookPath: `${webhookType}${counter}-${agentData.agent_type}`,
      status: 'ativo'
    });
  }
});

const response = {
  success: true,
  message: `${workflows.length} workflows criados com sucesso`,
  agentName: agentData.agent_name,
  agentType: agentData.agent_type,
  agentId: agentData.agent_id,
  workflows: workflows,
  summary: {
    totalWorkflows: workflows.length,
    activeWorkflows: workflows.filter(w => w.status === 'ativo').length,
    webhookTypes: workflows.map(w => w.webhookType)
  },
  timestamp: new Date().toISOString(),
  executionId: $execution.id
};

return response;
```

## 4. Adicionar Conexões Redis

Adicionar no objeto "connections":

```json
"Normalização1": {
  "main": [
    [
      {
        "node": "Redis GET Counter",
        "type": "main",
        "index": 0
      }
    ]
  ]
},
"Redis GET Counter": {
  "main": [
    [
      {
        "node": "Busca Informações do Agente SDR - Start",
        "type": "main",
        "index": 0
      },
      {
        "node": "Busca Informações do Agente SDR - status-agente",
        "type": "main",
        "index": 0
      },
      {
        "node": "Busca Informações do Agente SDR - lista-prospeccao-agente",
        "type": "main",
        "index": 0
      },
      {
        "node": "Busca Informações do Agente SDR - Stop",
        "type": "main",
        "index": 0
      }
    ]
  ]
}
```

## 5. Payload Esperado pelo Frontend

O frontend deve enviar:
```json
{
  "agent_name": "Nome do Agente",
  "agent_type": "tipo-agente",
  "agent_id": "ID_UNICO_AGENTE",
  "user_id": "1",
  "icone": "🤖",
  "cor": "bg-blue-500",
  "descricao": "Descrição do agente"
}
```

## 6. Resposta do Webhook

O webhook retornará:
```json
{
  "success": true,
  "message": "4 workflows criados com sucesso",
  "agentName": "Nome do Agente",
  "agentType": "tipo-agente",
  "agentId": "ID_UNICO_AGENTE",
  "workflows": [
    {
      "id": "workflow-id-1",
      "name": "Agente SDR - Start-1",
      "webhookType": "start",
      "counter": 1,
      "webhookPath": "start1-tipo-agente",
      "status": "ativo"
    },
    {
      "id": "workflow-id-2",
      "name": "Agente SDR - Status-2",
      "webhookType": "status", 
      "counter": 2,
      "webhookPath": "status2-tipo-agente",
      "status": "ativo"
    },
    {
      "id": "workflow-id-3",
      "name": "Agente SDR - Lista-3",
      "webhookType": "lista",
      "counter": 3,
      "webhookPath": "lista3-tipo-agente",
      "status": "ativo"
    },
    {
      "id": "workflow-id-4",
      "name": "Agente SDR - Stop-4",
      "webhookType": "stop",
      "counter": 4,
      "webhookPath": "stop4-tipo-agente",
      "status": "ativo"
    }
  ],
  "summary": {
    "totalWorkflows": 4,
    "activeWorkflows": 4,
    "webhookTypes": ["start", "status", "lista", "stop"]
  },
  "timestamp": "2024-01-15T10:30:00.000Z",
  "executionId": "execution-123"
}
```

## 7. Configuração Redis Server

Certifique-se de que o Redis Counter Server está rodando:
```bash
node redis-counter-server.js
```

O servidor deve estar disponível em: `http://localhost:3001`
