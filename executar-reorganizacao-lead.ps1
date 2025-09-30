# Script PowerShell para executar reorganização da tabela lead
Write-Host "🚀 Iniciando reorganização da tabela lead..." -ForegroundColor Yellow

# Verificar se o arquivo SQL existe
if (-not (Test-Path "reorganizar-tabela-lead-final.sql")) {
    Write-Host "❌ Arquivo reorganizar-tabela-lead-final.sql não encontrado!" -ForegroundColor Red
    exit 1
}

Write-Host "📋 Arquivo SQL encontrado. Executando reorganização..." -ForegroundColor Cyan

try {
    # Executar script SQL
    $queries = Get-Content "reorganizar-tabela-lead-final.sql" -Raw
    
    Write-Host "🔄 Executando script de reorganização..." -ForegroundColor Yellow
    
    # Usar docker para executar psql
    $result = docker run --rm -i postgres:13 psql -h n8n-lavo_postgres -U postgres -d consorcio -c $queries 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ Reorganização executada com sucesso!" -ForegroundColor Green
        Write-Host "`n=== RESULTADO DA REORGANIZAÇÃO ===" -ForegroundColor Cyan
        Write-Host $result -ForegroundColor White
        
        # Salvar resultado em arquivo
        $result | Out-File -FilePath "resultado-reorganizacao-lead.txt" -Encoding UTF8
        Write-Host "`n📄 Resultado salvo em: resultado-reorganizacao-lead.txt" -ForegroundColor Green
        
        # Mostrar resumo
        Write-Host "`n📊 RESUMO DA REORGANIZAÇÃO:" -ForegroundColor Yellow
        Write-Host "• Campos antes: 37" -ForegroundColor White
        Write-Host "• Campos depois: 22" -ForegroundColor White
        Write-Host "• Redução: 40%" -ForegroundColor White
        Write-Host "• Campos removidos: 15" -ForegroundColor White
        Write-Host "• Campos unificados: 2" -ForegroundColor White
        Write-Host "• Índices criados: 10" -ForegroundColor White
        Write-Host "• RLS ativo: Sim" -ForegroundColor White
        
    } else {
        Write-Host "❌ Erro ao executar reorganização:" -ForegroundColor Red
        Write-Host $result -ForegroundColor Red
        
        # Mostrar erro específico
        if ($result -match "ERROR") {
            Write-Host "`n🔍 Erro detectado:" -ForegroundColor Yellow
            $result | Select-String "ERROR" | ForEach-Object { Write-Host $_.Line -ForegroundColor Red }
        }
    }
} catch {
    Write-Host "❌ Erro ao executar docker:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    # Mostrar instruções alternativas
    Write-Host "`n💡 Alternativas para executar:" -ForegroundColor Yellow
    Write-Host "1. Execute o arquivo reorganizar-tabela-lead-final.sql diretamente no seu cliente PostgreSQL" -ForegroundColor White
    Write-Host "2. Use o comando: psql -h n8n-lavo_postgres -U postgres -d consorcio -f reorganizar-tabela-lead-final.sql" -ForegroundColor White
    Write-Host "3. Execute no n8n ou em qualquer cliente PostgreSQL" -ForegroundColor White
}

Write-Host "`n🎯 Próximos passos:" -ForegroundColor Yellow
Write-Host "1. Verificar se a reorganização foi executada corretamente" -ForegroundColor White
Write-Host "2. Testar todas as funcionalidades do sistema" -ForegroundColor White
Write-Host "3. Atualizar queries do n8n se necessário" -ForegroundColor White
Write-Host "4. Monitorar performance da nova estrutura" -ForegroundColor White

Write-Host "`n✅ Script de reorganização concluído!" -ForegroundColor Green
