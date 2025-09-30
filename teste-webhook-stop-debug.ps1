# Teste detalhado do webhook stop
Write-Host "🔍 TESTE DETALHADO: Webhook Stop" -ForegroundColor Yellow
Write-Host "=" * 50

# Simular dados de um agente rodando
$agenteRodando = @{
    id = 81
    nome = "Zé"
    status_atual = "running"
    execution_id_ativo = "121411"
    webhook_stop_url = "webhook/stop12-ze"
}

Write-Host "📋 Dados do agente:" -ForegroundColor Cyan
$agenteRodando | ConvertTo-Json

# Testar webhook stop com execution_id
$webhookUrl = "https://n8n.code-iq.com.br/webhook/stop12-ze"
Write-Host "`n🌐 Testando webhook: $webhookUrl" -ForegroundColor Yellow

$payloadStop = @{
    action = "stop"
    agent_type = $agenteRodando.id
    workflow_id = $agenteRodando.id
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    usuario_id = 6
    execution_id = $agenteRodando.execution_id_ativo
}

Write-Host "`n📦 Payload enviado:" -ForegroundColor Cyan
$payloadStop | ConvertTo-Json

try {
    Write-Host "`n🚀 Enviando requisição..." -ForegroundColor Green
    $response = Invoke-RestMethod -Uri $webhookUrl -Method Post -ContentType "application/json" -Body ($payloadStop | ConvertTo-Json)
    
    Write-Host "✅ Resposta recebida:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
    
    # Verificar se a resposta indica sucesso
    if ($response.success -eq $true -or $response.message -like "*sucesso*" -or $response.message -like "*parado*") {
        Write-Host "`n✅ SUCESSO: Agente deve ter sido parado!" -ForegroundColor Green
    } else {
        Write-Host "`n⚠️ AVISO: Resposta não indica sucesso claro" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "`n❌ ERRO na requisição:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode
        Write-Host "Status Code: $statusCode" -ForegroundColor Red
    }
}

Write-Host "`n" + "=" * 50
Write-Host "Teste concluido!" -ForegroundColor Green
