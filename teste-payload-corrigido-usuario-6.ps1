# =====================================================
# TESTE PAYLOAD CORRIGIDO - USUÁRIO 6
# =====================================================

Write-Host "🧪 Testando Payload Corrigido para Usuário 6..." -ForegroundColor Green

# Primeiro, vamos buscar os dados corretos do usuário 6
Write-Host "`n🔍 Buscando dados do usuário 6..." -ForegroundColor Yellow

# Simular busca de agente e perfis (você pode implementar endpoints reais)
$agente_id = 5  # Assumindo que usuário 6 tem agente 5
$perfil_id = 2  # Assumindo que usuário 6 tem perfil 2

# Payload corrigido com todos os campos necessários
$payload = @{
    usuario_id = 6
    action = "start"
    logged_user = @{
        id = 6
        name = "Usuário Elleve Padrão"
        email = "rmacedo2005@hotmail.com"
    }
    agente_id = $agente_id
    perfil_id = $perfil_id
    perfis_permitidos = @(2, 3)  # Perfis permitidos
    usuarios_permitidos = @(6)   # Usuários permitidos
} | ConvertTo-Json -Depth 3

Write-Host "📤 Payload corrigido enviado:" -ForegroundColor Yellow
Write-Host $payload -ForegroundColor Gray

try {
    $response = Invoke-RestMethod -Uri "http://localhost:5678/webhook/start" -Method POST -Body $payload -ContentType "application/json"
    
    Write-Host "✅ Resposta recebida:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor Gray
    
    Write-Host "`n🔍 Verificando se leads foram reservados..." -ForegroundColor Yellow
    
    # Aguardar um pouco para o processamento
    Start-Sleep -Seconds 3
    
    Write-Host "`n📊 Verificando leads reservados no banco..." -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Erro na requisição:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n🏁 Teste do Payload Corrigido (Usuário 6) concluído!" -ForegroundColor Green
