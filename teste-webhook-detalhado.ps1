# Teste detalhado do webhook list-agentes
# Executar com: .\teste-webhook-detalhado.ps1

Write-Host "🧪 TESTE: Webhook list-agentes" -ForegroundColor Cyan
Write-Host "📍 URL: https://n8n.code-iq.com.br/webhook/list-agentes" -ForegroundColor Yellow
Write-Host "⏰ Timestamp: $(Get-Date -Format 'yyyy-MM-ddTHH:mm:ss.fffZ')" -ForegroundColor Gray
Write-Host "━" * 60 -ForegroundColor DarkGray

try {
    # Fazer requisição
    $response = Invoke-RestMethod -Uri "https://n8n.code-iq.com.br/webhook/list-agentes" -Method GET -Headers @{"Accept"="application/json"}
    
    Write-Host "✅ STATUS: Sucesso" -ForegroundColor Green
    Write-Host ""
    Write-Host "📊 RESPOSTA COMPLETA:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 10 | Write-Host
    
    Write-Host ""
    Write-Host "🔍 VALIDAÇÃO DOS CAMPOS:" -ForegroundColor Cyan
    Write-Host "━" * 40 -ForegroundColor DarkGray
    
    # Validar estrutura básica
    $requiredFields = @('success', 'message', 'data', 'total', 'timestamp')
    foreach ($field in $requiredFields) {
        $exists = $response.PSObject.Properties.Name -contains $field
        $status = if ($exists) { "✅" } else { "❌" }
        $message = if ($exists) { "OK" } else { "FALTANDO" }
        Write-Host "$status $field`: $message" -ForegroundColor $(if ($exists) { "Green" } else { "Red" })
    }
    
    # Validar dados dos agentes
    if ($response.data -and $response.data.Count -gt 0) {
        $agent = $response.data[0]
        Write-Host ""
        Write-Host "🤖 CAMPOS DO AGENTE:" -ForegroundColor Cyan
        Write-Host "━" * 30 -ForegroundColor DarkGray
        
        $agentFields = @(
            # Campos básicos
            'id', 'nome', 'descricao', 'icone', 'cor', 'ativo',
            'created_at', 'updated_at',
            
            # Workflow IDs
            'workflow_start_id', 'workflow_status_id', 
            'workflow_lista_id', 'workflow_stop_id',
            
            # Webhook URLs
            'webhook_start_url', 'webhook_status_url',
            'webhook_lista_url', 'webhook_stop_url',
            
            # Status de execução
            'status_atual', 'execution_id_ativo'
        )
        
        foreach ($field in $agentFields) {
            $exists = $agent.PSObject.Properties.Name -contains $field
            $value = if ($exists) { $agent.$field } else { $null }
            $type = if ($value -ne $null) { $value.GetType().Name } else { "null" }
            $displayValue = if ($value -ne $null) { $value.ToString() } else { "null" }
            
            $status = if ($exists) { "✅" } else { "❌" }
            Write-Host "$status $field`: $type = $displayValue" -ForegroundColor $(if ($exists) { "Green" } else { "Red" })
        }
        
        # Validações específicas
        Write-Host ""
        Write-Host "🎯 VALIDAÇÕES ESPECÍFICAS:" -ForegroundColor Cyan
        Write-Host "━" * 30 -ForegroundColor DarkGray
        
        # Verificar se tem webhooks específicos
        $hasSpecificWebhooks = $agent.webhook_start_url -or $agent.webhook_stop_url -or $agent.webhook_status_url -or $agent.webhook_lista_url
        $status = if ($hasSpecificWebhooks) { "✅" } else { "❌" }
        $message = if ($hasSpecificWebhooks) { "SIM" } else { "NÃO" }
        Write-Host "$status Webhooks específicos: $message" -ForegroundColor $(if ($hasSpecificWebhooks) { "Green" } else { "Red" })
        
        # Verificar padrão dos webhooks
        $webhookPatterns = @(
            @{ name = 'start'; url = $agent.webhook_start_url },
            @{ name = 'stop'; url = $agent.webhook_stop_url },
            @{ name = 'status'; url = $agent.webhook_status_url },
            @{ name = 'lista'; url = $agent.webhook_lista_url }
        )
        
        foreach ($pattern in $webhookPatterns) {
            if ($pattern.url) {
                $expectedPattern = "webhook/$($pattern.name)3-$($agent.nome.ToLower())"
                $matchesPattern = $pattern.url -eq $expectedPattern
                $status = if ($matchesPattern) { "✅" } else { "❌" }
                $message = "$($pattern.url)"
                if (-not $matchesPattern) {
                    $message += " (esperado: $expectedPattern)"
                }
                Write-Host "$status $($pattern.name): $message" -ForegroundColor $(if ($matchesPattern) { "Green" } else { "Red" })
            } else {
                Write-Host "⚠️  $($pattern.name): URL não encontrada" -ForegroundColor Yellow
            }
        }
        
        # Verificar status
        Write-Host "✅ Status atual: $($agent.status_atual)" -ForegroundColor Green
        Write-Host "✅ Execution ID: $($agent.execution_id_ativo)" -ForegroundColor Green
        
    } else {
        Write-Host "❌ ERRO: Nenhum agente encontrado nos dados" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "🎉 TESTE CONCLUÍDO COM SUCESSO!" -ForegroundColor Green
    
} catch {
    Write-Host "❌ ERRO NO TESTE: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "📋 Detalhes: $($_.Exception)" -ForegroundColor Red
}
