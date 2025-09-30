# Deploy para Raiz do Site
Write-Host "Deploy para Raiz do Site - Hostinger" -ForegroundColor Green

# Credenciais FTP
$FtpHost = "195.200.3.228"
$FtpUser = "u535869980"
$FtpPass = "F0rm@T1001"

# Verificar build
if (-not (Test-Path "./dist")) {
    Write-Host "Build nao encontrado. Executando build..." -ForegroundColor Yellow
    npm run build
}

Write-Host "Build verificado!" -ForegroundColor Green

Write-Host "Conectando a Hostinger..." -ForegroundColor Yellow

try {
    # Testar conexao
    $ftp = [System.Net.FtpWebRequest]::Create("ftp://$FtpHost/")
    $ftp.Credentials = New-Object System.Net.NetworkCredential($FtpUser, $FtpPass)
    $ftp.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
    $response = $ftp.GetResponse()
    $response.Close()
    
    Write-Host "Conexao estabelecida!" -ForegroundColor Green
    
    # Upload index.html para public_html/ (raiz do site)
    Write-Host "Enviando index.html para raiz..." -ForegroundColor Yellow
    $ftp = [System.Net.FtpWebRequest]::Create("ftp://$FtpHost/public_html/index.html")
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
    
    Write-Host "index.html enviado para raiz!" -ForegroundColor Green
    
    # Upload assets para public_html/assets/
    Write-Host "Enviando pasta assets..." -ForegroundColor Yellow
    
    $assetsPath = "./dist/assets"
    if (Test-Path $assetsPath) {
        $assetFiles = Get-ChildItem -Path $assetsPath -File
        $uploadCount = 0
        foreach ($file in $assetFiles) {
            $ftp = [System.Net.FtpWebRequest]::Create("ftp://$FtpHost/public_html/assets/" + $file.Name)
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
            $ftp = [System.Net.FtpWebRequest]::Create("ftp://$FtpHost/public_html/" + $file)
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
    Write-Host "Acesse: https://code-iq.com.br/" -ForegroundColor Cyan
    Write-Host "A aplicacao React substituiu a pagina principal!" -ForegroundColor Yellow
    
}
catch {
    Write-Host "Erro: $($_.Exception.Message)" -ForegroundColor Red
}
