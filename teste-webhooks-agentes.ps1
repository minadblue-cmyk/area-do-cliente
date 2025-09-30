# Teste de webhooks relacionados a agentes
$webhooks = @(
    "https://n8n.code-iq.com.br/webhook/list-agentes",
    "https://n8n.code-iq.com.br/webhook/create-agente",
    "https://n8n.code-iq.com.br/webhook/delete-agente",
    "https://n8n.code-iq.com.br/webhook/update-agente"
)

foreach ($webhook in $webhooks) {
    Write-Host "Testando: $webhook"
    try {
        $response = Invoke-RestMethod -Uri $webhook -Method POST -ContentType "application/json"
        Write-Host "SUCESSO! Resposta:"
        $response | ConvertTo-Json -Depth 3
        Write-Host "---"
    }
    catch {
        Write-Host "Erro: $($_.Exception.Message)"
    }
    Write-Host ""
}
