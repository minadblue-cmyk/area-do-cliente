# 🚀 Guia de Deploy - Área do Cliente

## 📋 Pré-requisitos

✅ **Projeto buildado com sucesso** - O build de produção foi gerado no diretório `dist/`  
✅ **Arquivos estáticos prontos** - Todos os assets foram compilados e otimizados  
✅ **Aplicação React/Vite** - Projeto moderno e otimizado para produção  

## 🎯 Opções de Deploy

### 1. **Deploy via FTP/SFTP (Recomendado para hospedagem tradicional)**

#### Passo 1: Preparar arquivos
```bash
# O build já está pronto em dist/
# Todos os arquivos necessários estão em:
dist/
├── index.html
├── favicon.svg
├── vite.svg
└── assets/
    ├── index-BAPDVwdl.css
    ├── index-DNiEnL8r.js
    └── [outros arquivos JS/CSS]
```

#### Passo 2: Upload via FTP
1. **Conecte-se ao seu servidor** via FTP/SFTP
2. **Navegue até** `www.code-iq.com.br/area-do-cliente/`
3. **Faça upload de TODOS os arquivos** do diretório `dist/` para o servidor
4. **Mantenha a estrutura de pastas** (especialmente a pasta `assets/`)

#### Passo 3: Configurar servidor web
Adicione estas regras no seu `.htaccess` (Apache) ou configuração do servidor:

```apache
# .htaccess para Apache
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
```

### 2. **Deploy via GitHub Pages (Gratuito)**

#### Passo 1: Configurar repositório
```bash
# Criar repositório no GitHub
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/seu-usuario/area-do-cliente.git
git push -u origin main
```

#### Passo 2: Configurar GitHub Pages
1. Vá em **Settings** > **Pages**
2. Selecione **Deploy from a branch**
3. Escolha **main** branch e pasta **/ (root)**
4. Configure o workflow para build automático

#### Passo 3: Criar workflow automático
Crie `.github/workflows/deploy.yml`:

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout
      uses: actions/checkout@v3
      
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
        
    - name: Install dependencies
      run: npm ci
      
    - name: Build
      run: npm run build
      
    - name: Deploy to GitHub Pages
      uses: peaceiris/actions-gh-pages@v3
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./dist
```

### 3. **Deploy via Vercel (Recomendado - Mais fácil)**

#### Passo 1: Instalar Vercel CLI
```bash
npm i -g vercel
```

#### Passo 2: Deploy
```bash
# No diretório do projeto
vercel

# Seguir as instruções:
# - Link to existing project? N
# - Project name: area-do-cliente
# - Directory: ./dist
# - Override settings? N
```

#### Passo 3: Configurar domínio personalizado
1. Acesse o dashboard da Vercel
2. Vá em **Settings** > **Domains**
3. Adicione `www.code-iq.com.br`
4. Configure os DNS conforme instruções

### 4. **Deploy via Netlify**

#### Passo 1: Build settings
- **Build command**: `npm run build`
- **Publish directory**: `dist`
- **Node version**: `18`

#### Passo 2: Deploy
1. Conecte seu repositório GitHub
2. Configure as opções acima
3. Deploy automático a cada push

## 🔧 Configurações Importantes

### Variáveis de Ambiente
Crie um arquivo `.env.production` se necessário:

```env
VITE_API_URL=https://api.code-iq.com.br
VITE_APP_NAME=Área do Cliente
```

### Configuração de Proxy (se necessário)
Se você tiver problemas de CORS, configure um proxy no `vite.config.ts`:

```typescript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      '/api': {
        target: 'https://sua-api.com',
        changeOrigin: true,
        secure: true
      }
    }
  }
})
```

## 🚨 Checklist de Deploy

### Antes do Deploy
- [ ] Build executado com sucesso (`npm run build`)
- [ ] Todos os arquivos em `dist/` estão corretos
- [ ] Teste local funcionando (`npm run preview`)
- [ ] Variáveis de ambiente configuradas
- [ ] URLs de API atualizadas para produção

### Após o Deploy
- [ ] Site carregando corretamente
- [ ] Todas as rotas funcionando (SPA)
- [ ] Assets carregando (CSS, JS, imagens)
- [ ] API calls funcionando
- [ ] HTTPS configurado
- [ ] Headers de segurança aplicados

## 🔍 Troubleshooting

### Problema: Página em branco
**Solução**: Verificar se todas as rotas redirecionam para `index.html`

### Problema: Assets não carregam
**Solução**: Verificar se a pasta `assets/` foi uploadada corretamente

### Problema: Erro 404 em rotas
**Solução**: Configurar rewrite rules para SPA

### Problema: CORS errors
**Solução**: Configurar proxy ou headers CORS no servidor

## 📞 Suporte

Se encontrar problemas:
1. Verifique os logs do servidor
2. Teste localmente primeiro
3. Verifique a configuração de DNS
4. Confirme que todos os arquivos foram uploadados

---

## 🎉 Próximos Passos

1. **Teste completo** - Acesse todas as funcionalidades
2. **Monitoramento** - Configure logs e analytics
3. **Backup** - Mantenha backup dos arquivos de build
4. **Atualizações** - Configure deploy automático para futuras atualizações

**URL final**: `https://www.code-iq.com.br/area-do-cliente/`

---

*Deploy realizado com sucesso! 🚀*
