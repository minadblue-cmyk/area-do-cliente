# =====================================================
# TESTE LISTA DE PROSPECÇÃO - USUÁRIO 6
# =====================================================

Write-Host "🧪 Testando Lista de Prospecção com Usuário 6..." -ForegroundColor Green

# Payload para buscar lista de prospecção do usuário 6
$payload = @{
    usuario_id = 6
    agente_id = 5
    perfil_id = 2
    perfis_permitidos = @(2, 3)
    usuarios_permitidos = @(6)
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
        Write-Host "⚠️  Nenhum lead encontrado para o usuário 6" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "❌ Erro na requisição:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n🏁 Teste da Lista de Prospecção (Usuário 6) concluído!" -ForegroundColor Green
