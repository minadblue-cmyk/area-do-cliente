# Script PowerShell para configurar Redis Counter Server no Windows

Write-Host "🚀 Configurando Redis Counter Server no Windows..." -ForegroundColor Green

# Verificar se Node.js está instalado
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js encontrado: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js não está instalado. Instale do site oficial: https://nodejs.org/" -ForegroundColor Red
    exit 1
}

# Verificar se Redis está instalado
try {
    $redisVersion = redis-server --version
    Write-Host "✅ Redis encontrado" -ForegroundColor Green
} catch {
    Write-Host "❌ Redis não está instalado." -ForegroundColor Red
    Write-Host "📥 Instale Redis para Windows:" -ForegroundColor Yellow
    Write-Host "   1. Baixe de: https://github.com/microsoftarchive/redis/releases" -ForegroundColor Yellow
    Write-Host "   2. Ou use Chocolatey: choco install redis-64" -ForegroundColor Yellow
    Write-Host "   3. Ou use WSL com Ubuntu" -ForegroundColor Yellow
    exit 1
}

# Instalar dependências do Node.js
Write-Host "📦 Instalando dependências..." -ForegroundColor Yellow
try {
    npm install express redis cors
    Write-Host "✅ Dependências instaladas com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro ao instalar dependências" -ForegroundColor Red
    exit 1
}

# Criar diretório de logs
if (!(Test-Path "logs")) {
    New-Item -ItemType Directory -Name "logs"
    Write-Host "📁 Diretório 'logs' criado" -ForegroundColor Green
}

# Criar arquivo de configuração do Redis
$redisConfig = @"
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
logfile logs/redis-server.log

# Memória
maxmemory 256mb
maxmemory-policy allkeys-lru
"@

$redisConfig | Out-File -FilePath "redis.conf" -Encoding UTF8
Write-Host "📝 Arquivo de configuração Redis criado" -ForegroundColor Green

Write-Host ""
Write-Host "✅ Configuração concluída!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Próximos passos:" -ForegroundColor Yellow
Write-Host "1. Iniciar Redis Server:" -ForegroundColor White
Write-Host "   redis-server" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Iniciar o Redis Counter Server (em outro terminal):" -ForegroundColor White
Write-Host "   node redis-counter-server.js" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Testar o servidor:" -ForegroundColor White
Write-Host "   node test-redis-counter.js" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. Importar o workflow no N8N:" -ForegroundColor White
Write-Host "   - Importar: create-agente-workflow-with-redis.json" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔧 Endpoints disponíveis:" -ForegroundColor Yellow
Write-Host "   - POST http://localhost:3001/api/counter/next" -ForegroundColor Cyan
Write-Host "   - GET  http://localhost:3001/api/counter/current/:agentType/:webhookType" -ForegroundColor Cyan
Write-Host "   - POST http://localhost:3001/api/counter/reset" -ForegroundColor Cyan
Write-Host "   - GET  http://localhost:3001/api/counter/list" -ForegroundColor Cyan
Write-Host "   - GET  http://localhost:3001/health" -ForegroundColor Cyan
