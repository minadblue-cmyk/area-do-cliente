# 🔄 Sistema de Sincronização Automática de Agentes

## 🎯 Objetivo

Criar uma lógica no frontend para que após a criação de um novo agente (com webhooks dinâmicos via Redis), os botões de iniciar/parar e o status do agente estejam funcionais automaticamente, sem necessidade de recarregar a página.

## 🏗️ Arquitetura Implementada

### **1. Hook `useAgentSync`**
- **Localização**: `src/hooks/useAgentSync.ts`
- **Função**: Gerencia a sincronização automática de agentes
- **Características**:
  - Sincronização automática a cada 15 segundos
  - Detecção de novos agentes
  - Detecção de agentes removidos
  - Callbacks para notificações
  - Controle manual da sincronização

### **2. Componente `AgentSyncManager`**
- **Localização**: `src/components/AgentSyncManager.tsx`
- **Função**: Interface visual para gerenciar a sincronização
- **Características**:
  - Dashboard de status da sincronização
  - Controles para pausar/iniciar sincronização
  - Botão de sincronização manual
  - Lista detalhada de agentes sincronizados
  - Notificações visuais de mudanças

### **3. Integração na Página Upload**
- **Localização**: `src/pages/Upload/index.tsx`
- **Modificações**:
  - Removida função `loadAgentConfigs` antiga
  - Integrado `useAgentSync` hook
  - Adicionado componente `AgentSyncManager`
  - Sincronização automática de `dynamicAgentTypes`

## 🔄 Fluxo de Funcionamento

### **Criação de Novo Agente:**
1. **Usuário cria agente** via modal de criação
2. **N8N processa criação** e gera webhooks dinâmicos via Redis
3. **Sistema detecta novo agente** na próxima sincronização (máx 15s)
4. **Webhooks são registrados automaticamente** via `registerAllAgentWebhooks`
5. **Interface é atualizada** com novo agente
6. **Botões Iniciar/Parar ficam funcionais** imediatamente

### **Sincronização Automática:**
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Frontend      │───▶│  useAgentSync    │───▶│  N8N Webhook    │
│   (15s timer)   │    │  Hook            │    │  list-agentes   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  UI Atualizada  │◀───│  Processa        │◀───│  Retorna        │
│  Automaticamente│    │  Novos Agentes   │    │  Lista Atual    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 🚀 Funcionalidades Implementadas

### **✅ Detecção Automática**
- Novos agentes são detectados automaticamente
- Agentes removidos são detectados e limpos
- Webhooks são registrados dinamicamente

### **✅ Interface Reativa**
- Botões Iniciar/Parar funcionam imediatamente
- Status do agente é atualizado em tempo real
- Notificações de toast para mudanças

### **✅ Controle Manual**
- Botão de sincronização forçada
- Pausar/iniciar sincronização automática
- Dashboard de status detalhado

### **✅ Robustez**
- Tratamento de erros de rede
- Fallback para dados locais
- Logs detalhados para debugging

## 📋 Webhooks Registrados Automaticamente

Para cada novo agente, os seguintes webhooks são registrados:

```typescript
// Webhooks padrão por agente
`webhook/start-${agentId}`     // Iniciar agente
`webhook/stop-${agentId}`      // Parar agente  
`webhook/status-${agentId}`    // Status do agente
`webhook/lista-${agentId}`     // Lista de prospects

// Webhook personalizado (se configurado)
`webhook/custom-${agentId}`    // Webhook customizado do agente
```

## 🎮 Como Usar

### **1. Criação de Agente**
1. Clique em "Criar Novo Agente"
2. Preencha os dados do agente
3. Confirme a criação
4. **O agente aparecerá automaticamente** na lista (máx 15s)

### **2. Controle de Agentes**
1. **Botões Iniciar/Parar** ficam funcionais imediatamente
2. **Status é atualizado** em tempo real
3. **Prospects são carregados** automaticamente

### **3. Gerenciamento de Sincronização**
1. **Dashboard de Status** mostra informações em tempo real
2. **Botão Pausar/Iniciar** para controlar sincronização automática
3. **Botão Sincronizar** para forçar atualização manual

## 🔧 Configuração

### **Intervalo de Sincronização**
```typescript
// Padrão: 15 segundos
syncInterval: 15000

// Para desenvolvimento: 5 segundos
syncInterval: 5000

// Para produção: 30 segundos
syncInterval: 30000
```

### **Callbacks Personalizados**
```typescript
const { agents, syncAgents } = useAgentSync({
  autoSync: true,
  syncInterval: 15000,
  onAgentAdded: (agentId, agentData) => {
    console.log('Novo agente:', agentData)
    // Lógica personalizada
  },
  onAgentRemoved: (agentId) => {
    console.log('Agente removido:', agentId)
    // Limpeza personalizada
  },
  onSyncError: (error) => {
    console.error('Erro de sincronização:', error)
    // Tratamento de erro personalizado
  }
})
```

## 📊 Monitoramento

### **Logs do Console**
- `🔄 [SYNC] Carregando agentes...`
- `🆕 [SYNC] Novo agente detectado: ${nome}`
- `🗑️ [SYNC] Agente removido: ${agentId}`
- `✅ [SYNC] Sincronização completa - ${count} agentes ativos`

### **Interface Visual**
- Contador de agentes ativos
- Última sincronização
- Status da sincronização automática
- Lista detalhada de agentes

## 🎯 Benefícios

1. **🔄 Automático**: Novos agentes aparecem sem recarregar página
2. **⚡ Rápido**: Máximo 15 segundos para detectar mudanças
3. **🎮 Funcional**: Botões funcionam imediatamente
4. **🔍 Visível**: Dashboard mostra status em tempo real
5. **🛡️ Robusto**: Tratamento de erros e fallbacks
6. **⚙️ Configurável**: Intervalos e callbacks personalizáveis

**Status**: ✅ IMPLEMENTADO E FUNCIONAL
