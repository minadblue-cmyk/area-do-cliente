# Deploy robusto usando metodo diferente
Write-Host "Deploy robusto da aplicacao React..." -ForegroundColor Green

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

Write-Host "Enviando aplicacao React com metodo robusto..." -ForegroundColor Yellow

# Upload index.html
Upload-File-WebClient "dist/index.html" "/area-cliente-app.html"

# Upload assets
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

Write-Host "Deploy robusto concluido!" -ForegroundColor Green
Write-Host "Teste: https://code-iq.com.br/area-cliente-app.html" -ForegroundColor Yellow
