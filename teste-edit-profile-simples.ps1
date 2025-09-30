# Teste simples do webhook edit-profile
$webhookUrl = "https://n8n.code-iq.com.br/webhook/edit-profile"

$payload = @{
    id = 32
    name = "User Elleve Consorsios 1 - Atualizado"
    description = "Usuário padrão de atendimento - Versão atualizada"
    permissoes = @(53, 54, 55, 56, 57)
} | ConvertTo-Json

Write-Host "Testando webhook edit-profile..."
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
