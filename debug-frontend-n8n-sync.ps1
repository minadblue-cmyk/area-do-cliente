Write-Host "🔍 DEBUG: SINCRONIZAÇÃO FRONTEND-N8N" -ForegroundColor Yellow
Write-Host ""

# 1. Testar login e capturar resposta completa
Write-Host "1. TESTANDO LOGIN E CAPTURANDO RESPOSTA COMPLETA:" -ForegroundColor Cyan
$loginBody = @{
    email = "fith@fithinvestimento.com"
    password = "F0rm@T10"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "https://n8n.code-iq.com.br/webhook/login" -Method POST -Body $loginBody -ContentType "application/json"
    Write-Host "✅ Login realizado com sucesso:" -ForegroundColor Green
    Write-Host "Resposta completa do n8n:" -ForegroundColor White
    $loginResponse | ConvertTo-Json -Depth 5
    
    Write-Host ""
    Write-Host "ANÁLISE DOS DADOS:" -ForegroundColor Yellow
    Write-Host "- usuario_id: $($loginResponse.usuario_id)" -ForegroundColor White
    Write-Host "- nome: $($loginResponse.nome)" -ForegroundColor White
    Write-Host "- email: $($loginResponse.email)" -ForegroundColor White
    Write-Host "- perfil_id: $($loginResponse.perfil_id)" -ForegroundColor White
    Write-Host "- empresa_id: $($loginResponse.empresa_id)" -ForegroundColor Red
    Write-Host "- plano: $($loginResponse.plano)" -ForegroundColor White
    
    # Verificar se empresa_id existe
    if ($loginResponse.empresa_id) {
        Write-Host "✅ empresa_id encontrado: $($loginResponse.empresa_id)" -ForegroundColor Green
    } else {
        Write-Host "❌ empresa_id NÃO encontrado na resposta do n8n" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Erro no login: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 2. Testar listagem de agentes
Write-Host "2. TESTANDO LISTAGEM DE AGENTES:" -ForegroundColor Cyan
try {
    $agentesResponse = Invoke-RestMethod -Uri "https://n8n.code-iq.com.br/webhook/list-agentes" -Method GET
    Write-Host "✅ Agentes carregados: $($agentesResponse.Count)" -ForegroundColor Green
    Write-Host "Resposta completa dos agentes:" -ForegroundColor White
    $agentesResponse | ConvertTo-Json -Depth 5
    
    if ($agentesResponse -and $agentesResponse.Count -gt 0) {
        $primeiroAgente = $agentesResponse[0]
        Write-Host ""
        Write-Host "PRIMEIRO AGENTE:" -ForegroundColor Yellow
        Write-Host "- ID: $($primeiroAgente.id)" -ForegroundColor White
        Write-Host "- Nome: $($primeiroAgente.nome)" -ForegroundColor White
        Write-Host "- Webhook Start: $($primeiroAgente.webhook_start_url)" -ForegroundColor White
        Write-Host "- Webhook Stop: $($primeiroAgente.webhook_stop_url)" -ForegroundColor White
        Write-Host "- Webhook Status: $($primeiroAgente.webhook_status_url)" -ForegroundColor White
        Write-Host "- Webhook Lista: $($primeiroAgente.webhook_lista_url)" -ForegroundColor White
    }
} catch {
    Write-Host "❌ Erro ao listar agentes: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# 3. Simular payload que o frontend enviaria
Write-Host "3. SIMULANDO PAYLOAD QUE O FRONTEND ENVIARIA:" -ForegroundColor Cyan
if ($loginResponse -and $agentesResponse -and $agentesResponse.Count -gt 0) {
    $primeiroAgente = $agentesResponse[0]
    
    $frontendPayload = @{
        usuario_id = $loginResponse.usuario_id
        action = "start"
        logged_user = @{
            id = $loginResponse.usuario_id
            name = $loginResponse.nome
            email = $loginResponse.email
            empresa_id = $loginResponse.empresa_id
        }
        agente_id = $primeiroAgente.id
        perfil_id = $loginResponse.perfil_id
        perfis_permitidos = @($loginResponse.perfil_id)
        usuarios_permitidos = @($loginResponse.usuario_id)
        empresa_id = $loginResponse.empresa_id
    }
    
    Write-Host "Payload que o frontend enviaria:" -ForegroundColor White
    $frontendPayload | ConvertTo-Json -Depth 5
    
    Write-Host ""
    Write-Host "ANÁLISE DO PAYLOAD:" -ForegroundColor Yellow
    Write-Host "- usuario_id: $($frontendPayload.usuario_id)" -ForegroundColor White
    Write-Host "- agente_id: $($frontendPayload.agente_id)" -ForegroundColor White
    Write-Host "- empresa_id (nivel principal): $($frontendPayload.empresa_id)" -ForegroundColor White
    Write-Host "- empresa_id (logged_user): $($frontendPayload.logged_user.empresa_id)" -ForegroundColor White
    
    # Verificar se empresa_id é null
    if ($frontendPayload.empresa_id -eq $null) {
        Write-Host "❌ PROBLEMA: empresa_id é NULL no payload!" -ForegroundColor Red
        Write-Host "Isso significa que o frontend não consegue enviar empresa_id correto" -ForegroundColor Red
    } else {
        Write-Host "✅ empresa_id presente no payload: $($frontendPayload.empresa_id)" -ForegroundColor Green
    }
}

Write-Host ""

# 4. Testar start real (se empresa_id existir)
Write-Host "4. TESTANDO START REAL:" -ForegroundColor Cyan
if ($loginResponse.empresa_id -and $agentesResponse -and $agentesResponse.Count -gt 0) {
    $primeiroAgente = $agentesResponse[0]
    
    Write-Host "Tentando start com empresa_id: $($loginResponse.empresa_id)" -ForegroundColor White
    
    $startPayload = @{
        usuario_id = $loginResponse.usuario_id
        action = "start"
        logged_user = @{
            id = $loginResponse.usuario_id
            name = $loginResponse.nome
            email = $loginResponse.email
            empresa_id = $loginResponse.empresa_id
        }
        agente_id = $primeiroAgente.id
        perfil_id = $loginResponse.perfil_id
        perfis_permitidos = @($loginResponse.perfil_id)
        usuarios_permitidos = @($loginResponse.usuario_id)
        empresa_id = $loginResponse.empresa_id
    } | ConvertTo-Json -Depth 3

    try {
        $startResponse = Invoke-RestMethod -Uri $primeiroAgente.webhook_start_url -Method POST -Body $startPayload -ContentType "application/json"
        Write-Host "✅ Start realizado com sucesso:" -ForegroundColor Green
        $startResponse | ConvertTo-Json -Depth 3
    } catch {
        Write-Host "❌ Erro no start: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Response Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Não é possível testar start - empresa_id ou agente não disponível" -ForegroundColor Red
}

Write-Host ""
Write-Host "🔍 DEBUG CONCLUÍDO" -ForegroundColor Yellow
