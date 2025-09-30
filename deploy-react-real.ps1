# Deploy da aplicacao React REAL que desenvolvemos localmente
Write-Host "Deploy da aplicacao React REAL..." -ForegroundColor Green

# Credenciais FTP
$FtpHost = "ftp.code-iq.com.br"
$FtpUser = "u535869980.cursor"
$FtpPass = "F0rm@T1001"

# Funcao para upload de arquivo
function Upload-File {
    param($localFile, $remoteFile)
    
    try {
        $ftp = [System.Net.FtpWebRequest]::Create("ftp://$FtpHost$remoteFile")
        $ftp.Credentials = New-Object System.Net.NetworkCredential($FtpUser, $FtpPass)
        $ftp.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
        $ftp.UseBinary = $true
        $ftp.UsePassive = $true
        
        $fileContent = [System.IO.File]::ReadAllBytes($localFile)
        $ftp.ContentLength = $fileContent.Length
        
        $requestStream = $ftp.GetRequestStream()
        $requestStream.Write($fileContent, 0, $fileContent.Length)
        $requestStream.Close()
        
        $response = $ftp.GetResponse()
        $response.Close()
        
        Write-Host "Enviado: $remoteFile" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Erro ao enviar $remoteFile : $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

Write-Host "Enviando aplicacao React REAL..." -ForegroundColor Yellow

# Upload index.html da aplicacao React real
Upload-File "dist/index.html" "/area-cliente-app.html"

# Upload todos os assets
$assetsPath = "dist/assets"
if (Test-Path $assetsPath) {
    $assets = Get-ChildItem -Path $assetsPath -File
    foreach ($asset in $assets) {
        $remotePath = "/assets/$($asset.Name)"
        Upload-File $asset.FullName $remotePath
    }
}

# Upload favicon.svg se existir
if (Test-Path "dist/favicon.svg") {
    Upload-File "dist/favicon.svg" "/favicon.svg"
}

Write-Host "Aplicacao React REAL enviada!" -ForegroundColor Green
Write-Host "Agora voce tem o projeto completo que desenvolvemos localmente!" -ForegroundColor Cyan
Write-Host "Teste: https://code-iq.com.br/area-cliente-app.html" -ForegroundColor Yellow
