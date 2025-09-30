# Verificar arquivos no FTP
Write-Host "Verificando arquivos no servidor FTP..." -ForegroundColor Green

# Credenciais FTP
$FtpHost = "ftp.code-iq.com.br"
$FtpUser = "u535869980.cursor"
$FtpPass = "F0rm@T1001"

# Funcao para listar diretorio
function List-Directory {
    param($remotePath)
    
    try {
        $ftp = [System.Net.FtpWebRequest]::Create("ftp://$FtpHost$remotePath")
        $ftp.Credentials = New-Object System.Net.NetworkCredential($FtpUser, $FtpPass)
        $ftp.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
        $ftp.UsePassive = $true
        
        $response = $ftp.GetResponse()
        $stream = $response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $contents = $reader.ReadToEnd()
        $reader.Close()
        $response.Close()
        
        Write-Host "Conteudo do diretorio $remotePath :" -ForegroundColor Yellow
        Write-Host $contents -ForegroundColor Cyan
        return $true
    }
    catch {
        Write-Host "Erro ao listar $remotePath : $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Listar diretorio raiz
Write-Host "Listando diretorio raiz..." -ForegroundColor Yellow
List-Directory "/"

# Listar diretorio area-do-cliente
Write-Host "`nListando diretorio area-do-cliente..." -ForegroundColor Yellow
List-Directory "/area-do-cliente/"

# Listar diretorio assets
Write-Host "`nListando diretorio assets..." -ForegroundColor Yellow
List-Directory "/area-do-cliente/assets/"
