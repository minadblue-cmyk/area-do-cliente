# 🔍 Solução: Query Unificada para Agentes

## 💡 Problema Identificado

O `list-agentes` atual retorna apenas informações básicas dos agentes, mas a tabela `agentes_config` tem muito mais dados úteis:

- **Webhook URLs específicos** (`webhook_start_url`, `webhook_stop_url`, etc.)
- **Workflow IDs** (`workflow_start_id`, `workflow_status_id`, etc.)
- **Informações de status** (prospects, execuções, etc.)

## ✅ Solução Proposta

### **1. Query SQL Unificada**

```sql
SELECT 
    -- Campos básicos
    ac.id, ac.nome, ac.descricao, ac.icone, ac.cor, ac.ativo,
    ac.created_at, ac.updated_at,
    
    -- Workflow IDs
    ac.workflow_start_id, ac.workflow_status_id, 
    ac.workflow_lista_id, ac.workflow_stop_id,
    
    -- Webhook URLs específicos
    ac.webhook_start_url, ac.webhook_status_url,
    ac.webhook_lista_url, ac.webhook_stop_url,
    
    -- Informações de status (subqueries)
    COALESCE(
        (SELECT COUNT(*) FROM prospects WHERE agente_id = ac.id AND ativo = true),
        0
    ) as total_prospects,
    
    COALESCE(
        (SELECT status FROM execucoes WHERE agente_id = ac.id ORDER BY created_at DESC LIMIT 1),
        'stopped'
    ) as status_atual,
    
    (
        SELECT execution_id 
        FROM execucoes 
        WHERE agente_id = ac.id AND status = 'running'
        ORDER BY created_at DESC LIMIT 1
    ) as execution_id_ativo

FROM agentes_config ac
WHERE ac.ativo = true
ORDER BY ac.nome;
```

### **2. Benefícios da Query Unificada**

#### **🎯 Informações Completas:**
- **Webhooks específicos** de cada agente
- **Status em tempo real** das execuções
- **Contadores de prospects** ativos
- **IDs de workflow** para referência

#### **⚡ Performance:**
- **Uma única query** em vez de múltiplas
- **Subqueries otimizadas** para dados relacionados
- **Cache eficiente** no frontend

#### **🔧 Configuração Automática:**
- **Webhooks específicos** registrados automaticamente
- **Status real** sem necessidade de polling adicional
- **Informações de contexto** para melhor UX

## 🚀 Implementação

### **1. Atualizar Workflow N8N**

Substituir a query atual no node PostgreSQL por:

```sql
-- Usar a query do arquivo query-agentes-simples.sql
```

### **2. Frontend Enhanced**

Criado `useAgentSyncEnhanced` que:

- **Usa webhooks específicos** quando disponíveis
- **Fallback para webhooks padrão** quando não disponíveis
- **Informações de status** em tempo real
- **Cache inteligente** para performance

### **3. Estrutura de Resposta Esperada**

```json
{
  "success": true,
  "data": [
    {
      "id": 59,
      "nome": "Zeca",
      "descricao": "Agente de prospecção",
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
      
      // Status em tempo real
      "total_prospects": 15,
      "prospects_pendentes": 8,
      "status_atual": "running",
      "execution_id_ativo": "abc123def456"
    }
  ]
}
```

## 🔄 Fluxo de Funcionamento

### **1. Detecção de Agente:**
```typescript
// Sistema detecta agente com webhooks específicos
onAgentAdded: (agentId, agentData) => {
  // agentData.webhook_start_url = "webhook/start3-zeca"
  // agentData.status_atual = "running"
  // agentData.total_prospects = 15
}
```

### **2. Registro de Webhooks:**
```typescript
// Registra webhooks específicos se disponíveis
if (agent.webhook_start_url) {
  addWebhook(`webhook/start-${agentId}`, `https://n8n.code-iq.com.br/${agent.webhook_start_url}`)
} else {
  // Fallback para webhooks padrão
  registerAllAgentWebhooks(agentId, agent.nome)
}
```

### **3. Status em Tempo Real:**
```typescript
// Interface mostra status real
const agent = getAgentById("59")
console.log(agent.status_atual) // "running"
console.log(agent.total_prospects) // 15
console.log(agent.execution_id_ativo) // "abc123def456"
```

## 📊 Comparação: Antes vs Depois

### **❌ Antes (Query Simples):**
```json
{
  "id": 59,
  "nome": "Zeca",
  "ativo": true
  // Sem webhooks específicos
  // Sem status em tempo real
  // Sem informações de prospects
}
```

### **✅ Depois (Query Unificada):**
```json
{
  "id": 59,
  "nome": "Zeca",
  "ativo": true,
  "webhook_start_url": "webhook/start3-zeca",
  "status_atual": "running",
  "total_prospects": 15,
  "execution_id_ativo": "abc123def456"
  // Todas as informações necessárias
}
```

## 🎯 Próximos Passos

1. **Atualizar workflow N8N** com a nova query
2. **Testar resposta** do webhook atualizado
3. **Integrar `useAgentSyncEnhanced`** no frontend
4. **Verificar webhooks específicos** funcionando
5. **Confirmar status em tempo real**

## 💡 Vantagens Adicionais

- **Menos requisições** ao banco de dados
- **Informações mais ricas** para o frontend
- **Configuração automática** de webhooks
- **Status real** sem polling adicional
- **Melhor experiência** do usuário

**Status**: ✅ SOLUÇÃO PRONTA PARA IMPLEMENTAÇÃO
