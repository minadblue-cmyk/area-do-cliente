# Teste de Acesso
Write-Host "Testando acesso direto a Area do Cliente" -ForegroundColor Green

try {
    $response = Invoke-WebRequest -Uri "https://code-iq.com.br/area-cliente-app.html" -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Tamanho: $($response.Content.Length) bytes" -ForegroundColor Green
    
    if ($response.Content -like "*Área do Cliente*") {
        Write-Host "✅ Página carregou corretamente!" -ForegroundColor Green
    } else {
        Write-Host "❌ Página não contém conteúdo esperado" -ForegroundColor Red
    }
}
catch {
    Write-Host "❌ Erro ao acessar: $($_.Exception.Message)" -ForegroundColor Red
}
