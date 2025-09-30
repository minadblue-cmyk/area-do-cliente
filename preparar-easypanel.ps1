# Script para preparar projeto para EasyPanel
Write-Host "=== PREPARANDO PROJETO PARA EASYPANEL ==="
Write-Host ""

# Verificar se Git está instalado
$gitInstalled = Get-Command git -ErrorAction SilentlyContinue

if (-not $gitInstalled) {
    Write-Host "❌ Git não encontrado. Instalando..."
    winget install Git.Git -y
    Write-Host "✅ Git instalado. Reinicie o terminal e execute novamente."
    exit 0
}

Write-Host "✅ Git encontrado"
Write-Host ""

# Verificar se já é um repositório Git
if (-not (Test-Path ".git")) {
    Write-Host "Inicializando repositório Git..."
    git init
    git branch -M main
    Write-Host "✅ Repositório Git inicializado"
} else {
    Write-Host "✅ Repositório Git já existe"
}

# Criar/Atualizar .gitignore
Write-Host ""
Write-Host "Criando .gitignore..."

$gitignore = @"
# Dependencies
node_modules
package-lock.json

# Build
dist
build
.cache

# Environment
.env
.env.local
.env.*.local

# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# OS
.DS_Store
Thumbs.db
*.swp
*.swo
*~

# IDE
.vscode
.idea
*.sublime-*

# Temp
*.tmp
*.temp
*.bak
.tmp

# Scripts PowerShell
*.ps1
!preparar-easypanel.ps1

# Arquivos de deploy local
*.zip
*.tar.gz
*.txt
area-*.html
deploy-*.ps1
upload-*.ps1
htaccess-*
teste-*.html
index-*.html
assets-cliente/

# Docker local (mantém apenas configs)
docker-compose.override.yml

# Markdown de instruções locais
INSTRUCOES_*.md
RESUMO_*.md
CORRECOES_*.md
"@

$gitignore | Out-File -FilePath ".gitignore" -Encoding UTF8
Write-Host "✅ .gitignore criado"

# Criar README para o repositório
Write-Host ""
Write-Host "Criando README.md..."

$readme = @"
# Área do Cliente - Code-IQ

Aplicação React para gerenciamento de clientes com autenticação, permissões e webhooks.

## 🚀 Deploy

Esta aplicação está configurada para deploy via EasyPanel com Docker.

### Pré-requisitos

- Node.js 20+
- Docker & Docker Compose

### Deploy Local

\`\`\`bash
npm install
npm run dev
\`\`\`

### Deploy via Docker

\`\`\`bash
docker compose build
docker compose up -d
\`\`\`

### Acesso

- **Produção**: http://212.85.12.183:3001
- **Hostinger**: https://code-iq.com.br/area-do-cliente.html

## 📋 Estrutura

- \`/src\` - Código fonte React/TypeScript
- \`/public\` - Assets estáticos
- \`Dockerfile\` - Build da aplicação
- \`docker-compose.yml\` - Orquestração
- \`nginx.conf\` - Configuração Nginx

## 🔧 Tecnologias

- React 18
- TypeScript
- Vite
- React Router
- Axios
- Tailwind CSS (ou seu framework)
- Docker + Nginx
"@

$readme | Out-File -FilePath "README.md" -Encoding UTF8
Write-Host "✅ README.md criado"

# Adicionar arquivos ao Git
Write-Host ""
Write-Host "Adicionando arquivos ao Git..."
git add .

# Criar commit
Write-Host "Criando commit..."
git commit -m "feat: Configuração para deploy via EasyPanel com Docker

- Dockerfile multi-stage com build Node e runtime Nginx
- docker-compose.yml com volumes persistentes
- nginx.conf otimizado para SPA
- Health check endpoint
- Configuração de cache e compressão
- Security headers" -m "Deploy ready for EasyPanel"

Write-Host "✅ Commit criado"
Write-Host ""

Write-Host "📋 PRÓXIMOS PASSOS:"
Write-Host ""
Write-Host "1. Crie um repositório no GitHub:"
Write-Host "   https://github.com/new"
Write-Host "   Nome sugerido: area-do-cliente"
Write-Host ""
Write-Host "2. Execute os comandos:"
Write-Host "   git remote add origin https://github.com/SEU-USUARIO/area-do-cliente.git"
Write-Host "   git push -u origin main"
Write-Host ""
Write-Host "3. No EasyPanel (http://212.85.12.183:3000):"
Write-Host "   - Clique em 'Create Service'"
Write-Host "   - Escolha 'Git Repository'"
Write-Host "   - Cole a URL do repositório"
Write-Host "   - Configure porta 3001:80"
Write-Host "   - Clique em 'Deploy'"
Write-Host ""
Write-Host "✅ Projeto preparado para EasyPanel!"
