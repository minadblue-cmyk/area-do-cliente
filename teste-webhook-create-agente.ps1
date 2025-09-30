# Teste do Webhook Create Agente
Write-Host "=== TESTE WEBHOOK CREATE AGENTE ===" -ForegroundColor Green

# URL do webhook (substitua pela sua URL real)
$webhookUrl = "https://n8n.code-iq.com.br/webhook/create-agente"

# Dados de teste para criar um agente
$testData = @{
    name = "Agente Teste SDR"
    agentType = "vendas-premium"
    icone = "🚀"
    cor = "bg-blue-500"
    descricao = "Agente de teste para prospecção"
    agentId = 999
} | ConvertTo-Json

Write-Host "URL: $webhookUrl" -ForegroundColor Yellow
Write-Host "Dados enviados:" -ForegroundColor Yellow
Write-Host $testData -ForegroundColor Cyan

try {
    Write-Host "`nEnviando requisição..." -ForegroundColor Green
    
    $response = Invoke-RestMethod -Uri $webhookUrl -Method POST -Body $testData -ContentType "application/json" -ErrorAction Stop
    
    Write-Host "`n✅ SUCESSO!" -ForegroundColor Green
    Write-Host "Resposta:" -ForegroundColor Yellow
    $response | ConvertTo-Json -Depth 10 | Write-Host -ForegroundColor Cyan
    
} catch {
    Write-Host "`n❌ ERRO!" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Mensagem: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response Body: $responseBody" -ForegroundColor Red
    }
}

Write-Host "`n=== FIM DO TESTE ===" -ForegroundColor Green
