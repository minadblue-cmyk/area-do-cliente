# Teste com todos os campos do formulário
$webhookUrl = "https://n8n.code-iq.com.br/webhook/create-agente"

Write-Host "Testando envio de todos os campos do formulário..."

$payload = @{
    action = "create"
    agent_name = "Agente Teste Completo"
    agent_type = "testeCompleto"
    agent_id = "TESTCOMPLETE123"
    user_id = "5"
    descricao = "Agente de teste com todos os campos preenchidos"
    icone = "🤖"
    cor = "bg-blue-500"
    ativo = $true
    workflow_id = ""
    webhook_url = ""
} | ConvertTo-Json

Write-Host "Payload completo:"
$payload | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri $webhookUrl -Method POST -Body $payload -ContentType "application/json"
    Write-Host "Sucesso! Resposta:"
    $response | ConvertTo-Json -Depth 10
}
catch {
    Write-Host "Erro: $($_.Exception.Message)"
}
