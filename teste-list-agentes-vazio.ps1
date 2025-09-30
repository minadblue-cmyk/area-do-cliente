# Teste do webhook list-agentes
$webhookUrl = "https://n8n.code-iq.com.br/webhook/list-agentes"

Write-Host "Testando webhook list-agentes..."

try {
    $response = Invoke-RestMethod -Uri $webhookUrl -Method GET
    Write-Host "Status: Sucesso"
    Write-Host "Tipo da resposta: $($response.GetType().Name)"
    Write-Host "Resposta:"
    $response | ConvertTo-Json -Depth 10
    
    if ($response -eq $null -or $response -eq '') {
        Write-Host "⚠️ Resposta vazia detectada"
    } elseif ($response -is [array] -and $response.Length -eq 0) {
        Write-Host "⚠️ Array vazio detectado"
    } elseif ($response -is [object] -and $response.PSObject.Properties.Count -eq 0) {
        Write-Host "⚠️ Objeto vazio detectado"
    } else {
        Write-Host "✅ Dados encontrados"
    }
}
catch {
    Write-Host "Erro: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        Write-Host "Status Code: $($_.Exception.Response.StatusCode)"
    }
}
