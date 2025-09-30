# Teste do webhook list-agentes com método GET
$webhookUrl = "https://n8n.code-iq.com.br/webhook/list-agentes"

Write-Host "Testando webhook list-agentes com GET..."

try {
    $response = Invoke-RestMethod -Uri $webhookUrl -Method GET
    Write-Host "Sucesso! Resposta:"
    $response | ConvertTo-Json -Depth 10
}
catch {
    Write-Host "Erro: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        Write-Host "Status: $($_.Exception.Response.StatusCode)"
    }
}
