# Deploy Simples para Hostinger
Write-Host "🚀 Deploy para Hostinger - Área do Cliente" -ForegroundColor Green

# Verificar build
if (-not (Test-Path "./dist")) {
    Write-Host "❌ Build não encontrado. Executando build..." -ForegroundColor Yellow
    npm run build
}

Write-Host "✅ Build verificado!" -ForegroundColor Green

# Solicitar credenciais
Write-Host "`n📋 Informações da Hostinger:" -ForegroundColor Yellow
$FtpHost = Read-Host "Host FTP (ex: ftp.hostinger.com)"
$FtpUser = Read-Host "Usuário FTP"
$FtpPass = Read-Host "Senha FTP" -AsSecureString
$FtpPass = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($FtpPass))

$RemotePath = "/public_html/area-do-cliente/"

Write-Host "`n📤 Conectando à Hostinger..." -ForegroundColor Yellow

try {
    # Testar conexão
    $ftp = [System.Net.FtpWebRequest]::Create("ftp://$FtpHost$RemotePath")
    $ftp.Credentials = New-Object System.Net.NetworkCredential($FtpUser, $FtpPass)
    $ftp.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
    $response = $ftp.GetResponse()
    $response.Close()
    
    Write-Host "✅ Conexão estabelecida!" -ForegroundColor Green
    
    # Upload index.html
    Write-Host "📤 Enviando index.html..." -ForegroundColor Yellow
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
    
    Write-Host "✅ index.html enviado!" -ForegroundColor Green
    
    # Upload assets
    Write-Host "📦 Enviando pasta assets..." -ForegroundColor Yellow
    
    $assetsPath = "./dist/assets"
    if (Test-Path $assetsPath) {
        $assetFiles = Get-ChildItem -Path $assetsPath -File
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
            
            Write-Host "✅ $($file.Name)" -ForegroundColor Green
        }
    }
    
    # Upload outros arquivos
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
            
            Write-Host "✅ $file" -ForegroundColor Green
        }
    }
    
    Write-Host "`n🎉 Deploy concluído com sucesso!" -ForegroundColor Green
    Write-Host "🌐 Acesse: https://www.code-iq.com.br/area-do-cliente/" -ForegroundColor Cyan
    
}
catch {
    Write-Host "❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
}
