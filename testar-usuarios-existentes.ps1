Write-Host "Testando usuarios existentes" -ForegroundColor Yellow

# Testar rmacedo2005@hotmail.com (que sabemos que funciona)
Write-Host "1. Testando rmacedo2005@hotmail.com:" -ForegroundColor Cyan
$body1 = @{
    email = "rmacedo2005@hotmail.com"
    password = "123456"
} | ConvertTo-Json

try {
    $response1 = Invoke-RestMethod -Uri "https://n8n.code-iq.com.br/webhook/login" -Method POST -Body $body1 -ContentType "application/json"
    Write-Host "Login rmacedo2005@hotmail.com:" -ForegroundColor Green
    $response1 | ConvertTo-Json -Depth 3
} catch {
    Write-Host "Erro no login rmacedo2005@hotmail.com: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Testar fith@fithinvestimento
Write-Host "2. Testando fith@fithinvestimento:" -ForegroundColor Cyan
$body2 = @{
    email = "fith@fithinvestimento"
    password = "123456"
} | ConvertTo-Json

try {
    $response2 = Invoke-RestMethod -Uri "https://n8n.code-iq.com.br/webhook/login" -Method POST -Body $body2 -ContentType "application/json"
    Write-Host "Login fith@fithinvestimento:" -ForegroundColor Green
    $response2 | ConvertTo-Json -Depth 3
} catch {
    Write-Host "Erro no login fith@fithinvestimento: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Testar admin@admin.com
Write-Host "3. Testando admin@admin.com:" -ForegroundColor Cyan
$body3 = @{
    email = "admin@admin.com"
    password = "123456"
} | ConvertTo-Json

try {
    $response3 = Invoke-RestMethod -Uri "https://n8n.code-iq.com.br/webhook/login" -Method POST -Body $body3 -ContentType "application/json"
    Write-Host "Login admin@admin.com:" -ForegroundColor Green
    $response3 | ConvertTo-Json -Depth 3
} catch {
    Write-Host "Erro no login admin@admin.com: $($_.Exception.Message)" -ForegroundColor Red
}
