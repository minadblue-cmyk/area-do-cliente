# 📝 Webhook n8n: Status do Agente

Este documento descreve o webhook do n8n para buscar o status atual dos agentes de prospecção.

## 🎯 Objetivo
Receber uma requisição do frontend e retornar o status atual das execuções do agente para o usuário específico.

## 🔗 Endpoint
```
GET /webhook/status-agente1
```

## 📥 Parâmetros de Entrada (Query Parameters)
```
GET /webhook/status-agente1?usuario_id=5&workflow_id=123&status=running&logged_user_id=5&logged_user_name=Administrator Code-IQ&logged_user_email=admin@code-iq.com.br
```

### Parâmetros:
- `usuario_id`: ID do usuário (obrigatório)
- `workflow_id`: ID do workflow do agente (obrigatório)
- `status`: Status do agente (opcional: running, stopped, completed, error)
- `logged_user_id`: ID do usuário logado
- `logged_user_name`: Nome do usuário logado
- `logged_user_email`: Email do usuário logado

## 📤 Resposta Esperada

### Opção 1: Lista de Execuções por Tipo de Agente (Recomendado)
```json
[
  {
    "id": "uuid-da-execucao",
    "execution_id": "44117",
    "usuario_id": 5,
    "agent_type": "prospeccao-quente",
    "status": "running",
    "started_at": "2025-01-11T13:46:47.219Z",
    "stopped_at": null,
    "progress": 45,
    "message": "Processando leads...",
    "payload": {...},
    "response": {...}
  },
  {
    "id": "uuid-da-execucao-2",
    "execution_id": "44118",
    "usuario_id": 5,
    "agent_type": "follow-up",
    "status": "disconnected",
    "started_at": "2025-01-11T12:30:00.000Z",
    "stopped_at": "2025-01-11T13:00:00.000Z",
    "progress": 100,
    "message": "Follow-up concluído",
    "payload": {...},
    "response": {...}
  }
]
```

### Opção 2: Status Único (Compatibilidade)
```json
{
  "status": "running",
  "execution_id": "44117",
  "usuario_id": 5,
  "agent_type": "prospeccao-quente",
  "started_at": "2025-01-11T13:46:47.219Z",
  "progress": 45,
  "message": "Agente em execução"
}
```

## 🗄️ Query SQL Sugerida

### Para Buscar por Workflow ID + Status (Recomendado)
```sql
SELECT 
    id,
    execution_id,
    workflow_id,
    usuario_id,
    usuario_nome,
    usuario_email,
    status,
    iniciado_em,
    parado_em,
    payload_inicial,
    payload_parada,
    CASE 
        WHEN status = 'running' THEN 'Agente em execução'
        WHEN status = 'stopped' THEN 'Agente parado'
        WHEN status = 'error' THEN 'Agente com erro'
        WHEN status = 'completed' THEN 'Agente concluído'
        ELSE 'Status desconhecido'
    END as message
FROM agente_execucoes 
WHERE usuario_id = $1 
  AND workflow_id = $2
  AND ($3 IS NULL OR status = $3)
ORDER BY iniciado_em DESC;
```

### Para Buscar Última Execução do Workflow
```sql
SELECT 
    id,
    execution_id,
    workflow_id,
    usuario_id,
    status,
    iniciado_em,
    parado_em,
    CASE 
        WHEN status = 'running' THEN 'Agente em execução'
        WHEN status = 'stopped' THEN 'Agente parado'
        WHEN status = 'error' THEN 'Agente com erro'
        WHEN status = 'completed' THEN 'Agente concluído'
        ELSE 'Status desconhecido'
    END as message
FROM agente_execucoes 
WHERE usuario_id = $1 
  AND workflow_id = $2
ORDER BY iniciado_em DESC 
LIMIT 1;
```

### Para Buscar Todas as Execuções do Usuário
```sql
SELECT 
    id,
    execution_id,
    workflow_id,
    usuario_id,
    status,
    iniciado_em,
    parado_em,
    CASE 
        WHEN status = 'running' THEN 'Agente em execução'
        WHEN status = 'stopped' THEN 'Agente parado'
        WHEN status = 'error' THEN 'Agente com erro'
        WHEN status = 'completed' THEN 'Agente concluído'
        ELSE 'Status desconhecido'
    END as message
FROM agente_execucoes 
WHERE usuario_id = $1 
ORDER BY workflow_id, iniciado_em DESC;
```

## 🔧 Configuração do Node PostgreSQL

### Parâmetros
- **Query**: Use uma das queries SQL acima
- **Parameters**: 
  - `$1` = `{{ $json.query.usuario_id }}` (ID do usuário)
  - `$2` = `{{ $json.query.workflow_id }}` (ID do workflow)
  - `$3` = `{{ $json.query.status }}` (Status opcional - pode ser NULL)

### Campos de Retorno
- `status`: Status atual da execução
- `execution_id`: ID da execução no n8n
- `usuario_id`: ID do usuário
- `started_at`: Data/hora de início
- `stopped_at`: Data/hora de parada (se aplicável)
- `message`: Mensagem descritiva do status

## 🎨 Workflow Sugerido

1. **Webhook Trigger** (`/webhook/status-agente1`) - **Método: GET**
2. **Set Node** (Normalização)
   - `usuario_id`: `{{ $json.query.usuario_id }}`
   - `workflow_id`: `{{ $json.query.workflow_id }}`
   - `status`: `{{ $json.query.status }}`
   - `logged_user_id`: `{{ $json.query.logged_user_id }}`
   - `logged_user_name`: `{{ $json.query.logged_user_name }}`
   - `logged_user_email`: `{{ $json.query.logged_user_email }}`
3. **PostgreSQL Node** (Buscar Status)
   - Query: SQL acima (recomendado: "Para Buscar por Workflow ID + Status")
   - Parameters: 
     - `$1` = `{{ $json.query.usuario_id }}`
     - `$2` = `{{ $json.query.workflow_id }}`
     - `$3` = `{{ $json.query.status }}`
4. **Response Node** (Retornar dados)

## 🚀 Benefícios

- ✅ **Performance**: Webhook específico para status
- ✅ **Simplicidade**: Não precisa filtrar por `action`
- ✅ **Flexibilidade**: Pode retornar status único ou lista
- ✅ **Confiabilidade**: Sempre busca dados atualizados do banco
- ✅ **Escalabilidade**: Pode ser usado por múltiplos usuários

## 🔄 Integração com Frontend

O frontend já está configurado para:
- Chamar este webhook ao carregar a página
- Recarregar status após iniciar/parar agente
- Mostrar indicador de carregamento
- Botão de refresh manual

## 📋 Status Possíveis

- `running`: Agente em execução
- `stopped`: Agente parado manualmente
- `error`: Agente com erro
- `completed`: Agente concluído com sucesso

## 🎯 Próximos Passos

1. Criar o workflow no n8n
2. Configurar o webhook `/webhook/status-agente`
3. Testar com dados reais
4. Verificar performance e ajustar se necessário
