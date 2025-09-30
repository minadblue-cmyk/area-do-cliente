$webhookUrl = "https://n8n.code-iq.com.br/webhook/create-agente"
$payload = @{
    action = "create"
    agent_name = "Teste"
    agent_type = "teste"
    agent_id = "TEST123"
    user_id = "5"
} | ConvertTo-Json

Write-Host "Testando webhook..."
Write-Host "URL: $webhookUrl"
Write-Host "Payload: $payload"

try {
    $response = Invoke-RestMethod -Uri $webhookUrl -Method POST -Body $payload -ContentType "application/json"
    Write-Host "Resposta:"
    $response | ConvertTo-Json -Depth 10
}
catch {
    Write-Host "Erro: $($_.Exception.Message)"
}
