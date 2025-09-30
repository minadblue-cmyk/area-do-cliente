# Deploy para Corrigir Assets
Write-Host "Corrigindo Assets - Hostinger" -ForegroundColor Green

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

Write-Host "Reenviando assets..." -ForegroundColor Yellow

# Upload assets novamente
$assetsPath = "./dist/assets"
if (Test-Path $assetsPath) {
    $assetFiles = Get-ChildItem -Path $assetsPath -File
    $uploadCount = 0
    foreach ($file in $assetFiles) {
        if (Upload-File $file.FullName "/area-do-cliente/assets/" + $file.Name) {
            $uploadCount++
        }
    }
    Write-Host "Assets reenviados: $uploadCount/$($assetFiles.Count)" -ForegroundColor Green
}

# Upload index.html novamente
Write-Host "Reenviando index.html..." -ForegroundColor Yellow
Upload-File "./dist/index.html" "/area-do-cliente/index.html"

Write-Host "Correcao concluida!" -ForegroundColor Green
Write-Host "Teste: https://code-iq.com.br/area-do-cliente/" -ForegroundColor Cyan
