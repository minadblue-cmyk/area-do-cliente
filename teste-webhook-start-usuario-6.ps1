# =====================================================
# TESTE WEBHOOK START - USUÁRIO 6
# =====================================================

Write-Host "🧪 Testando Webhook Start com Usuário 6..." -ForegroundColor Green

# Payload para usuário 6
$payload = @{
    usuario_id = 6
    action = "start"
    logged_user = @{
        id = 6
        name = "Usuário Teste 6"
        email = "usuario6@teste.com"
    }
    agente_id = 5  # Assumindo que usuário 6 tem agente 5
    perfil_id = 2
    perfis_permitidos = @(2, 3)
    usuarios_permitidos = @(6)
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

Write-Host "`n🏁 Teste do Usuário 6 concluído!" -ForegroundColor Green
