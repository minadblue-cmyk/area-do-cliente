# Redis Counter Server para N8N Workflows

Este sistema resolve o problema de nomes duplicados nos webhooks ao criar agentes no N8N, utilizando Redis para gerenciar contadores atômicos únicos.

## 🎯 Problema Resolvido

**Antes:** Todos os workflows clonados tinham nomes similares:
- `Agente SDR - Start-2`
- `Agente SDR - Status-2` 
- `Agente SDR - lista-prospeccao-agente-2`
- `Agente SDR - Stop-2`

**Depois:** Cada workflow tem um contador único baseado no Redis:
- `Agente SDR - Start - Agente Vendas-1`
- `Agente SDR - Status - Agente Vendas-2`
- `Agente SDR - Lista - Agente Vendas-3`
- `Agente SDR - Stop - Agente Vendas-4`

## 🏗️ Arquitetura

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Frontend      │───▶│  N8N Workflow    │───▶│ Redis Counter   │
│   (React)       │    │  Create Agente   │    │    Server       │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌──────────────────┐
                       │  N8N API         │
                       │  (Clone/Activate)│
                       └──────────────────┘
```

## 📁 Arquivos Criados

### Core Files
- `redis-counter-server.js` - Servidor principal do Redis Counter
- `package-redis.json` - Dependências do Node.js
- `create-agente-workflow-with-redis.json` - Workflow N8N corrigido

### Setup & Test
- `setup-redis.sh` - Script de instalação para Linux/Mac
- `setup-redis.ps1` - Script de instalação para Windows
- `test-redis-counter.js` - Testes automatizados
- `exemplo-uso-redis.js` - Exemplos de uso

## 🚀 Instalação

### Windows (PowerShell)
```powershell
# Executar script de configuração
.\setup-redis.ps1

# Ou manualmente:
npm install express redis cors
```

### Linux/Mac (Bash)
```bash
# Executar script de configuração
chmod +x setup-redis.sh
./setup-redis.sh

# Ou manualmente:
npm install express redis cors
```

## 🔧 Configuração

### 1. Iniciar Redis
```bash
# Linux/Mac
redis-server

# Windows (se instalado via Chocolatey)
redis-server
```

### 2. Iniciar Redis Counter Server
```bash
node redis-counter-server.js
```

### 3. Testar o Servidor
```bash
node test-redis-counter.js
```

## 📡 API Endpoints

### POST `/api/counter/next`
Obtém o próximo contador único para um agente/tipo específico.

**Request:**
```json
{
  "agentType": "vendas-premium",
  "webhookType": "start"
}
```

**Response:**
```json
{
  "success": true,
  "counter": 5,
  "agentType": "vendas-premium",
  "webhookType": "start",
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

### GET `/api/counter/current/:agentType/:webhookType`
Obtém o contador atual sem incrementar.

**Response:**
```json
{
  "success": true,
  "counter": 5,
  "agentType": "vendas-premium",
  "webhookType": "start"
}
```

### POST `/api/counter/reset`
Reseta o contador para um agente/tipo específico.

**Request:**
```json
{
  "agentType": "vendas-premium",
  "webhookType": "start"
}
```

### GET `/api/counter/list`
Lista todos os contadores ativos.

**Response:**
```json
{
  "success": true,
  "counters": {
    "vendas-premium": {
      "start": 5,
      "status": 3,
      "lista": 2,
      "stop": 1
    }
  },
  "totalKeys": 4
}
```

### GET `/health`
Health check do servidor.

## 🔄 Workflow N8N

### Importação
1. Abra o N8N
2. Importe o arquivo `create-agente-workflow-with-redis.json`
3. Configure as credenciais necessárias

### Fluxo de Execução
1. **Webhook** recebe dados do agente
2. **Normalização** processa os dados
3. **Preparar Workflows** cria estrutura para 4 workflows
4. **Obter Contador Redis** busca contador único para cada tipo
5. **Buscar Template** obtém template do workflow
6. **Preparar Workflow Clonado** aplica contador único
7. **Clonar Workflow** cria novo workflow no N8N
8. **Ativar Workflow** ativa o workflow clonado
9. **Consolidar Resultados** prepara resposta final

### Exemplo de Payload
```json
{
  "agent_name": "Agente Vendas Premium",
  "agent_type": "vendas-premium",
  "agent_id": "VENDA_PREMIUM_001",
  "user_id": "5",
  "icone": "💼",
  "cor": "bg-green-500"
}
```

### Exemplo de Resposta
```json
{
  "success": true,
  "message": "4 workflows criados com sucesso",
  "agentName": "Agente Vendas Premium",
  "agentType": "vendas-premium",
  "agentId": "VENDA_PREMIUM_001",
  "workflows": [
    {
      "id": "workflow-id-1",
      "name": "Agente SDR - Start - Agente Vendas Premium-1",
      "webhookType": "start",
      "counter": 1,
      "webhookPath": "start-vendas-premium-1"
    },
    {
      "id": "workflow-id-2", 
      "name": "Agente SDR - Status - Agente Vendas Premium-2",
      "webhookType": "status",
      "counter": 2,
      "webhookPath": "status-vendas-premium-2"
    },
    {
      "id": "workflow-id-3",
      "name": "Agente SDR - Lista - Agente Vendas Premium-3", 
      "webhookType": "lista",
      "counter": 3,
      "webhookPath": "lista-vendas-premium-3"
    },
    {
      "id": "workflow-id-4",
      "name": "Agente SDR - Stop - Agente Vendas Premium-4",
      "webhookType": "stop", 
      "counter": 4,
      "webhookPath": "stop-vendas-premium-4"
    }
  ],
  "timestamp": "2024-01-15T10:30:00.000Z",
  "executionId": "execution-123"
}
```

## 🧪 Testes

### Teste Básico
```bash
node test-redis-counter.js
```

### Teste de Exemplo
```bash
node exemplo-uso-redis.js
```

### Teste Manual (cURL)
```bash
# Health check
curl http://localhost:3001/health

# Obter próximo contador
curl -X POST http://localhost:3001/api/counter/next \
  -H "Content-Type: application/json" \
  -d '{"agentType": "teste", "webhookType": "start"}'

# Listar contadores
curl http://localhost:3001/api/counter/list
```

## 🔍 Monitoramento

### Logs do Redis Counter Server
```bash
# Ver logs em tempo real
tail -f logs/redis-counter.log
```

### Monitorar Redis
```bash
# Conectar ao Redis CLI
redis-cli

# Ver todas as chaves
KEYS *

# Ver valor específico
GET agent_counter:vendas-premium:start

# Ver TTL de uma chave
TTL agent_counter:vendas-premium:start
```

## 🛠️ Troubleshooting

### Problema: Redis não conecta
```bash
# Verificar se Redis está rodando
redis-cli ping

# Deve retornar: PONG
```

### Problema: Porta 3001 ocupada
```bash
# Verificar processo na porta
netstat -tulpn | grep 3001

# Matar processo se necessário
kill -9 <PID>
```

### Problema: N8N não consegue acessar Redis Server
- Verificar se o servidor está rodando em `http://localhost:3001`
- Verificar CORS configurado
- Verificar firewall/antivírus bloqueando conexões

## 📊 Vantagens do Sistema

1. **Atomicidade**: Redis garante incrementos atômicos
2. **Persistência**: Contadores persistem entre reinicializações
3. **Escalabilidade**: Suporta múltiplas instâncias
4. **Flexibilidade**: Fácil reset e gerenciamento de contadores
5. **Monitoramento**: APIs para verificar estado dos contadores
6. **Performance**: Redis é extremamente rápido

## 🔄 Migração do Sistema Antigo

Para migrar do sistema antigo:

1. **Backup**: Faça backup dos workflows existentes
2. **Setup**: Configure Redis e Redis Counter Server
3. **Import**: Importe o novo workflow `create-agente-workflow-with-redis.json`
4. **Test**: Teste com dados de exemplo
5. **Deploy**: Substitua o workflow antigo pelo novo
6. **Monitor**: Monitore os logs e contadores

## 📝 Licença

MIT License - Livre para uso comercial e não comercial.
