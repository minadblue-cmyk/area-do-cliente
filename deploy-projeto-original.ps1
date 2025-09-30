# Deploy do projeto React ORIGINAL que desenvolvemos localmente
Write-Host "Deploy do projeto React ORIGINAL..." -ForegroundColor Green

# Credenciais FTP
$FtpHost = "ftp.code-iq.com.br"
$FtpUser = "u535869980.cursor"
$FtpPass = "F0rm@T1001"

# Funcao para upload usando WebClient
function Upload-File-WebClient {
    param($localFile, $remoteFile)
    
    try {
        $uri = "ftp://$FtpHost$remoteFile"
        $webClient = New-Object System.Net.WebClient
        $webClient.Credentials = New-Object System.Net.NetworkCredential($FtpUser, $FtpPass)
        
        $webClient.UploadFile($uri, $localFile)
        $webClient.Dispose()
        
        Write-Host "Enviado: $remoteFile" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Erro ao enviar $remoteFile : $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

Write-Host "Enviando projeto React ORIGINAL..." -ForegroundColor Yellow

# Upload index.html do projeto original
Upload-File-WebClient "dist/index.html" "/area-cliente-app.html"

# Upload todos os assets
$assetsPath = "dist/assets"
if (Test-Path $assetsPath) {
    $assets = Get-ChildItem -Path $assetsPath -File
    foreach ($asset in $assets) {
        $remotePath = "/assets/$($asset.Name)"
        Upload-File-WebClient $asset.FullName $remotePath
    }
}

# Upload favicon
if (Test-Path "dist/favicon.svg") {
    Upload-File-WebClient "dist/favicon.svg" "/favicon.svg"
}

Write-Host "Projeto React ORIGINAL enviado!" -ForegroundColor Green
Write-Host "Agora voce tem o projeto real que desenvolvemos localmente!" -ForegroundColor Cyan
Write-Host "Teste: https://code-iq.com.br/area-cliente-app.html" -ForegroundColor Yellow
