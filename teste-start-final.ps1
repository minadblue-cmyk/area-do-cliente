# Teste webhook start
$n8nCodeIqUrl = "https://n8n.code-iq.com.br"

$payload = @{
    usuario_id = 6
    action = "start"
    logged_user = @{
        id = 6
        name = "Usuario Elleve Padrao 1"
        email = "rmacedo2005@hotmail.com"
        empresa_id = 2
    }
    agente_id = 82
    perfil_id = 2
    perfis_permitidos = @(2, 3)
    usuarios_permitidos = @(6)
    empresa_id = 2
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
}

Write-Host "TESTE WEBHOOK START" -ForegroundColor Yellow
Write-Host "Payload:" -ForegroundColor Cyan
$payload | ConvertTo-Json -Depth 3

Write-Host "`nTestando webhook..." -ForegroundColor Green

try {
    $response = Invoke-WebRequest -Uri "$n8nCodeIqUrl/webhook/start13-agente2elleve" -Method POST -ContentType "application/json" -Body ($payload | ConvertTo-Json -Depth 3) -UseBasicParsing -TimeoutSec 30
    
    Write-Host "SUCESSO! Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Resposta:" -ForegroundColor Cyan
    Write-Host $response.Content -ForegroundColor White

} catch {
    Write-Host "ERRO: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
}

Write-Host "`nDADOS PARA SINTAXES N8N:" -ForegroundColor Yellow
Write-Host "empresa_id: $($payload.empresa_id)" -ForegroundColor White
Write-Host "usuario_id: $($payload.usuario_id)" -ForegroundColor White
Write-Host "agente_id: $($payload.agente_id)" -ForegroundColor White
Write-Host "logged_user.empresa_id: $($payload.logged_user.empresa_id)" -ForegroundColor White
