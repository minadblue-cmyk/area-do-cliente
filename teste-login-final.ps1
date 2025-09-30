# Teste Final do Login
Write-Host "=== TESTE LOGIN FINAL ===" -ForegroundColor Green

$loginUrl = "https://n8n.code-iq.com.br/webhook/login"

$loginData = @{
    email = "admin@code-iq.com.br"
    password = "F0rm@T10"
} | ConvertTo-Json

Write-Host "Testando login final..." -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri $loginUrl -Method POST -Body $loginData -ContentType "application/json" -ErrorAction Stop
    Write-Host "✅ LOGIN - SUCESSO!" -ForegroundColor Green
    Write-Host "Resposta:" -ForegroundColor Yellow
    $response | ConvertTo-Json -Depth 5 | Write-Host -ForegroundColor Cyan
    
    # Verificar se tem os campos esperados
    if ($response.success -eq $true) {
        Write-Host "`n✅ Campos encontrados:" -ForegroundColor Green
        Write-Host "  - success: $($response.success)" -ForegroundColor Cyan
        Write-Host "  - token: $($response.token)" -ForegroundColor Cyan
        Write-Host "  - nome: $($response.nome)" -ForegroundColor Cyan
        Write-Host "  - user.id: $($response.user.id)" -ForegroundColor Cyan
        Write-Host "  - user.email: $($response.user.email)" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host "❌ LOGIN - ERRO!" -ForegroundColor Red
    Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Mensagem: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== FIM DO TESTE ===" -ForegroundColor Green
