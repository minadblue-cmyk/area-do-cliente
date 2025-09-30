# Teste do webhook list-profile correto
$webhookUrl = "https://n8n.code-iq.com.br/webhook/list-profile"

Write-Host "Testando webhook list-profile correto..."

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
