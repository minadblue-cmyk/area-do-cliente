# Teste de webhooks relacionados a perfis
$webhooks = @(
    "https://n8n.code-iq.com.br/webhook/list-profiles",
    "https://n8n.code-iq.com.br/webhook/list-profile", 
    "https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/list-profiles",
    "https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/list-profile",
    "https://n8n.code-iq.com.br/webhook/create-profile",
    "https://n8n.code-iq.com.br/webhook/edit-profile"
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
