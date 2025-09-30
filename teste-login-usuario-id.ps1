# Teste Login com usuario_id
Write-Host "=== TESTE LOGIN COM USUARIO_ID ===" -ForegroundColor Green

$loginUrl = "https://n8n.code-iq.com.br/webhook/login"

$loginData = @{
    email = "admin@code-iq.com.br"
    password = "F0rm@T10"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $loginUrl -Method POST -Body $loginData -ContentType "application/json" -ErrorAction Stop
    Write-Host "✅ LOGIN - SUCESSO!" -ForegroundColor Green
    Write-Host "`n📊 RESPOSTA:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 10 | Write-Host -ForegroundColor White
    
    Write-Host "`n🔍 CAMPOS ESPECÍFICOS:" -ForegroundColor Yellow
    Write-Host "  - usuario_id: $($response.usuario_id)" -ForegroundColor Cyan
    Write-Host "  - nome: $($response.nome)" -ForegroundColor Cyan
    Write-Host "  - email: $($response.email)" -ForegroundColor Cyan
    Write-Host "  - perfil: $($response.perfil)" -ForegroundColor Cyan
    Write-Host "  - perfil_id: $($response.perfil_id)" -ForegroundColor Cyan
    Write-Host "  - plano: $($response.plano)" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ LOGIN - ERRO!" -ForegroundColor Red
    Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Mensagem: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== FIM DO TESTE ===" -ForegroundColor Green
