# Teste de webhooks de atualização
$webhooks = @(
    "https://n8n.code-iq.com.br/webhook/update-agente",
    "https://n8n.code-iq.com.br/webhook/edit-agente",
    "https://n8n.code-iq.com.br/webhook/save-agente",
    "https://n8n.code-iq.com.br/webhook/modify-agente"
)

foreach ($webhook in $webhooks) {
    Write-Host "Testando: $webhook"
    try {
        $response = Invoke-RestMethod -Uri $webhook -Method POST -ContentType "application/json" -Body '{"test": true}'
        Write-Host "SUCESSO! Resposta:"
        $response | ConvertTo-Json -Depth 3
        Write-Host "---"
    }
    catch {
        Write-Host "Erro: $($_.Exception.Message)"
    }
    Write-Host ""
}
