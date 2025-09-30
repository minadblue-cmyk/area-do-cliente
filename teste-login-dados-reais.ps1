# Teste de Login com Dados Reais
Write-Host "=== TESTE LOGIN COM DADOS REAIS ===" -ForegroundColor Green

$loginUrl = "https://n8n.code-iq.com.br/webhook/login"

# Teste com usuário que existe no banco (ID 5)
$loginData = @{
    email = "admin@code-iq.com.br"
    password = "admin123"  # Senha comum para teste
} | ConvertTo-Json

Write-Host "Testando com usuário: admin@code-iq.com.br" -ForegroundColor Yellow
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
