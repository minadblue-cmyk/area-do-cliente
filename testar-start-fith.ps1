Write-Host "Testando start de agente para usuario fith@fithinvestimento.com" -ForegroundColor Yellow

# 1. Fazer login
$loginBody = @{
    email = "fith@fithinvestimento.com"
    password = "F0rm@T10"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "https://n8n.code-iq.com.br/webhook/login" -Method POST -Body $loginBody -ContentType "application/json"
    Write-Host "Login realizado com sucesso:" -ForegroundColor Green
    Write-Host "Usuario ID: $($loginResponse.usuario_id)" -ForegroundColor White
    Write-Host "Nome: $($loginResponse.nome)" -ForegroundColor White
    Write-Host "Perfil ID: $($loginResponse.perfil_id)" -ForegroundColor White
    Write-Host "EMPRESA_ID: $($loginResponse.empresa_id)" -ForegroundColor Red
} catch {
    Write-Host "Erro no login: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 2. Listar agentes
Write-Host "Listando agentes disponiveis:" -ForegroundColor Cyan
try {
    $agentesResponse = Invoke-RestMethod -Uri "https://n8n.code-iq.com.br/webhook/list-agentes" -Method GET
    Write-Host "Agentes encontrados: $($agentesResponse.Count)" -ForegroundColor Green
    foreach ($agente in $agentesResponse) {
        Write-Host "- $($agente.nome) (ID: $($agente.id))" -ForegroundColor White
    }
} catch {
    Write-Host "Erro ao listar agentes: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 3. Testar start do primeiro agente
if ($agentesResponse -and $agentesResponse.Count -gt 0) {
    $primeiroAgente = $agentesResponse[0]
    Write-Host "Testando start do agente: $($primeiroAgente.nome)" -ForegroundColor Cyan
    
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

    Write-Host "Payload enviado:" -ForegroundColor Yellow
    $startPayload

    try {
        $startResponse = Invoke-RestMethod -Uri $primeiroAgente.webhook_start_url -Method POST -Body $startPayload -ContentType "application/json"
        Write-Host "Start realizado com sucesso:" -ForegroundColor Green
        $startResponse | ConvertTo-Json -Depth 3
    } catch {
        Write-Host "Erro no start: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Response: $($_.Exception.Response)" -ForegroundColor Red
    }
} else {
    Write-Host "Nenhum agente disponivel para teste" -ForegroundColor Red
}
