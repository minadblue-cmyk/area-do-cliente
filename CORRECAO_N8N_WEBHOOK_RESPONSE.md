# 🔧 Correção do Webhook Response no n8n

## Problema Identificado
O webhook `/webhook/create-agente` está retornando a definição completa do workflow n8n em vez de uma resposta JSON limpa.

## Solução: Adicionar Nó "Set" antes do "Respond to Webhook"

### 1. **Configuração do Nó "Set"**

Adicione um nó "Set" antes do "Respond to Webhook" com as seguintes configurações:

#### **Nome do Nó:** `Fix Response Payload`

#### **Assignments (Campos de saída):**

```json
{
  "success": true,
  "message": "Agente criado com sucesso",
  "agentId": "={{ $json.agent_id || $('Webhook Create Fixed').item.json.body.agent_id }}",
  "agentName": "={{ $json.agent_name || $('Webhook Create Fixed').item.json.body.agent_name }}",
  "workflowId": "={{ $json.id || $json.workflow_id }}",
  "webhookUrl": "webhook/start-{{ $json.agent_type || $('Webhook Create Fixed').item.json.body.agent_type }}",
  "timestamp": "={{ $now.toISO() }}",
  "executionId": "={{ $execution.id }}"
}
```

### 2. **Configuração Detalhada dos Campos**

| Campo | Tipo | Valor | Descrição |
|-------|------|-------|-----------|
| `success` | boolean | `true` | Flag de sucesso |
| `message` | string | `"Agente criado com sucesso"` | Mensagem de confirmação |
| `agentId` | string | `={{ $json.agent_id \|\| $('Webhook Create Fixed').item.json.body.agent_id }}` | ID do agente criado |
| `agentName` | string | `={{ $json.agent_name \|\| $('Webhook Create Fixed').item.json.body.agent_name }}` | Nome do agente |
| `workflowId` | string | `={{ $json.id \|\| $json.workflow_id }}` | ID do workflow criado |
| `webhookUrl` | string | `webhook/start-{{ $json.agent_type \|\| $('Webhook Create Fixed').item.json.body.agent_type }}` | URL do webhook |
| `timestamp` | string | `={{ $now.toISO() }}` | Timestamp da criação |
| `executionId` | string | `={{ $execution.id }}` | ID da execução |

### 3. **Posicionamento no Workflow**

```
[Webhook Create Fixed] → [Outros nós...] → [Fix Response Payload] → [Respond to Webhook]
```

### 4. **Configuração do "Respond to Webhook"**

Certifique-se de que o nó "Respond to Webhook" está configurado com:

- **Response Mode:** `responseNode`
- **Response Code:** `200`
- **Response Body:** Deixe vazio (usará os dados do nó anterior)

### 5. **Resultado Esperado**

Após a correção, o webhook retornará:

```json
{
  "success": true,
  "message": "Agente criado com sucesso",
  "agentId": "TESTE_WEBHOOK_123",
  "agentName": "Agente Teste Webhook",
  "workflowId": "p7QT3lFg7lGhNLae",
  "webhookUrl": "webhook/start-agente-teste-webhook",
  "timestamp": "2025-09-20T23:21:15.844Z",
  "executionId": "47957"
}
```

### 6. **Passos para Implementar**

1. **Acesse o n8n** em `https://n8n.code-iq.com.br`
2. **Abra o workflow** que contém o webhook `/webhook/create-agente`
3. **Adicione um nó "Set"** antes do "Respond to Webhook"
4. **Configure os assignments** conforme mostrado acima
5. **Conecte o nó** na sequência correta
6. **Teste o webhook** novamente

### 7. **Teste de Validação**

Após implementar, execute o teste:

```bash
node test-create-agente-simple.js
```

O resultado deve ser um JSON limpo em vez da definição do workflow.

## 🎯 **Benefícios da Correção**

- ✅ Resposta JSON limpa e estruturada
- ✅ Compatibilidade com o frontend
- ✅ Informações úteis sobre o agente criado
- ✅ Melhor debugging e monitoramento
- ✅ Padrão consistente com outros webhooks
