#!/bin/bash

echo "🚀 Configurando Redis Counter Server..."

# Verificar se Node.js está instalado
if ! command -v node &> /dev/null; then
    echo "❌ Node.js não está instalado. Instalando..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Verificar se Redis está instalado
if ! command -v redis-server &> /dev/null; then
    echo "❌ Redis não está instalado. Instalando..."
    sudo apt-get update
    sudo apt-get install -y redis-server
fi

# Iniciar Redis se não estiver rodando
if ! pgrep -x "redis-server" > /dev/null; then
    echo "🔄 Iniciando Redis..."
    sudo systemctl start redis-server
    sudo systemctl enable redis-server
fi

# Instalar dependências do Node.js
echo "📦 Instalando dependências..."
npm install express redis cors

# Criar diretório de logs
mkdir -p logs

# Criar arquivo de configuração do Redis
cat > redis.conf << EOF
# Configuração básica do Redis
bind 127.0.0.1
port 6379
timeout 0
tcp-keepalive 60

# Persistência
save 900 1
save 300 10
save 60 10000

# Logs
loglevel notice
logfile /var/log/redis/redis-server.log

# Memória
maxmemory 256mb
maxmemory-policy allkeys-lru
EOF

echo "✅ Configuração concluída!"
echo ""
echo "📋 Próximos passos:"
echo "1. Iniciar o servidor Redis Counter:"
echo "   node redis-counter-server.js"
echo ""
echo "2. Testar o servidor:"
echo "   node test-redis-counter.js"
echo ""
echo "3. Importar o workflow no N8N:"
echo "   - Importar: create-agente-workflow-with-redis.json"
echo ""
echo "🔧 Endpoints disponíveis:"
echo "   - POST http://localhost:3001/api/counter/next"
echo "   - GET  http://localhost:3001/api/counter/current/:agentType/:webhookType"
echo "   - POST http://localhost:3001/api/counter/reset"
echo "   - GET  http://localhost:3001/api/counter/list"
echo "   - GET  http://localhost:3001/health"
