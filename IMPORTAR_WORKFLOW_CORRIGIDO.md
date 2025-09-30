# 🚀 Como Importar o Workflow Corrigido no n8n

## 🚨 **Problema Atual**
O webhook `create-agente` está retornando resposta vazia porque o workflow no n8n ainda não foi atualizado com as correções.

## ✅ **Solução: Importar Workflow Corrigido**

### **Passo 1: Acessar o n8n**
1. Abra `https://n8n.code-iq.com.br`
2. Faça login com suas credenciais

### **Passo 2: Importar o Workflow**
1. Clique em **"Import"** (ou **"Importar"**)
2. Selecione **"From File"** (ou **"Do Arquivo"**)
3. Escolha o arquivo `create-agente-workflow-fixed.json`
4. Clique em **"Import"**

### **Passo 3: Ativar o Workflow**
1. Após a importação, abra o workflow
2. Clique no botão **"Activate"** (ou **"Ativar"**)
3. Confirme a ativação

### **Passo 4: Verificar Webhook**
1. Vá para **"Webhooks"** no menu lateral
2. Verifique se o webhook `create-agente` está listado
3. Anote a URL completa do webhook

### **Passo 5: Testar**
Execute o teste novamente:
```bash
node test-create-agente-detailed.js
```

## 🔧 **Alternativa: Corrigir Workflow Existente**

Se preferir corrigir o workflow existente:

### **1. Abrir o Workflow Atual**
1. Acesse `https://n8n.code-iq.com.br`
2. Encontre o workflow "Create Agente"
3. Abra para edição

### **2. Corrigir o Nó "Modificar Webhook Path"**
1. Clique no nó "Modificar Webhook Path"
2. Vá para a aba **"Code"**
3. Substitua o código pelo código corrigido:

```javascript
// Modificar webhook path baseado no tipo - VERSÃO CORRIGIDA
const workflowData = $json;
const agentType = $('Normalizar Dados').item.json.agentType;
const webhookType = $('Encontrar Templates').item.json.webhookType;

console.log('🔧 Modificando webhook para:', webhookType);
console.log('🔧 Agent Type:', agentType);
console.log('🔧 Workflow Data recebido:', workflowData);

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
```

### **3. Salvar e Ativar**
1. Clique em **"Save"** (ou **"Salvar"**)
2. Clique em **"Activate"** (ou **"Ativar"**)

## 🧪 **Teste Final**

Após importar ou corrigir o workflow, execute:

```bash
node test-create-agente-detailed.js
```

### **Resultado Esperado:**
```json
{
  "success": true,
  "message": "Agente criado com sucesso",
  "agentId": "TESTE_FIX_123",
  "agentName": "Agente Teste Fix",
  "workflowId": "workflow_id_gerado",
  "webhookUrl": "webhook/start-agente-teste-fix",
  "webhookType": "start",
  "timestamp": "2025-09-20T23:45:06.000Z",
  "executionId": "execution_id"
}
```

## ⚠️ **Importante**

- O arquivo `create-agente-workflow-fixed.json` contém todas as correções
- Certifique-se de que o workflow está **ATIVO** após a importação
- Verifique se o webhook está funcionando antes de testar
