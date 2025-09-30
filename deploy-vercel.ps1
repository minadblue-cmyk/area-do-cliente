# Deploy para Vercel
Write-Host "Deploy para Vercel..." -ForegroundColor Green

# Instalar Vercel CLI se nao estiver instalado
if (!(Get-Command "vercel" -ErrorAction SilentlyContinue)) {
    Write-Host "Instalando Vercel CLI..." -ForegroundColor Yellow
    npm install -g vercel
}

# Fazer login no Vercel
Write-Host "Fazendo login no Vercel..." -ForegroundColor Yellow
vercel login

# Deploy
Write-Host "Fazendo deploy..." -ForegroundColor Yellow
vercel --prod

Write-Host "Deploy para Vercel concluido!" -ForegroundColor Green