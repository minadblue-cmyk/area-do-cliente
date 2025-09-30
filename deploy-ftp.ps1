# Script de Deploy Automático via FTP
# Execute: .\deploy-ftp.ps1

param(
    [string]$FtpHost = "",
    [string]$FtpUser = "",
    [string]$FtpPass = "",
    [string]$RemotePath = "/area-do-cliente/",
    [string]$LocalPath = "./dist/"
)

Write-Host "🚀 Iniciando Deploy da Área do Cliente..." -ForegroundColor Green

# Verificar se o build existe
if (-not (Test-Path $LocalPath)) {
    Write-Host "❌ Diretório dist/ não encontrado. Execute 'npm run build' primeiro." -ForegroundColor Red
    exit 1
}

# Verificar se os arquivos principais existem
$requiredFiles = @("index.html", "assets")
foreach ($file in $requiredFiles) {
    if (-not (Test-Path "$LocalPath$file")) {
        Write-Host "❌ Arquivo/pasta $file não encontrado em $LocalPath" -ForegroundColor Red
        exit 1
    }
}

Write-Host "✅ Build verificado com sucesso!" -ForegroundColor Green

# Solicitar credenciais se não fornecidas
if (-not $FtpHost) {
    $FtpHost = Read-Host "Digite o host FTP (ex: ftp.code-iq.com.br)"
}
if (-not $FtpUser) {
    $FtpUser = Read-Host "Digite o usuário FTP"
}
if (-not $FtpPass) {
    $FtpPass = Read-Host "Digite a senha FTP" -AsSecureString
    $FtpPass = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($FtpPass))
}

Write-Host "📤 Conectando ao servidor FTP..." -ForegroundColor Yellow

try {
    # Criar conexão FTP
    $ftp = [System.Net.FtpWebRequest]::Create("ftp://$FtpHost$RemotePath")
    $ftp.Credentials = New-Object System.Net.NetworkCredential($FtpUser, $FtpPass)
    $ftp.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
    
    # Testar conexão
    $response = $ftp.GetResponse()
    $response.Close()
    
    Write-Host "✅ Conexão FTP estabelecida!" -ForegroundColor Green
    
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
        }
        catch {
            Write-Host "❌ Erro no upload de $remoteFile : $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    # Upload de arquivos principais
    Write-Host "📁 Fazendo upload dos arquivos..." -ForegroundColor Yellow
    
    # Upload index.html
    Upload-File "$LocalPath/index.html" "index.html"
    
    # Upload favicon.svg
    if (Test-Path "$LocalPath/favicon.svg") {
        Upload-File "$LocalPath/favicon.svg" "favicon.svg"
    }
    
    # Upload vite.svg
    if (Test-Path "$LocalPath/vite.svg") {
        Upload-File "$LocalPath/vite.svg" "vite.svg"
    }
    
    # Upload da pasta assets
    Write-Host "📦 Fazendo upload da pasta assets..." -ForegroundColor Yellow
    
    $assetsPath = "$LocalPath/assets"
    if (Test-Path $assetsPath) {
        $assetFiles = Get-ChildItem -Path $assetsPath -File
        foreach ($file in $assetFiles) {
            Upload-File $file.FullName "assets/$($file.Name)"
        }
    }
    
    Write-Host "🎉 Deploy concluído com sucesso!" -ForegroundColor Green
    Write-Host "🌐 Acesse: https://www.code-iq.com.br/area-do-cliente/" -ForegroundColor Cyan
    
    # Criar arquivo .htaccess
    Write-Host "📝 Criando arquivo .htaccess..." -ForegroundColor Yellow
    
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
"@
    
    # Salvar .htaccess localmente
    $htaccessContent | Out-File -FilePath ".htaccess" -Encoding UTF8
    
    # Upload do .htaccess
    Upload-File ".htaccess" ".htaccess"
    
    # Limpar arquivo temporário
    Remove-Item ".htaccess" -Force
    
    Write-Host "✅ Arquivo .htaccess configurado!" -ForegroundColor Green
    
}
catch {
    Write-Host "❌ Erro na conexão FTP: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n🎯 Deploy finalizado! Verifique o site em:" -ForegroundColor Cyan
Write-Host "   https://www.code-iq.com.br/area-do-cliente/" -ForegroundColor White
Write-Host "`n📋 Próximos passos:" -ForegroundColor Yellow
Write-Host "   1. Teste todas as funcionalidades" -ForegroundColor White
Write-Host "   2. Verifique se as APIs estão funcionando" -ForegroundColor White
Write-Host "   3. Configure monitoramento se necessário" -ForegroundColor White
