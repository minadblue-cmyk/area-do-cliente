# Teste Delete Simples - Só com agentId
Write-Host "=== TESTE DELETE SIMPLES ===" -ForegroundColor Green

$deleteUrl = "https://n8n.code-iq.com.br/webhook/delete-agente"

# Testar com agentId que existe no banco (criado anteriormente)
$deleteData = @{
    agentId = 8888  # ID do agente criado no teste anterior
    reason = "Teste de remoção simples"
} | ConvertTo-Json

Write-Host "Agent ID para deletar: 8888" -ForegroundColor Yellow
Write-Host "Dados (sem nome):" -ForegroundColor Yellow
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
