# Deploy FTP Final para Hostinger
Write-Host "Deploy FTP Final para Hostinger - Area do Cliente" -ForegroundColor Green

# Credenciais FTP corretas
$FtpHost = "ftp.code-iq.com.br"
$FtpUser = "u535869980.cursor"
$FtpPass = "F0rm@T1001"
$RemotePath = "/area-do-cliente/"

# Verificar build
if (-not (Test-Path "./dist")) {
    Write-Host "Build nao encontrado. Executando build..." -ForegroundColor Yellow
    npm run build
}

Write-Host "Build verificado!" -ForegroundColor Green

Write-Host "Conectando a Hostinger via FTP..." -ForegroundColor Yellow

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
    param($dirName)
    
    try {
        $ftp = [System.Net.FtpWebRequest]::Create("ftp://$FtpHost$dirName")
        $ftp.Credentials = New-Object System.Net.NetworkCredential($FtpUser, $FtpPass)
        $ftp.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory
        $ftp.UsePassive = $true
        
        $response = $ftp.GetResponse()
        $response.Close()
        
        Write-Host "Diretorio criado: $dirName" -ForegroundColor Green
        return $true
    }
    catch {
        # Diretorio pode ja existir
        return $false
    }
}

try {
    # Criar diretorio area-do-cliente
    Write-Host "Criando diretorio area-do-cliente..." -ForegroundColor Yellow
    Create-Directory $RemotePath
    
    # Criar diretorio assets
    Write-Host "Criando diretorio assets..." -ForegroundColor Yellow
    Create-Directory ($RemotePath + "assets/")
    
    # Upload index.html
    Write-Host "Enviando index.html..." -ForegroundColor Yellow
    Upload-File "./dist/index.html" ($RemotePath + "index.html")
    
    # Upload favicon.svg
    if (Test-Path "./dist/favicon.svg") {
        Upload-File "./dist/favicon.svg" ($RemotePath + "favicon.svg")
    }
    
    # Upload vite.svg
    if (Test-Path "./dist/vite.svg") {
        Upload-File "./dist/vite.svg" ($RemotePath + "vite.svg")
    }
    
    # Upload assets
    Write-Host "Enviando pasta assets..." -ForegroundColor Yellow
    $assetsPath = "./dist/assets"
    if (Test-Path $assetsPath) {
        $assetFiles = Get-ChildItem -Path $assetsPath -File
        $uploadCount = 0
        foreach ($file in $assetFiles) {
            if (Upload-File $file.FullName ($RemotePath + "assets/" + $file.Name)) {
                $uploadCount++
            }
        }
        Write-Host "Assets enviados: $uploadCount/$($assetFiles.Count)" -ForegroundColor Green
    }
    
    # Criar arquivo .htaccess
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
    Upload-File ".htaccess" ($RemotePath + ".htaccess")
    
    # Limpar arquivo temporario
    Remove-Item ".htaccess" -Force -ErrorAction SilentlyContinue
    
    Write-Host "Deploy concluido com sucesso!" -ForegroundColor Green
    Write-Host "Acesse: https://code-iq.com.br/area-do-cliente/" -ForegroundColor Cyan
    Write-Host "A aplicacao React esta no ar!" -ForegroundColor Yellow
    
}
catch {
    Write-Host "Erro geral: $($_.Exception.Message)" -ForegroundColor Red
}
