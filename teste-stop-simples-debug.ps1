# Teste simples do webhook stop
Write-Host "Teste webhook stop" -ForegroundColor Yellow

$agente = @{
    id = 81
    nome = "Ze"
    execution_id_ativo = "121411"
}

$webhookUrl = "https://n8n.code-iq.com.br/webhook/stop12-ze"

$payload = @{
    action = "stop"
    agent_type = $agente.id
    workflow_id = $agente.id
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    usuario_id = 6
    execution_id = $agente.execution_id_ativo
}

Write-Host "Payload:" -ForegroundColor Cyan
$payload | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $webhookUrl -Method Post -ContentType "application/json" -Body ($payload | ConvertTo-Json)
    Write-Host "Resposta:" -ForegroundColor Green
    $response | ConvertTo-Json
} catch {
    Write-Host "Erro:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "Teste concluido!" -ForegroundColor Green
