# Correcao Final
Write-Host "Corrigindo pagina principal e area do cliente" -ForegroundColor Green

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

Write-Host "1. Restaurando pagina principal com acentuacao correta..." -ForegroundColor Yellow
Upload-File "C:\Users\rmace\Downloads\code-iq-starter-site-v6\index.html" "/index.html"

Write-Host "2. Enviando aplicacao React..." -ForegroundColor Yellow
Upload-File "area-cliente-app.html" "/area-cliente-app.html"

Write-Host "3. Enviando assets..." -ForegroundColor Yellow
$assetsPath = "./dist/assets"
if (Test-Path $assetsPath) {
    $assetFiles = Get-ChildItem -Path $assetsPath -File
    foreach ($file in $assetFiles) {
        Upload-File $file.FullName "/assets/$($file.Name)"
    }
}

Write-Host "4. Enviando outros arquivos..." -ForegroundColor Yellow
Upload-File "./dist/favicon.svg" "/favicon.svg"
Upload-File "./dist/vite.svg" "/vite.svg"

Write-Host "Correcao finalizada!" -ForegroundColor Green
Write-Host "Site principal: https://code-iq.com.br/" -ForegroundColor Cyan
Write-Host "Area do Cliente: https://code-iq.com.br/area-cliente-app.html" -ForegroundColor Yellow
