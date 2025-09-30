# 🔧 GUIA DE ATUALIZAÇÃO DO TEMPLATE DE AGENTE

## 📋 **ALTERAÇÕES NECESSÁRIAS NO TEMPLATE:**

### **1. CORRIGIR CHAVES REDIS (CRÍTICO)**

#### **Nó "Cria chave running":**
```json
{
  "parameters": {
    "operation": "set",
    "key": "=agente_execution:{{ $execution.id }}",
    "value": "running"
  }
}
```

#### **Nó "Redis Status Check":**
```json
{
  "parameters": {
    "operation": "get",
    "key": "=agente_execution:{{ $execution.id }}",
    "options": {}
  }
}
```

#### **Nó "Redis1" (no Loop):**
```json
{
  "parameters": {
    "operation": "set",
    "key": "=agente_execution:{{ $execution.id }}",
    "value": "stopped",
    "expire": true,
    "ttl": 3600
  }
}
```

### **2. ADICIONAR CONFIGURAÇÕES DE RETRY**

#### **Nó "Humanizador de saudação":**
```json
{
  "retryOnFail": true,
  "waitBetweenTries": 2000
}
```

#### **Nó "Fragmentador de mensagens":**
```json
{
  "retryOnFail": true,
  "waitBetweenTries": 2000
}
```

### **3. SUBSTITUIR "prep_out" POR "Execute Workflow"**

#### **Remover nó "prep_out" e adicionar:**
```json
{
  "parameters": {
    "workflowId": {
      "__rl": true,
      "value": "FCSvSi9tbnQva6z8",
      "mode": "list",
      "cachedResultName": "Envio WhatsApp Agente SDR"
    },
    "workflowInputs": {
      "mappingMode": "defineBelow",
      "value": {},
      "matchingColumns": [],
      "schema": [],
      "attemptToConvertTypes": false,
      "convertFieldsToString": true
    },
    "options": {
      "waitForSubWorkflow": false
    }
  },
  "type": "n8n-nodes-base.executeWorkflow",
  "typeVersion": 1.2,
  "position": [5184, 1600],
  "id": "089d715c-e102-4a2b-bb13-5bb15ae9647b",
  "name": "Execute Workflow"
}
```

### **4. ATUALIZAR CONEXÕES**

#### **Fragmentador de mensagens → Execute Workflow:**
```json
"Fragmentador de mensagens": {
  "main": [
    [
      {
        "node": "Execute Workflow",
        "type": "main",
        "index": 0
      }
    ]
  ]
}
```

#### **Execute Workflow → Atualiza lead contatado:**
```json
"Execute Workflow": {
  "main": [
    [
      {
        "node": "Atualiza lead contatado",
        "type": "main",
        "index": 0
      }
    ]
  ]
}
```

### **5. ADICIONAR CAMPO execution_id_da_ultima_execucao**

#### **No nó "Iniciar Agente":**
```json
{
  "id": "execution_id_da_ultima_execucao",
  "displayName": "execution_id_da_ultima_execucao",
  "required": false,
  "defaultMatch": false,
  "display": true,
  "type": "string",
  "canBeUsedToMatch": true,
  "removed": false
}
```

### **6. CONFIGURAÇÕES DE WORKFLOW**

#### **Adicionar no settings:**
```json
{
  "settings": {
    "executionOrder": "v1",
    "timezone": "America/Sao_Paulo",
    "callerPolicy": "workflowsFromSameOwner",
    "saveExecutionProgress": true
  }
}
```

## ✅ **RESULTADO ESPERADO:**

Após essas alterações, o template terá:
- ✅ Chaves Redis consistentes com o agente funcional
- ✅ Retry automático em nós críticos
- ✅ Integração com workflow de envio WhatsApp
- ✅ Mesma estrutura de controle de status
- ✅ Compatibilidade total com o frontend dinâmico

## 🚀 **PRÓXIMOS PASSOS:**

1. Aplicar as alterações no template
2. Testar criação de novo agente
3. Verificar se webhooks são gerados corretamente
4. Confirmar funcionamento no frontend
