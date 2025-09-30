# ➕ WORKFLOW CREATE AGENTE - NODE A NODE

## 📋 **ESTRUTURA COMPLETA DO WORKFLOW**

### **1. 🌐 WEBHOOK CREATE AGENTE**
- **Tipo:** `n8n-nodes-base.webhook`
- **Método:** POST
- **Path:** `create-agente`
- **CORS:** ✅ Configurado para aceitar requisições do frontend
- **Headers permitidos:** Content-Type, Authorization, X-Requested-With
- **Origins permitidos:** * (todos)

### **2. 🔧 NORMALIZAR DADOS**
- **Tipo:** `n8n-nodes-base.set`
- **Função:** Extrair e organizar dados do payload
- **Campos extraídos:**
  - `agentName`: `{{ $json.body.agent_name }}`
  - `agentType`: `{{ $json.body.agent_type }}`
  - `agentId`: `{{ $json.body.agent_id }}`
  - `userId`: `{{ $json.body.user_id }}`
  - `icone`: `{{ $json.body.icone || '🤖' }}`
  - `cor`: `{{ $json.body.cor || 'bg-blue-500' }}`
  - `descricao`: `{{ $json.body.descricao || 'Agente automatizado para prospecção' }}`

### **3. 🗄️ INSERIR AGENTE NO BANCO**
- **Tipo:** `n8n-nodes-base.postgres`
- **Operação:** `executeQuery`
- **Query:** `INSERT INTO agente_config (nome, workflow_id, webhook_url, descricao, icone, cor, ativo, user_id) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING id`
- **Parâmetros:** 8 parâmetros para inserção completa
- **Credenciais:** Postgres Consorcio

### **4. 📋 LISTAR TEMPLATES**
- **Tipo:** `n8n-nodes-base.httpRequest`
- **Método:** GET
- **URL:** `https://n8n.code-iq.com.br/api/v1/workflows`
- **Autenticação:** n8nApi
- **Função:** Buscar todos os workflows para encontrar templates

### **5. 🔍 ENCONTRAR TEMPLATES**
- **Tipo:** `n8n-nodes-base.code`
- **Função:** JavaScript para encontrar templates essenciais
- **Templates procurados:**
  - `start-agente`
  - `stop-agente`
  - `status-agente`
  - `lista-prospeccao-agente`

### **6. 📋 CLONAR WORKFLOW**
- **Tipo:** `n8n-nodes-base.httpRequest`
- **Método:** POST
- **URL:** `https://n8n.code-iq.com.br/api/v1/workflows/{{ $json.id }}/duplicate`
- **Autenticação:** n8nApi
- **Função:** Clonar cada template encontrado

### **7. ✅ RESPONDER SUCESSO**
- **Tipo:** `n8n-nodes-base.respondToWebhook`
- **Código:** 200
- **Resposta:**
```json
{
  "success": true,
  "message": "Agente criado com sucesso!",
  "agentId": "TESTE123",
  "agentName": "Agente SDR - Teste",
  "workflowsCreated": 4,
  "timestamp": "2025-09-20T23:00:00.000Z"
}
```

## 🔄 **FLUXO DE EXECUÇÃO**

```
Webhook → Normalizar → Inserir DB → Listar Templates → Encontrar → Clonar → Responder
```

## 🛠️ **CORREÇÕES APLICADAS**

1. **✅ CORS Configurado**
   - `allowedOrigins: "*"`
   - `allowedMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"]`
   - `allowedHeaders: ["Content-Type", "Authorization", "X-Requested-With"]`

2. **✅ Inserção PostgreSQL Completa**
   - Todos os campos da tabela `agente_config`
   - Valores padrão para campos opcionais
   - `RETURNING id` para confirmar inserção

3. **✅ Busca de Templates Inteligente**
   - Procura por nomes parciais dos templates
   - Logs detalhados para debug
   - Tratamento de erros

4. **✅ Clonagem de Workflows**
   - Usa API n8n para duplicar workflows
   - Nome personalizado com nome do agente
   - Workflows criados como inativos

## 🧪 **TESTE**

Execute: `node test-create-agente-completo.js`

## 📁 **ARQUIVOS CRIADOS**

- `create-agente-workflow-completo.json` - Workflow completo
- `test-create-agente-completo.js` - Script de teste
- `CREATE_AGENTE_NODES.md` - Esta documentação

---
**Status:** ✅ PRONTO PARA IMPORTAÇÃO  
**CORS:** ✅ CONFIGURADO  
**Teste:** ✅ SCRIPT CRIADO
