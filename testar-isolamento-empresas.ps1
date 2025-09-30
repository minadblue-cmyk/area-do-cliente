# Script para testar isolamento de empresas
Write-Host "🔍 TESTANDO ISOLAMENTO DE EMPRESAS" -ForegroundColor Yellow
Write-Host ""

# 1. Testar login do usuário fith@fithinvestimento
Write-Host "1. TESTANDO LOGIN DO USUÁRIO FITH:" -ForegroundColor Cyan
$loginPayload = @{
    email = "fith@fithinvestimento"
    password = "123456"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "https://n8n.code-iq.com.br/webhook/login" -Method POST -Body $loginPayload -ContentType "application/json"
    Write-Host "✅ Login realizado com sucesso:" -ForegroundColor Green
    $loginResponse | ConvertTo-Json -Depth 3
    $userData = $loginResponse
} catch {
    Write-Host "❌ Erro no login: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 2. Testar listagem de agentes para o usuário
Write-Host "2. TESTANDO LISTAGEM DE AGENTES:" -ForegroundColor Cyan
try {
    $agentesResponse = Invoke-RestMethod -Uri "https://n8n.code-iq.com.br/webhook/list-agentes" -Method GET
    Write-Host "✅ Agentes carregados:" -ForegroundColor Green
    $agentesResponse | ConvertTo-Json -Depth 3
} catch {
    Write-Host "❌ Erro ao carregar agentes: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# 3. Testar start de agente (se houver agentes disponíveis)
if ($agentesResponse -and $agentesResponse.Count -gt 0) {
    $primeiroAgente = $agentesResponse[0]
    Write-Host "3. TESTANDO START DO PRIMEIRO AGENTE:" -ForegroundColor Cyan
    Write-Host "Agente: $($primeiroAgente.nome)" -ForegroundColor White
    
    $startPayload = @{
        usuario_id = $userData.usuario_id
        action = "start"
        logged_user = @{
            id = $userData.usuario_id
            name = $userData.nome
            email = $userData.email
            empresa_id = $userData.empresa_id
        }
        agente_id = $primeiroAgente.id
        perfil_id = $userData.perfil_id
        perfis_permitidos = @($userData.perfil_id)
        usuarios_permitidos = @($userData.usuario_id)
        empresa_id = $userData.empresa_id
    } | ConvertTo-Json -Depth 3

    try {
        $startResponse = Invoke-RestMethod -Uri $primeiroAgente.webhook_start_url -Method POST -Body $startPayload -ContentType "application/json"
        Write-Host "✅ Start realizado com sucesso:" -ForegroundColor Green
        $startResponse | ConvertTo-Json -Depth 3
    } catch {
        Write-Host "❌ Erro no start: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Payload enviado:" -ForegroundColor Yellow
        $startPayload
    }
} else {
    Write-Host "❌ Nenhum agente disponível para teste" -ForegroundColor Red
}

Write-Host ""
Write-Host "🔍 TESTE CONCLUÍDO" -ForegroundColor Yellow
