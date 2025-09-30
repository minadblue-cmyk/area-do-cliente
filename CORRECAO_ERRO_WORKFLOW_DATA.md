# 🔧 Correção do Erro "Cannot read properties of undefined (reading 'map')"

## 🚨 **Problema Identificado**

O erro `Cannot read properties of undefined (reading 'map')` na linha 22 do nó "Modificar Webhook Path" indica que `workflowData.nodes` está `undefined`.

## 🔍 **Causa Raiz**

O workflow clonado não está retornando a estrutura esperada. O nó "Buscar Workflow Clonado" pode estar retornando:
- Dados vazios
- Estrutura diferente da esperada
- Erro na API do n8n

## ✅ **Solução Implementada**

### 1. **Código Corrigido para "Modificar Webhook Path"**

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

### 2. **Verificações Adicionais**

#### **A. Verificar se o nó "Buscar Workflow Clonado" está funcionando**
- Verificar se a URL está correta
- Verificar se as credenciais estão configuradas
- Verificar se o workflow foi clonado com sucesso

#### **B. Verificar logs de execução**
- Acessar o n8n
- Abrir o workflow
- Verificar logs de execução
- Identificar onde está falhando

#### **C. Testar cada nó individualmente**
- Executar o nó "Buscar Workflow Clonado" isoladamente
- Verificar a resposta
- Ajustar conforme necessário

## 🚀 **Workflow Corrigido**

Use o arquivo `create-agente-workflow-fixed.json` que contém:

1. **Código corrigido** para "Modificar Webhook Path"
2. **Tratamento de erros** robusto
3. **Logs detalhados** para debugging
4. **Verificações de estrutura** de dados

## 📋 **Passos para Correção**

### **Opção 1: Importar Workflow Corrigido**
1. Acesse `https://n8n.code-iq.com.br`
2. Importe `create-agente-workflow-fixed.json`
3. Ative o workflow
4. Teste novamente

### **Opção 2: Corrigir Workflow Existente**
1. Abra o workflow atual
2. Edite o nó "Modificar Webhook Path"
3. Substitua o código pelo código corrigido acima
4. Salve e teste

## 🧪 **Teste de Validação**

Após a correção, execute:

```bash
node test-webhook-after-fix.js
```

### **Resultado Esperado**
```json
{
  "success": true,
  "message": "Agente criado com sucesso",
  "agentId": "TESTE_FIX_123",
  "agentName": "Agente Teste Fix",
  "workflowId": "workflow_id_gerado",
  "webhookUrl": "webhook/start-agente-teste-fix",
  "webhookType": "start",
  "timestamp": "2025-09-20T23:31:42.251-04:00",
  "executionId": "49088"
}
```

## 🔍 **Debugging Adicional**

Se o problema persistir:

1. **Verificar logs** do nó "Buscar Workflow Clonado"
2. **Verificar se** o workflow foi clonado com sucesso
3. **Verificar se** a API do n8n está funcionando
4. **Verificar se** as credenciais estão corretas

## ⚠️ **Notas Importantes**

- O código corrigido inclui **tratamento de erros** robusto
- **Logs detalhados** para facilitar debugging
- **Verificações múltiplas** para encontrar nodes
- **Fallbacks** para diferentes estruturas de dados
