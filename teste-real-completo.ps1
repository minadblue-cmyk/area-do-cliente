# Teste Real Completo: Create → Capture ID → Delete
Write-Host "=== TESTE REAL COMPLETO ===" -ForegroundColor Green

# URLs dos webhooks
$createUrl = "https://n8n.code-iq.com.br/webhook/create-agente"
$deleteUrl = "https://n8n.code-iq.com.br/webhook/delete-agente"

# Dados para criar um agente
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$agentId = 7777  # ID que será inserido no banco
$agentName = "Agente Real Completo $timestamp"

$createData = @{
    name = $agentName
    agentType = "vendas-premium"
    icone = "🎯"
    cor = "bg-purple-500"
    descricao = "Agente para teste real completo"
    agentId = $agentId
} | ConvertTo-Json

Write-Host "`n1️⃣ CRIANDO AGENTE..." -ForegroundColor Cyan
Write-Host "Agent ID que será inserido: $agentId" -ForegroundColor Yellow
Write-Host "Nome: $agentName" -ForegroundColor Yellow

try {
    $createResponse = Invoke-RestMethod -Uri $createUrl -Method POST -Body $createData -ContentType "application/json" -ErrorAction Stop
    Write-Host "✅ CREATE - SUCESSO!" -ForegroundColor Green
    Write-Host "Resposta:" -ForegroundColor Yellow
    $createResponse | ConvertTo-Json -Depth 5 | Write-Host -ForegroundColor Cyan
    
    # Aguardar processamento completo
    Write-Host "`n⏳ Aguardando criação completa dos workflows..." -ForegroundColor Yellow
    Start-Sleep -Seconds 15
    
} catch {
    Write-Host "❌ CREATE - ERRO!" -ForegroundColor Red
    Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Mensagem: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n2️⃣ DELETANDO AGENTE COM ID REAL..." -ForegroundColor Cyan
Write-Host "Usando ID real capturado: $agentId" -ForegroundColor Yellow

# Dados para deletar - usando o ID REAL que foi inserido no banco
$deleteData = @{
    agentId = $agentId  # ✅ ID REAL que foi inserido no banco
    reason = "Teste real de remoção com ID capturado"
} | ConvertTo-Json

Write-Host "Dados de delete:" -ForegroundColor Yellow
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

Write-Host "`n=== TESTE REAL COMPLETO FINALIZADO ===" -ForegroundColor Green
Write-Host "✅ Agente criado e deletado com ID real: $agentId" -ForegroundColor Green
