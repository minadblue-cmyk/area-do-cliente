# Script para testar o webhook list-agentes e ver os webhooks reais
Write-Host "🔍 Testando webhook list-agentes para ver webhooks reais..." -ForegroundColor Yellow

$n8nBaseUrl = "https://n8n.code-iq.com.br"
$webhookPath = "webhook/list-agentes"
$fullUri = "$n8nBaseUrl/$webhookPath"

Write-Host "`n🌐 Testando: $fullUri" -ForegroundColor Green

try {
    $response = Invoke-WebRequest -Uri $fullUri -Method GET -ContentType "application/json" -UseBasicParsing
    
    Write-Host "`n✅ SUCESSO! Webhook executado!" -ForegroundColor Green
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    
    # Converter resposta para JSON
    $jsonResponse = $response.Content | ConvertFrom-Json
    
    Write-Host "`n📄 Resposta completa:" -ForegroundColor Cyan
    $jsonResponse | ConvertTo-Json -Depth 10 | Write-Host -ForegroundColor White
    
    # Analisar estrutura
    Write-Host "`n🔍 Análise da estrutura:" -ForegroundColor Yellow
    
    if ($jsonResponse -is [array]) {
        Write-Host "• Resposta é um array com $($jsonResponse.Count) itens" -ForegroundColor White
        
        if ($jsonResponse.Count -gt 0) {
            $firstItem = $jsonResponse[0]
            Write-Host "• Primeiro item:" -ForegroundColor White
            $firstItem | ConvertTo-Json -Depth 5 | Write-Host -ForegroundColor White
            
            # Verificar se tem data
            if ($firstItem.data) {
                Write-Host "• Primeiro item tem propriedade 'data'" -ForegroundColor Green
                if ($firstItem.data -is [array]) {
                    Write-Host "• 'data' é um array com $($firstItem.data.Count) agentes" -ForegroundColor Green
                    
                    if ($firstItem.data.Count -gt 0) {
                        $primeiroAgente = $firstItem.data[0]
                        Write-Host "`n🤖 Primeiro agente encontrado:" -ForegroundColor Cyan
                        $primeiroAgente | ConvertTo-Json -Depth 5 | Write-Host -ForegroundColor White
                        
                        # Verificar webhooks específicos
                        Write-Host "`n🔗 Webhooks do primeiro agente:" -ForegroundColor Yellow
                        $webhookProps = @('webhook_start_url', 'webhook_stop_url', 'webhook_status_url', 'webhook_lista_url')
                        foreach ($prop in $webhookProps) {
                            if ($primeiroAgente.$prop) {
                                Write-Host "• $prop`: $($primeiroAgente.$prop)" -ForegroundColor Green
                            } else {
                                Write-Host "• $prop`: NÃO ENCONTRADO" -ForegroundColor Red
                            }
                        }
                    }
                }
            }
        }
    } else {
        Write-Host "• Resposta é um objeto" -ForegroundColor White
        $jsonResponse | ConvertTo-Json -Depth 5 | Write-Host -ForegroundColor White
    }
    
} catch {
    Write-Host "`n❌ ERRO!" -ForegroundColor Red
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

Write-Host "`n🏁 Teste finalizado!" -ForegroundColor Cyan
