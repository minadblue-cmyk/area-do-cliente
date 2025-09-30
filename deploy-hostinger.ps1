# Script de Deploy Automático para Hostinger
# Execute: .\deploy-hostinger.ps1

param(
    [string]$FtpHost = "",
    [string]$FtpUser = "",
    [string]$FtpPass = "",
    [string]$RemotePath = "/public_html/area-do-cliente/",
    [string]$LocalPath = "./dist/"
)

Write-Host "🚀 Deploy para Hostinger - Área do Cliente" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Cyan

# Verificar se o build existe
if (-not (Test-Path $LocalPath)) {
    Write-Host "❌ Diretório dist/ não encontrado. Executando build..." -ForegroundColor Yellow
    npm run build
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Erro no build. Verifique os erros acima." -ForegroundColor Red
        exit 1
    }
}

Write-Host "✅ Build verificado!" -ForegroundColor Green

# Verificar arquivos principais
$requiredFiles = @("index.html", "assets")
foreach ($file in $requiredFiles) {
    if (-not (Test-Path "$LocalPath$file")) {
        Write-Host "❌ Arquivo/pasta $file não encontrado em $LocalPath" -ForegroundColor Red
        exit 1
    }
}

Write-Host "✅ Arquivos principais verificados!" -ForegroundColor Green

# Solicitar credenciais se não fornecidas
if (-not $FtpHost) {
    Write-Host "`n📋 Informações da Hostinger:" -ForegroundColor Yellow
    $FtpHost = Read-Host "Digite o host FTP (ex: ftp.hostinger.com ou ftp.code-iq.com.br)"
}
if (-not $FtpUser) {
    $FtpUser = Read-Host "Digite o usuário FTP"
}
if (-not $FtpPass) {
    $FtpPass = Read-Host "Digite a senha FTP" -AsSecureString
    $FtpPass = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($FtpPass))
}

Write-Host "`n📤 Conectando à Hostinger..." -ForegroundColor Yellow

try {
    # Testar conexão FTP
    $ftp = [System.Net.FtpWebRequest]::Create("ftp://$FtpHost$RemotePath")
    $ftp.Credentials = New-Object System.Net.NetworkCredential($FtpUser, $FtpPass)
    $ftp.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
    
    $response = $ftp.GetResponse()
    $response.Close()
    
    Write-Host "✅ Conexão FTP estabelecida com sucesso!" -ForegroundColor Green
    
    # Função para upload de arquivo
    function Upload-File {
        param($localFile, $remoteFile)
        
        try {
            $ftp = [System.Net.FtpWebRequest]::Create("ftp://$FtpHost$RemotePath$remoteFile")
            $ftp.Credentials = New-Object System.Net.NetworkCredential($FtpUser, $FtpPass)
            $ftp.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
            $ftp.UseBinary = $true
            
            $fileContent = [System.IO.File]::ReadAllBytes($localFile)
            $ftp.ContentLength = $fileContent.Length
            
            $requestStream = $ftp.GetRequestStream()
            $requestStream.Write($fileContent, 0, $fileContent.Length)
            $requestStream.Close()
            
            $response = $ftp.GetResponse()
            $response.Close()
            
            Write-Host "✅ Upload: $remoteFile" -ForegroundColor Green
            return $true
        }
        catch {
            Write-Host "❌ Erro no upload de $remoteFile : $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    }
    
    # Função para criar diretório
    function Create-Directory {
        param($dirName)
        
        try {
            $ftp = [System.Net.FtpWebRequest]::Create("ftp://$FtpHost$RemotePath$dirName")
            $ftp.Credentials = New-Object System.Net.NetworkCredential($FtpUser, $FtpPass)
            $ftp.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory
            
            $response = $ftp.GetResponse()
            $response.Close()
            
            Write-Host "✅ Diretório criado: $dirName" -ForegroundColor Green
            return $true
        }
        catch {
            # Diretório pode já existir
            return $false
        }
    }
    
    Write-Host "`n📁 Criando estrutura de diretórios..." -ForegroundColor Yellow
    
    # Criar diretório assets se necessário
    Create-Directory "assets"
    
    Write-Host "`n📤 Fazendo upload dos arquivos..." -ForegroundColor Yellow
    
    # Upload index.html
    if (Upload-File "$LocalPath/index.html" "index.html") {
        Write-Host "✅ Página principal enviada!" -ForegroundColor Green
    }
    
    # Upload favicon.svg
    if (Test-Path "$LocalPath/favicon.svg") {
        Upload-File "$LocalPath/favicon.svg" "favicon.svg"
    }
    
    # Upload vite.svg
    if (Test-Path "$LocalPath/vite.svg") {
        Upload-File "$LocalPath/vite.svg" "vite.svg"
    }
    
    # Upload da pasta assets
    Write-Host "`n📦 Fazendo upload da pasta assets..." -ForegroundColor Yellow
    
    $assetsPath = "$LocalPath/assets"
    if (Test-Path $assetsPath) {
        $assetFiles = Get-ChildItem -Path $assetsPath -File
        $uploadCount = 0
        $totalFiles = $assetFiles.Count
        
        foreach ($file in $assetFiles) {
            if (Upload-File $file.FullName "assets/$($file.Name)") {
                $uploadCount++
            }
        }
        
        Write-Host "✅ Assets enviados: $uploadCount/$totalFiles arquivos" -ForegroundColor Green
    }
    
    # Criar arquivo .htaccess para SPA
    Write-Host "`n📝 Criando arquivo .htaccess..." -ForegroundColor Yellow
    
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

# Headers de segurança
Header always set X-Frame-Options DENY
Header always set X-Content-Type-Options nosniff
Header always set Referrer-Policy "strict-origin-when-cross-origin"

# Compressão GZIP
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
    
    # Salvar .htaccess localmente
    $htaccessContent | Out-File -FilePath ".htaccess" -Encoding UTF8
    
    # Upload do .htaccess
    if (Upload-File ".htaccess" ".htaccess") {
        Write-Host "✅ Arquivo .htaccess configurado!" -ForegroundColor Green
    }
    
    # Limpar arquivo temporário
    Remove-Item ".htaccess" -Force -ErrorAction SilentlyContinue
    
    Write-Host "`n🎉 Deploy concluído com sucesso!" -ForegroundColor Green
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "🌐 Acesse seu site em:" -ForegroundColor Yellow
    Write-Host "   https://www.code-iq.com.br/area-do-cliente/" -ForegroundColor White
    Write-Host "`n📋 Próximos passos:" -ForegroundColor Yellow
    Write-Host "   1. ✅ Teste o site no navegador" -ForegroundColor White
    Write-Host "   2. ✅ Verifique se todas as páginas carregam" -ForegroundColor White
    Write-Host "   3. ✅ Teste as funcionalidades principais" -ForegroundColor White
    Write-Host "   4. ✅ Verifique se as APIs estão funcionando" -ForegroundColor White
    
}
catch {
    Write-Host "`n❌ Erro na conexão FTP: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`n🔧 Verifique:" -ForegroundColor Yellow
    Write-Host "   - Host FTP correto" -ForegroundColor White
    Write-Host "   - Usuário e senha corretos" -ForegroundColor White
    Write-Host "   - Conexão com a internet" -ForegroundColor White
    Write-Host "   - Firewall não bloqueando FTP" -ForegroundColor White
    exit 1
}

Write-Host "`n🎯 Deploy finalizado!" -ForegroundColor Green
Write-Host "Seu site está no ar! 🚀" -ForegroundColor Cyan