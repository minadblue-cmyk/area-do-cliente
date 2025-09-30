# Teste do Webhook Edit Users
Write-Host "=== TESTE WEBHOOK EDIT USERS ===" -ForegroundColor Green

$webhookUrl = "https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/edit-users"

# Dados de teste baseados no frontend
$testData = @{
    id = 6
    email = "rmacedo2005@hotmail.com"
    senha = ""
    nome = "Teste de Dashboard"
    ativo = "true"
    empresa = "Dell EMC"
    empresa_id = 12
    plano = "basico"
    perfil = ""
    perfil_id = $null
    perfis = @()
} | ConvertTo-Json -Depth 3

Write-Host "URL: $webhookUrl" -ForegroundColor Yellow
Write-Host "Dados:" -ForegroundColor Yellow
Write-Host $testData -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri $webhookUrl -Method POST -Body $testData -ContentType "application/json" -ErrorAction Stop
    Write-Host "✅ WEBHOOK - SUCESSO!" -ForegroundColor Green
    Write-Host "Resposta:" -ForegroundColor Yellow
    $response | ConvertTo-Json -Depth 10 | Write-Host -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ WEBHOOK - ERRO!" -ForegroundColor Red
    Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Mensagem: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== FIM DO TESTE ===" -ForegroundColor Green
