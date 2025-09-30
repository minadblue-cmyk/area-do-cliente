# Teste do webhook create-agente-complete
$webhookUrl = "https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/create-agente"

Write-Host "Testando webhook create-agente-complete..."

$payload = @{
    action = "create"
    agent_name = "Zezinho"
    agent_type = "zezinho"
    agent_id = "MFTCMGP5D8QFQ"
    user_id = "5"
} | ConvertTo-Json

Write-Host "Payload: $payload"

try {
    $response = Invoke-RestMethod -Uri $webhookUrl -Method POST -Body $payload -ContentType "application/json"
    Write-Host "Sucesso! Resposta:"
    $response | ConvertTo-Json -Depth 10
}
catch {
    Write-Host "Erro: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        Write-Host "Status: $($_.Exception.Response.StatusCode)"
    }
}
