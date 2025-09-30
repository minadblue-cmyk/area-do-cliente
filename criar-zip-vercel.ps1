# Criar ZIP para upload manual no Vercel
Write-Host "Criando ZIP para upload manual no Vercel..." -ForegroundColor Green

# Criar diretorio temporario
$tempDir = "vercel-deploy"
if (Test-Path $tempDir) {
    Remove-Item $tempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $tempDir

# Copiar arquivos essenciais
Copy-Item "package.json" "$tempDir/"
Copy-Item "vite.config.ts" "$tempDir/"
Copy-Item "tsconfig.json" "$tempDir/"
Copy-Item "tsconfig.app.json" "$tempDir/"
Copy-Item "tsconfig.node.json" "$tempDir/"
Copy-Item "tailwind.config.ts" "$tempDir/"
Copy-Item "postcss.config.js" "$tempDir/"
Copy-Item "eslint.config.js" "$tempDir/"
Copy-Item "index.html" "$tempDir/"
Copy-Item "src" "$tempDir/src" -Recurse
Copy-Item "public" "$tempDir/public" -Recurse

# Criar ZIP
Compress-Archive -Path "$tempDir/*" -DestinationPath "area-cliente-vercel.zip" -Force

# Limpar diretorio temporario
Remove-Item $tempDir -Recurse -Force

Write-Host "ZIP criado: area-cliente-vercel.zip" -ForegroundColor Green
Write-Host "Agora faca upload manual deste ZIP no Vercel" -ForegroundColor Yellow
Write-Host "1. Va para https://vercel.com/new" -ForegroundColor Cyan
Write-Host "2. Clique em 'Import Third-Party Git Repository'" -ForegroundColor Cyan
Write-Host "3. Faça upload do arquivo ZIP" -ForegroundColor Cyan
