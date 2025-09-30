Write-Host "Debug: Sincronizacao Frontend-N8N" -ForegroundColor Yellow

# 1. Testar login
$loginBody = @{
    email = "fith@fithinvestimento.com"
    password = "F0rm@T10"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "https://n8n.code-iq.com.br/webhook/login" -Method POST -Body $loginBody -ContentType "application/json"
    Write-Host "Login realizado:" -ForegroundColor Green
    Write-Host "usuario_id: $($loginResponse.usuario_id)" -ForegroundColor White
    Write-Host "nome: $($loginResponse.nome)" -ForegroundColor White
    Write-Host "empresa_id: $($loginResponse.empresa_id)" -ForegroundColor Red
    
    if ($loginResponse.empresa_id) {
        Write-Host "empresa_id encontrado: $($loginResponse.empresa_id)" -ForegroundColor Green
    } else {
        Write-Host "empresa_id NAO encontrado" -ForegroundColor Red
    }
} catch {
    Write-Host "Erro no login: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 2. Testar agentes
try {
    $agentesResponse = Invoke-RestMethod -Uri "https://n8n.code-iq.com.br/webhook/list-agentes" -Method GET
    Write-Host "Agentes encontrados: $($agentesResponse.Count)" -ForegroundColor Green
    
    if ($agentesResponse -and $agentesResponse.Count -gt 0) {
        $agente = $agentesResponse[0]
        Write-Host "Primeiro agente:" -ForegroundColor White
        Write-Host "ID: $($agente.id)" -ForegroundColor White
        Write-Host "Nome: $($agente.nome)" -ForegroundColor White
        Write-Host "Webhook Start: $($agente.webhook_start_url)" -ForegroundColor White
    }
} catch {
    Write-Host "Erro ao listar agentes: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Debug concluido" -ForegroundColor Yellow
