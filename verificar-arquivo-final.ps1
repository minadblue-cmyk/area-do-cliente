# Verificar se o arquivo final foi enviado
Write-Host "Verificando se area-cliente-app.html existe..." -ForegroundColor Green

# Credenciais FTP
$FtpHost = "ftp.code-iq.com.br"
$FtpUser = "u535869980.cursor"
$FtpPass = "F0rm@T1001"

# Funcao para verificar se arquivo existe
function Test-FileExists {
    param($remoteFile)
    
    try {
        $ftp = [System.Net.FtpWebRequest]::Create("ftp://$FtpHost$remoteFile")
        $ftp.Credentials = New-Object System.Net.NetworkCredential($FtpUser, $FtpPass)
        $ftp.Method = [System.Net.WebRequestMethods+Ftp]::GetFileSize
        $ftp.UsePassive = $true
        
        $response = $ftp.GetResponse()
        $fileSize = $response.ContentLength
        $response.Close()
        
        Write-Host "Arquivo existe: $remoteFile (Tamanho: $fileSize bytes)" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Arquivo NAO existe: $remoteFile" -ForegroundColor Red
        return $false
    }
}

# Verificar arquivos
Test-FileExists "/area-cliente-app.html"
Test-FileExists "/assets/index-BtybfubG.js"
Test-FileExists "/assets/index-BAPDVwdl.css"
