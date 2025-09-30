# Script para testar o webhook list-agentes
Write-Host "Testando webhook list-agentes..." -ForegroundColor Yellow

$n8nBaseUrl = "https://n8n.code-iq.com.br"
$webhookPath = "webhook/list-agentes"
$fullUri = "$n8nBaseUrl/$webhookPath"

Write-Host "`nTestando: $fullUri" -ForegroundColor Green

try {
    $response = Invoke-WebRequest -Uri $fullUri -Method GET -ContentType "application/json" -UseBasicParsing
    
    Write-Host "`nSUCESSO! Webhook executado!" -ForegroundColor Green
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    
    # Converter resposta para JSON
    $jsonResponse = $response.Content | ConvertFrom-Json
    
    Write-Host "`nResposta completa:" -ForegroundColor Cyan
    $jsonResponse | ConvertTo-Json -Depth 10 | Write-Host -ForegroundColor White
    
    # Analisar estrutura
    Write-Host "`nAnalise da estrutura:" -ForegroundColor Yellow
    
    if ($jsonResponse -is [array]) {
        Write-Host "Resposta e um array com $($jsonResponse.Count) itens" -ForegroundColor White
        
        if ($jsonResponse.Count -gt 0) {
            $firstItem = $jsonResponse[0]
            Write-Host "`nPrimeiro item:" -ForegroundColor White
            $firstItem | ConvertTo-Json -Depth 5 | Write-Host -ForegroundColor White
            
            # Verificar se tem data
            if ($firstItem.data) {
                Write-Host "`nPrimeiro item tem propriedade 'data'" -ForegroundColor Green
                if ($firstItem.data -is [array]) {
                    Write-Host "'data' e um array com $($firstItem.data.Count) agentes" -ForegroundColor Green
                    
                    if ($firstItem.data.Count -gt 0) {
                        $primeiroAgente = $firstItem.data[0]
                        Write-Host "`nPrimeiro agente encontrado:" -ForegroundColor Cyan
                        $primeiroAgente | ConvertTo-Json -Depth 5 | Write-Host -ForegroundColor White
                        
                        # Verificar webhooks específicos
                        Write-Host "`nWebhooks do primeiro agente:" -ForegroundColor Yellow
                        $webhookProps = @('webhook_start_url', 'webhook_stop_url', 'webhook_status_url', 'webhook_lista_url')
                        foreach ($prop in $webhookProps) {
                            if ($primeiroAgente.$prop) {
                                Write-Host "${prop}: $($primeiroAgente.$prop)" -ForegroundColor Green
                            } else {
                                Write-Host "${prop}: NAO ENCONTRADO" -ForegroundColor Red
                            }
                        }
                    }
                }
            }
        }
    } else {
        Write-Host "Resposta e um objeto" -ForegroundColor White
        $jsonResponse | ConvertTo-Json -Depth 5 | Write-Host -ForegroundColor White
    }
    
} catch {
    Write-Host "`nERRO!" -ForegroundColor Red
    Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Erro: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $responseBody = $reader.ReadToEnd()
        Write-Host "`nResposta de Erro:" -ForegroundColor Red
        $responseBody | Write-Host -ForegroundColor Red
    }
}

Write-Host "`nTeste finalizado!" -ForegroundColor Cyan
