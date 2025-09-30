# =====================================================
# TESTE SEM CORS - USANDO CURL
# =====================================================

Write-Host "🧪 Testando webhook start sem CORS usando curl..." -ForegroundColor Green

# Payload corrigido
$payload = @{
    usuario_id = 6
    action = "start"
    logged_user = @{
        id = 6
        name = "Usuario Elleve Padrao"
        email = "rmacedo2005@hotmail.com"
    }
    agente_id = 81
    perfil_id = 2
    perfis_permitidos = @(2, 3)
    usuarios_permitidos = @(6)
} | ConvertTo-Json -Depth 3

Write-Host "📤 Payload enviado:" -ForegroundColor Yellow
Write-Host $payload -ForegroundColor Gray

Write-Host "`n🚀 Enviando para webhook start..." -ForegroundColor Cyan

try {
    # Usar curl para evitar CORS
    $response = curl -X POST "https://n8n.code-iq.com.br/webhook/start12-ze" `
        -H "Content-Type: application/json" `
        -d $payload `
        --silent --show-error
    
    Write-Host "✅ Resposta recebida:" -ForegroundColor Green
    Write-Host $response -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Erro na requisição:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n🏁 Teste sem CORS concluido!" -ForegroundColor Green
