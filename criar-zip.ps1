# Criar ZIP com o projeto React original
Write-Host "Criando ZIP com o projeto React original..." -ForegroundColor Green

# Criar diretorio temporario
$tempDir = "temp-deploy"
if (Test-Path $tempDir) {
    Remove-Item $tempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $tempDir

# Copiar arquivos
Copy-Item "dist/index.html" "$tempDir/area-cliente-app.html"
Copy-Item "dist/favicon.svg" "$tempDir/favicon.svg"
Copy-Item "dist/assets" "$tempDir/assets" -Recurse

# Criar ZIP
Compress-Archive -Path "$tempDir/*" -DestinationPath "area-cliente-completo.zip" -Force

# Limpar diretorio temporario
Remove-Item $tempDir -Recurse -Force

Write-Host "ZIP criado: area-cliente-completo.zip" -ForegroundColor Green
Write-Host "Agora faca upload manual deste ZIP para o servidor" -ForegroundColor Yellow
