# 🔧 Correção dos Nomes dos Webhooks

## Problema Identificado
Todos os workflows estão sendo criados com o mesmo nome baseado no `agent_type`, mas cada um precisa ter seu webhook path específico:

- **Start**: `webhook/start-{agent_type}`
- **Status**: `webhook/status-{agent_type}`
- **Lista**: `webhook/lista-{agent_type}`
- **Stop**: `webhook/stop-{agent_type}`

## Solução: Modificar os Nós de Clonagem

### 1. **Nó "Encontrar Templates" - Adicionar Tipo**

Modifique o nó "Encontrar Templates" para incluir o tipo de webhook:

```javascript
// Encontrar templates dos 4 workflows essenciais
const templates = $input.first().json.data || $input.first().json;
const agentName = $('Normalizar Dados').item.json.agentName;
const agentType = $('Normalizar Dados').item.json.agentType;

console.log('🔍 Procurando templates para:', agentName);
console.log('🔍 Agent Type:', agentType);

if (!Array.isArray(templates)) {
  console.log('❌ Templates não é um array!');
  return [];
}

// Templates essenciais para clonar com seus tipos
const essentialTemplates = [
  { name: 'start-agente', webhookType: 'start' },
  { name: 'stop-agente', webhookType: 'stop' },
  { name: 'status-agente', webhookType: 'status' },
  { name: 'lista-prospeccao-agente', webhookType: 'lista' }
];

const foundTemplates = [];

for (const templateConfig of essentialTemplates) {
  const template = templates.find(t => 
    t.name && t.name.toLowerCase().includes(templateConfig.name.toLowerCase())
  );
  
  if (template) {
    console.log(`✅ Template encontrado: ${template.name} (ID: ${template.id})`);
    foundTemplates.push({
      json: {
        id: template.id,
        name: template.name,
        webhookType: templateConfig.webhookType, // ← ADICIONAR TIPO
        agentName: agentName,
        agentType: agentType
      }
    });
  } else {
    console.log(`❌ Template não encontrado: ${templateConfig.name}`);
  }
}

console.log(`📊 Total de templates encontrados: ${foundTemplates.length}`);
return foundTemplates;
```

### 2. **Nó "Clonar Workflow" - Modificar Nome**

Modifique o nó "Clonar Workflow" para usar o tipo específico:

```json
{
  "url": "https://n8n.code-iq.com.br/api/v1/workflows/{{ $json.id }}/duplicate",
  "method": "POST",
  "jsonBody": "={{ {\n  \"name\": $('Normalizar Dados').item.json.agentName + \" - \" + $json.webhookType,\n  \"active\": false\n} }}"
}
```

### 3. **Adicionar Nó "Modificar Webhook Path"**

Adicione um nó após a clonagem para modificar o webhook path:

```javascript
// Modificar webhook path baseado no tipo
const workflowData = $json;
const agentType = $('Normalizar Dados').item.json.agentType;
const webhookType = $('Encontrar Templates').item.json.webhookType;

console.log('🔧 Modificando webhook para:', webhookType);
console.log('🔧 Agent Type:', agentType);

// Encontrar o nó webhook no workflow
const modifiedNodes = workflowData.nodes.map(node => {
  if (node.type === 'n8n-nodes-base.webhook') {
    const newPath = `start${webhookType === 'start' ? '' : '-' + webhookType}-${agentType}`;
    
    return {
      ...node,
      parameters: {
        ...node.parameters,
        path: newPath
      }
    };
  }
  return node;
});

return [{
  json: {
    ...workflowData,
    nodes: modifiedNodes,
    webhookType: webhookType
  }
}];
```

### 4. **Nó "Atualizar Workflow"**

Adicione um nó para atualizar o workflow com as modificações:

```json
{
  "url": "https://n8n.code-iq.com.br/api/v1/workflows/{{ $json.id }}",
  "method": "PUT",
  "jsonBody": "={{ {\n  \"name\": $json.name,\n  \"nodes\": $json.nodes,\n  \"connections\": $json.connections,\n  \"active\": false\n} }}"
}
```

## Fluxo Corrigido

```
[Encontrar Templates] → [Clonar Workflow] → [Modificar Webhook Path] → [Atualizar Workflow] → [Ativar Workflow]
```

## Resultado Esperado

Cada workflow será criado com:

- **Start**: `webhook/start-{agent_type}`
- **Status**: `webhook/status-{agent_type}`
- **Lista**: `webhook/lista-{agent_type}`
- **Stop**: `webhook/stop-{agent_type}`

## Exemplo de Implementação

### Nó "Modificar Webhook Path"

```javascript
// Modificar webhook path baseado no tipo
const workflowData = $json;
const agentType = $('Normalizar Dados').item.json.agentType;
const webhookType = $('Encontrar Templates').item.json.webhookType;

console.log('🔧 Modificando webhook para:', webhookType);
console.log('🔧 Agent Type:', agentType);

// Mapear tipos para paths
const webhookPaths = {
  'start': `start-${agentType}`,
  'status': `status-${agentType}`,
  'lista': `lista-${agentType}`,
  'stop': `stop-${agentType}`
};

const newPath = webhookPaths[webhookType] || `start-${agentType}`;

// Encontrar o nó webhook no workflow
const modifiedNodes = workflowData.nodes.map(node => {
  if (node.type === 'n8n-nodes-base.webhook') {
    return {
      ...node,
      parameters: {
        ...node.parameters,
        path: newPath
      }
    };
  }
  return node;
});

return [{
  json: {
    ...workflowData,
    nodes: modifiedNodes,
    webhookPath: newPath
  }
}];
```

## Teste de Validação

Após implementar, teste com:

```bash
node test-webhook-after-fix.js
```

Verifique se os workflows são criados com os webhook paths corretos.
