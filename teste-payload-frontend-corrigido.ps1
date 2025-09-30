# =====================================================
# TESTE PAYLOAD FRONTEND CORRIGIDO
# =====================================================

Write-Host "🧪 Testando Payload Frontend Corrigido..." -ForegroundColor Green

# Simular o payload que o frontend corrigido deve enviar
$payload = @{
    usuario_id = 6
    action = "start"
    logged_user = @{
        id = 6
        name = "Usuário Elleve Padrão"
        email = "rmacedo2005@hotmail.com"
    }
    agente_id = 5  # ID do agente que será iniciado
    perfil_id = 2  # Perfil principal do usuário
    perfis_permitidos = @(2, 3)  # Todos os perfis do usuário
    usuarios_permitidos = @(6)   # Usuários permitidos
} | ConvertTo-Json -Depth 3

Write-Host "📤 Payload corrigido (como será enviado pelo frontend):" -ForegroundColor Yellow
Write-Host $payload -ForegroundColor Gray

Write-Host "`n🔍 Comparando com payload anterior:" -ForegroundColor Cyan
Write-Host "❌ ANTES (incorreto):" -ForegroundColor Red
Write-Host '  - action: "start"' -ForegroundColor Gray
Write-Host '  - agent_type: 81' -ForegroundColor Gray
Write-Host '  - workflow_id: 81' -ForegroundColor Gray
Write-Host '  - timestamp: "2025-09-25T19:06:23.574Z"' -ForegroundColor Gray
Write-Host '  - usuario_id: 6' -ForegroundColor Gray
Write-Host '  - logged_user: { ... }' -ForegroundColor Gray
Write-Host '  - webhookUrl: "https://n8n.code-iq.com.br/webhook/start12-ze"' -ForegroundColor Gray
Write-Host '  - executionMode: "production"' -ForegroundColor Gray

Write-Host "`n✅ AGORA (correto):" -ForegroundColor Green
Write-Host '  - usuario_id: 6' -ForegroundColor Gray
Write-Host '  - action: "start"' -ForegroundColor Gray
Write-Host '  - logged_user: { ... }' -ForegroundColor Gray
Write-Host '  - agente_id: 5' -ForegroundColor Gray
Write-Host '  - perfil_id: 2' -ForegroundColor Gray
Write-Host '  - perfis_permitidos: [2, 3]' -ForegroundColor Gray
Write-Host '  - usuarios_permitidos: [6]' -ForegroundColor Gray

Write-Host "`n🚀 Testando webhook com payload corrigido..." -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "http://localhost:5678/webhook/start" -Method POST -Body $payload -ContentType "application/json"
    
    Write-Host "✅ Resposta recebida:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor Gray
    
    Write-Host "`n🔍 Verificando se leads foram reservados..." -ForegroundColor Yellow
    
    # Aguardar um pouco para o processamento
    Start-Sleep -Seconds 3
    
} catch {
    Write-Host "❌ Erro na requisição:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n🏁 Teste do Payload Frontend Corrigido concluido!" -ForegroundColor Green
