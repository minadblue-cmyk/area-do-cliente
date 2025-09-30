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
    return node; // Retorna o nó original se não for webhook
  }),
  connections: originalWorkflow.connections || {}
};

return { workflowData: clonedWorkflow, counter: counter, webhookType: 'start' };
