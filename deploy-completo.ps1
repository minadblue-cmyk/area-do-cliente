# Deploy Completo para Hostinger
Write-Host "Deploy Completo para Hostinger - Area do Cliente" -ForegroundColor Green

# Credenciais FTP
$FtpHost = "195.200.3.228"
$FtpUser = "u535869980"
$FtpPass = "F0rm@T1001"
$RemotePath = "/public_html/area-do-cliente/"

# Verificar build
if (-not (Test-Path "./dist")) {
    Write-Host "Build nao encontrado. Executando build..." -ForegroundColor Yellow
    npm run build
}

Write-Host "Build verificado!" -ForegroundColor Green

Write-Host "Conectando a Hostinger..." -ForegroundColor Yellow

try {
    # Testar conexao com diretorio raiz
    $ftp = [System.Net.FtpWebRequest]::Create("ftp://$FtpHost/public_html/")
    $ftp.Credentials = New-Object System.Net.NetworkCredential($FtpUser, $FtpPass)
    $ftp.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
    $response = $ftp.GetResponse()
    $response.Close()
    
    Write-Host "Conexao estabelecida!" -ForegroundColor Green
    
    # Criar diretorio area-do-cliente
    Write-Host "Criando diretorio area-do-cliente..." -ForegroundColor Yellow
    $ftp = [System.Net.FtpWebRequest]::Create("ftp://$FtpHost/public_html/area-do-cliente/")
    $ftp.Credentials = New-Object System.Net.NetworkCredential($FtpUser, $FtpPass)
    $ftp.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory
    $ftp.GetResponse().Close()
    
    Write-Host "Diretorio criado!" -ForegroundColor Green
    
    # Upload index.html
    Write-Host "Enviando index.html..." -ForegroundColor Yellow
    $ftp = [System.Net.FtpWebRequest]::Create("ftp://$FtpHost$RemotePath" + "index.html")
    $ftp.Credentials = New-Object System.Net.NetworkCredential($FtpUser, $FtpPass)
    $ftp.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
    $ftp.UseBinary = $true
    
    $fileContent = [System.IO.File]::ReadAllBytes("./dist/index.html")
    $ftp.ContentLength = $fileContent.Length
    
    $requestStream = $ftp.GetRequestStream()
    $requestStream.Write($fileContent, 0, $fileContent.Length)
    $requestStream.Close()
    
    $response = $ftp.GetResponse()
    $response.Close()
    
    Write-Host "index.html enviado!" -ForegroundColor Green
    
    # Criar diretorio assets
    Write-Host "Criando diretorio assets..." -ForegroundColor Yellow
    $ftp = [System.Net.FtpWebRequest]::Create("ftp://$FtpHost$RemotePath" + "assets/")
    $ftp.Credentials = New-Object System.Net.NetworkCredential($FtpUser, $FtpPass)
    $ftp.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory
    $ftp.GetResponse().Close()
    
    # Upload assets
    Write-Host "Enviando pasta assets..." -ForegroundColor Yellow
    
    $assetsPath = "./dist/assets"
    if (Test-Path $assetsPath) {
        $assetFiles = Get-ChildItem -Path $assetsPath -File
        $uploadCount = 0
        foreach ($file in $assetFiles) {
            $ftp = [System.Net.FtpWebRequest]::Create("ftp://$FtpHost$RemotePath" + "assets/" + $file.Name)
            $ftp.Credentials = New-Object System.Net.NetworkCredential($FtpUser, $FtpPass)
            $ftp.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
            $ftp.UseBinary = $true
            
            $fileContent = [System.IO.File]::ReadAllBytes($file.FullName)
            $ftp.ContentLength = $fileContent.Length
            
            $requestStream = $ftp.GetRequestStream()
            $requestStream.Write($fileContent, 0, $fileContent.Length)
            $requestStream.Close()
            
            $response = $ftp.GetResponse()
            $response.Close()
            
            $uploadCount++
            Write-Host "Enviado: $($file.Name) ($uploadCount/$($assetFiles.Count))" -ForegroundColor Green
        }
    }
    
    # Upload outros arquivos
    Write-Host "Enviando outros arquivos..." -ForegroundColor Yellow
    $otherFiles = @("favicon.svg", "vite.svg")
    foreach ($file in $otherFiles) {
        if (Test-Path "./dist/$file") {
            $ftp = [System.Net.FtpWebRequest]::Create("ftp://$FtpHost$RemotePath" + $file)
            $ftp.Credentials = New-Object System.Net.NetworkCredential($FtpUser, $FtpPass)
            $ftp.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
            $ftp.UseBinary = $true
            
            $fileContent = [System.IO.File]::ReadAllBytes("./dist/$file")
            $ftp.ContentLength = $fileContent.Length
            
            $requestStream = $ftp.GetRequestStream()
            $requestStream.Write($fileContent, 0, $fileContent.Length)
            $requestStream.Close()
            
            $response = $ftp.GetResponse()
            $response.Close()
            
            Write-Host "Enviado: $file" -ForegroundColor Green
        }
    }
    
    # Criar arquivo .htaccess para SPA
    Write-Host "Criando arquivo .htaccess..." -ForegroundColor Yellow
    
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
    
    # Salvar .htaccess localmente
    $htaccessContent | Out-File -FilePath ".htaccess" -Encoding UTF8
    
    # Upload do .htaccess
    $ftp = [System.Net.FtpWebRequest]::Create("ftp://$FtpHost$RemotePath" + ".htaccess")
    $ftp.Credentials = New-Object System.Net.NetworkCredential($FtpUser, $FtpPass)
    $ftp.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
    $ftp.UseBinary = $true
    
    $fileContent = [System.IO.File]::ReadAllBytes(".htaccess")
    $ftp.ContentLength = $fileContent.Length
    
    $requestStream = $ftp.GetRequestStream()
    $requestStream.Write($fileContent, 0, $fileContent.Length)
    $requestStream.Close()
    
    $response = $ftp.GetResponse()
    $response.Close()
    
    # Limpar arquivo temporario
    Remove-Item ".htaccess" -Force -ErrorAction SilentlyContinue
    
    Write-Host ".htaccess enviado!" -ForegroundColor Green
    
    Write-Host "Deploy concluido com sucesso!" -ForegroundColor Green
    Write-Host "Acesse: https://code-iq.com.br/area-do-cliente/" -ForegroundColor Cyan
    Write-Host "A aplicacao React substituiu a pagina estatica!" -ForegroundColor Yellow
    
}
catch {
    Write-Host "Erro: $($_.Exception.Message)" -ForegroundColor Red
}
