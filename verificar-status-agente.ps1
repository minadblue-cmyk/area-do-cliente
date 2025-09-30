# Script para verificar status do agente
$n8nCodeIqUrl = "https://n8n.code-iq.com.br"

Write-Host "VERIFICANDO STATUS DO AGENTE" -ForegroundColor Yellow
Write-Host "=" * 50 -ForegroundColor Yellow

# Testar webhook de status
$payload = @{
    execution_id = "126248"  # ID da execução anterior
    agente_id = 82
    usuario_id = 6
    empresa_id = 2
}

Write-Host "`nTestando webhook de status..." -ForegroundColor Cyan
Write-Host "Execution ID: $($payload.execution_id)" -ForegroundColor White

try {
    $response = Invoke-WebRequest -Uri "$n8nCodeIqUrl/webhook/status-agente" -Method POST -ContentType "application/json" -Body ($payload | ConvertTo-Json -Depth 3) -UseBasicParsing -TimeoutSec 30
    
    Write-Host "SUCESSO! Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Resposta:" -ForegroundColor Cyan
    
    if ($response.Content) {
        try {
            $responseJson = $response.Content | ConvertFrom-Json
            $responseJson | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor White
        } catch {
            Write-Host "Resposta (texto): $($response.Content)" -ForegroundColor White
        }
    } else {
        Write-Host "Resposta vazia" -ForegroundColor Gray
    }

} catch {
    Write-Host "ERRO: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
}

Write-Host "`n" + "=" * 50 -ForegroundColor Yellow
Write-Host "VERIFICACAO CONCLUIDA" -ForegroundColor Yellow
