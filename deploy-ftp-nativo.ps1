# Deploy usando FTP Nativo do Windows
Write-Host "Deploy usando FTP Nativo - Hostinger" -ForegroundColor Green

# Credenciais FTP
$FtpHost = "195.200.3.228"
$FtpUser = "u535869980"
$FtpPass = "F0rm@T1001"

# Verificar build
if (-not (Test-Path "./dist")) {
    Write-Host "Build nao encontrado. Executando build..." -ForegroundColor Yellow
    npm run build
}

Write-Host "Build verificado!" -ForegroundColor Green

# Criar arquivo de comandos FTP
$ftpCommands = @"
open $FtpHost
user $FtpUser $FtpPass
binary
cd public_html
put ./dist/index.html index.html
put ./dist/favicon.svg favicon.svg
put ./dist/vite.svg vite.svg
mkdir assets
cd assets
"@

# Adicionar comandos para upload dos assets
$assetsPath = "./dist/assets"
if (Test-Path $assetsPath) {
    $assetFiles = Get-ChildItem -Path $assetsPath -File
    foreach ($file in $assetFiles) {
        $ftpCommands += "`nput `"./dist/assets/$($file.Name)`" `"$($file.Name)`""
    }
}

$ftpCommands += "`nquit"

# Salvar comandos em arquivo
$ftpCommands | Out-File -FilePath "ftp_commands.txt" -Encoding ASCII

Write-Host "Executando upload via FTP..." -ForegroundColor Yellow

# Executar FTP
ftp -s:ftp_commands.txt

# Limpar arquivo temporario
Remove-Item "ftp_commands.txt" -Force -ErrorAction SilentlyContinue

Write-Host "Deploy concluido!" -ForegroundColor Green
Write-Host "Acesse: https://code-iq.com.br/" -ForegroundColor Cyan
