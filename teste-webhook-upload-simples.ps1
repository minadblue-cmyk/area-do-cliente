# Script simples para testar webhook de upload de leads
Write-Host "🧪 Teste simples do webhook de upload..." -ForegroundColor Yellow

# Configurações
$n8nBaseUrl = "https://n8n.code-iq.com.br"
$webhookId = "webhook/upload" # Substitua pelo ID correto do webhook
$fullUri = "$n8nBaseUrl/$webhookId"

# Payload simples com um lead
$payload = @{
    logged_user = @{
        id = 6
        name = "Usuário Elleve Padrão"
        email = "rmacedo2005@hotmail.com"
        empresa_id = 1
    }
    data = @{
        agente_id = 81
    }
    leads = @(
        @{
            nome = "Roger Macedo da Silva"
            telefone = "5551984033242"
            email = "roger@exemplo.com"
            profissao = "Analista de Suporte"
            idade = 40
            estado_civil = "Casado"
            filhos = $true
            qtd_filhos = 2
            fonte_prospec = "Márcio André"
            data_processamento = "2025-09-26T09:02:24.422-03:00"
        }
    )
}

# Converter para JSON
$jsonPayload = $payload | ConvertTo-Json -Depth 5

Write-Host "`n📋 Payload de teste:" -ForegroundColor Cyan
Write-Host $jsonPayload -ForegroundColor White

Write-Host "`n🔗 Testando webhook: $fullUri" -ForegroundColor Yellow

try {
    # Fazer requisição POST
    $response = Invoke-WebRequest -Uri $fullUri -Method POST -Body $jsonPayload -ContentType "application/json" -UseBasicParsing
    
    Write-Host "`n✅ Webhook executado com sucesso!" -ForegroundColor Green
    Write-Host "Status Code: $($response.StatusCode)" -ForegroundColor White
    Write-Host "`n📄 Resposta do webhook:" -ForegroundColor Cyan
    Write-Host $response.Content -ForegroundColor White
    
} catch {
    Write-Host "`n❌ Erro ao testar webhook:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode
        Write-Host "Status Code: $statusCode" -ForegroundColor Red
    }
}

Write-Host "`n🔧 Query Parameters para configurar no n8n:" -ForegroundColor Cyan
Write-Host "1. usuario_id: {{ `$('Insert mercado1').item.json.body.logged_user.id }}" -ForegroundColor White
Write-Host "2. empresa_id: {{ `$('Insert mercado1').item.json.body.logged_user.empresa_id }}" -ForegroundColor White
Write-Host "3. nome: {{ `$json.nome }}" -ForegroundColor White
Write-Host "4. telefone: {{ `$json.telefone }}" -ForegroundColor White
Write-Host "5. email: {{ `$json.email || '' }}" -ForegroundColor White
Write-Host "6. profissao: {{ `$json.profissao }}" -ForegroundColor White
Write-Host "7. idade: {{ `$json.idade }}" -ForegroundColor White
Write-Host "8. estado_civil: {{ `$json.estado_civil }}" -ForegroundColor White
Write-Host "9. filhos: {{ `$json.filhos }}" -ForegroundColor White
Write-Host "10. qtd_filhos: {{ `$json.qtd_filhos }}" -ForegroundColor White
Write-Host "11. fonte_prospec: {{ `$json.fonte_prospec }}" -ForegroundColor White
Write-Host "12. data_processamento: {{ `$('Normalização').item.json.data_processamento }}" -ForegroundColor White

Write-Host "`n✅ Teste concluído!" -ForegroundColor Green
