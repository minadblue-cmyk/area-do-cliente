# Teste simples do payload corrigido

Write-Host "Testando Payload Frontend Corrigido..." -ForegroundColor Green

$payload = @{
    usuario_id = 6
    action = "start"
    logged_user = @{
        id = 6
        name = "Usuario Elleve Padrao"
        email = "rmacedo2005@hotmail.com"
    }
    agente_id = 5
    perfil_id = 2
    perfis_permitidos = @(2, 3)
    usuarios_permitidos = @(6)
} | ConvertTo-Json -Depth 3

Write-Host "Payload enviado:" -ForegroundColor Yellow
Write-Host $payload -ForegroundColor Gray

try {
    $response = Invoke-RestMethod -Uri "http://localhost:5678/webhook/start" -Method POST -Body $payload -ContentType "application/json"
    
    Write-Host "Resposta recebida:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor Gray
    
} catch {
    Write-Host "Erro na requisicao:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "Teste concluido!" -ForegroundColor Green
