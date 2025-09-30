# Teste da nova estrutura de resposta do n8n
$webhookUrl = "https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/create-agente"

Write-Host "Testando nova estrutura de resposta do n8n..."

$payload = @{
    action = "create"
    agent_name = "Agente Teste Nova Estrutura"
    agent_type = "teste"
    agent_id = "TEST123456"
    user_id = "5"
} | ConvertTo-Json

Write-Host "Payload: $payload"

try {
    $response = Invoke-RestMethod -Uri $webhookUrl -Method POST -Body $payload -ContentType "application/json"
    Write-Host "Sucesso! Resposta:"
    $response | ConvertTo-Json -Depth 10
    
    # Verificar se tem a nova estrutura
    if ($response.success -and $response.agentId) {
        Write-Host "✅ Nova estrutura detectada:"
        Write-Host "   - Success: $($response.success)"
        Write-Host "   - Agent ID: $($response.agentId)"
        Write-Host "   - Agent Name: $($response.agentName)"
        Write-Host "   - Execution ID: $($response.executionId)"
    } else {
        Write-Host "⚠️ Estrutura antiga ou inesperada"
    }
}
catch {
    Write-Host "Erro: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        Write-Host "Status: $($_.Exception.Response.StatusCode)"
    }
}
