# 🎯 Sistema de Webhooks Específicos por Agente

## 💡 Objetivo

Criar um sistema que automaticamente detecte e configure os **webhooks específicos** de cada agente recém-criado, permitindo que o frontend use os webhooks corretos sem conflitos.

## 🔍 Estrutura Atual

### **Tabela `agentes_config`:**
```sql
-- Campos básicos
id, nome, descricao, icone, cor, ativo, created_at, updated_at

-- Workflow IDs (referência)
workflow_start_id, workflow_status_id, workflow_lista_id, workflow_stop_id

-- Webhook URLs específicos (o que importa)
webhook_start_url, webhook_status_url, webhook_lista_url, webhook_stop_url
```

### **Exemplo de Dados:**
```json
{
  "id": 59,
  "nome": "Zeca",
  "descricao": "Agente de prospecção",
  "icone": "🤖",
  "cor": "bg-blue-500",
  "ativo": true,
  
  "workflow_start_id": "jA48xT8ybzAjiPG2",
  "workflow_status_id": "eZBRGWEF95E1qDPj",
  "workflow_lista_id": "BUwu4Tg1HhhGP0D5",
  "workflow_stop_id": "2BjCVbtg1RWc2EBi",
  
  "webhook_start_url": "webhook/start3-zeca",
  "webhook_status_url": "webhook/status3-zeca",
  "webhook_lista_url": "webhook/lista3-zeca",
  "webhook_stop_url": "webhook/stop3-zeca"
}
```

## ✅ Solução Implementada

### **1. Query Simplificada (`query-agentes-webhooks.sql`)**

```sql
SELECT 
    -- Campos básicos do agente
    ac.id, ac.nome, ac.descricao, ac.icone, ac.cor, ac.ativo,
    ac.created_at, ac.updated_at,
    
    -- Workflow IDs (para referência)
    ac.workflow_start_id, ac.workflow_status_id,
    ac.workflow_lista_id, ac.workflow_stop_id,
    
    -- Webhook URLs específicos (o que realmente importa)
    ac.webhook_start_url, ac.webhook_status_url,
    ac.webhook_lista_url, ac.webhook_stop_url,
    
    -- Status básico de execução (usando tabela agente_execucoes)
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

FROM agentes_config ac
WHERE ac.ativo = true
ORDER BY ac.nome;
```

### **2. Hook Especializado (`useAgentSyncWebhooks`)**

**Características:**
- ✅ **Foco apenas em webhooks** (sem misturar status de leads)
- ✅ **Detecção automática** de novos agentes
- ✅ **Registro automático** de webhooks específicos
- ✅ **Fallback para webhooks padrão** quando necessário
- ✅ **Cache inteligente** (15 segundos)
- ✅ **Rate limiting** (mínimo 10 segundos entre syncs)

### **3. Fluxo de Funcionamento**

#### **Detecção de Novo Agente:**
```typescript
onAgentAdded: (agentId, agentData) => {
  // agentData.webhook_start_url = "webhook/start3-zeca"
  // agentData.webhook_stop_url = "webhook/stop3-zeca"
  // agentData.webhook_status_url = "webhook/status3-zeca"
  // agentData.webhook_lista_url = "webhook/lista3-zeca"
}
```

#### **Registro Automático de Webhooks:**
```typescript
// Se tem webhooks específicos
if (agent.webhook_start_url) {
  addWebhook(`webhook/start-${agentId}`, `https://n8n.code-iq.com.br/${agent.webhook_start_url}`)
  addWebhook(`webhook/stop-${agentId}`, `https://n8n.code-iq.com.br/${agent.webhook_stop_url}`)
  addWebhook(`webhook/status-${agentId}`, `https://n8n.code-iq.com.br/${agent.webhook_status_url}`)
  addWebhook(`webhook/lista-${agentId}`, `https://n8n.code-iq.com.br/${agent.webhook_lista_url}`)
} else {
  // Fallback para webhooks padrão
  registerAllAgentWebhooks(agentId, agent.nome)
}
```

## 🎯 Benefícios

### **1. Configuração Automática:**
- **Novos agentes** são detectados automaticamente
- **Webhooks específicos** são registrados automaticamente
- **Sem intervenção manual** necessária

### **2. Flexibilidade:**
- **Webhooks específicos** quando disponíveis
- **Webhooks padrão** como fallback
- **Compatibilidade** com sistema existente

### **3. Performance:**
- **Cache inteligente** reduz chamadas desnecessárias
- **Rate limiting** previne sobrecarga
- **Sincronização otimizada** (30 segundos)

### **4. Separação de Responsabilidades:**
- **Webhooks de agente** → `useAgentSyncWebhooks`
- **Status de leads** → webhook específico `lista-prospeccao`
- **Status de execução** → webhook específico `status-agente`

## 📊 Comparação: Antes vs Depois

### **❌ Antes:**
```typescript
// Webhooks hardcoded ou genéricos
const webhookStart = "webhook/start-agente1"
const webhookStop = "webhook/stop-agente1"
// Conflitos entre agentes
```

### **✅ Depois:**
```typescript
// Webhooks específicos por agente
const webhookStart = "webhook/start3-zeca"  // Específico do Zeca
const webhookStop = "webhook/stop3-zeca"    // Específico do Zeca
const webhookStatus = "webhook/status3-zeca" // Específico do Zeca
const webhookLista = "webhook/lista3-zeca"   // Específico do Zeca
// Sem conflitos
```

## 🚀 Implementação

### **1. Atualizar Workflow N8N:**
- Substituir query atual por `query-agentes-webhooks.sql`
- Testar resposta do webhook atualizado

### **2. Integrar Hook no Frontend:**
```typescript
import { useAgentSyncWebhooks } from '../hooks/useAgentSyncWebhooks'

const { agents, getAgentWebhooks, hasSpecificWebhooks } = useAgentSyncWebhooks({
  autoSync: true,
  syncInterval: 30000,
  onAgentAdded: (agentId, agentData) => {
    console.log(`✅ Agente ${agentData.nome} configurado automaticamente`)
  }
})
```

### **3. Usar Webhooks Específicos:**
```typescript
// Para agente específico
const webhooks = getAgentWebhooks("59")
console.log(webhooks.start)   // "webhook/start3-zeca"
console.log(webhooks.stop)    // "webhook/stop3-zeca"
console.log(webhooks.status)  // "webhook/status3-zeca"
console.log(webhooks.lista)   // "webhook/lista3-zeca"
```

## 🎯 Próximos Passos

1. **Atualizar workflow N8N** com `query-agentes-webhooks.sql`
2. **Testar resposta** do webhook atualizado
3. **Integrar `useAgentSyncWebhooks`** no frontend
4. **Verificar webhooks específicos** funcionando
5. **Confirmar detecção automática** de novos agentes

## 💡 Vantagens Adicionais

- **Zero configuração manual** para novos agentes
- **Webhooks únicos** por agente (sem conflitos)
- **Sistema robusto** com fallbacks
- **Performance otimizada** com cache
- **Fácil manutenção** e debug

**Status**: ✅ SOLUÇÃO FOCADA EM WEBHOOKS PRONTA
