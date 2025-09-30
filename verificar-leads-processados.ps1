# Script para verificar se os leads foram processados
$n8nCodeIqUrl = "https://n8n.code-iq.com.br"

Write-Host "VERIFICANDO LEADS PROCESSADOS" -ForegroundColor Yellow
Write-Host "=" * 50 -ForegroundColor Yellow

# Testar webhook de lista para ver os leads
$payload = @{
    client_id = 6
    agente_id = 82
    workflow_id = 82
    usuario_id = 6
    empresa_id = 2
}

Write-Host "`nTestando webhook de lista..." -ForegroundColor Cyan

try {
    $response = Invoke-WebRequest -Uri "$n8nCodeIqUrl/webhook/list-prospects" -Method GET -Body $payload -UseBasicParsing -TimeoutSec 30
    
    Write-Host "SUCESSO! Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Resposta:" -ForegroundColor Cyan
    
    if ($response.Content) {
        try {
            $responseJson = $response.Content | ConvertFrom-Json
            $responseJson | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor White
            
            Write-Host "`nLEADS ENCONTRADOS: $($responseJson.Count)" -ForegroundColor Yellow
            
            if ($responseJson.Count -gt 0) {
                Write-Host "`nPrimeiros 5 leads:" -ForegroundColor Cyan
                $responseJson | Select-Object -First 5 | ForEach-Object {
                    Write-Host "- ID: $($_.id), Nome: $($_.nome), Status: $($_.status), Empresa: $($_.empresa_id)" -ForegroundColor White
                }
            }
            
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
