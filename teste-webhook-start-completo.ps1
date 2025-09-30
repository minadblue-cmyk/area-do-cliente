# Teste completo do webhook start com payload real
$n8nCodeIqUrl = "https://n8n.code-iq.com.br"

# Payload completo baseado no frontend atualizado
$payload = @{
    usuario_id = 6
    action = "start"
    logged_user = @{
        id = 6
        name = "Usuário Elleve Padrão 1"
        email = "rmacedo2005@hotmail.com"
        empresa_id = 2  # ✅ ADICIONADO: empresa_id para isolamento
    }
    agente_id = 82  # Agente 1 Elleve
    perfil_id = 2
    perfis_permitidos = @(2, 3)
    usuarios_permitidos = @(6)
    empresa_id = 2  # ✅ ADICIONADO: empresa_id no payload principal
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
}

Write-Host "🧪 TESTE COMPLETO DO WEBHOOK START" -ForegroundColor Yellow
Write-Host "=" * 50 -ForegroundColor Yellow

Write-Host "`n📦 Payload enviado:" -ForegroundColor Cyan
$payload | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor White

Write-Host "`n🔍 Testando webhook: $n8nCodeIqUrl/webhook/start13-agente2elleve" -ForegroundColor Green

try {
    $response = Invoke-WebRequest -Uri "$n8nCodeIqUrl/webhook/start13-agente2elleve" -Method POST -ContentType "application/json" -Body ($payload | ConvertTo-Json -Depth 3) -UseBasicParsing -TimeoutSec 30
    
    Write-Host "`n✅ SUCESSO! Webhook executado!" -ForegroundColor Green
    Write-Host "Status Code: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "`n📥 Resposta do webhook:" -ForegroundColor Cyan
    
    if ($response.Content) {
        try {
            $responseJson = $response.Content | ConvertFrom-Json
            $responseJson | ConvertTo-Json -Depth 5 | Write-Host -ForegroundColor White
        } catch {
            Write-Host "Resposta (texto): $($response.Content)" -ForegroundColor White
        }
    } else {
        Write-Host "Resposta vazia" -ForegroundColor Gray
    }
    
    Write-Host "`n📊 Headers da resposta:" -ForegroundColor Cyan
    $response.Headers | Format-Table -AutoSize | Write-Host -ForegroundColor White

} catch {
    Write-Host "`n❌ ERRO! Webhook falhou:" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Status Description: $($_.Exception.Response.StatusDescription)" -ForegroundColor Red
    Write-Host "Erro: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $responseBody = $reader.ReadToEnd()
        Write-Host "`nResposta de Erro Detalhada:" -ForegroundColor Red
        Write-Host $responseBody -ForegroundColor Red
    }
}

Write-Host "`n" + "=" * 50 -ForegroundColor Yellow
Write-Host "🎯 DADOS PARA TRABALHAR AS SINTAXES:" -ForegroundColor Yellow
Write-Host "`n1. Payload enviado:" -ForegroundColor Cyan
Write-Host "   - usuario_id: $($payload.usuario_id)" -ForegroundColor White
Write-Host "   - agente_id: $($payload.agente_id)" -ForegroundColor White
Write-Host "   - empresa_id: $($payload.empresa_id)" -ForegroundColor White
Write-Host "   - logged_user.empresa_id: $($payload.logged_user.empresa_id)" -ForegroundColor White
Write-Host "   - perfil_id: $($payload.perfil_id)" -ForegroundColor White
Write-Host "   - perfis_permitidos: $($payload.perfis_permitidos -join ', ')" -ForegroundColor White
Write-Host "   - usuarios_permitidos: $($payload.usuarios_permitidos -join ', ')" -ForegroundColor White

Write-Host "`n2. Query Parameters para n8n:" -ForegroundColor Cyan
Write-Host "   - {{`$json.empresa_id}} = $($payload.empresa_id)" -ForegroundColor White
Write-Host "   - {{`$json.usuario_id}} = $($payload.usuario_id)" -ForegroundColor White
Write-Host "   - {{`$json.agente_id}} = $($payload.agente_id)" -ForegroundColor White
Write-Host "   - {{`$json.logged_user.empresa_id}} = $($payload.logged_user.empresa_id)" -ForegroundColor White

Write-Host "`n3. Campos disponíveis no payload:" -ForegroundColor Cyan
$payload.Keys | ForEach-Object { Write-Host "   - $_" -ForegroundColor White }
Write-Host "   - logged_user.id" -ForegroundColor White
Write-Host "   - logged_user.name" -ForegroundColor White
Write-Host "   - logged_user.email" -ForegroundColor White
Write-Host "   - logged_user.empresa_id" -ForegroundColor White

Write-Host "`n✅ Teste concluído!" -ForegroundColor Green