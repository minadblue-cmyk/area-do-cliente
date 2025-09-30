# Teste Debug do Webhook Listar Saudação
Write-Host "=== TESTE DEBUG LISTAR SAUDACAO ===" -ForegroundColor Green

$webhookUrl = "https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/listar-saudacao"

# Teste com dados reais do banco
$testData = @{
    usuario_id = 5  # ID do usuário admin
    nome = "Administrator Code-IQ"
    email = "admin@code-iq.com.br"
    tipo = "Administrador"
    role = "Administrador"
} | ConvertTo-Json

Write-Host "URL: $webhookUrl" -ForegroundColor Yellow
Write-Host "Dados enviados:" -ForegroundColor Yellow
Write-Host $testData -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri $webhookUrl -Method POST -Body $testData -ContentType "application/json" -ErrorAction Stop
    Write-Host "✅ WEBHOOK - SUCESSO!" -ForegroundColor Green
    Write-Host "Resposta:" -ForegroundColor Yellow
    $response | ConvertTo-Json -Depth 10 | Write-Host -ForegroundColor Cyan
    
    # Verificar se tem dados
    if ($response.data) {
        Write-Host "`n✅ DADOS ENCONTRADOS:" -ForegroundColor Green
        Write-Host "  - Total de saudações: $($response.data.Count)" -ForegroundColor Cyan
        $response.data | ForEach-Object {
            Write-Host "  - ID: $($_.id), Texto: $($_.texto.Substring(0, [Math]::Min(50, $_.texto.Length)))..." -ForegroundColor White
        }
    } else {
        Write-Host "`n⚠️ Nenhuma saudação encontrada" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "❌ WEBHOOK - ERRO!" -ForegroundColor Red
    Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Mensagem: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== FIM DO TESTE ===" -ForegroundColor Green
