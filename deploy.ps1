# Deploy para Hostinger
Write-Host "Deploy para Hostinger - Area do Cliente" -ForegroundColor Green

# Verificar build
if (-not (Test-Path "./dist")) {
    Write-Host "Build nao encontrado. Executando build..." -ForegroundColor Yellow
    npm run build
}

Write-Host "Build verificado!" -ForegroundColor Green

# Solicitar credenciais
Write-Host "Informacoes da Hostinger:" -ForegroundColor Yellow
$FtpHost = Read-Host "Host FTP"
$FtpUser = Read-Host "Usuario FTP"
$FtpPass = Read-Host "Senha FTP" -AsSecureString
$FtpPass = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($FtpPass))

$RemotePath = "/public_html/area-do-cliente/"

Write-Host "Conectando a Hostinger..." -ForegroundColor Yellow

try {
    # Testar conexao
    $ftp = [System.Net.FtpWebRequest]::Create("ftp://$FtpHost$RemotePath")
    $ftp.Credentials = New-Object System.Net.NetworkCredential($FtpUser, $FtpPass)
    $ftp.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
    $response = $ftp.GetResponse()
    $response.Close()
    
    Write-Host "Conexao estabelecida!" -ForegroundColor Green
    
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
    
    # Upload assets
    Write-Host "Enviando pasta assets..." -ForegroundColor Yellow
    
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
            
            Write-Host "Enviado: $($file.Name)" -ForegroundColor Green
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
            
            Write-Host "Enviado: $file" -ForegroundColor Green
        }
    }
    
    Write-Host "Deploy concluido com sucesso!" -ForegroundColor Green
    Write-Host "Acesse: https://www.code-iq.com.br/area-do-cliente/" -ForegroundColor Cyan
    
}
catch {
    Write-Host "Erro: $($_.Exception.Message)" -ForegroundColor Red
}
