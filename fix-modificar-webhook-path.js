// 🔧 Código corrigido para o nó "Modificar Webhook Path"

// Modificar webhook path baseado no tipo
const workflowData = $json;
const agentType = $('Normalizar Dados').item.json.agentType;
const webhookType = $('Encontrar Templates').item.json.webhookType;

console.log('🔧 Modificando webhook para:', webhookType);
console.log('🔧 Agent Type:', agentType);
console.log('🔧 Workflow Data:', workflowData);

// Verificar se workflowData tem a estrutura esperada
if (!workflowData) {
  console.log('❌ workflowData está undefined');
  return [{
    json: {
      error: 'workflowData is undefined',
      webhookType: webhookType,
      agentType: agentType
    }
  }];
}

// Verificar se tem nodes
if (!workflowData.nodes) {
  console.log('❌ workflowData.nodes está undefined');
  console.log('🔍 Estrutura do workflowData:', Object.keys(workflowData));
  
  // Tentar acessar nodes de diferentes formas
  const possibleNodes = workflowData.data?.nodes || workflowData.nodes || workflowData.body?.nodes;
  
  if (possibleNodes) {
    console.log('✅ Encontrou nodes em data.nodes ou body.nodes');
    workflowData.nodes = possibleNodes;
  } else {
    console.log('❌ Não foi possível encontrar nodes');
    return [{
      json: {
        error: 'nodes not found in workflowData',
        webhookType: webhookType,
        agentType: agentType,
        availableKeys: Object.keys(workflowData)
      }
    }];
  }
}

// Mapear tipos para paths
const webhookPaths = {
  'start': `start-${agentType}`,
  'status': `status-${agentType}`,
  'lista': `lista-${agentType}`,
  'stop': `stop-${agentType}`
};

const newPath = webhookPaths[webhookType] || `start-${agentType}`;

console.log('🔧 Novo path do webhook:', newPath);
console.log('🔧 Nodes encontrados:', workflowData.nodes.length);

// Encontrar o nó webhook no workflow
const modifiedNodes = workflowData.nodes.map(node => {
  if (node.type === 'n8n-nodes-base.webhook') {
    console.log('🔧 Modificando nó webhook:', node.name);
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

console.log('✅ Modificação concluída');

return [{
  json: {
    ...workflowData,
    nodes: modifiedNodes,
    webhookPath: newPath,
    webhookType: webhookType
  }
}];
