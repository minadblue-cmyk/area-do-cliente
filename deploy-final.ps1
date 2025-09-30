# Deploy Final para Hostinger
Write-Host "Deploy Final para Hostinger - Area do Cliente" -ForegroundColor Green

# Credenciais FTP
$FtpHost = "195.200.3.228"
$FtpUser = "u535869980"
$FtpPass = "F0rm@T1001"

# Verificar build
if (-not (Test-Path "./dist")) {
    Write-Host "Build nao encontrado. Executando build..." -ForegroundColor Yellow
    npm run build
}

Write-Host "Build verificado!" -ForegroundColor Green

Write-Host "Conectando a Hostinger..." -ForegroundColor Yellow

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

try {
    # Upload index.html
    Write-Host "Enviando index.html..." -ForegroundColor Yellow
    Upload-File "./dist/index.html" "/public_html/area-do-cliente/index.html"
    
    # Upload favicon.svg
    if (Test-Path "./dist/favicon.svg") {
        Upload-File "./dist/favicon.svg" "/public_html/area-do-cliente/favicon.svg"
    }
    
    # Upload vite.svg
    if (Test-Path "./dist/vite.svg") {
        Upload-File "./dist/vite.svg" "/public_html/area-do-cliente/vite.svg"
    }
    
    # Upload assets
    Write-Host "Enviando pasta assets..." -ForegroundColor Yellow
    $assetsPath = "./dist/assets"
    if (Test-Path $assetsPath) {
        $assetFiles = Get-ChildItem -Path $assetsPath -File
        $uploadCount = 0
        foreach ($file in $assetFiles) {
            if (Upload-File $file.FullName "/public_html/area-do-cliente/assets/$($file.Name)") {
                $uploadCount++
            }
        }
        Write-Host "Assets enviados: $uploadCount/$($assetFiles.Count)" -ForegroundColor Green
    }
    
    Write-Host "Deploy concluido!" -ForegroundColor Green
    Write-Host "Acesse: https://code-iq.com.br/area-do-cliente/" -ForegroundColor Cyan
    
}
catch {
    Write-Host "Erro geral: $($_.Exception.Message)" -ForegroundColor Red
}
