# Teste do botão Stop - Verificar se execution_id está sendo enviado corretamente

Write-Host "🧪 TESTE: Botão Stop - Verificação do execution_id" -ForegroundColor Green
Write-Host "=" * 60

# Simular dados de um agente com execution_id
$agenteComExecutionId = @{
    id = 82
    nome = "Agente 2 Elleve"
    status_atual = "running"
    execution_id_ativo = "exec_12345_test"
    execution_id = "exec_12345_test"
}

Write-Host "📋 Dados do agente para teste:" -ForegroundColor Cyan
$agenteComExecutionId | ConvertTo-Json -Depth 3

Write-Host "`n🔍 Testando lógica de extração do execution_id..." -ForegroundColor Yellow

# Simular a lógica do frontend
$executionId = $agenteComExecutionId.execution_id_ativo
if (-not $executionId) {
    $executionId = $agenteComExecutionId.execution_id
}
if (-not $executionId) {
    $executionId = $null
}

Write-Host "✅ Execution ID extraído: '$executionId'" -ForegroundColor Green

if ($executionId) {
    Write-Host "✅ SUCESSO: Execution ID válido encontrado!" -ForegroundColor Green
    
    # Simular payload do webhook stop
    $payloadStop = @{
        action = "stop"
        agent_type = $agenteComExecutionId.id
        workflow_id = $agenteComExecutionId.id
        timestamp = (Get-Date).ToISOString()
        usuario_id = 38
        execution_id = $executionId
    }
    
    Write-Host "`n📦 Payload do webhook stop:" -ForegroundColor Cyan
    $payloadStop | ConvertTo-Json -Depth 3
    
    # Testar webhook stop
    $webhookUrl = "https://n8n.code-iq.com.br/webhook/stop13-agente2elleve"
    Write-Host "`n🌐 Testando webhook: $webhookUrl" -ForegroundColor Yellow
    
    try {
        $response = Invoke-RestMethod -Uri $webhookUrl -Method Post -ContentType "application/json" -Body ($payloadStop | ConvertTo-Json)
        Write-Host "✅ Webhook stop executado com sucesso!" -ForegroundColor Green
        Write-Host "📥 Resposta:" -ForegroundColor Cyan
        $response | ConvertTo-Json -Depth 3
    } catch {
        Write-Host "❌ Erro no webhook stop:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
} else {
    Write-Host "❌ ERRO: Execution ID não encontrado!" -ForegroundColor Red
    Write-Host "🔍 Verificar se o agente está rodando e tem execution_id válido" -ForegroundColor Yellow
}

Write-Host "`n" + "=" * 60
Write-Host "🏁 Teste concluído!" -ForegroundColor Green
