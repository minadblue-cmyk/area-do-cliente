# =====================================================
# TESTE LISTA DE PROSPECÇÃO - USUÁRIO 7
# =====================================================

Write-Host "🧪 Testando Lista de Prospecção com Usuário 7..." -ForegroundColor Green

# Payload para buscar lista de prospecção do usuário 7
$payload = @{
    usuario_id = 7
    agente_id = 6
    perfil_id = 1
    perfis_permitidos = @(1, 2)
    usuarios_permitidos = @(7)
} | ConvertTo-Json -Depth 3

Write-Host "📤 Payload enviado:" -ForegroundColor Yellow
Write-Host $payload -ForegroundColor Gray

try {
    $response = Invoke-RestMethod -Uri "http://localhost:5678/webhook/list" -Method POST -Body $payload -ContentType "application/json"
    
    Write-Host "✅ Resposta recebida:" -ForegroundColor Green
    Write-Host "📊 Total de leads encontrados: $($response.Count)" -ForegroundColor Cyan
    
    if ($response.Count -gt 0) {
        Write-Host "`n📋 Primeiros 3 leads:" -ForegroundColor Yellow
        $response | Select-Object -First 3 | ForEach-Object {
            Write-Host "  - ID: $($_.id), Nome: $($_.nome_cliente), Telefone: $($_.telefone), Contatado: $($_.contatado)" -ForegroundColor Gray
        }
        
        # Verificar se todos os leads têm contatado = true
        $leadsSemContatado = $response | Where-Object { $_.contatado -ne $true }
        if ($leadsSemContatado.Count -gt 0) {
            Write-Host "⚠️  ATENÇÃO: $($leadsSemContatado.Count) leads sem campo contatado = true" -ForegroundColor Red
        } else {
            Write-Host "✅ Todos os leads têm contatado = true" -ForegroundColor Green
        }
    } else {
        Write-Host "⚠️  Nenhum lead encontrado para o usuário 7" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "❌ Erro na requisição:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n🏁 Teste da Lista de Prospecção (Usuário 7) concluído!" -ForegroundColor Green
