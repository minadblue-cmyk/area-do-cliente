# Teste do webhook update-agente
$webhookUrl = "https://n8n.code-iq.com.br/webhook/update-agente"

Write-Host "Testando webhook update-agente..."

$payload = @{
    id = 7
    nome = "Elleven Agente 1 (Maria) - Atualizado"
    descricao = "Agente para prospecção de leads - Versão atualizada"
    icone = "🧠"
    cor = "bg-pink-500"
    ativo = $true
} | ConvertTo-Json

Write-Host "Payload: $payload"

try {
    $response = Invoke-RestMethod -Uri $webhookUrl -Method POST -Body $payload -ContentType "application/json"
    Write-Host "Sucesso! Resposta:"
    $response | ConvertTo-Json -Depth 10
}
catch {
    Write-Host "Erro: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        Write-Host "Status: $($_.Exception.Response.StatusCode)"
    }
}
