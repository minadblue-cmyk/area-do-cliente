# Solucao Final - Deploy
Write-Host "Solucao Final - Deploy" -ForegroundColor Green

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

Write-Host "Fazendo deploy da solucao final..." -ForegroundColor Yellow

# 1. Upload index.html principal (React)
Upload-File "./dist/index.html" "/area-do-cliente/index.html"

# 2. Upload index-redirect.html como fallback
Upload-File "index-redirect.html" "/area-do-cliente/index-redirect.html"

# 3. Upload todos os assets
$assetsPath = "./dist/assets"
if (Test-Path $assetsPath) {
    $assetFiles = Get-ChildItem -Path $assetsPath -File
    foreach ($file in $assetFiles) {
        Upload-File $file.FullName "/area-do-cliente/assets/$($file.Name)"
    }
}

# 4. Upload outros arquivos
Upload-File "./dist/favicon.svg" "/area-do-cliente/favicon.svg"
Upload-File "./dist/vite.svg" "/area-do-cliente/vite.svg"

# 5. Criar .htaccess mais simples
$htaccessContent = @"
DirectoryIndex index.html
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . index.html [L]
"@

$htaccessContent | Out-File -FilePath ".htaccess" -Encoding UTF8
Upload-File ".htaccess" "/area-do-cliente/.htaccess"
Remove-Item ".htaccess" -Force -ErrorAction SilentlyContinue

Write-Host "Deploy da solucao final concluido!" -ForegroundColor Green
Write-Host "Teste: https://code-iq.com.br/area-do-cliente/" -ForegroundColor Cyan
Write-Host "Se nao funcionar, teste: https://code-iq.com.br/area-do-cliente/index.html" -ForegroundColor Yellow
