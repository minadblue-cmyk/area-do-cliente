# Teste de Debug do Login - Verificar estrutura completa
Write-Host "=== DEBUG LOGIN - ESTRUTURA COMPLETA ===" -ForegroundColor Green

$loginUrl = "https://n8n.code-iq.com.br/webhook/login"

$loginData = @{
    email = "admin@code-iq.com.br"
    password = "F0rm@T10"
} | ConvertTo-Json

Write-Host "Enviando dados de login..." -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri $loginUrl -Method POST -Body $loginData -ContentType "application/json" -ErrorAction Stop
    Write-Host "✅ LOGIN - SUCESSO!" -ForegroundColor Green
    Write-Host "`n📊 ESTRUTURA COMPLETA DA RESPOSTA:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 10 | Write-Host -ForegroundColor White
    
    Write-Host "`n🔍 CAMPOS DISPONÍVEIS:" -ForegroundColor Yellow
    $response.PSObject.Properties | ForEach-Object {
        Write-Host "  - $($_.Name): $($_.Value)" -ForegroundColor Cyan
    }
    
    if ($response.user) {
        Write-Host "`n👤 DADOS DO USUÁRIO:" -ForegroundColor Yellow
        $response.user.PSObject.Properties | ForEach-Object {
            Write-Host "  - user.$($_.Name): $($_.Value)" -ForegroundColor Cyan
        }
    }
    
} catch {
    Write-Host "❌ LOGIN - ERRO!" -ForegroundColor Red
    Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Mensagem: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== FIM DO DEBUG ===" -ForegroundColor Green
