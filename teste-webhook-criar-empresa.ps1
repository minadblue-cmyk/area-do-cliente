# Script para testar o webhook de criar empresa
# Testa se o n8n está recebendo e processando corretamente

Write-Host "🔍 Testando webhook de criar empresa..." -ForegroundColor Yellow

# Configurações
$n8nBaseUrl = "https://n8n-lavo-n8n.15gxno.easypanel.host"
$webhookPath = "webhook/create-company"
$fullUri = "$n8nBaseUrl/$webhookPath"

# Payload de teste (baseado no que o frontend está enviando)
$payload = @{
    nome = "Fith Consorcios e Assessoria Financeira"
    cnpj = "57086253/0001-47"
    email = "fith@fithinvestimento.com"
    telefone = ""
    celular = "51985650668"
    logradouro = "Rua Teste"
    numero = "123"
    complemento = "Sala 1"
    bairro = "Centro"
    cidade = "Porto Alegre"
    estado = "RS"
    cep = "90000-000"
    inscricao_estadual = "123456789"
    inscricao_municipal = "987654321"
    regime_tributario = "Simples Nacional"
    cnae = "1234567"
    banco = "Banco do Brasil"
    agencia = "1234"
    conta_corrente = "12345-6"
    descricao = "Empresa de teste"
    action = "create_company"
}

Write-Host "`n📦 Payload de teste:" -ForegroundColor Cyan
$payload | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor White

Write-Host "`n🌐 Testando webhook: $fullUri" -ForegroundColor Green

try {
    Write-Host "`n⏳ Enviando requisição..." -ForegroundColor Yellow
    
    $response = Invoke-WebRequest -Uri $fullUri -Method POST -ContentType "application/json" -Body ($payload | ConvertTo-Json -Depth 3) -UseBasicParsing
    
    Write-Host "`n✅ Webhook executado com sucesso!" -ForegroundColor Green
    Write-Host "Status Code: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "`n📄 Resposta do webhook:" -ForegroundColor Cyan
    $response.Content | Write-Host -ForegroundColor White
    
} catch {
    Write-Host "`n❌ Erro ao executar webhook:" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Status Description: $($_.Exception.Response.StatusDescription)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        try {
            $errorResponse = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorResponse)
            $responseBody = $reader.ReadToEnd()
            Write-Host "`n📄 Resposta de Erro:" -ForegroundColor Red
            $responseBody | Write-Host -ForegroundColor Red
        } catch {
            Write-Host "`n❌ Não foi possível ler a resposta de erro" -ForegroundColor Red
        }
    }
    
    Write-Host "`n🔍 Detalhes do erro:" -ForegroundColor Yellow
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n✅ Teste concluído!" -ForegroundColor Green
