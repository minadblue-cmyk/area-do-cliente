# Teste final usando PowerShell para enviar dados ao webhook

Write-Host "🧪 Teste Final - Enviando dados para o webhook via PowerShell" -ForegroundColor Green
Write-Host ""

# URL do webhook
$webhookUrl = "https://n8n.code-iq.com.br/webhook/create-agente"

# Dados de teste
$dados = @{
    agent_name = "Agente Vendas Premium"
    agent_type = "vendas-premium"
    agent_id = 8
    user_id = 5
    icone = "💼"
    cor = "bg-green-500"
    descricao = "Agente para vendas premium"
} | ConvertTo-Json

Write-Host "📤 Dados sendo enviados:" -ForegroundColor Yellow
Write-Host $dados
Write-Host ""

Write-Host "🌐 Enviando para: $webhookUrl" -ForegroundColor Cyan
Write-Host ""

try {
    # Enviar requisição
    $response = Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $dados -ContentType "application/json" -TimeoutSec 30
    
    Write-Host "✅ Resposta recebida:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 10
    
    # Verificar estrutura da resposta
    if ($response.success) {
        Write-Host ""
        Write-Host "🎯 Estrutura da resposta validada:" -ForegroundColor Green
        Write-Host "- Success: $($response.success)"
        Write-Host "- Message: $($response.message)"
        Write-Host "- Agent Name: $($response.agentName)"
        Write-Host "- Agent Type: $($response.agentType)"
        Write-Host "- Agent ID: $($response.agentId)"
        Write-Host "- Total Workflows: $($response.summary.totalWorkflows)"
        Write-Host "- Workflows Types: $($response.summary.webhookTypes -join ', ')"
        
        if ($response.workflows) {
            Write-Host ""
            Write-Host "🏗️ Workflows criados:" -ForegroundColor Green
            for ($i = 0; $i -lt $response.workflows.Count; $i++) {
                $workflow = $response.workflows[$i]
                Write-Host "$($i + 1). $($workflow.name)"
                Write-Host "   Webhook: $($workflow.webhookPath)"
                Write-Host "   Status: $($workflow.status)"
            }
        }
    }
    
} catch {
    Write-Host "❌ Erro no teste:" -ForegroundColor Red
    Write-Host $_.Exception.Message
    
    if ($_.Exception.Response) {
        Write-Host "Status Code: $($_.Exception.Response.StatusCode)"
    }
}

Write-Host ""
Write-Host "✅ Teste concluído!" -ForegroundColor Green
