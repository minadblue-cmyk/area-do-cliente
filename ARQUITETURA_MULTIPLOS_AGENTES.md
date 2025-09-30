# 🏗️ Arquitetura: Sistema de Múltiplos Agentes

Este documento descreve a arquitetura escalável para gerenciar múltiplos agentes de automação por usuário.

## 🎯 Visão Geral

O sistema permite que cada usuário execute múltiplos tipos de agentes simultaneamente, cada um com seu próprio estado, progresso e controles independentes.

## 📊 Estrutura de Dados

### Frontend (React)
```typescript
interface Agent {
  id: string
  name: string
  type: string
  status: 'disconnected' | 'running' | 'paused' | 'error' | 'completed'
  executionId: string | null
  startedAt: string | null
  stoppedAt: string | null
  progress?: number
  message?: string
}

interface AgentType {
  id: string
  name: string
  description: string
  icon: string
  color: string
  webhook: string
}
```

### Backend (PostgreSQL)
```sql
CREATE TABLE agente_execucoes (
    id SERIAL PRIMARY KEY,
    execution_id VARCHAR(50) UNIQUE NOT NULL,
    workflow_id VARCHAR(50) NOT NULL,
    usuario_id INTEGER NOT NULL,
    agent_type VARCHAR(50) DEFAULT 'prospeccao-quente',
    status VARCHAR(20) DEFAULT 'running',
    progress INTEGER DEFAULT 0,
    message TEXT,
    iniciado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    parado_em TIMESTAMP NULL,
    payload_inicial JSONB,
    payload_parada JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 🤖 Tipos de Agentes Configurados

### 1. Prospecção Quente 🔥
- **ID**: `prospeccao-quente`
- **Webhook**: `webhook/agente1`
- **Descrição**: Agente para prospecção de leads quentes
- **Cor**: Vermelho

### 2. Prospecção Fria ❄️
- **ID**: `prospeccao-fria`
- **Webhook**: `webhook/agente-fria`
- **Descrição**: Agente para prospecção de leads frios
- **Cor**: Azul

### 3. Follow-up 📞
- **ID**: `follow-up`
- **Webhook**: `webhook/agente-followup`
- **Descrição**: Agente para follow-up de clientes
- **Cor**: Verde

### 4. Suporte 🎧
- **ID**: `suporte`
- **Webhook**: `webhook/agente-suporte`
- **Descrição**: Agente para atendimento ao cliente
- **Cor**: Roxo

## 🔄 Fluxo de Funcionamento

### 1. Inicialização
```mermaid
graph TD
    A[Usuário acessa página] --> B[loadAgentStatus()]
    B --> C[Chama webhook/status-agente]
    C --> D[PostgreSQL: SELECT por usuario_id]
    D --> E[Retorna array de execuções]
    E --> F[Processa por agent_type]
    F --> G[Atualiza estado dos agentes]
    G --> H[Renderiza interface]
```

### 2. Iniciar Agente
```mermaid
graph TD
    A[Usuário clica Iniciar] --> B[handleStartAgent(agentType)]
    B --> C[Valida agentType]
    C --> D[Chama webhook específico]
    D --> E[n8n salva execução]
    E --> F[Retorna execution_id]
    F --> G[Atualiza estado local]
    G --> H[Recarrega status]
```

### 3. Parar Agente
```mermaid
graph TD
    A[Usuário clica Parar] --> B[handleStopAgent(agentType)]
    B --> C[Valida executionId]
    C --> D[Chama webhook/parar-agente]
    D --> E[n8n atualiza status]
    E --> F[Atualiza estado local]
    F --> G[Recarrega status]
```

## 🎨 Interface do Usuário

### Layout Responsivo
- **Desktop**: Grid 2x2 (4 agentes)
- **Tablet**: Grid 2x1 (2 agentes por linha)
- **Mobile**: Grid 1x1 (1 agente por linha)

### Componentes por Agente
- **Header**: Ícone, nome, descrição
- **Status**: Indicador visual + texto
- **Info**: Data de início, progresso, mensagem
- **Controles**: Botões Iniciar/Parar independentes

### Estados Visuais
- **Desconectado**: Ponto vermelho + botão "Iniciar" ativo
- **Executando**: Ponto verde + barra de progresso + botão "Parar" ativo
- **Carregando**: Ponto amarelo pulsante + botões desabilitados

## 🔧 Configuração n8n

### Webhook de Status
```
POST /webhook/status-agente
```
**Query SQL**:
```sql
SELECT 
    id, execution_id, usuario_id, agent_type, status,
    started_at, stopped_at, progress, message,
    payload_inicial, payload_parada
FROM agente_execucoes 
WHERE usuario_id = $1 
ORDER BY agent_type, started_at DESC;
```

### Webhooks por Agente
- `webhook/agente1` → Prospecção Quente
- `webhook/agente-fria` → Prospecção Fria
- `webhook/agente-followup` → Follow-up
- `webhook/agente-suporte` → Suporte

### Webhook de Parada
```
POST /webhook/parar-agente
```
**Payload**:
```json
{
  "action": "stop",
  "agent_type": "prospeccao-quente",
  "execution_id": "44117",
  "usuario_id": 5
}
```

## 📈 Escalabilidade

### Adicionar Novo Agente
1. **Frontend**: Adicionar em `agentTypes`
2. **Backend**: Criar webhook específico
3. **Banco**: Usar `agent_type` existente
4. **n8n**: Configurar workflow

### Performance
- **Refresh automático**: 30 segundos
- **Refresh manual**: Sob demanda
- **Índices**: `usuario_id`, `agent_type`, `status`
- **Cache**: Estado local no React

### Monitoramento
- **Logs**: Console do navegador
- **Métricas**: Contador de refresh automático
- **Status**: Tempo real via webhook

## 🚀 Benefícios

### Para o Usuário
- ✅ **Controle independente**: Cada agente tem seus próprios controles
- ✅ **Visão clara**: Status visual de todos os agentes
- ✅ **Flexibilidade**: Pode executar múltiplos agentes simultaneamente
- ✅ **Informações detalhadas**: Progresso, tempo de execução, mensagens

### Para o Sistema
- ✅ **Escalável**: Fácil adicionar novos tipos de agentes
- ✅ **Organizado**: Separação clara por tipo de agente
- ✅ **Eficiente**: Queries otimizadas com índices
- ✅ **Confiável**: Estado sempre sincronizado com banco

### Para Desenvolvimento
- ✅ **Modular**: Cada agente é independente
- ✅ **Reutilizável**: Componentes compartilhados
- ✅ **Manutenível**: Código organizado e documentado
- ✅ **Testável**: Estados isolados e previsíveis

## 🔮 Próximos Passos

1. **Dashboard de Métricas**: Gráficos de performance por agente
2. **Histórico de Execuções**: Lista de execuções anteriores
3. **Configurações por Agente**: Parâmetros personalizáveis
4. **Notificações**: Alertas quando agentes param/completam
5. **API REST**: Endpoints para integração externa
