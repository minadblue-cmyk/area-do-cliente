Write-Host "Testando login do usuario fith@fithinvestimento" -ForegroundColor Yellow

$body = @{
    email = "fith@fithinvestimento.com"
    password = "F0rm@T10"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "https://n8n.code-iq.com.br/webhook/login" -Method POST -Body $body -ContentType "application/json"
    Write-Host "Login realizado com sucesso:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "Erro no login: $($_.Exception.Message)" -ForegroundColor Red
}
