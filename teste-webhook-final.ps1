# Teste final para o webhook

Write-Host "Teste Final do Webhook" -ForegroundColor Green
Write-Host ""

$webhookUrl = "https://n8n.code-iq.com.br/webhook/create-agente"

$dados = @{
    agent_name = "Agente Teste Final"
    agent_type = "teste-final"
    agent_id = 999
    user_id = 1
    icone = "robot"
    cor = "bg-blue-500"
    descricao = "Teste final do webhook"
} | ConvertTo-Json

Write-Host "URL: $webhookUrl"
Write-Host "Dados: $dados"
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri $webhookUrl -Method Post -Body $dados -ContentType "application/json" -TimeoutSec 30
    
    Write-Host "Status: $($response.StatusCode)"
    Write-Host "Resposta: $($response.Content)"
    
} catch {
    Write-Host "Erro: $($_.Exception.Message)"
    
    if ($_.Exception.Response) {
        Write-Host "Status Code: $($_.Exception.Response.StatusCode)"
    }
}

Write-Host "Teste concluido"
