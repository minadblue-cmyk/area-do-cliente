# Script para verificar todos os webhooks retornados pelo list-agentes
Write-Host "Verificando webhooks completos do list-agentes..." -ForegroundColor Yellow

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
    
    if ($jsonResponse.data -and $jsonResponse.data.Count -gt 0) {
        Write-Host "`n=== ANALISE DETALHADA DOS WEBHOOKS ===" -ForegroundColor Cyan
        
        foreach ($agente in $jsonResponse.data) {
            Write-Host "`n--- Agente: $($agente.nome) (ID: $($agente.id)) ---" -ForegroundColor Yellow
            
            # Verificar cada tipo de webhook
            $webhookTypes = @(
                @{Name="START"; Key="webhook_start_url"; Value=$agente.webhook_start_url},
                @{Name="STOP"; Key="webhook_stop_url"; Value=$agente.webhook_stop_url},
                @{Name="STATUS"; Key="webhook_status_url"; Value=$agente.webhook_status_url},
                @{Name="LISTA"; Key="webhook_lista_url"; Value=$agente.webhook_lista_url}
            )
            
            foreach ($webhook in $webhookTypes) {
                if ($webhook.Value) {
                    Write-Host "  ✅ $($webhook.Name): $($webhook.Value)" -ForegroundColor Green
                } else {
                    Write-Host "  ❌ $($webhook.Name): NAO ENCONTRADO" -ForegroundColor Red
                }
            }
            
            # Verificar se tem todos os 4 webhooks
            $webhooksPresentes = $webhookTypes | Where-Object { $_.Value -ne $null -and $_.Value -ne "" }
            $totalWebhooks = $webhooksPresentes.Count
            
            if ($totalWebhooks -eq 4) {
                Write-Host "  🎉 TODOS OS 4 WEBHOOKS PRESENTES!" -ForegroundColor Green
            } else {
                Write-Host "  ⚠️  FALTAM $((4 - $totalWebhooks)) WEBHOOK(S)" -ForegroundColor Red
            }
        }
        
        Write-Host "`n=== RESUMO GERAL ===" -ForegroundColor Cyan
        $totalAgentes = $jsonResponse.data.Count
        Write-Host "Total de agentes: $totalAgentes" -ForegroundColor White
        
        # Contar webhooks por tipo
        $startCount = ($jsonResponse.data | Where-Object { $_.webhook_start_url }).Count
        $stopCount = ($jsonResponse.data | Where-Object { $_.webhook_stop_url }).Count
        $statusCount = ($jsonResponse.data | Where-Object { $_.webhook_status_url }).Count
        $listaCount = ($jsonResponse.data | Where-Object { $_.webhook_lista_url }).Count
        
        Write-Host "Webhooks START: $startCount/$totalAgentes" -ForegroundColor $(if($startCount -eq $totalAgentes) {"Green"} else {"Red"})
        Write-Host "Webhooks STOP: $stopCount/$totalAgentes" -ForegroundColor $(if($stopCount -eq $totalAgentes) {"Green"} else {"Red"})
        Write-Host "Webhooks STATUS: $statusCount/$totalAgentes" -ForegroundColor $(if($statusCount -eq $totalAgentes) {"Green"} else {"Red"})
        Write-Host "Webhooks LISTA: $listaCount/$totalAgentes" -ForegroundColor $(if($listaCount -eq $totalAgentes) {"Green"} else {"Red"})
        
    } else {
        Write-Host "`n❌ Nenhum agente encontrado na resposta" -ForegroundColor Red
    }
    
} catch {
    Write-Host "`nERRO!" -ForegroundColor Red
    Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Erro: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nTeste finalizado!" -ForegroundColor Cyan
