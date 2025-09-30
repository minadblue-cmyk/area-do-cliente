# Teste do Webhook Start com Dados Reais
# Este script simula o envio de dados reais para o webhook start

Write-Host "🚀 Testando Webhook Start com Dados Reais..." -ForegroundColor Green

# URL do webhook start
$webhookUrl = "https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/start12-ze"

# Payload real baseado no que você enviou
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

Write-Host "📤 Payload enviado:" -ForegroundColor Yellow
Write-Host $payload -ForegroundColor Cyan

try {
    Write-Host "`n🔄 Enviando requisição..." -ForegroundColor Blue
    
    $response = Invoke-RestMethod -Uri $webhookUrl -Method POST -Body $payload -ContentType "application/json" -TimeoutSec 30
    
    Write-Host "✅ Resposta recebida:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 5 | Write-Host -ForegroundColor Green
    
    # Verificar se a resposta contém dados de leads
    if ($response -is [array] -and $response.Count -gt 0) {
        Write-Host "`n📊 Análise dos dados:" -ForegroundColor Yellow
        Write-Host "Total de leads: $($response.Count)" -ForegroundColor Cyan
        
        $firstLead = $response[0]
        Write-Host "`n🔍 Primeiro lead:" -ForegroundColor Yellow
        Write-Host "ID: $($firstLead.id)" -ForegroundColor White
        Write-Host "Nome: $($firstLead.nome_cliente)" -ForegroundColor White
        Write-Host "Telefone: $($firstLead.telefone)" -ForegroundColor White
        Write-Host "Status: $($firstLead.status)" -ForegroundColor White
        Write-Host "Agente ID: $($firstLead.agente_id)" -ForegroundColor White
        Write-Host "Reservado por: $($firstLead.reservado_por)" -ForegroundColor White
        Write-Host "Reservado lote: $($firstLead.reservado_lote)" -ForegroundColor White
        
        # Verificar se tem permissões de acesso
        if ($firstLead.permissoes_acesso) {
            Write-Host "`n🔐 Permissões de acesso:" -ForegroundColor Yellow
            $firstLead.permissoes_acesso | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor Green
        } else {
            Write-Host "`n⚠️  ATENÇÃO: Campo permissoes_acesso não encontrado!" -ForegroundColor Red
        }
    }
    
} catch {
    Write-Host "❌ Erro na requisição:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode
        Write-Host "Status Code: $statusCode" -ForegroundColor Red
        
        try {
            $errorStream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorStream)
            $errorBody = $reader.ReadToEnd()
            Write-Host "Error Body: $errorBody" -ForegroundColor Red
        } catch {
            Write-Host "Não foi possível ler o corpo do erro" -ForegroundColor Red
        }
    }
}

Write-Host "`n🏁 Teste concluído!" -ForegroundColor Green
