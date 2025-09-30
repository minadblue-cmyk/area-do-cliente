# Corrigir .htaccess para funcionar corretamente
Write-Host "Corrigindo .htaccess..." -ForegroundColor Green

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

# Criar .htaccess corrigido
$htaccessContent = @"
RewriteEngine On
RewriteBase /area-do-cliente/

# Handle client-side routing - redirect all requests to index.html
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ /area-do-cliente/index.html [L,QSA]

# Cache static assets
<FilesMatch "\.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$">
    ExpiresActive On
    ExpiresDefault "access plus 1 year"
    Header set Cache-Control "public, immutable"
</FilesMatch>

# Security headers
Header always set X-Content-Type-Options nosniff
Header always set X-Frame-Options DENY
Header always set X-XSS-Protection "1; mode=block"

# Enable compression
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/plain
    AddOutputFilterByType DEFLATE text/html
    AddOutputFilterByType DEFLATE text/xml
    AddOutputFilterByType DEFLATE text/css
    AddOutputFilterByType DEFLATE application/xml
    AddOutputFilterByType DEFLATE application/xhtml+xml
    AddOutputFilterByType DEFLATE application/rss+xml
    AddOutputFilterByType DEFLATE application/javascript
    AddOutputFilterByType DEFLATE application/x-javascript
</IfModule>
"@

$htaccessPath = "htaccess-corrigido.txt"
$htaccessContent | Out-File -FilePath $htaccessPath -Encoding UTF8

Write-Host "Enviando .htaccess corrigido..." -ForegroundColor Yellow
Upload-File $htaccessPath "/area-do-cliente/.htaccess"

# Tambem enviar para o diretorio raiz
Write-Host "Enviando .htaccess para diretorio raiz..." -ForegroundColor Yellow
Upload-File $htaccessPath "/.htaccess"

Remove-Item $htaccessPath

Write-Host ".htaccess corrigido!" -ForegroundColor Green
Write-Host "Teste: https://code-iq.com.br/area-do-cliente/" -ForegroundColor Yellow
