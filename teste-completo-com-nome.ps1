# Teste Completo: Create + Delete com Nome
Write-Host "=== TESTE COMPLETO COM NOME ===" -ForegroundColor Green

# URLs dos webhooks
$createUrl = "https://n8n.code-iq.com.br/webhook/create-agente"
$deleteUrl = "https://n8n.code-iq.com.br/webhook/delete-agente"

# Dados para criar um agente
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$agentId = 8888  # ID fixo para teste
$agentName = "Agente Teste Nome $timestamp"

$createData = @{
    name = $agentName
    agentType = "vendas-premium"
    icone = "🎯"
    cor = "bg-purple-500"
    descricao = "Agente para teste com nome"
    agentId = $agentId
} | ConvertTo-Json

Write-Host "`n1️⃣ CRIANDO AGENTE..." -ForegroundColor Cyan
Write-Host "Agent ID: $agentId" -ForegroundColor Yellow
Write-Host "Nome: $agentName" -ForegroundColor Yellow
Write-Host "Dados:" -ForegroundColor Yellow
Write-Host $createData -ForegroundColor Cyan

try {
    $createResponse = Invoke-RestMethod -Uri $createUrl -Method POST -Body $createData -ContentType "application/json" -ErrorAction Stop
    Write-Host "✅ CREATE - SUCESSO!" -ForegroundColor Green
    Write-Host "Resposta:" -ForegroundColor Yellow
    $createResponse | ConvertTo-Json -Depth 5 | Write-Host -ForegroundColor Cyan
    
    # Aguardar processamento
    Write-Host "`n⏳ Aguardando criação dos workflows..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    
} catch {
    Write-Host "❌ CREATE - ERRO!" -ForegroundColor Red
    Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Mensagem: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n2️⃣ DELETANDO AGENTE COM NOME..." -ForegroundColor Cyan

# Dados para deletar - INCLUINDO O NOME
$deleteData = @{
    agentId = $agentId
    name = $agentName  # ✅ ENVIANDO O NOME!
    workflowId = "dummy-workflow-id"
    reason = "Teste de remoção com nome"
} | ConvertTo-Json

Write-Host "Agent ID para deletar: $agentId" -ForegroundColor Yellow
Write-Host "Nome do agente: $agentName" -ForegroundColor Yellow
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
