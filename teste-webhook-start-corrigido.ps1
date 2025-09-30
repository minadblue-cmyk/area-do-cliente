# Teste do Webhook Start - Versão Corrigida
Write-Host "🚀 Testando Webhook Start..." -ForegroundColor Green

$webhookUrl = "https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/start12-ze"

$payload = @{
    action = "start"
    agent_type = 81
    workflow_id = 81
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    usuario_id = "6"
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
    $response | ConvertTo-Json -Depth 5 | Write-Host -ForegroundColor Green
    
    if ($response -is [array] -and $response.Count -gt 0) {
        Write-Host "`n📊 Total de leads: $($response.Count)" -ForegroundColor Cyan
        $firstLead = $response[0]
        Write-Host "🔍 Primeiro lead - ID: $($firstLead.id), Nome: $($firstLead.nome_cliente)" -ForegroundColor White
        
        if ($firstLead.permissoes_acesso) {
            Write-Host "🔐 Permissões encontradas!" -ForegroundColor Green
            $firstLead.permissoes_acesso | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor Green
        } else {
            Write-Host "⚠️  Permissões NÃO encontradas!" -ForegroundColor Red
        }
    } else {
        Write-Host "⚠️  Resposta vazia ou não é array" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
}

Write-Host "`n🏁 Concluído!" -ForegroundColor Green
