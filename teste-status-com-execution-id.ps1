# Teste do status com execution_id
Write-Host "Teste status com execution_id" -ForegroundColor Yellow

# Usar o execution_id que vimos nos logs anteriores
$executionId = "121865"
$webhookStatusUrl = "https://n8n.code-iq.com.br/webhook/status12-ze"

Write-Host "Testando com execution_id: $executionId" -ForegroundColor Cyan

# Testar com parâmetros
$params = @{
    execution_id = $executionId
    workflow_id = "81"
}

try {
    $uri = $webhookStatusUrl + "?" + ($params.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join "&"
    Write-Host "URI completa: $uri" -ForegroundColor Gray
    
    $response = Invoke-RestMethod -Uri $uri -Method GET
    Write-Host "Resposta com execution_id:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
    
} catch {
    Write-Host "Erro ao consultar com execution_id:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`nTeste concluido!" -ForegroundColor Green
