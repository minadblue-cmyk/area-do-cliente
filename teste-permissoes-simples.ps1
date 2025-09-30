# Teste Simples de Permissões da Lista de Prospecção
Write-Host "🔍 Testando Permissões da Lista de Prospecção..." -ForegroundColor Green

# Cenários de teste
Write-Host "`n🧪 Cenário 1: Usuário com Acesso Direto" -ForegroundColor Yellow
Write-Host "Usuário ID: 6" -ForegroundColor Cyan
Write-Host "Perfil ID: 1" -ForegroundColor Cyan
Write-Host "Agente ID: 81" -ForegroundColor Cyan

# Verificar acesso
$usuario_id = 6
$perfil_id = 1
$agente_id = 81
$usuarios_permitidos = @(6, 7)
$perfis_permitidos = @(1, 2)

$temAcesso = $false
$motivo = ""

if ($usuarios_permitidos -contains $usuario_id) {
    $temAcesso = $true
    $motivo = "Usuário está na lista de usuários permitidos"
} elseif ($perfis_permitidos -contains $perfil_id) {
    $temAcesso = $true
    $motivo = "Perfil está na lista de perfis permitidos"
} elseif ($agente_id -eq 81) {
    $temAcesso = $true
    $motivo = "É o agente responsável pelo lead"
} else {
    $motivo = "Usuário não tem acesso"
}

if ($temAcesso) {
    Write-Host "✅ ACESSO PERMITIDO: $motivo" -ForegroundColor Green
} else {
    Write-Host "❌ ACESSO NEGADO: $motivo" -ForegroundColor Red
}

Write-Host "`n🧪 Cenário 2: Usuário com Acesso por Perfil" -ForegroundColor Yellow
Write-Host "Usuário ID: 7" -ForegroundColor Cyan
Write-Host "Perfil ID: 2" -ForegroundColor Cyan
Write-Host "Agente ID: 82" -ForegroundColor Cyan

$usuario_id = 7
$perfil_id = 2
$agente_id = 82

$temAcesso = $false
$motivo = ""

if ($usuarios_permitidos -contains $usuario_id) {
    $temAcesso = $true
    $motivo = "Usuário está na lista de usuários permitidos"
} elseif ($perfis_permitidos -contains $perfil_id) {
    $temAcesso = $true
    $motivo = "Perfil está na lista de perfis permitidos"
} elseif ($agente_id -eq 81) {
    $temAcesso = $true
    $motivo = "É o agente responsável pelo lead"
} else {
    $motivo = "Usuário não tem acesso"
}

if ($temAcesso) {
    Write-Host "✅ ACESSO PERMITIDO: $motivo" -ForegroundColor Green
} else {
    Write-Host "❌ ACESSO NEGADO: $motivo" -ForegroundColor Red
}

Write-Host "`n🧪 Cenário 3: Usuário Sem Acesso" -ForegroundColor Yellow
Write-Host "Usuário ID: 9" -ForegroundColor Cyan
Write-Host "Perfil ID: 3" -ForegroundColor Cyan
Write-Host "Agente ID: 83" -ForegroundColor Cyan

$usuario_id = 9
$perfil_id = 3
$agente_id = 83

$temAcesso = $false
$motivo = ""

if ($usuarios_permitidos -contains $usuario_id) {
    $temAcesso = $true
    $motivo = "Usuário está na lista de usuários permitidos"
} elseif ($perfis_permitidos -contains $perfil_id) {
    $temAcesso = $true
    $motivo = "Perfil está na lista de perfis permitidos"
} elseif ($agente_id -eq 81) {
    $temAcesso = $true
    $motivo = "É o agente responsável pelo lead"
} else {
    $motivo = "Usuário não tem acesso"
}

if ($temAcesso) {
    Write-Host "✅ ACESSO PERMITIDO: $motivo" -ForegroundColor Green
} else {
    Write-Host "❌ ACESSO NEGADO: $motivo" -ForegroundColor Red
}

Write-Host "`n🎯 Resumo:" -ForegroundColor Yellow
Write-Host "✅ Usuário ID 6: Deve ter acesso (está em usuarios_permitidos)" -ForegroundColor Green
Write-Host "✅ Usuário ID 7: Deve ter acesso (perfil 2 está em perfis_permitidos)" -ForegroundColor Green
Write-Host "❌ Usuário ID 9: NÃO deve ter acesso (não está em nenhuma lista)" -ForegroundColor Red

Write-Host "`n🏁 Teste Concluído!" -ForegroundColor Green
