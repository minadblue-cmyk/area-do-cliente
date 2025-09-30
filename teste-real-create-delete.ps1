# Teste REAL: Create + Delete com dados reais
Write-Host "=== TESTE REAL CREATE + DELETE ===" -ForegroundColor Green

# URLs dos webhooks
$createUrl = "https://n8n.code-iq.com.br/webhook/create-agente"
$deleteUrl = "https://n8n.code-iq.com.br/webhook/delete-agente"

# Dados para criar um agente REAL
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$agentId = 9999  # ID fixo para teste
$createData = @{
    name = "Agente Real Teste $timestamp"
    agentType = "vendas-premium"
    icone = "🎯"
    cor = "bg-purple-500"
    descricao = "Agente real para teste de deleção"
    agentId = $agentId
} | ConvertTo-Json

Write-Host "`n1️⃣ CRIANDO AGENTE REAL..." -ForegroundColor Cyan
Write-Host "Agent ID: $agentId" -ForegroundColor Yellow
Write-Host "Nome: Agente Real Teste $timestamp" -ForegroundColor Yellow
Write-Host "Dados:" -ForegroundColor Yellow
Write-Host $createData -ForegroundColor Cyan

try {
    $createResponse = Invoke-RestMethod -Uri $createUrl -Method POST -Body $createData -ContentType "application/json" -ErrorAction Stop
    Write-Host "✅ CREATE - SUCESSO!" -ForegroundColor Green
    Write-Host "Resposta:" -ForegroundColor Yellow
    $createResponse | ConvertTo-Json -Depth 5 | Write-Host -ForegroundColor Cyan
    
    # Aguardar processamento do workflow
    Write-Host "`n⏳ Aguardando criação dos workflows..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    
} catch {
    Write-Host "❌ CREATE - ERRO!" -ForegroundColor Red
    Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Mensagem: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n2️⃣ DELETANDO AGENTE REAL..." -ForegroundColor Cyan

# Dados para deletar o agente REAL
# Usar o nome real do agente para localizar os workflows
$deleteData = @{
    agentId = $agentId
    workflowId = "Agente Real Teste $timestamp"  # Nome real do agente
    reason = "Teste real de remoção"
} | ConvertTo-Json

Write-Host "Agent ID para deletar: $agentId" -ForegroundColor Yellow
Write-Host "Nome do agente: Agente Real Teste $timestamp" -ForegroundColor Yellow
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

Write-Host "`n=== TESTE REAL FINALIZADO ===" -ForegroundColor Green
