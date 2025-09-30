# Teste de status apos stop
Write-Host "Teste status apos stop" -ForegroundColor Yellow

# Simular agente que foi "parado"
$agente = @{
    id = 81
    nome = "Ze"
    status_atual = "stopped"
    execution_id_ativo = $null
}

Write-Host "Agente apos stop:" -ForegroundColor Cyan
$agente | ConvertTo-Json

# Testar webhook de status
$webhookStatusUrl = "https://n8n.code-iq.com.br/webhook/status12-ze"
Write-Host "`nTestando webhook status: $webhookStatusUrl" -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri $webhookStatusUrl -Method GET
    Write-Host "Resposta status:" -ForegroundColor Green
    $response | ConvertTo-Json
} catch {
    Write-Host "Erro status:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`nTeste concluido!" -ForegroundColor Green
