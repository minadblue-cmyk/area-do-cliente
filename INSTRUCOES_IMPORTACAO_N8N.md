# 📥 Instruções de Importação no n8n

## Arquivo para Importação
- **Arquivo**: `create-agente-workflow-corrected.json`
- **Nome do Workflow**: "Create Agente - Corrigido"

## 🔧 Correções Implementadas

### 1. **Webhook Names Corrigidos**
- **Start**: `webhook/start-{agent_type}`
- **Status**: `webhook/status-{agent_type}`
- **Lista**: `webhook/lista-{agent_type}`
- **Stop**: `webhook/stop-{agent_type}`

### 2. **Fluxo Completo**
```
[Webhook Create Agente] 
    ↓
[Normalizar Dados]
    ↓
[Buscar Templates] → [Encontrar Templates]
    ↓
[Clonar Workflow] → [Buscar Workflow Clonado]
    ↓
[Modificar Webhook Path] → [Atualizar Workflow]
    ↓
[Ativar Workflow] → [Inserir Agente Config]
    ↓
[Prepara Json] → [Respond to Webhook]
```

### 3. **Nós Principais**

#### **Encontrar Templates**
- Identifica os 4 templates essenciais
- Adiciona tipo específico para cada webhook
- Mapeia: start, stop, status, lista

#### **Modificar Webhook Path**
- Ajusta o path do webhook baseado no tipo
- Modifica o nó webhook no workflow clonado
- Aplica o path correto para cada tipo

#### **Prepara Json**
- Retorna resposta JSON limpa
- Inclui informações do agente criado
- Estrutura padronizada para o frontend

## 📋 Passos para Importação

### 1. **Acessar n8n**
- URL: `https://n8n.code-iq.com.br`
- Fazer login com suas credenciais

### 2. **Importar Workflow**
- Clicar em "Import from File"
- Selecionar o arquivo `create-agente-workflow-corrected.json`
- Confirmar a importação

### 3. **Configurar Credenciais**
- **n8n API**: Verificar se a credencial "n8n Admin" está configurada
- **PostgreSQL**: Verificar se a credencial "Postgres Consorcio" está configurada

### 4. **Ativar Workflow**
- Clicar no toggle para ativar o workflow
- Verificar se está com status "Active" (verde)

### 5. **Testar Webhook**
- Copiar a URL do webhook: `https://n8n.code-iq.com.br/webhook/create-agente`
- Testar com o script: `node test-webhook-after-fix.js`

## 🧪 Teste de Validação

### Script de Teste
```bash
node test-webhook-after-fix.js
```

### Resultado Esperado
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

## 🔍 Verificações Pós-Importação

### 1. **Verificar Webhooks Criados**
- Acessar a lista de workflows
- Verificar se foram criados 4 workflows com nomes corretos
- Confirmar se os webhooks têm os paths corretos

### 2. **Verificar Banco de Dados**
- Verificar se o agente foi inserido na tabela `agente_config`
- Confirmar se o `webhook_url` está correto

### 3. **Testar Frontend**
- Acessar a página de configuração de agentes
- Testar a criação de um novo agente
- Verificar se a resposta é JSON limpa

## ⚠️ Troubleshooting

### Problema: Webhook retorna erro 500
- **Solução**: Verificar se as credenciais estão configuradas
- **Verificar**: Logs de execução no n8n

### Problema: Webhooks com nomes incorretos
- **Solução**: Verificar se o nó "Modificar Webhook Path" está funcionando
- **Verificar**: Logs do nó para ver se está modificando corretamente

### Problema: Resposta não é JSON
- **Solução**: Verificar se o nó "Prepara Json" está configurado corretamente
- **Verificar**: Se o nó "Respond to Webhook" está usando `$json`

## ✅ Checklist de Validação

- [ ] Workflow importado com sucesso
- [ ] Credenciais configuradas
- [ ] Workflow ativo (toggle verde)
- [ ] Webhook testado e funcionando
- [ ] Resposta JSON limpa
- [ ] Webhooks criados com nomes corretos
- [ ] Banco de dados atualizado
- [ ] Frontend funcionando

## 🎯 Resultado Final

Após a importação e configuração, o webhook `/webhook/create-agente` deve:

1. **Receber** payload com dados do agente
2. **Clonar** 4 workflows essenciais
3. **Modificar** webhook paths específicos
4. **Ativar** workflows clonados
5. **Inserir** configuração no banco
6. **Retornar** JSON limpo com informações do agente

## 📞 Suporte

Se encontrar problemas durante a importação:

1. Verificar logs de execução no n8n
2. Testar cada nó individualmente
3. Verificar configurações de credenciais
4. Consultar documentação do n8n
