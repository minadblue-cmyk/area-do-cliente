# Teste do webhook list-profiles (com s)
$webhookUrl = "https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/list-profiles"

Write-Host "Testando webhook list-profiles..."

try {
    $response = Invoke-RestMethod -Uri $webhookUrl -Method POST -ContentType "application/json"
    Write-Host "Sucesso! Resposta:"
    $response | ConvertTo-Json -Depth 10
}
catch {
    Write-Host "Erro: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        Write-Host "Status: $($_.Exception.Response.StatusCode)"
    }
}
