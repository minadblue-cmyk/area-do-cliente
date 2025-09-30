# 🚀 SISTEMA DE CLONAGEM DE AGENTES

## 📋 VISÃO GERAL

Sistema completo para criar novos agentes automaticamente, clonando os 4 workflows essenciais:
- **Start** - Iniciar agente
- **Stop** - Parar agente  
- **Status** - Verificar status
- **Lista** - Listar prospects

## 🔧 COMPONENTES CRIADOS

### 1. **Workflow n8n** (`agente-clone-workflow-organized.json`)
- **Webhook**: `/webhook/create-agente`
- **Funcionalidade**: Clona os 4 workflows essenciais na estrutura organizacional
- **API**: Usa a API do n8n para buscar pastas e criar workflows organizados
- **Organização**: Cria workflows na pasta "Elleve Consorcios" existente

### 2. **Frontend** (`src/components/CreateAgentModal.tsx`)
- **Modal**: Interface para criar novo agente
- **Validação**: Campos obrigatórios e auto-geração de IDs
- **Integração**: Chama webhook de criação

### 3. **Página Upload** (`src/pages/Upload/index.tsx`)
- **Botão**: "Criar Agente" na interface
- **Estado**: Gerencia modal e novos agentes
- **Callback**: Atualiza lista após criação

### 4. **Teste** (`test-create-agent.js`)
- **Script**: Testa criação via webhook
- **Validação**: Verifica resposta e workflows criados

## 🎯 FLUXO DE FUNCIONAMENTO

```
┌─────────────────────────────────────────┐
│ 1. USUÁRIO CLICA "CRIAR AGENTE"         │
├─────────────────────────────────────────┤
│ 2. MODAL ABRE COM FORMULÁRIO            │
├─────────────────────────────────────────┤
│ 3. USUÁRIO PREENCHE NOME E ID           │
├─────────────────────────────────────────┤
│ 4. FRONTEND CHAMA /webhook/create-agente│
├─────────────────────────────────────────┤
│ 5. n8n BUSCA 4 WORKFLOWS ORIGINAIS      │
├─────────────────────────────────────────┤
│ 6. n8n CLONA E PERSONALIZA WORKFLOWS   │
├─────────────────────────────────────────┤
│ 7. n8n CRIA 4 NOVOS WORKFLOWS          │
├─────────────────────────────────────────┤
│ 8. FRONTEND RECEBE RESPOSTA             │
├─────────────────────────────────────────┤
│ 9. NOVO AGENTE APARECE NA LISTA        │
└─────────────────────────────────────────┘
```

## 📝 IMPLEMENTAÇÃO NO n8n

### **PASSO 1: Importar Workflow**
1. Abrir n8n
2. Clicar em "Import from File"
3. Selecionar `agente-clone-workflow-organized.json`
4. Salvar workflow

### **PASSO 2: Configurar Credenciais**
- **Redis**: "Redis Messages"
- **PostgreSQL**: "Postgres Consorcio"  
- **OpenAI**: "Elleve Consorcios"

### **PASSO 3: Ativar Workflow**
1. Clicar no toggle "Active"
2. Workflow ficará disponível em `/webhook/create-agente`

## 🔧 CONFIGURAÇÕES TÉCNICAS

### **Webhooks Gerados**
- `start-{agentType}` - Iniciar agente
- `stop-{agentType}` - Parar agente
- `status-{agentType}` - Status do agente
- `lista-prospeccao-{agentType}` - Lista prospects

### **Nomenclatura**
- **Nome**: `Agente SDR - {Tipo} - {Nome}`
- **Tipo**: Baseado no nome (ex: "Agente João" → "agenteJoao")
- **ID**: Gerado automaticamente (timestamp + random)

### **Personalização**
- **Webhook paths**: Atualizados para novo agente
- **Workflow IDs**: Substituídos nos nodes
- **Credenciais**: Mantidas (Redis, PostgreSQL, OpenAI)
- **Organização**: Workflows criados na pasta "Elleve Consorcios"
- **Tags**: Adicionadas para organização (Agente, Nome, Tipo, Elleve Consorcios)

## 📁 ORGANIZAÇÃO ESTRUTURAL

### **Estrutura Atual**
```
Personal/
└── Produção/
    └── Clientes/
        └── Elleve Consorcios/
            └── Agente1/
                ├── Agente SDR - Start - Agente1
                ├── Agente SDR - Stop - Agente1
                ├── Agente SDR - Status - Agente1
                └── Agente SDR - Lista Prospecção - Agente1
```

### **Estrutura Após Clonagem**
```
Personal/
└── Produção/
    └── Clientes/
        └── Elleve Consorcios/
            ├── Agente1/ (existente)
            ├── Agente2/ (novo)
            │   ├── Agente SDR - Start - Agente2
            │   ├── Agente SDR - Stop - Agente2
            │   ├── Agente SDR - Status - Agente2
            │   └── Agente SDR - Lista Prospecção - Agente2
            └── Agente3/ (novo)
                ├── Agente SDR - Start - Agente3
                ├── Agente SDR - Stop - Agente3
                ├── Agente SDR - Status - Agente3
                └── Agente SDR - Lista Prospecção - Agente3
```

### **Funcionalidades de Organização**
- **Busca Automática**: Encontra pasta "Elleve Consorcios" automaticamente
- **Criação Organizada**: Todos os workflows ficam na mesma pasta
- **Tags Consistentes**: Cada workflow recebe tags para facilitar busca
- **Estrutura Hierárquica**: Mantém organização existente

## 🧪 TESTE DO SISTEMA

### **Via Frontend**
1. Acessar página Upload
2. Clicar "Criar Agente"
3. Preencher nome do agente
4. Clicar "Criar Agente"
5. Verificar criação dos 4 workflows

### **Via Script**
```bash
node test-create-agent.js
```

### **Via cURL**
```bash
curl -X POST https://n8n.code-iq.com.br/webhook/create-agente \
  -H "Content-Type: application/json" \
  -d '{
    "action": "create",
    "agent_name": "Agente Teste",
    "agent_type": "agenteTeste", 
    "agent_id": "TEST123456789",
    "user_id": "user123"
  }'
```

## 📊 RESPOSTA ESPERADA

```json
{
  "success": true,
  "message": "Agente Agente Teste criado com sucesso na estrutura organizacional!",
  "agent": {
    "name": "Agente Teste",
    "type": "agenteTeste",
    "id": "TEST123456789"
  },
  "organization": {
    "folderId": "folder_elleve_consorcios_id",
    "folderName": "Elleve Consorcios",
    "structure": "Personal/Produção/Clientes/Elleve Consorcios"
  },
  "workflows": {
    "start": {
      "id": "workflow_id_start",
      "name": "Agente SDR - Start - Agente Teste",
      "webhook": "start-agenteTeste",
      "folderId": "folder_elleve_consorcios_id"
    },
    "lista": {
      "id": "workflow_id_lista", 
      "name": "Agente SDR - Lista Prospecção - Agente Teste",
      "webhook": "lista-prospeccao-agenteTeste",
      "folderId": "folder_elleve_consorcios_id"
    },
    "status": {
      "id": "workflow_id_status",
      "name": "Agente SDR - Status - Agente Teste", 
      "webhook": "status-agenteTeste",
      "folderId": "folder_elleve_consorcios_id"
    },
    "stop": {
      "id": "workflow_id_stop",
      "name": "Agente SDR - Stop - Agente Teste",
      "webhook": "stop-agenteTeste",
      "folderId": "folder_elleve_consorcios_id"
    }
  },
  "timestamp": "2025-01-19T16:00:00.000Z"
}
```

## 🚨 PONTOS DE ATENÇÃO

### **IDs dos Workflows Originais**
- **Start**: `eBcColwirndBaFZX`
- **Lista**: `piyABVIDxK9OoLYB`
- **Status**: `AwYrhj5Z6z4K0Mgv`
- **Stop**: `wBDZdXsfY8GYYUYg`

### **API do n8n**
- **URL**: `https://n8n.code-iq.com.br/api/v1/`
- **Token**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

### **Credenciais Necessárias**
- Redis Messages
- Postgres Consorcio
- Elleve Consorcios (OpenAI)

## ✅ CHECKLIST DE IMPLEMENTAÇÃO

- [ ] Importar workflow `agente-clone-workflow-organized.json` no n8n
- [ ] Configurar credenciais (Redis, PostgreSQL, OpenAI)
- [ ] Ativar workflow no n8n
- [ ] Verificar pasta "Elleve Consorcios" existe no n8n
- [ ] Testar criação via frontend
- [ ] Verificar 4 workflows criados na pasta correta
- [ ] Validar organização estrutural
- [ ] Testar funcionalidades do novo agente
- [ ] Validar webhooks específicos funcionando

## 🎉 RESULTADO FINAL

Após implementação completa:
- ✅ Botão "Criar Agente" no frontend
- ✅ Modal com formulário intuitivo
- ✅ Clonagem automática de 4 workflows
- ✅ Webhooks específicos por agente
- ✅ Sistema escalável para N agentes
- ✅ Integração completa com frontend existente

**O sistema está pronto para criar agentes ilimitados com workflows automáticos!** 🚀
