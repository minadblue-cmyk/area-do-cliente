# 🔧 Workflow n8n: Parar Agente

## 📋 **Visão Geral**
Este documento descreve como configurar o workflow no n8n para parar execuções do agente usando o execution_id.

## 🏗️ **Estrutura do Workflow**

### **1. Webhook Node: "parar-agente"**
```json
{
  "name": "parar-agente",
  "type": "n8n-nodes-base.webhook",
  "parameters": {
    "httpMethod": "POST",
    "path": "parar-agente",
    "responseMode": "responseNode",
    "options": {}
  }
}
```

**Payload esperado:**
```json
{
  "action": "stop",
  "execution_id": "44106",
  "timestamp": "2025-01-11T12:56:52.219Z",
  "usuario_id": 5,
  "logged_user": {
    "id": 5,
    "name": "Administrator Code-IQ",
    "email": "admin@code-iq.com.br"
  }
}
```

### **2. PostgreSQL Node: "Salvar Execução"**
```sql
-- Query para salvar execução inicial
INSERT INTO agente_execucoes (
    execution_id, 
    workflow_id, 
    usuario_id, 
    usuario_nome, 
    usuario_email, 
    payload_inicial
) VALUES (
    $1, -- execution_id
    $2, -- workflow_id (eBcColwirndBaFZX)
    $3, -- usuario_id
    $4, -- usuario_nome
    $5, -- usuario_email
    $6  -- payload_inicial (JSON)
) ON CONFLICT (execution_id) DO UPDATE SET
    status = 'running',
    updated_at = CURRENT_TIMESTAMP
RETURNING id, execution_id, status;
```

### **3. HTTP Request Node: "Deletar Execução n8n"**
```json
{
  "name": "deletar-execucao-n8n",
  "type": "n8n-nodes-base.httpRequest",
  "parameters": {
    "url": "https://n8n.code-iq.com.br/api/v1/executions/{{$json.execution_id}}",
    "method": "DELETE",
    "authentication": "genericCredentialType",
    "genericAuthType": "httpHeaderAuth",
    "options": {
      "headers": {
        "X-N8N-API-KEY": "{{$credentials.n8nApiKey}}"
      }
    }
  }
}
```

### **4. PostgreSQL Node: "Atualizar Status"**
```sql
-- Query para atualizar status após parar
UPDATE agente_execucoes 
SET 
    status = 'stopped',
    parado_em = CURRENT_TIMESTAMP,
    payload_parada = $1,
    updated_at = CURRENT_TIMESTAMP
WHERE execution_id = $2
RETURNING id, execution_id, status, parado_em;
```

### **5. Respond to Webhook Node**
```json
{
  "name": "resposta-sucesso",
  "type": "n8n-nodes-base.respondToWebhook",
  "parameters": {
    "respondWith": "json",
    "responseBody": {
      "success": true,
      "message": "Agente parado com sucesso",
      "execution_id": "{{$json.execution_id}}",
      "status": "stopped",
      "parado_em": "{{$json.parado_em}}"
    }
  }
}
```

## 🔄 **Fluxo Completo**

```
1. Frontend → POST /webhook/parar-agente
2. n8n recebe payload com execution_id
3. PostgreSQL: Busca execução por execution_id
4. HTTP Request: DELETE /api/v1/executions/{execution_id}
5. PostgreSQL: Atualiza status para 'stopped'
6. Resposta: JSON com sucesso
```

## 🔑 **Configurações Necessárias**

### **A. Credenciais n8n API**
- **Tipo:** HTTP Header Auth
- **Header Name:** X-N8N-API-KEY
- **Header Value:** [Sua API Key do n8n]

### **B. Credenciais PostgreSQL**
- **Host:** [Seu host PostgreSQL]
- **Database:** [Nome do banco]
- **User:** [Usuário]
- **Password:** [Senha]
- **Port:** 5432

## 📊 **Tabela PostgreSQL**

```sql
CREATE TABLE agente_execucoes (
    id SERIAL PRIMARY KEY,
    execution_id VARCHAR(50) UNIQUE NOT NULL,
    workflow_id VARCHAR(50) NOT NULL,
    usuario_id INTEGER NOT NULL,
    usuario_nome VARCHAR(255),
    usuario_email VARCHAR(255),
    status VARCHAR(20) DEFAULT 'running',
    iniciado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    parado_em TIMESTAMP NULL,
    payload_inicial JSONB,
    payload_parada JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 🚀 **Como Implementar**

### **1. No n8n:**
1. Criar novo workflow
2. Adicionar Webhook node com path "parar-agente"
3. Configurar PostgreSQL nodes
4. Configurar HTTP Request para API n8n
5. Configurar Respond to Webhook
6. Ativar workflow

### **2. No Frontend:**
- ✅ Já implementado
- ✅ Botão "Parar Agente" funcional
- ✅ Captura execution_id automaticamente
- ✅ Envia payload correto

### **3. No PostgreSQL:**
- ✅ Executar script `13_criar_tabela_execucoes.sql`
- ✅ Configurar credenciais no n8n

## 🔍 **Testando**

### **1. Teste Manual:**
```bash
curl -X POST http://localhost:3001/n8n/webhook/parar-agente \
  -H "Content-Type: application/json" \
  -d '{
    "action": "stop",
    "execution_id": "44106",
    "timestamp": "2025-01-11T12:56:52.219Z",
    "usuario_id": 5,
    "logged_user": {
      "id": 5,
      "name": "Administrator Code-IQ",
      "email": "admin@code-iq.com.br"
    }
  }'
```

### **2. Resposta Esperada:**
```json
{
  "success": true,
  "message": "Agente parado com sucesso",
  "execution_id": "44106",
  "status": "stopped",
  "parado_em": "2025-01-11T13:00:00.000Z"
}
```

## ⚠️ **Considerações Importantes**

1. **API Key n8n:** Necessária para deletar execuções
2. **Permissões:** Usuário deve ter permissão para parar execuções
3. **Logs:** Todas as ações são logadas no PostgreSQL
4. **Segurança:** Validação de usuário e execution_id
5. **Performance:** Índices criados para consultas rápidas

## 🎯 **Benefícios**

- ✅ **Controle total** sobre execuções do agente
- ✅ **Auditoria completa** no PostgreSQL
- ✅ **Interface intuitiva** no frontend
- ✅ **Integração perfeita** com n8n
- ✅ **Escalabilidade** para múltiplos usuários
