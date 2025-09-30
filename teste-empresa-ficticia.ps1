# Script para testar webhook de criar empresa com dados fictícios
# Testa se o n8n está funcionando corretamente

Write-Host "🧪 Testando webhook de criar empresa com dados fictícios..." -ForegroundColor Yellow

# Configurações
$n8nBaseUrl = "https://n8n-lavo-n8n.15gxno.easypanel.host"
$webhookPath = "webhook/create-company"
$fullUri = "$n8nBaseUrl/$webhookPath"

# Payload de teste com empresa fictícia
$payload = @{
    nome = "Tech Solutions LTDA"
    cnpj = "12345678000199"
    email = "contato@techsolutions.com.br"
    telefone = "1133334444"
    celular = "11999887766"
    logradouro = "Av. Paulista"
    numero = "1000"
    complemento = "Conjunto 101"
    bairro = "Bela Vista"
    cidade = "São Paulo"
    estado = "SP"
    cep = "01310100"
    inscricao_estadual = "123456789012"
    inscricao_municipal = "987654321"
    regime_tributario = "Lucro Real"
    cnae = "6201500"
    banco = "Itaú"
    agencia = "1234"
    conta_corrente = "12345-6"
    descricao = "Empresa de tecnologia especializada em soluções digitais"
    action = "create_company"
}

Write-Host "`n📦 Payload de teste (Empresa Fictícia):" -ForegroundColor Cyan
$payload | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor White

Write-Host "`n🌐 Testando webhook: $fullUri" -ForegroundColor Green
Write-Host "`n⏳ Enviando requisição..." -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri $fullUri -Method POST -ContentType "application/json" -Body ($payload | ConvertTo-Json -Depth 3) -UseBasicParsing
    
    Write-Host "`n✅ SUCESSO! Webhook executado corretamente!" -ForegroundColor Green
    Write-Host "Status Code: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "`n📄 Resposta do webhook:" -ForegroundColor Cyan
    $response.Content | Write-Host -ForegroundColor White
    
    Write-Host "`n🎉 Teste concluído com sucesso!" -ForegroundColor Green
    Write-Host "O webhook está funcionando corretamente." -ForegroundColor Green
    
} catch {
    Write-Host "`n❌ ERRO! Webhook falhou:" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Status Description: $($_.Exception.Response.StatusDescription)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        try {
            $errorResponse = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorResponse)
            $responseBody = $reader.ReadToEnd()
            Write-Host "`n📄 Resposta de Erro Detalhada:" -ForegroundColor Red
            $responseBody | Write-Host -ForegroundColor Red
        } catch {
            Write-Host "`n❌ Não foi possível ler a resposta de erro" -ForegroundColor Red
        }
    }
    
    Write-Host "`n🔍 Detalhes do erro:" -ForegroundColor Yellow
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    Write-Host "`n💡 Possíveis soluções:" -ForegroundColor Yellow
    Write-Host "1. Verificar se o webhook existe no n8n" -ForegroundColor White
    Write-Host "2. Verificar se o workflow está ativo" -ForegroundColor White
    Write-Host "3. Verificar logs do n8n para erros específicos" -ForegroundColor White
    Write-Host "4. Verificar configuração do webhook" -ForegroundColor White
}

Write-Host "`n🏁 Teste finalizado!" -ForegroundColor Cyan
