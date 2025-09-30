# Teste do webhook edit-profile
$webhookUrl = "https://n8n.code-iq.com.br/webhook/edit-profile"

# Dados de teste para editar um perfil
$payload = @{
    id = 32
    name = "User Elleve Consorsios 1 - Atualizado"
    description = "Usuário padrão de atendimento - Versão atualizada"
    permissoes = @(53, 54, 55, 56, 57)
} | ConvertTo-Json

Write-Host "🚀 Testando webhook edit-profile..."
Write-Host "📦 Payload enviado:"
Write-Host $payload

try {
    $response = Invoke-RestMethod -Uri $webhookUrl -Method POST -Body $payload -ContentType "application/json" -Headers @{
        "Accept" = "application/json"
    }
    
    Write-Host "✅ Resposta recebida:"
    $response | ConvertTo-Json -Depth 10
}
catch {
    Write-Host "❌ Erro na requisição:"
    Write-Host $_.Exception.Message
    
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode
        Write-Host "Status Code: $statusCode"
        
        $responseStream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($responseStream)
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response Body: $($responseBody)"
    }
}
