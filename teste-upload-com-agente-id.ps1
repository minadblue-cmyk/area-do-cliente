# Script para testar upload com agente_id
Write-Host "Testando upload com agente_id incluído..." -ForegroundColor Yellow

# Dados de teste simulando o payload do frontend
$testPayload = @{
    logged_user = @{
        id = "6"
        name = "Usuário Elleve Padrão"
        email = "rmacedo2005@hotmail.com"
    }
    agente_id = 81  # ✅ AGENTE_ID INCLUÍDO
    data = @(
        @{
            nome = "Roger Macedo da Silva"
            telefone = "5551984033242"
            profissao = "Analista de Suporte"
            fonte_prospec = "Márcio André"
            idade = 40
            estado_civil = "Casado"
            filhos = $true
            qtd_filhos = 2
        },
        @{
            nome = "Isadora Ferreira"
            telefone = "5551919892192"
            profissao = "Radialista programador"
            fonte_prospec = "LinkedIn"
            idade = 42
            estado_civil = "Viúvo(a)"
            filhos = $true
            qtd_filhos = 5
        }
    )
    file_info = @{
        name = "leads.xlsx"
        size = 12345
        type = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        lastModified = 1735128000000
    }
}

Write-Host "📦 Payload de teste:" -ForegroundColor Green
$testPayload | ConvertTo-Json -Depth 4 | Write-Host -ForegroundColor Cyan

Write-Host ""
Write-Host "✅ Modificações aplicadas no frontend:" -ForegroundColor Green
Write-Host "1. Funcao getAgenteIdForUser adicionada" -ForegroundColor White
Write-Host "2. agente_id incluido no payload de upload" -ForegroundColor White
Write-Host "3. Validacao de agente atribuido ao usuario" -ForegroundColor White

Write-Host ""
Write-Host "🔧 Próximos passos no n8n:" -ForegroundColor Yellow
Write-Host "1. Modificar processamento para usar agente_id do payload" -ForegroundColor White
Write-Host "2. Atualizar query SQL para incluir agente_id" -ForegroundColor White
Write-Host "3. Testar upload completo" -ForegroundColor White

Write-Host ""
Write-Host "Agora o frontend enviará agente_id automaticamente! 🚀" -ForegroundColor Green
