# Teste do status real no n8n
Write-Host "Teste status real no n8n" -ForegroundColor Yellow

$webhookStatusUrl = "https://n8n.code-iq.com.br/webhook/status12-ze"
Write-Host "Testando webhook status: $webhookStatusUrl" -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri $webhookStatusUrl -Method GET
    Write-Host "Resposta do n8n:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
    
    # Analisar campos importantes
    Write-Host "`nAnalise dos campos:" -ForegroundColor Yellow
    Write-Host "Status: $($response.status)" -ForegroundColor White
    Write-Host "Execution ID: $($response.executionId)" -ForegroundColor White
    Write-Host "Workflow ID: $($response.workflowId)" -ForegroundColor White
    Write-Host "Iniciado em: $($response.iniciadoEm)" -ForegroundColor White
    Write-Host "Parado em: $($response.paradoEm)" -ForegroundColor White
    Write-Host "Finalizado em: $($response.finalizadoEm)" -ForegroundColor White
    
} catch {
    Write-Host "Erro ao consultar status:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`nTeste concluido!" -ForegroundColor Green
