# Deletar todos os arquivos atuais
Write-Host "Deletando todos os arquivos atuais..." -ForegroundColor Red

# Credenciais FTP
$FtpHost = "ftp.code-iq.com.br"
$FtpUser = "u535869980.cursor"
$FtpPass = "F0rm@T1001"

# Funcao para deletar arquivo
function Delete-File {
    param($remoteFile)
    
    try {
        $ftp = [System.Net.FtpWebRequest]::Create("ftp://$FtpHost$remoteFile")
        $ftp.Credentials = New-Object System.Net.NetworkCredential($FtpUser, $FtpPass)
        $ftp.Method = [System.Net.WebRequestMethods+Ftp]::DeleteFile
        $ftp.UsePassive = $true
        
        $response = $ftp.GetResponse()
        $response.Close()
        
        Write-Host "Deletado: $remoteFile" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Erro ao deletar $remoteFile : $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Deletar arquivos
Delete-File "/area-cliente-app.html"
Delete-File "/area-do-cliente/index.html"
Delete-File "/area-do-cliente/.htaccess"

Write-Host "Arquivos deletados!" -ForegroundColor Green
