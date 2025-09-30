# Teste simples do botão Stop
Write-Host "Teste do botao Stop - Verificacao do execution_id" -ForegroundColor Green

# Simular agente com execution_id
$agente = @{
    id = 82
    nome = "Agente 2 Elleve"
    execution_id_ativo = "exec_12345_test"
}

Write-Host "Dados do agente:" -ForegroundColor Cyan
$agente | ConvertTo-Json

# Extrair execution_id
$executionId = $agente.execution_id_ativo
Write-Host "Execution ID extraido: $executionId" -ForegroundColor Green

if ($executionId) {
    Write-Host "SUCESSO: Execution ID encontrado!" -ForegroundColor Green
    
    # Criar payload
    $payload = @{
        action = "stop"
        agent_type = $agente.id
        workflow_id = $agente.id
        timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        usuario_id = 38
        execution_id = $executionId
    }
    
    Write-Host "Payload do webhook stop:" -ForegroundColor Cyan
    $payload | ConvertTo-Json
    
    # Testar webhook
    $webhookUrl = "https://n8n.code-iq.com.br/webhook/stop13-agente2elleve"
    Write-Host "Testando webhook: $webhookUrl" -ForegroundColor Yellow
    
    try {
        $response = Invoke-RestMethod -Uri $webhookUrl -Method Post -ContentType "application/json" -Body ($payload | ConvertTo-Json)
        Write-Host "Webhook executado com sucesso!" -ForegroundColor Green
        Write-Host "Resposta:"
        $response | ConvertTo-Json
    } catch {
        Write-Host "Erro no webhook:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
} else {
    Write-Host "ERRO: Execution ID nao encontrado!" -ForegroundColor Red
}

Write-Host "Teste concluido!" -ForegroundColor Green
