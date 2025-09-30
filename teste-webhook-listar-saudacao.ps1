# Teste do Webhook Listar Saudação
Write-Host "=== TESTE WEBHOOK LISTAR SAUDACAO ===" -ForegroundColor Green

$webhookUrl = "https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/listar-saudacao"

# Dados de teste baseados no frontend
$testData = @{
    usuario_id = 5
    nome = "Administrator Code-IQ"
    email = "admin@code-iq.com.br"
    tipo = "Administrador"
    role = "Administrador"
} | ConvertTo-Json

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
