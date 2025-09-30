# Teste Completo: Create + Delete Agente
Write-Host "=== TESTE COMPLETO CREATE + DELETE ===" -ForegroundColor Green

# URLs dos webhooks
$createUrl = "https://n8n.code-iq.com.br/webhook/create-agente"
$deleteUrl = "https://n8n.code-iq.com.br/webhook/delete-agente"

# Dados para criar um novo agente
$agentId = Get-Random -Minimum 1000 -Maximum 9999
$createData = @{
    name = "Agente Teste Completo $agentId"
    agentType = "vendas-premium"
    icone = "🎯"
    cor = "bg-purple-500"
    descricao = "Agente de teste para fluxo completo"
    agentId = $agentId
} | ConvertTo-Json

Write-Host "`n1️⃣ CRIANDO NOVO AGENTE..." -ForegroundColor Cyan
Write-Host "Agent ID: $agentId" -ForegroundColor Yellow
Write-Host "Dados:" -ForegroundColor Yellow
Write-Host $createData -ForegroundColor Cyan

try {
    $createResponse = Invoke-RestMethod -Uri $createUrl -Method POST -Body $createData -ContentType "application/json" -ErrorAction Stop
    Write-Host "✅ CREATE - SUCESSO!" -ForegroundColor Green
    Write-Host "Resposta:" -ForegroundColor Yellow
    $createResponse | ConvertTo-Json -Depth 5 | Write-Host -ForegroundColor Cyan
    
    # Aguardar um pouco para o workflow processar
    Write-Host "`n⏳ Aguardando processamento..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    
} catch {
    Write-Host "❌ CREATE - ERRO!" -ForegroundColor Red
    Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Mensagem: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n2️⃣ DELETANDO AGENTE CRIADO..." -ForegroundColor Cyan

# Dados para deletar o agente
$deleteData = @{
    agentId = $agentId
    workflowId = "test-workflow-$agentId"
    reason = "Teste de remoção completa"
} | ConvertTo-Json

Write-Host "Agent ID para deletar: $agentId" -ForegroundColor Yellow
Write-Host "Dados:" -ForegroundColor Yellow
Write-Host $deleteData -ForegroundColor Cyan

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

Write-Host "`n=== TESTE COMPLETO FINALIZADO ===" -ForegroundColor Green
