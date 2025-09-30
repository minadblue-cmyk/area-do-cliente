# Teste com a URL que o frontend está usando
$webhookUrl = "https://n8n.code-iq.com.br/webhook/create-agente"

Write-Host "Testando com a URL do frontend: $webhookUrl"

$payload = @{
    action = "create"
    agent_name = "Agente Teste Frontend"
    agent_type = "frontend"
    agent_id = "FRONTEND123"
    user_id = "5"
} | ConvertTo-Json

Write-Host "Payload: $payload"

try {
    $response = Invoke-RestMethod -Uri $webhookUrl -Method POST -Body $payload -ContentType "application/json"
    Write-Host "Sucesso! Resposta:"
    $response | ConvertTo-Json -Depth 10
    
    # Verificar estrutura da resposta
    if ($response.success -and $response.agentId) {
        Write-Host "✅ Nova estrutura detectada:"
        Write-Host "   - Success: $($response.success)"
        Write-Host "   - Agent ID: $($response.agentId)"
        Write-Host "   - Agent Name: $($response.agentName)"
        Write-Host "   - Execution ID: $($response.executionId)"
    } elseif ($response.message -eq "Workflow was started") {
        Write-Host "⚠️ Estrutura antiga: Workflow was started"
    } else {
        Write-Host "🔍 Estrutura desconhecida:"
        Write-Host "   - Tipo: $($response.GetType().Name)"
        Write-Host "   - Propriedades: $($response.PSObject.Properties.Name -join ', ')"
    }
}
catch {
    Write-Host "Erro: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        Write-Host "Status: $($_.Exception.Response.StatusCode)"
    }
}
