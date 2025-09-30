# Códigos Corrigidos para os Nós "PREPARAR WORKFLOW CLONADO"

## 1. PREPARAR WORKFLOW CLONADO - Start (posição -64)

```javascript
// Obter contador do Redis
const counterData = $('Redis GET Counter - Start').item.json;
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

return { workflowData: clonedWorkflow, counter: counter, webhookType: 'start' };
```

## 2. PREPARAR WORKFLOW CLONADO1 (Status - posição 224)

```javascript
// Obter contador do Redis
const counterData = $('Redis GET Counter - Status').item.json;
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

return { workflowData: clonedWorkflow, counter: counter, webhookType: 'status' };
```

## 3. PREPARAR WORKFLOW CLONADO - lista-prospeccao-agente (posição 464)

```javascript
// Obter contador do Redis
const counterData = $('Redis GET Counter - Lista').item.json;
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

return { workflowData: clonedWorkflow, counter: counter, webhookType: 'lista' };
```

## 4. PREPARAR WORKFLOW CLONADO - Stop (posição 704)

```javascript
// Obter contador do Redis
const counterData = $('Redis GET Counter - Stop').item.json;
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

return { workflowData: clonedWorkflow, counter: counter, webhookType: 'stop' };
```

## 5. Prepara Json (posição 2080) - CORRIGIDO

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
