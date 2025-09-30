# Deploy alternativo na raiz
Write-Host "Deploy alternativo na raiz do servidor..." -ForegroundColor Green

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

Write-Host "Criando versao alternativa na raiz..." -ForegroundColor Yellow

# Copiar index.html da aplicacao React para area-cliente-app.html
Copy-Item "dist/index.html" "area-cliente-app.html"

# Upload da aplicacao React como area-cliente-app.html
Upload-File "area-cliente-app.html" "/area-cliente-app.html"

# Upload todos os assets para a raiz
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

Write-Host "Aplicacao React enviada para raiz!" -ForegroundColor Green
Write-Host "Teste: https://code-iq.com.br/area-cliente-app.html" -ForegroundColor Yellow
