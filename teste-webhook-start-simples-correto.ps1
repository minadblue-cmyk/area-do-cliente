# Teste do Webhook Start com Payload Correto
Write-Host "🚀 Testando Webhook Start com Payload Correto..." -ForegroundColor Green

$webhookUrl = "https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/start12-ze"

$payload = @{
    action = "start"
    agent_type = 81
    workflow_id = 81
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    usuario_id = "6"
    agente_id = 81
    perfil_id = 1
    perfis_permitidos = @(1, 2)
    usuarios_permitidos = @(6, 7)
    logged_user = @{
        id = "6"
        name = "Usuário Elleve Padrão"
        email = "rmacedo2005@hotmail.com"
    }
} | ConvertTo-Json -Depth 3

Write-Host "📤 Payload:" -ForegroundColor Yellow
Write-Host $payload -ForegroundColor Cyan

try {
    Write-Host "`n🔄 Enviando..." -ForegroundColor Blue
    $response = Invoke-RestMethod -Uri $webhookUrl -Method POST -Body $payload -ContentType "application/json" -TimeoutSec 30
    
    Write-Host "✅ Resposta:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 5 | Write-Host -ForegroundColor White
    
    Write-Host "`n🎉 Teste CONCLUÍDO!" -ForegroundColor Green
}
catch {
    Write-Host "`n❌ ERRO:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n🏁 Fim do teste!" -ForegroundColor Green
