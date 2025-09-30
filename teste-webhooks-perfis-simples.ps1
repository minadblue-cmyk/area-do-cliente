# Teste de webhooks relacionados a perfis
$webhooks = @(
    "https://n8n.code-iq.com.br/webhook/list-profiles",
    "https://n8n.code-iq.com.br/webhook/list-profile", 
    "https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/list-profiles",
    "https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/list-profile"
)

foreach ($webhook in $webhooks) {
    Write-Host "Testando: $webhook"
    try {
        $response = Invoke-RestMethod -Uri $webhook -Method POST -ContentType "application/json"
        Write-Host "Sucesso! Resposta:"
        $response | ConvertTo-Json -Depth 5
        break
    }
    catch {
        Write-Host "Erro: $($_.Exception.Message)"
    }
}
