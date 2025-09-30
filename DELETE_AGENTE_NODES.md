# 🗑️ WORKFLOW DELETE AGENTE - NODE A NODE

## 📋 **ESTRUTURA COMPLETA DO WORKFLOW**

### **1. 🌐 WEBHOOK DELETE AGENTE**
- **Tipo:** `n8n-nodes-base.webhook`
- **Método:** POST
- **Path:** `delete-agente`
- **CORS:** ✅ Configurado para aceitar requisições do frontend
- **Headers permitidos:** Content-Type, Authorization, X-Requested-With
- **Origins permitidos:** * (todos)

### **2. 🔧 NORMALIZAR DADOS**
- **Tipo:** `n8n-nodes-base.set`
- **Função:** Extrair e organizar dados do payload
- **Campos extraídos:**
  - `agentId`: `{{ $json.body.id }}`
  - `agentName`: `{{ $json.body.agent_name }}`
  - `userId`: `{{ $json.body.logged_user?.id || '5' }}`
  - `userName`: `{{ $json.body.logged_user?.name || 'Sistema' }}`

### **3. 🗄️ DELETAR DO BANCO**
- **Tipo:** `n8n-nodes-base.postgres`
- **Operação:** `executeQuery`
- **Query:** `DELETE FROM agente_config WHERE id = $1`
- **Parâmetros:** `id` (agentId)
- **Credenciais:** Postgres Consorcio

### **4. 📋 LISTAR WORKFLOWS**
- **Tipo:** `n8n-nodes-base.httpRequest`
- **Método:** GET
- **URL:** `https://n8n.code-iq.com.br/api/v1/workflows`
- **Autenticação:** n8nApi
- **Função:** Buscar todos os workflows para filtrar

### **5. 🔍 FILTRAR WORKFLOWS DO AGENTE**
- **Tipo:** `n8n-nodes-base.code`
- **Função:** JavaScript para filtrar workflows relacionados ao agente
- **Lógica:**
  - Busca workflows que contenham o nome do agente
  - Busca workflows que contenham o ID do agente
  - Retorna array de workflows para deletar

### **6. 🗑️ DELETAR WORKFLOW**
- **Tipo:** `n8n-nodes-base.httpRequest`
- **Método:** DELETE
- **URL:** `https://n8n.code-iq.com.br/api/v1/workflows/{{ $json.id }}`
- **Autenticação:** n8nApi
- **Função:** Deletar cada workflow filtrado

### **7. ✅ RESPONDER SUCESSO**
- **Tipo:** `n8n-nodes-base.respondToWebhook`
- **Código:** 200
- **Resposta:**
```json
{
  "success": true,
  "message": "Agente e workflows deletados com sucesso!",
  "agentId": "AGENTE_2",
  "agentName": "Agente SDR - 2",
  "workflowsDeleted": 4,
  "timestamp": "2025-09-20T22:50:00.000Z"
}
```

## 🔄 **FLUXO DE EXECUÇÃO**

```
Webhook → Normalizar → Deletar DB → Listar Workflows → Filtrar → Deletar Workflows → Responder
```

## 🛠️ **CORREÇÕES APLICADAS**

1. **✅ CORS Configurado**
   - `allowedOrigins: "*"`
   - `allowedMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"]`
   - `allowedHeaders: ["Content-Type", "Authorization", "X-Requested-With"]`

2. **✅ Parâmetros PostgreSQL Corretos**
   - Uso de `queryParameters` em vez de `queryReplacement`
   - Sintaxe correta para DELETE

3. **✅ Filtro de Workflows Robusto**
   - Verificação se é array
   - Busca por nome e ID do agente
   - Logs detalhados para debug

4. **✅ Resposta Estruturada**
   - JSON válido
   - Informações completas
   - Código de status 200

## 🧪 **TESTE**

Execute: `node test-delete-agente-completo.js`

## 📁 **ARQUIVOS CRIADOS**

- `delete-agente-workflow-completo.json` - Workflow completo
- `test-delete-agente-completo.js` - Script de teste
- `DELETE_AGENTE_NODES.md` - Esta documentação

---
**Status:** ✅ PRONTO PARA IMPORTAÇÃO  
**CORS:** ✅ CONFIGURADO  
**Teste:** ✅ SCRIPT CRIADO
