# Deploy da aplicacao React original
Write-Host "Deploy da aplicacao React original" -ForegroundColor Green

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

# Funcao para criar diretorio
function Create-Directory {
    param($remotePath)
    
    try {
        $ftp = [System.Net.FtpWebRequest]::Create("ftp://$FtpHost$remotePath")
        $ftp.Credentials = New-Object System.Net.NetworkCredential($FtpUser, $FtpPass)
        $ftp.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory
        $ftp.UsePassive = $true
        
        $response = $ftp.GetResponse()
        $response.Close()
        
        Write-Host "Diretorio criado: $remotePath" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Erro ao criar diretorio $remotePath : $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

Write-Host "Criando diretorio /area-do-cliente/..." -ForegroundColor Yellow
Create-Directory "/area-do-cliente/"

Write-Host "Enviando arquivos da aplicacao React original..." -ForegroundColor Yellow

# Upload index.html
Upload-File "dist/index.html" "/area-do-cliente/index.html"

# Upload todos os assets
$assetsPath = "dist/assets"
if (Test-Path $assetsPath) {
    $assets = Get-ChildItem -Path $assetsPath -File
    foreach ($asset in $assets) {
        $remotePath = "/area-do-cliente/assets/$($asset.Name)"
        Upload-File $asset.FullName $remotePath
    }
}

# Upload favicon.svg se existir
if (Test-Path "dist/favicon.svg") {
    Upload-File "dist/favicon.svg" "/area-do-cliente/favicon.svg"
}

# Criar .htaccess para SPA
$htaccessContent = @"
RewriteEngine On
RewriteBase /area-do-cliente/

# Handle client-side routing
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /area-do-cliente/index.html [L]

# Cache static assets
<FilesMatch "\.(css|js|png|jpg|jpeg|gif|ico|svg)$">
    ExpiresActive On
    ExpiresDefault "access plus 1 year"
    Header set Cache-Control "public, immutable"
</FilesMatch>

# Security headers
Header always set X-Content-Type-Options nosniff
Header always set X-Frame-Options DENY
Header always set X-XSS-Protection "1; mode=block"
"@

$htaccessPath = "temp.htaccess"
$htaccessContent | Out-File -FilePath $htaccessPath -Encoding UTF8
Upload-File $htaccessPath "/area-do-cliente/.htaccess"
Remove-Item $htaccessPath

Write-Host "Aplicacao React original enviada!" -ForegroundColor Green
Write-Host "Teste: https://code-iq.com.br/area-do-cliente/" -ForegroundColor Yellow
