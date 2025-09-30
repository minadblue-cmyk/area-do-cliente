# Teste Completo dos Webhooks Create e Delete Agente
Write-Host "=== TESTE COMPLETO DOS WEBHOOKS ===" -ForegroundColor Green

# URLs dos webhooks (substitua pelas suas URLs reais)
$createUrl = "https://n8n.code-iq.com.br/webhook/create-agente"
$deleteUrl = "https://n8n.code-iq.com.br/webhook/delete-agente"

# Dados para criar agente
$createData = @{
    name = "Agente Teste Completo"
    agentType = "vendas-premium"
    icone = "🎯"
    cor = "bg-purple-500"
    descricao = "Agente de teste completo"
    agentId = 888
} | ConvertTo-Json

# Dados para deletar agente
$deleteData = @{
    agentId = 888
    workflowId = "test-workflow-id"
    reason = "Teste de remoção completo"
} | ConvertTo-Json

Write-Host "`n1️⃣ TESTANDO CREATE AGENTE..." -ForegroundColor Cyan
Write-Host "URL: $createUrl" -ForegroundColor Yellow

try {
    $createResponse = Invoke-RestMethod -Uri $createUrl -Method POST -Body $createData -ContentType "application/json" -ErrorAction Stop
    Write-Host "✅ CREATE - SUCESSO!" -ForegroundColor Green
    Write-Host "Resposta:" -ForegroundColor Yellow
    $createResponse | ConvertTo-Json -Depth 5 | Write-Host -ForegroundColor Cyan
} catch {
    Write-Host "❌ CREATE - ERRO!" -ForegroundColor Red
    Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Mensagem: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n2️⃣ TESTANDO DELETE AGENTE..." -ForegroundColor Cyan
Write-Host "URL: $deleteUrl" -ForegroundColor Yellow

try {
    $deleteResponse = Invoke-RestMethod -Uri $deleteUrl -Method POST -Body $deleteData -ContentType "application/json" -ErrorAction Stop
    Write-Host "✅ DELETE - SUCESSO!" -ForegroundColor Green
    Write-Host "Resposta:" -ForegroundColor Yellow
    $deleteResponse | ConvertTo-Json -Depth 5 | Write-Host -ForegroundColor Cyan
} catch {
    Write-Host "❌ DELETE - ERRO!" -ForegroundColor Red
    Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Mensagem: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== FIM DOS TESTES ===" -ForegroundColor Green
