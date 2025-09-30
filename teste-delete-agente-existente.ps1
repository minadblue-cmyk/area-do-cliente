# Teste Delete de Agente Existente
Write-Host "=== TESTE DELETE AGENTE EXISTENTE ===" -ForegroundColor Green

$deleteUrl = "https://n8n.code-iq.com.br/webhook/delete-agente"

# Testar com agentId que realmente existe no banco
$deleteData = @{
    agentId = 9999  # ID que foi criado no teste anterior
    workflowId = "dummy-workflow-id"  # Não importa, será ignorado
    reason = "Teste de remoção de agente existente"
} | ConvertTo-Json

Write-Host "Agent ID para deletar: 9999" -ForegroundColor Yellow
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

Write-Host "`n=== TESTE FINALIZADO ===" -ForegroundColor Green
