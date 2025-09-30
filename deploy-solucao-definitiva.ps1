# Solucao Definitiva
Write-Host "Solucao Definitiva - Deploy" -ForegroundColor Green

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

Write-Host "Fazendo deploy da solucao definitiva..." -ForegroundColor Yellow

# 1. Restaurar site original
Write-Host "Restaurando site original..." -ForegroundColor Yellow
Upload-File "C:\Users\rmace\Downloads\code-iq-starter-site-v6\index.html" "/index.html"

# 2. Upload aplicacao React como area-cliente-app.html
Write-Host "Enviando aplicacao React..." -ForegroundColor Yellow
Upload-File "area-cliente-app.html" "/area-cliente-app.html"

# 3. Upload todos os assets
Write-Host "Enviando assets..." -ForegroundColor Yellow
$assetsPath = "./dist/assets"
if (Test-Path $assetsPath) {
    $assetFiles = Get-ChildItem -Path $assetsPath -File
    foreach ($file in $assetFiles) {
        Upload-File $file.FullName "/assets/$($file.Name)"
    }
}

# 4. Upload outros arquivos
Upload-File "./dist/favicon.svg" "/favicon.svg"
Upload-File "./dist/vite.svg" "/vite.svg"

# 5. Atualizar link no menu principal
Write-Host "Atualizando menu principal..." -ForegroundColor Yellow
$menuContent = Get-Content "C:\Users\rmace\Downloads\code-iq-starter-site-v6\index.html" -Raw
$menuContent = $menuContent -replace 'href="/area-do-cliente.html"', 'href="/area-cliente-app.html"'
$menuContent | Out-File -FilePath "menu-atualizado.html" -Encoding UTF8
Upload-File "menu-atualizado.html" "/index.html"
Remove-Item "menu-atualizado.html" -Force -ErrorAction SilentlyContinue

Write-Host "Solucao definitiva implementada!" -ForegroundColor Green
Write-Host "Site original: https://code-iq.com.br/" -ForegroundColor Cyan
Write-Host "Area do Cliente: https://code-iq.com.br/area-cliente-app.html" -ForegroundColor Yellow
