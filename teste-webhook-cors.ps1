# Teste CORS do Webhook
Write-Host "=== TESTE CORS WEBHOOK ===" -ForegroundColor Green

$webhookUrl = "https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/listar-saudacao"

# Teste com headers do navegador
$headers = @{
    "Content-Type" = "application/json"
    "Origin" = "http://localhost:5173"
    "Referer" = "http://localhost:5173/"
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
}

$testData = @{
    id = 5
    usuario_id = 5
    nome = "Administrator Code-IQ"
    email = "admin@code-iq.com.br"
    tipo = "Administrador"
    role = "Administrador"
} | ConvertTo-Json

Write-Host "URL: $webhookUrl" -ForegroundColor Yellow
Write-Host "Headers:" -ForegroundColor Yellow
$headers | ConvertTo-Json | Write-Host -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri $webhookUrl -Method POST -Body $testData -Headers $headers -ErrorAction Stop
    Write-Host "✅ WEBHOOK - SUCESSO!" -ForegroundColor Green
    Write-Host "Resposta:" -ForegroundColor Yellow
    $response | ConvertTo-Json -Depth 10 | Write-Host -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ WEBHOOK - ERRO!" -ForegroundColor Red
    Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Mensagem: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response Body: $responseBody" -ForegroundColor Red
    }
}

Write-Host "`n=== FIM DO TESTE ===" -ForegroundColor Green
