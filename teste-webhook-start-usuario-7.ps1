# =====================================================
# TESTE WEBHOOK START - USUÁRIO 7
# =====================================================

Write-Host "🧪 Testando Webhook Start com Usuário 7..." -ForegroundColor Green

# Payload para usuário 7
$payload = @{
    usuario_id = 7
    action = "start"
    logged_user = @{
        id = 7
        name = "Usuário Teste 7"
        email = "usuario7@teste.com"
    }
    agente_id = 6  # Assumindo que usuário 7 tem agente 6
    perfil_id = 1
    perfis_permitidos = @(1, 2)
    usuarios_permitidos = @(7)
} | ConvertTo-Json -Depth 3

Write-Host "📤 Payload enviado:" -ForegroundColor Yellow
Write-Host $payload -ForegroundColor Gray

try {
    $response = Invoke-RestMethod -Uri "http://localhost:5678/webhook/start" -Method POST -Body $payload -ContentType "application/json"
    
    Write-Host "✅ Resposta recebida:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor Gray
    
    Write-Host "`n🔍 Verificando se leads foram reservados..." -ForegroundColor Yellow
    
    # Aguardar um pouco para o processamento
    Start-Sleep -Seconds 3
    
} catch {
    Write-Host "❌ Erro na requisição:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n🏁 Teste do Usuário 7 concluído!" -ForegroundColor Green
