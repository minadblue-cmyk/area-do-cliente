$webhookUrl = "https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/list-user-profiles"
$payload = @{
    usuario_id = 6
}

Write-Host "Testando webhook list-user-profiles..." -ForegroundColor Green
Write-Host "URL: $webhookUrl" -ForegroundColor Cyan
Write-Host "Payload:" -ForegroundColor Cyan
$payload | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri $webhookUrl -Method Post -ContentType "application/json" -Body ($payload | ConvertTo-Json)
    Write-Host "✅ Requisição enviada com sucesso!" -ForegroundColor Green
    Write-Host "Resposta:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Host "❌ Erro na requisição:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
}

Write-Host "Teste concluído!" -ForegroundColor Green
