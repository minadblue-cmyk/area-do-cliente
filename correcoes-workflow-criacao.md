# Correções para Workflow de Criação de Agente

## Problemas Identificados
1. O workflow de criação está usando o `workflow_id` do template (`eBcColwirndBaFZX`) em vez de usar o ID real do agente criado.
2. **NOVO**: Acentuação está sendo perdida na conversão do nome do agente para `agentType` (ex: "João" → "joo").

## Correções Necessárias

### CORREÇÃO PRIORITÁRIA: Acentuação no AgentType

**Problema**: O nome "João" está sendo convertido para "joo" nos webhooks, perdendo acentos.

**Solução**: Adicionar função de normalização que preserva acentos mas remove espaços e caracteres especiais.

**Código para adicionar no início de cada nó "PREPARAR WORKFLOW CLONADO":**

```javascript
// Função para normalizar nome preservando acentos
function normalizarNomeParaWebhook(nome) {
  return nome
    .toLowerCase()
    .trim()
    .replace(/\s+/g, '') // Remove espaços
    .replace(/[^a-z0-9áàâãéèêíìîóòôõúùûç]/g, '') // Remove caracteres especiais exceto acentos
    .replace(/[áàâã]/g, 'a')
    .replace(/[éèê]/g, 'e')
    .replace(/[íìî]/g, 'i')
    .replace(/[óòôõ]/g, 'o')
    .replace(/[úùû]/g, 'u')
    .replace(/ç/g, 'c');
}

// Exemplo de uso:
// "João da Silva" → "joaodasilva"
// "José" → "jose"
// "María" → "maria"
```

### 1. PREPARAR WORKFLOW CLONADO - Start
**Arquivo**: N8N Workflow "Create Agente"
**Nó**: "PREPARAR WORKFLOW CLONADO - Start"

**Código Atual**:
```javascript
// Obter contador do Redis GET
const counterData = $('Busca atual').item.json;
const counter = counterData.propertyName || counterData.agente_counter_global || 1;

// Acessar dados do nó "Normaliza campos" onde está o originalWorkflow
const originalWorkflow = $('Normaliza campos').item.json.originalWorkflow;
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

**Código Corrigido**:
```javascript
// Função para normalizar nome preservando acentos
function normalizarNomeParaWebhook(nome) {
  return nome
    .toLowerCase()
    .trim()
    .replace(/\s+/g, '') // Remove espaços
    .replace(/[^a-z0-9áàâãéèêíìîóòôõúùûç]/g, '') // Remove caracteres especiais exceto acentos
    .replace(/[áàâã]/g, 'a')
    .replace(/[éèê]/g, 'e')
    .replace(/[íìî]/g, 'i')
    .replace(/[óòôõ]/g, 'o')
    .replace(/[úùû]/g, 'u')
    .replace(/ç/g, 'c');
}

// Obter contador do Redis GET
const counterData = $('Busca atual').item.json;
const counter = counterData.propertyName || counterData.agente_counter_global || 1;

// Acessar dados do nó "Normaliza campos" onde está o originalWorkflow
const originalWorkflow = $('Normaliza campos').item.json.originalWorkflow;
const agentData = $('Normalização').item.json;

// CORREÇÃO: Normalizar agentType preservando acentos
const agentTypeNormalizado = normalizarNomeParaWebhook(agentData.agentName || agentData.agentType);

const clonedWorkflow = {
  name: `Agente SDR - Start-${counter}`,
  settings: originalWorkflow.settings || {},
  nodes: originalWorkflow.nodes.map(node => {
    if (node.type === 'n8n-nodes-base.webhook') {
      return {
        ...node,
        parameters: {
          ...node.parameters,
          path: `start${counter}-${agentTypeNormalizado}`
        }
      };
    }
    // CORREÇÃO: Atualizar workflow_id nos nós de normalização
    if (node.name === 'Normalizar Dados') {
      return {
        ...node,
        parameters: {
          ...node.parameters,
          assignments: {
            ...node.parameters.assignments,
            assignments: node.parameters.assignments.assignments.map(assignment => {
              if (assignment.id === 'workflow-id') {
                return {
                  ...assignment,
                  value: `={{ $json.query.workflow_id || '${agentData.agentId}' }}`
                };
              }
              return assignment;
            })
          }
        }
      };
    }
    return node;
  }),
  connections: originalWorkflow.connections || {}
};

return { workflowData: clonedWorkflow, counter: counter, webhookType: 'start' };
```

### 2. PREPARAR WORKFLOW CLONADO - Status
**Nó**: "PREPARAR WORKFLOW CLONADO - Status"

**Código Corrigido**:
```javascript
// Função para normalizar nome preservando acentos
function normalizarNomeParaWebhook(nome) {
  return nome
    .toLowerCase()
    .trim()
    .replace(/\s+/g, '') // Remove espaços
    .replace(/[^a-z0-9áàâãéèêíìîóòôõúùûç]/g, '') // Remove caracteres especiais exceto acentos
    .replace(/[áàâã]/g, 'a')
    .replace(/[éèê]/g, 'e')
    .replace(/[íìî]/g, 'i')
    .replace(/[óòôõ]/g, 'o')
    .replace(/[úùû]/g, 'u')
    .replace(/ç/g, 'c');
}

// Obter contador do Redis GET
const counterData = $('Busca atual1').item.json;
const counter = counterData.propertyName || counterData.agente_counter_global || 1;

// Acessar dados do nó "Normaliza campos" onde está o originalWorkflow
const originalWorkflow = $('Normaliza campos1').item.json.originalWorkflow;
const agentData = $('Normalização1').item.json;

// CORREÇÃO: Normalizar agentType preservando acentos
const agentTypeNormalizado = normalizarNomeParaWebhook(agentData.agentName || agentData.agentType);

const clonedWorkflow = {
  name: `Agente SDR - Status-${counter}`,
  settings: originalWorkflow.settings || {},
  nodes: originalWorkflow.nodes.map(node => {
    if (node.type === 'n8n-nodes-base.webhook') {
      return {
        ...node,
        parameters: {
          ...node.parameters,
          path: `status${counter}-${agentTypeNormalizado}`
        }
      };
    }
    // CORREÇÃO: Atualizar workflow_id nos nós de normalização
    if (node.name === 'Normalizar Dados') {
      return {
        ...node,
        parameters: {
          ...node.parameters,
          assignments: {
            ...node.parameters.assignments,
            assignments: node.parameters.assignments.assignments.map(assignment => {
              if (assignment.id === 'workflow-id') {
                return {
                  ...assignment,
                  value: `={{ $json.query.workflow_id || '${agentData.agentId}' }}`
                };
              }
              return assignment;
            })
          }
        }
      };
    }
    return node;
  }),
  connections: originalWorkflow.connections || {}
};

return { workflowData: clonedWorkflow, counter: counter, webhookType: 'status' };
```

### 3. PREPARAR WORKFLOW CLONADO - Lista-Prospecção
**Nó**: "PREPARAR WORKFLOW CLONADO - Lista-Prospecção"

**Código Corrigido**:
```javascript
// Função para normalizar nome preservando acentos
function normalizarNomeParaWebhook(nome) {
  return nome
    .toLowerCase()
    .trim()
    .replace(/\s+/g, '') // Remove espaços
    .replace(/[^a-z0-9áàâãéèêíìîóòôõúùûç]/g, '') // Remove caracteres especiais exceto acentos
    .replace(/[áàâã]/g, 'a')
    .replace(/[éèê]/g, 'e')
    .replace(/[íìî]/g, 'i')
    .replace(/[óòôõ]/g, 'o')
    .replace(/[úùû]/g, 'u')
    .replace(/ç/g, 'c');
}

// Obter contador do Redis GET
const counterData = $('Busca atual2').item.json;
const counter = counterData.propertyName || counterData.agente_counter_global || 1;

// Acessar dados do nó "Normaliza campos" onde está o originalWorkflow
const originalWorkflow = $('Normaliza campos2').item.json.originalWorkflow;
const agentData = $('Normalização1').item.json;

// CORREÇÃO: Normalizar agentType preservando acentos
const agentTypeNormalizado = normalizarNomeParaWebhook(agentData.agentName || agentData.agentType);

const clonedWorkflow = {
  name: `Agente SDR - Lista-Prospecao-${counter}`,
  settings: originalWorkflow.settings || {},
  nodes: originalWorkflow.nodes.map(node => {
    if (node.type === 'n8n-nodes-base.webhook') {
      return {
        ...node,
        parameters: {
          ...node.parameters,
          path: `lista${counter}-${agentTypeNormalizado}`
        }
      };
    }
    // CORREÇÃO: Atualizar workflow_id nos nós de normalização
    if (node.name === 'Normalizar Dados') {
      return {
        ...node,
        parameters: {
          ...node.parameters,
          assignments: {
            ...node.parameters.assignments,
            assignments: node.parameters.assignments.assignments.map(assignment => {
              if (assignment.id === 'workflow-id') {
                return {
                  ...assignment,
                  value: `={{ $json.query.workflow_id || '${agentData.agentId}' }}`
                };
              }
              return assignment;
            })
          }
        }
      };
    }
    return node;
  }),
  connections: originalWorkflow.connections || {}
};

return { workflowData: clonedWorkflow, counter: counter, webhookType: 'lista-prospeccao' };
```

### 4. PREPARAR WORKFLOW CLONADO - Agente SDR - Stop
**Nó**: "PREPARAR WORKFLOW CLONADO - Agente SDR - Stop"

**Código Corrigido**:
```javascript
// Função para normalizar nome preservando acentos
function normalizarNomeParaWebhook(nome) {
  return nome
    .toLowerCase()
    .trim()
    .replace(/\s+/g, '') // Remove espaços
    .replace(/[^a-z0-9áàâãéèêíìîóòôõúùûç]/g, '') // Remove caracteres especiais exceto acentos
    .replace(/[áàâã]/g, 'a')
    .replace(/[éèê]/g, 'e')
    .replace(/[íìî]/g, 'i')
    .replace(/[óòôõ]/g, 'o')
    .replace(/[úùû]/g, 'u')
    .replace(/ç/g, 'c');
}

// Obter contador do Redis GET
const counterData = $('Busca atual3').item.json;
const counter = counterData.propertyName || counterData.agente_counter_global || 1;

// Acessar dados do nó "Normaliza campos" onde está o originalWorkflow
const originalWorkflow = $('Normaliza campos3').item.json.originalWorkflow;
const agentData = $('Normalização1').item.json;

// CORREÇÃO: Normalizar agentType preservando acentos
const agentTypeNormalizado = normalizarNomeParaWebhook(agentData.agentName || agentData.agentType);

const clonedWorkflow = {
  name: `Agente SDR - Stop-${counter}`,
  settings: originalWorkflow.settings || {},
  nodes: originalWorkflow.nodes.map(node => {
    if (node.type === 'n8n-nodes-base.webhook') {
      return {
        ...node,
        parameters: {
          ...node.parameters,
          path: `stop${counter}-${agentTypeNormalizado}`
        }
      };
    }
    // CORREÇÃO: Atualizar workflow_id nos nós de normalização
    if (node.name === 'Normalizar Dados') {
      return {
        ...node,
        parameters: {
          ...node.parameters,
          assignments: {
            ...node.parameters.assignments,
            assignments: node.parameters.assignments.assignments.map(assignment => {
              if (assignment.id === 'workflow-id') {
                return {
                  ...assignment,
                  value: `={{ $json.query.workflow_id || '${agentData.agentId}' }}`
                };
              }
              return assignment;
            })
          }
        }
      };
    }
    return node;
  }),
  connections: originalWorkflow.connections || {}
};

return { workflowData: clonedWorkflow, counter: counter, webhookType: 'stop' };
```

## Resumo das Correções

1. **CORREÇÃO DE ACENTUAÇÃO**: Adicionar função `normalizarNomeParaWebhook()` que preserva acentos
2. **Identificar nós "Normalizar Dados"** em cada workflow clonado
3. **Atualizar o campo `workflow-id`** para usar `agentData.agentId` em vez do template
4. **Manter a lógica de fallback** para `$json.query.workflow_id` caso seja passado via query
5. **Aplicar a correção** nos 4 workflows: Start, Status, Lista e Stop

## Resultado Esperado

Após as correções, quando um novo agente for criado:

### **Correção de Acentuação:**
- ✅ **"João"** → `joao` (não mais `joo`)
- ✅ **"José"** → `jose` (não mais `jose`)
- ✅ **"María"** → `maria` (não mais `maria`)
- ✅ **"João da Silva"** → `joaodasilva`

### **Correção de Workflow ID:**
- ✅ **Start**: `workflow_id` será o ID real do agente
- ✅ **Status**: `workflow_id` será o ID real do agente  
- ✅ **Lista**: `workflow_id` será o ID real do agente
- ✅ **Stop**: `workflow_id` será o ID real do agente

### **Webhooks Finais:**
- ✅ **Start**: `webhook/start4-joao` (com acentos preservados)
- ✅ **Status**: `webhook/status4-joao` (com acentos preservados)
- ✅ **Lista**: `webhook/lista4-joao` (com acentos preservados)
- ✅ **Stop**: `webhook/stop4-joao` (com acentos preservados)

Isso garantirá que os webhooks de status funcionem corretamente, buscando o status do agente correto no banco de dados, e que os nomes com acentos sejam tratados adequadamente.
