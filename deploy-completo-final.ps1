# Deploy Completo Final
Write-Host "Deploy Completo Final - Hostinger" -ForegroundColor Green

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

Write-Host "Fazendo deploy completo..." -ForegroundColor Yellow

# Upload index.html
Write-Host "Enviando index.html..." -ForegroundColor Yellow
Upload-File "./dist/index.html" "/area-do-cliente/index.html"

# Upload favicon.svg
if (Test-Path "./dist/favicon.svg") {
    Upload-File "./dist/favicon.svg" "/area-do-cliente/favicon.svg"
}

# Upload vite.svg
if (Test-Path "./dist/vite.svg") {
    Upload-File "./dist/vite.svg" "/area-do-cliente/vite.svg"
}

# Upload assets
Write-Host "Enviando assets..." -ForegroundColor Yellow
$assetsPath = "./dist/assets"
if (Test-Path $assetsPath) {
    $assetFiles = Get-ChildItem -Path $assetsPath -File
    $uploadCount = 0
    foreach ($file in $assetFiles) {
        if (Upload-File $file.FullName "/area-do-cliente/assets/$($file.Name)") {
            $uploadCount++
        }
    }
    Write-Host "Assets enviados: $uploadCount/$($assetFiles.Count)" -ForegroundColor Green
}

# Criar .htaccess
Write-Host "Criando .htaccess..." -ForegroundColor Yellow
$htaccessContent = @"
RewriteEngine On

# Redirecionar todas as rotas para index.html (SPA)
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /area-do-cliente/index.html [L]

# Headers de cache para assets
<FilesMatch "\.(js|css|png|jpg|jpeg|gif|ico|svg)$">
    ExpiresActive On
    ExpiresDefault "access plus 1 year"
    Header set Cache-Control "public, immutable"
</FilesMatch>

# Headers de seguranca
Header always set X-Frame-Options DENY
Header always set X-Content-Type-Options nosniff
Header always set Referrer-Policy "strict-origin-when-cross-origin"
"@

$htaccessContent | Out-File -FilePath ".htaccess" -Encoding UTF8
Upload-File ".htaccess" "/area-do-cliente/.htaccess"
Remove-Item ".htaccess" -Force -ErrorAction SilentlyContinue

Write-Host "Deploy completo finalizado!" -ForegroundColor Green
Write-Host "Teste: https://code-iq.com.br/area-do-cliente/" -ForegroundColor Cyan
