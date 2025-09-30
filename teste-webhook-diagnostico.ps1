# Teste de diagnóstico para o webhook

Write-Host "Diagnostico do Webhook - Teste Detalhado" -ForegroundColor Green
Write-Host ""

# URL do webhook
$webhookUrl = "https://n8n.code-iq.com.br/webhook/create-agente"

# Dados de teste
$dados = @{
    agent_name = "Agente Teste Diagnostico"
    agent_type = "teste-diagnostico"
    agent_id = 999
    user_id = 1
    icone = "🔧"
    cor = "bg-blue-500"
    descricao = "Teste de diagnostico do webhook"
} | ConvertTo-Json

Write-Host "URL do Webhook: $webhookUrl" -ForegroundColor Cyan
Write-Host "Dados sendo enviados:" -ForegroundColor Yellow
Write-Host $dados
Write-Host ""

try {
    # Enviar requisição com mais detalhes
    $response = Invoke-WebRequest -Uri $webhookUrl -Method Post -Body $dados -ContentType "application/json" -TimeoutSec 30
    
    Write-Host "Status Code: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Status Description: $($response.StatusDescription)" -ForegroundColor Green
    Write-Host "Headers:" -ForegroundColor Green
    $response.Headers | Format-Table
    
    Write-Host "Content:" -ForegroundColor Green
    if ($response.Content) {
        Write-Host $response.Content
    } else {
        Write-Host "Resposta vazia" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Erro no teste:" -ForegroundColor Red
    Write-Host "Tipo do erro: $($_.Exception.GetType().Name)"
    Write-Host "Mensagem: $($_.Exception.Message)"
    
    if ($_.Exception.Response) {
        Write-Host "Status Code: $($_.Exception.Response.StatusCode)"
        Write-Host "Status Description: $($_.Exception.Response.StatusDescription)"
        
        # Tentar ler o conteúdo da resposta de erro
        try {
            $errorStream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorStream)
            $errorContent = $reader.ReadToEnd()
            Write-Host "Conteudo do erro: $errorContent"
        } catch {
            Write-Host "Nao foi possivel ler o conteudo do erro"
        }
    }
}

Write-Host ""
Write-Host "Diagnostico concluido!" -ForegroundColor Green
