# Teste do Webhook Start com Payload Completo e Correto
Write-Host "🚀 Testando Webhook Start com Payload Completo..." -ForegroundColor Green

# URL do webhook start
$webhookUrl = "https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/start12-ze"

# Payload completo com dados de exemplo para agente_id, perfil_id, perfis_permitidos e usuarios_permitidos
$payload = @{
    action = "start"
    agent_type = 81
    workflow_id = 81
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    usuario_id = "6"
    agente_id = 81 # Exemplo: um ID de agente válido
    perfil_id = 1  # Exemplo: um ID de perfil válido
    perfis_permitidos = @(1, 2) # Exemplo: array de IDs de perfis permitidos
    usuarios_permitidos = @(6, 7) # Exemplo: array de IDs de usuários permitidos
    logged_user = @{
        id = "6"
        name = "Usuário Elleve Padrão"
        email = "rmacedo2005@hotmail.com"
    }
} | ConvertTo-Json -Depth 3

Write-Host "📤 Payload enviado:" -ForegroundColor Yellow
Write-Host $payload -ForegroundColor Cyan

try {
    Write-Host "`n🔄 Enviando requisição..." -ForegroundColor Blue
    
    $response = Invoke-RestMethod -Uri $webhookUrl -Method POST -Body $payload -ContentType "application/json" -TimeoutSec 30
    
    Write-Host "✅ Resposta recebida:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 5 | Write-Host -ForegroundColor White
    
    Write-Host "`n🎉 Teste de Webhook Start com Payload Completo CONCLUÍDO!" -ForegroundColor Green
}
catch {
    Write-Host "`n❌ ERRO ao enviar requisição para o Webhook Start:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $responseBody = $reader.ReadToEnd()
        Write-Host "Corpo da Resposta de Erro:" -ForegroundColor Red
        Write-Host $responseBody -ForegroundColor Red
    }
}
