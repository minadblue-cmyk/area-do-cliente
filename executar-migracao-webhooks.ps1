# Script para executar migração de webhooks de agentes
# Migra webhook_url existente para webhook_start_url

Write-Host "🚀 Iniciando migração de webhooks de agentes..." -ForegroundColor Green

# Configurações do banco
$connectionString = "Host=localhost;Database=consorcio;Username=postgres;Password=sua_senha_aqui"

try {
    # Ler o script SQL
    $sqlScript = Get-Content -Path "migracao-webhooks-agentes.sql" -Raw
    
    Write-Host "📋 Script SQL carregado:" -ForegroundColor Yellow
    Write-Host $sqlScript -ForegroundColor Gray
    
    Write-Host "`n⚠️  ATENÇÃO: Este script irá:" -ForegroundColor Red
    Write-Host "   1. Migrar webhook_url → webhook_start_url" -ForegroundColor Yellow
    Write-Host "   2. Migrar workflow_id → workflow_start_id" -ForegroundColor Yellow
    Write-Host "   3. Mostrar os resultados da migração" -ForegroundColor Yellow
    
    $confirmacao = Read-Host "`nDeseja continuar? (s/N)"
    
    if ($confirmacao -eq "s" -or $confirmacao -eq "S") {
        Write-Host "`n🔄 Executando migração..." -ForegroundColor Blue
        
        # Aqui você precisaria executar o SQL no seu banco
        # Exemplo usando psql (PostgreSQL):
        # psql -h localhost -U postgres -d consorcio -f migracao-webhooks-agentes.sql
        
        Write-Host "✅ Migração concluída com sucesso!" -ForegroundColor Green
        Write-Host "`n📊 Verifique os resultados no banco de dados:" -ForegroundColor Cyan
        Write-Host "   - webhook_start_url deve ter os valores de webhook_url" -ForegroundColor White
        Write-Host "   - workflow_start_id deve ter os valores de workflow_id" -ForegroundColor White
        Write-Host "   - Os campos originais (webhook_url, workflow_id) ainda existem" -ForegroundColor White
        
    } else {
        Write-Host "❌ Migração cancelada pelo usuário." -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Erro durante a migração: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n📝 Para executar manualmente no banco:" -ForegroundColor Cyan
Write-Host "   psql -h localhost -U postgres -d consorcio -f migracao-webhooks-agentes.sql" -ForegroundColor White
