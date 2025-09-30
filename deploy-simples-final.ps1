# Deploy simples final
Write-Host "Deploy simples final..." -ForegroundColor Green

# Credenciais FTP
$FtpHost = "ftp.code-iq.com.br"
$FtpUser = "u535869980.cursor"
$FtpPass = "F0rm@T1001"

# Usar FTP nativo do Windows
$ftpCommands = @"
open $FtpHost
$FtpUser
$FtpPass
binary
put "area-cliente-react-real.html" "area-cliente-app.html"
put "dist/favicon.svg" "favicon.svg"
cd assets
lcd "dist/assets"
mput *
quit
"@

$ftpCommands | Out-File -FilePath "ftp-commands.txt" -Encoding ASCII

Write-Host "Executando comandos FTP..." -ForegroundColor Yellow
ftp -s:ftp-commands.txt

Remove-Item "ftp-commands.txt"

Write-Host "Deploy simples concluido!" -ForegroundColor Green
Write-Host "Teste: https://code-iq.com.br/area-cliente-app.html" -ForegroundColor Yellow