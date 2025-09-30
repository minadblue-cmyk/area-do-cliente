# =====================================================
# TESTE DE UPLOAD DE LEADS
# =====================================================

Write-Host "🚀 Testando upload de leads..." -ForegroundColor Green

# URL do webhook
$webhookUrl = "https://n8n.code-iq.com.br/webhook/upload"

# Dados de teste (simulando uma planilha de leads)
$testData = @{
    "agent_id" = 81
    "leads" = @(
        @{
            "nome" = "João Silva"
            "telefone" = "11999999999"
            "email" = "joao@email.com"
            "profissao" = "Engenheiro"
            "fonte" = "Facebook"
        },
        @{
            "nome" = "Maria Santos"
            "telefone" = "11999999998"
            "email" = "maria@email.com"
            "profissao" = "Advogada"
            "fonte" = "Instagram"
        },
        @{
            "nome" = "Pedro Costa"
            "telefone" = "11999999997"
            "email" = "pedro@email.com"
            "profissao" = "Médico"
            "fonte" = "Google"
        }
    )
}

# Converter para JSON
$jsonData = $testData | ConvertTo-Json -Depth 3

Write-Host "📤 Enviando dados para o webhook..." -ForegroundColor Yellow
Write-Host "URL: $webhookUrl" -ForegroundColor Cyan
Write-Host "Dados: $jsonData" -ForegroundColor Gray

try {
    # Fazer a requisição POST
    $response = Invoke-RestMethod -Uri $webhookUrl -Method POST -Body $jsonData -ContentType "application/json"
    
    Write-Host "✅ Sucesso!" -ForegroundColor Green
    Write-Host "Resposta: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor White
}
catch {
    Write-Host "❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Detalhes: $($_.Exception.Response)" -ForegroundColor Red
}

Write-Host "`n🔍 Verificando se os leads foram criados..." -ForegroundColor Yellow

# Query para verificar se os leads foram criados
$checkQuery = @"
SELECT 
  COUNT(*) as total_leads,
  COUNT(CASE WHEN agente_id = 81 THEN 1 END) as leads_agente_81,
  COUNT(CASE WHEN contatado IS NOT TRUE THEN 1 END) as nao_contatados
FROM lead;
"@

Write-Host "Query de verificação: $checkQuery" -ForegroundColor Gray
