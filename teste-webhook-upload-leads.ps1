# Script para testar webhook de upload de leads
Write-Host "🧪 Testando webhook de upload de leads..." -ForegroundColor Yellow

# Configurações
$n8nBaseUrl = "https://n8n.code-iq.com.br"
$webhookId = "webhook/upload" # Substitua pelo ID correto do webhook
$fullUri = "$n8nBaseUrl/$webhookId"

# Payload baseado na estrutura da imagem
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
    file_info = @{
        webhookUrl = "https://n8n.code-iq.com.br/webhook/upload"
        executionMode = "production"
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
            client_id = 6
            login = "Usuário Elleve Padrão"
            email_login = "rmacedo2005@hotmail.com"
            agente_id = 81
        },
        @{
            nome = "Maria Silva Santos"
            telefone = "11987654321"
            email = "maria@exemplo.com"
            profissao = "Desenvolvedora"
            idade = 28
            estado_civil = "Solteira"
            filhos = $false
            qtd_filhos = 0
            fonte_prospec = "Indicação"
            data_processamento = "2025-09-26T09:05:15.123-03:00"
            client_id = 6
            login = "Usuário Elleve Padrão"
            email_login = "rmacedo2005@hotmail.com"
            agente_id = 81
        }
    )
}

# Converter para JSON
$jsonPayload = $payload | ConvertTo-Json -Depth 10

Write-Host "`n📋 Payload de teste:" -ForegroundColor Cyan
Write-Host $jsonPayload -ForegroundColor White

Write-Host "`n🔗 Testando webhook: $fullUri" -ForegroundColor Yellow

try {
    # Fazer requisição POST
    $response = Invoke-WebRequest -Uri $fullUri -Method POST -Body $jsonPayload -ContentType "application/json" -UseBasicParsing
    
    if ($response.StatusCode -eq 200) {
        Write-Host "`n✅ Webhook executado com sucesso!" -ForegroundColor Green
        Write-Host "Status Code: $($response.StatusCode)" -ForegroundColor White
        Write-Host "`n📄 Resposta do webhook:" -ForegroundColor Cyan
        Write-Host $response.Content -ForegroundColor White
    } else {
        Write-Host "`n⚠️ Webhook retornou status: $($response.StatusCode)" -ForegroundColor Yellow
        Write-Host "Resposta: $($response.Content)" -ForegroundColor White
    }
} catch {
    Write-Host "`n❌ Erro ao testar webhook:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode
        Write-Host "Status Code: $statusCode" -ForegroundColor Red
        
        # Tentar ler o conteúdo da resposta de erro
        try {
            $errorStream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorStream)
            $errorContent = $reader.ReadToEnd()
            Write-Host "Conteúdo do erro: $errorContent" -ForegroundColor Red
        } catch {
            Write-Host "Não foi possível ler o conteúdo do erro" -ForegroundColor Red
        }
    }
}

Write-Host "`n📊 Resumo do teste:" -ForegroundColor Yellow
Write-Host "• Webhook: $webhookId" -ForegroundColor White
Write-Host "• Leads enviados: $($payload.leads.Count)" -ForegroundColor White
Write-Host "• Usuário: $($payload.logged_user.name) (ID: $($payload.logged_user.id))" -ForegroundColor White
Write-Host "• Empresa: $($payload.logged_user.empresa_id)" -ForegroundColor White
Write-Host "• Agente: $($payload.data.agente_id)" -ForegroundColor White

Write-Host "`n🔧 Query Parameters esperados no n8n:" -ForegroundColor Cyan
Write-Host "1. usuario_id: $($payload.logged_user.id)" -ForegroundColor White
Write-Host "2. empresa_id: $($payload.logged_user.empresa_id)" -ForegroundColor White
Write-Host "3. nome: [do lead individual]" -ForegroundColor White
Write-Host "4. telefone: [do lead individual]" -ForegroundColor White
Write-Host "5. email: [do lead individual]" -ForegroundColor White
Write-Host "6. profissao: [do lead individual]" -ForegroundColor White
Write-Host "7. idade: [do lead individual]" -ForegroundColor White
Write-Host "8. estado_civil: [do lead individual]" -ForegroundColor White
Write-Host "9. filhos: [do lead individual]" -ForegroundColor White
Write-Host "10. qtd_filhos: [do lead individual]" -ForegroundColor White
Write-Host "11. fonte_prospec: [do lead individual]" -ForegroundColor White
Write-Host "12. data_processamento: [do lead individual]" -ForegroundColor White

Write-Host "`n✅ Teste concluído!" -ForegroundColor Green
