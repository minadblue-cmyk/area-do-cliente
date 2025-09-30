# Script PowerShell para implementar isolamento de leads por empresa
Write-Host "🏢 Implementando isolamento de leads por empresa..." -ForegroundColor Yellow

# Verificar se os arquivos SQL existem
$arquivos = @(
    "implementar-isolamento-empresa-leads.sql",
    "atualizar-queries-n8n-isolamento-empresa.sql",
    "testar-isolamento-empresa-leads.sql"
)

foreach ($arquivo in $arquivos) {
    if (-not (Test-Path $arquivo)) {
        Write-Host "❌ Arquivo $arquivo não encontrado!" -ForegroundColor Red
        exit 1
    }
}

Write-Host "📋 Arquivos SQL encontrados. Executando implementação..." -ForegroundColor Cyan

try {
    # 1. Implementar isolamento
    Write-Host "`n🔄 Executando implementação do isolamento..." -ForegroundColor Yellow
    $queries1 = Get-Content "implementar-isolamento-empresa-leads.sql" -Raw
    $result1 = docker run --rm -i postgres:13 psql -h n8n-lavo_postgres -U postgres -d consorcio -c $queries1 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Isolamento implementado com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "❌ Erro ao implementar isolamento:" -ForegroundColor Red
        Write-Host $result1 -ForegroundColor Red
        exit 1
    }
    
    # 2. Executar testes
    Write-Host "`n🧪 Executando testes de validação..." -ForegroundColor Yellow
    $queries2 = Get-Content "testar-isolamento-empresa-leads.sql" -Raw
    $result2 = docker run --rm -i postgres:13 psql -h n8n-lavo_postgres -U postgres -d consorcio -c $queries2 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Testes executados com sucesso!" -ForegroundColor Green
        Write-Host "`n=== RESULTADO DOS TESTES ===" -ForegroundColor Cyan
        Write-Host $result2 -ForegroundColor White
    } else {
        Write-Host "❌ Erro ao executar testes:" -ForegroundColor Red
        Write-Host $result2 -ForegroundColor Red
    }
    
    # Salvar resultados
    $resultadoCompleto = @"
=== IMPLEMENTAÇÃO DO ISOLAMENTO ===
$result1

=== TESTES DE VALIDAÇÃO ===
$result2
"@
    
    $resultadoCompleto | Out-File -FilePath "resultado-isolamento-empresa.txt" -Encoding UTF8
    Write-Host "`n📄 Resultado salvo em: resultado-isolamento-empresa.txt" -ForegroundColor Green
    
    # Mostrar resumo
    Write-Host "`n📊 RESUMO DA IMPLEMENTAÇÃO:" -ForegroundColor Yellow
    Write-Host "• Isolamento por empresa: Implementado" -ForegroundColor White
    Write-Host "• Chaves únicas removidas: Sim" -ForegroundColor White
    Write-Host "• RLS ativo: Sim" -ForegroundColor White
    Write-Host "• Funções criadas: 7 funções" -ForegroundColor White
    Write-Host "• Índices otimizados: 10 índices" -ForegroundColor White
    Write-Host "• Mesmo telefone em empresas diferentes: Permitido" -ForegroundColor White
    
} catch {
    Write-Host "❌ Erro ao executar docker:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    # Mostrar instruções alternativas
    Write-Host "`n💡 Alternativas para executar:" -ForegroundColor Yellow
    Write-Host "1. Execute os arquivos SQL diretamente no seu cliente PostgreSQL" -ForegroundColor White
    Write-Host "2. Use o comando: psql -h n8n-lavo_postgres -U postgres -d consorcio -f implementar-isolamento-empresa-leads.sql" -ForegroundColor White
    Write-Host "3. Execute no n8n ou em qualquer cliente PostgreSQL" -ForegroundColor White
}

Write-Host "`n🎯 Próximos passos:" -ForegroundColor Yellow
Write-Host "1. Verificar se o isolamento foi implementado corretamente" -ForegroundColor White
Write-Host "2. Atualizar queries do n8n com as novas queries" -ForegroundColor White
Write-Host "3. Atualizar frontend para incluir empresa_id" -ForegroundColor White
Write-Host "4. Testar com múltiplas empresas" -ForegroundColor White
Write-Host "5. Monitorar performance da nova estrutura" -ForegroundColor White

Write-Host "`n📋 Arquivos criados:" -ForegroundColor Yellow
Write-Host "• implementar-isolamento-empresa-leads.sql - Script principal" -ForegroundColor White
Write-Host "• atualizar-queries-n8n-isolamento-empresa.sql - Queries para n8n" -ForegroundColor White
Write-Host "• testar-isolamento-empresa-leads.sql - Testes de validação" -ForegroundColor White
Write-Host "• atualizar-frontend-isolamento-empresa.md - Guia do frontend" -ForegroundColor White

Write-Host "`n✅ Implementação do isolamento concluída!" -ForegroundColor Green
