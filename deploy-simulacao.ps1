# Deploy da simulacao
Write-Host "Deploy da simulacao..." -ForegroundColor Green

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

Write-Host "Enviando simulacao..." -ForegroundColor Yellow

# Upload simulacao
Upload-File-WebClient "area-cliente-simulacao.html" "/area-cliente-app.html"

Write-Host "Simulacao enviada!" -ForegroundColor Green
Write-Host "Teste: https://code-iq.com.br/area-cliente-app.html" -ForegroundColor Yellow
