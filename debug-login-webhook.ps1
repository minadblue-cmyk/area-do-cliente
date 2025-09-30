Write-Host "Debugando webhook de login" -ForegroundColor Yellow

# Testar com usuario que sabemos que tem empresa_id
$loginBody = @{
    email = "rmacedo2005@hotmail.com"
    password = "123456"
} | ConvertTo-Json

Write-Host "Testando login com rmacedo2005@hotmail.com:" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "https://n8n.code-iq.com.br/webhook/login" -Method POST -Body $loginBody -ContentType "application/json"
    Write-Host "Resposta completa:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "Erro: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Testando login com fith@fithinvestimento.com:" -ForegroundColor Cyan

$loginBody2 = @{
    email = "fith@fithinvestimento.com"
    password = "F0rm@T10"
} | ConvertTo-Json

try {
    $response2 = Invoke-RestMethod -Uri "https://n8n.code-iq.com.br/webhook/login" -Method POST -Body $loginBody2 -ContentType "application/json"
    Write-Host "Resposta completa:" -ForegroundColor Green
    $response2 | ConvertTo-Json -Depth 3
} catch {
    Write-Host "Erro: $($_.Exception.Message)" -ForegroundColor Red
}
