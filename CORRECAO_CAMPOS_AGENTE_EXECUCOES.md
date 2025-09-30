# 🔧 Correção: Campos da Tabela `agente_execucoes`

## 💡 Problema Identificado

A query estava usando campos incorretos para a tabela de execuções:
- ❌ **Antes**: `execucoes` com campo `agente_id`
- ✅ **Depois**: `agente_execucoes` com campo `id`

## ✅ Correções Aplicadas

### **1. Query SQL (`query-agentes-webhooks.sql`)**

**Antes:**
```sql
-- Status de execução (se existir tabela execucoes)
COALESCE(
    (SELECT status FROM execucoes WHERE agente_id = ac.id ORDER BY created_at DESC LIMIT 1),
    'stopped'
) as status_atual,

-- Execution ID ativo (se existir tabela execucoes)
(
    SELECT execution_id 
    FROM execucoes 
    WHERE agente_id = ac.id AND status = 'running'
    ORDER BY created_at DESC LIMIT 1
) as execution_id_ativo
```

**Depois:**
```sql
-- Status de execução (usando tabela agente_execucoes)
COALESCE(
    (SELECT status FROM agente_execucoes WHERE id = ac.id ORDER BY created_at DESC LIMIT 1),
    'stopped'
) as status_atual,

-- Execution ID ativo (usando tabela agente_execucoes)
(
    SELECT execution_id 
    FROM agente_execucoes 
    WHERE id = ac.id AND status = 'running'
    ORDER BY created_at DESC LIMIT 1
) as execution_id_ativo
```

### **2. Node "Prepara Json" (`node-prepara-json-corrigido.js`)**

**Antes:**
```javascript
return {
  id: data.id,
  nome: data.nome,
  workflow_id: data.workflow_id,        // ❌ Campo não existe
  webhook_url: data.webhook_url,        // ❌ Campo não existe
  descricao: data.descricao,
  icone: data.icone || '🤖',
  cor: data.cor || 'bg-blue-500',
  ativo: data.ativo,
  created_at: data.created_at,
  updated_at: data.updated_at
};
```

**Depois:**
```javascript
return {
  // Campos básicos
  id: data.id,
  nome: data.nome,
  descricao: data.descricao,
  icone: data.icone || '🤖',
  cor: data.cor || 'bg-blue-500',
  ativo: data.ativo,
  created_at: data.created_at,
  updated_at: data.updated_at,
  
  // Workflow IDs (para referência)
  workflow_start_id: data.workflow_start_id,
  workflow_status_id: data.workflow_status_id,
  workflow_lista_id: data.workflow_lista_id,
  workflow_stop_id: data.workflow_stop_id,
  
  // Webhook URLs específicos (o que realmente importa)
  webhook_start_url: data.webhook_start_url,
  webhook_status_url: data.webhook_status_url,
  webhook_lista_url: data.webhook_lista_url,
  webhook_stop_url: data.webhook_stop_url,
  
  // Status de execução
  status_atual: data.status_atual,
  execution_id_ativo: data.execution_id_ativo
};
```

### **3. Hook TypeScript (`useAgentSyncWebhooks.ts`)**

**Atualizado:**
```typescript
interface AgentData {
  // ... campos básicos ...
  
  // Status básico de execução (da tabela agente_execucoes)
  status_atual?: string
  execution_id_ativo?: string
}
```

## 📊 Estrutura de Resposta Esperada

### **Resposta do Webhook `list-agentes`:**
```json
{
  "success": true,
  "message": "Agentes encontrados",
  "data": [
    {
      "id": 59,
      "nome": "Zeca",
      "descricao": "",
      "icone": "🤖",
      "cor": "bg-blue-500",
      "ativo": true,
      "created_at": "2025-09-21T16:42:21.951Z",
      "updated_at": "2025-09-21T16:42:21.951Z",
      
      // Workflow IDs
      "workflow_start_id": "jA48xT8ybzAjiPG2",
      "workflow_status_id": "eZBRGWEF95E1qDPj",
      "workflow_lista_id": "BUwu4Tg1HhhGP0D5",
      "workflow_stop_id": "2BjCVbtg1RWc2EBi",
      
      // Webhook URLs específicos
      "webhook_start_url": "webhook/start3-zeca",
      "webhook_status_url": "webhook/status3-zeca",
      "webhook_lista_url": "webhook/lista3-zeca",
      "webhook_stop_url": "webhook/stop3-zeca",
      
      // Status de execução
      "status_atual": "stopped",
      "execution_id_ativo": null
    }
  ],
  "total": 1,
  "timestamp": "2025-09-21T12:30:48.310Z"
}
```

## 🎯 Benefícios das Correções

### **1. Campos Corretos:**
- ✅ **Tabela correta**: `agente_execucoes` em vez de `execucoes`
- ✅ **Campo correto**: `id` em vez de `agente_id`
- ✅ **Webhooks específicos**: Todos os campos de webhook incluídos

### **2. Mapeamento Completo:**
- ✅ **Todos os campos** da query mapeados no JSON
- ✅ **Workflow IDs** incluídos para referência
- ✅ **Webhook URLs** específicos para cada agente
- ✅ **Status de execução** da tabela correta

### **3. Compatibilidade:**
- ✅ **Frontend** recebe todos os dados necessários
- ✅ **Webhooks específicos** registrados automaticamente
- ✅ **Status real** da execução dos agentes

## 🚀 Próximos Passos

1. **Atualizar workflow N8N** com a query corrigida
2. **Substituir node "Prepara Json"** pelo código corrigido
3. **Testar resposta** do webhook atualizado
4. **Verificar webhooks específicos** funcionando
5. **Confirmar status** de execução correto

## 📁 Arquivos Atualizados

- ✅ `query-agentes-webhooks.sql` - Query com campos corretos
- ✅ `node-prepara-json-corrigido.js` - Node com mapeamento completo
- ✅ `useAgentSyncWebhooks.ts` - Hook atualizado
- ✅ `SISTEMA_WEBHOOKS_ESPECIFICOS.md` - Documentação corrigida

**Status**: ✅ CORREÇÕES APLICADAS - PRONTO PARA TESTE
