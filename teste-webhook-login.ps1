# Teste do Webhook de Login
Write-Host "=== TESTE WEBHOOK LOGIN ===" -ForegroundColor Green

$loginUrl = "https://n8n.code-iq.com.br/webhook/login"

# Dados de teste para login
$loginData = @{
    email = "teste@exemplo.com"
    password = "senha123"
} | ConvertTo-Json

Write-Host "URL: $loginUrl" -ForegroundColor Yellow
Write-Host "Dados:" -ForegroundColor Yellow
Write-Host $loginData -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri $loginUrl -Method POST -Body $loginData -ContentType "application/json" -ErrorAction Stop
    Write-Host "✅ LOGIN - SUCESSO!" -ForegroundColor Green
    Write-Host "Resposta:" -ForegroundColor Yellow
    $response | ConvertTo-Json -Depth 5 | Write-Host -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ LOGIN - ERRO!" -ForegroundColor Red
    Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Mensagem: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== FIM DO TESTE ===" -ForegroundColor Green
