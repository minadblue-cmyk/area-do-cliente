// 🔧 Exemplo de Correção dos Webhook Names no n8n

// 1. NÓ "Encontrar Templates" - Modificado
const findTemplatesCorrected = () => {
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
          webhookType: templateConfig.webhookType, // ← TIPO ESPECÍFICO
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
};

// 2. NÓ "Clonar Workflow" - Modificado
const cloneWorkflowCorrected = () => {
  return {
    url: "https://n8n.code-iq.com.br/api/v1/workflows/{{ $json.id }}/duplicate",
    method: "POST",
    jsonBody: {
      name: "{{ $('Normalizar Dados').item.json.agentName }} - {{ $json.webhookType }}",
      active: false
    }
  };
};

// 3. NÓ "Modificar Webhook Path" - NOVO
const modifyWebhookPath = () => {
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
};

// 4. NÓ "Atualizar Workflow" - NOVO
const updateWorkflow = () => {
  return {
    url: "https://n8n.code-iq.com.br/api/v1/workflows/{{ $json.id }}",
    method: "PUT",
    jsonBody: {
      name: "{{ $json.name }}",
      nodes: "{{ $json.nodes }}",
      connections: "{{ $json.connections }}",
      active: false
    }
  };
};

// 5. NÓ "Ativar Workflow" - Existente
const activateWorkflow = () => {
  return {
    url: "https://n8n.code-iq.com.br/api/v1/workflows/{{ $json.id }}/activate",
    method: "POST"
  };
};

// FLUXO COMPLETO CORRIGIDO
const workflowFlow = `
[Webhook Create Agente] 
    ↓
[Normalizar Dados]
    ↓
[Buscar Templates] → [Encontrar Templates] ← Modificado
    ↓
[Clonar Workflow] ← Modificado
    ↓
[Modificar Webhook Path] ← NOVO
    ↓
[Atualizar Workflow] ← NOVO
    ↓
[Ativar Workflow]
    ↓
[Prepara Json] → [Respond to Webhook]
`;

// RESULTADO ESPERADO
const expectedResult = {
  "success": true,
  "message": "Agente criado com sucesso",
  "agentId": "TESTE_FIX_123",
  "agentName": "Agente Teste Fix",
  "workflowId": "workflow_id_gerado",
  "webhookUrl": "webhook/start-agente-teste-fix",
  "timestamp": "2025-09-20T23:31:42.251-04:00",
  "executionId": "49088",
  "workflowsCreated": {
    "start": "webhook/start-agente-teste-fix",
    "status": "webhook/status-agente-teste-fix", 
    "lista": "webhook/lista-agente-teste-fix",
    "stop": "webhook/stop-agente-teste-fix"
  }
};

console.log('🔧 Exemplo de correção dos webhook names');
console.log('📋 Fluxo:', workflowFlow);
console.log('🎯 Resultado esperado:', expectedResult);
