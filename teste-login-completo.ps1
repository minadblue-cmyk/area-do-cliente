# Teste do Webhook de Login
Write-Host "=== TESTE WEBHOOK LOGIN ===" -ForegroundColor Green

$loginUrl = "https://n8n.code-iq.com.br/webhook/login"

# Teste com usuário existente
$loginData = @{
    email = "admin@code-iq.com.br"
    password = "senha123"  # Ajuste conforme necessário
} | ConvertTo-Json

Write-Host "URL: $loginUrl" -ForegroundColor Yellow
Write-Host "Dados de login:" -ForegroundColor Yellow
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
