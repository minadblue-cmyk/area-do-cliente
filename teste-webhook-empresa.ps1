# Teste do webhook de criar empresa
Write-Host "Testando webhook de criar empresa..." -ForegroundColor Yellow

$n8nBaseUrl = "https://n8n-lavo-n8n.15gxno.easypanel.host"
$webhookPath = "webhook/create-company"
$fullUri = "$n8nBaseUrl/$webhookPath"

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

Write-Host "`nPayload de teste:" -ForegroundColor Cyan
$payload | ConvertTo-Json -Depth 3

Write-Host "`nTestando webhook: $fullUri" -ForegroundColor Green

try {
    $response = Invoke-WebRequest -Uri $fullUri -Method POST -ContentType "application/json" -Body ($payload | ConvertTo-Json -Depth 3) -UseBasicParsing
    
    Write-Host "`nSUCESSO! Webhook executado corretamente!" -ForegroundColor Green
    Write-Host "Status Code: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "`nResposta do webhook:" -ForegroundColor Cyan
    $response.Content | Write-Host -ForegroundColor White
    
} catch {
    Write-Host "`nERRO! Webhook falhou:" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Status Description: $($_.Exception.Response.StatusDescription)" -ForegroundColor Red
    Write-Host "Erro: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        try {
            $errorResponse = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorResponse)
            $responseBody = $reader.ReadToEnd()
            Write-Host "`nResposta de Erro Detalhada:" -ForegroundColor Red
            $responseBody | Write-Host -ForegroundColor Red
        } catch {
            Write-Host "`nNao foi possivel ler a resposta de erro" -ForegroundColor Red
        }
    }
}

Write-Host "`nTeste finalizado!" -ForegroundColor Cyan
