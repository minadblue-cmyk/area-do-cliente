# Deploy na Raiz - Alternativa
Write-Host "Deploy na Raiz - Alternativa" -ForegroundColor Green

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

Write-Host "Fazendo backup do index.html atual..." -ForegroundColor Yellow

# Backup do index.html atual
Upload-File "C:\Users\rmace\Downloads\code-iq-starter-site-v6\index.html" "/index-backup.html"

Write-Host "Fazendo deploy da aplicacao React na raiz..." -ForegroundColor Yellow

# Upload da aplicacao React na raiz
Upload-File "./dist/index.html" "/index.html"

# Upload assets na raiz
$assetsPath = "./dist/assets"
if (Test-Path $assetsPath) {
    $assetFiles = Get-ChildItem -Path $assetsPath -File
    foreach ($file in $assetFiles) {
        Upload-File $file.FullName "/assets/$($file.Name)"
    }
}

# Upload outros arquivos
Upload-File "./dist/favicon.svg" "/favicon.svg"
Upload-File "./dist/vite.svg" "/vite.svg"

Write-Host "Deploy na raiz concluido!" -ForegroundColor Green
Write-Host "Teste: https://code-iq.com.br/" -ForegroundColor Cyan
Write-Host "A aplicacao React agora esta na raiz do site!" -ForegroundColor Yellow
