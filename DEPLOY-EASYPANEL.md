# 🚀 Deploy da Aplicação React via EasyPanel

## 📋 **Pré-requisitos:**

- ✅ EasyPanel instalado no VPS
- ✅ Acesso ao painel: http://212.85.12.183:3000 (ou porta configurada)
- ✅ Repositório Git (GitHub/GitLab) com o projeto

## 🎯 **Método 1: Deploy via GitHub (Recomendado)**

### **Passo 1: Criar Repositório GitHub**

1. Crie um repositório no GitHub: `area-do-cliente`
2. Faça push do projeto:

```bash
# No seu computador local (PowerShell)
cd C:\Users\rmace\area-do-cliente
git init
git add .
git commit -m "Initial commit - Área do Cliente"
git branch -M main
git remote add origin https://github.com/SEU-USUARIO/area-do-cliente.git
git push -u origin main
```

### **Passo 2: Configurar no EasyPanel**

1. **Acesse o EasyPanel**: http://212.85.12.183:3000
2. **Clique em "Create Service"** ou "New App"
3. **Configure:**
   - **Name**: `area-cliente`
   - **Type**: `Git Repository`
   - **Repository URL**: `https://github.com/SEU-USUARIO/area-do-cliente.git`
   - **Branch**: `main`
   - **Build Command**: `npm install && npm run build`
   - **Start Command**: Deixe vazio (usará Nginx do Dockerfile)

4. **Environment**:
   - **Port**: `80` (interno)
   - **Exposed Port**: `3001` (externo)

5. **Domains**:
   - Adicione: `area-cliente.212.85.12.183.nip.io` (ou seu domínio customizado)

6. **Deploy**:
   - Clique em "Deploy"
   - Aguarde o build terminar

---

## 🎯 **Método 2: Deploy via Docker Compose (Direto)**

### **Passo 1: No EasyPanel**

1. **Acesse o EasyPanel**
2. **Clique em "Create Service"**
3. **Selecione "Docker Compose"**
4. **Cole o conteúdo abaixo:**

```yaml
version: '3.8'

services:
  app:
    image: area-cliente-app:latest
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "3001:80"
    volumes:
      - area-cliente-data:/data
      - area-cliente-logs:/var/log/nginx
    restart: unless-stopped
    environment:
      - TZ=America/Sao_Paulo
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost/health"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 10s

volumes:
  area-cliente-data:
  area-cliente-logs:
```

5. **Clique em "Deploy"**

---

## 🎯 **Método 3: Upload Manual via EasyPanel**

### **Passo 1: Criar arquivo ZIP**

No seu computador (PowerShell):

```powershell
# Criar ZIP com arquivos necessários
$files = @(
    "Dockerfile",
    "docker-compose.yml",
    "nginx.conf",
    ".dockerignore",
    "package.json",
    "package-lock.json",
    "tsconfig.json",
    "vite.config.ts",
    "index.html"
)

Compress-Archive -Path src, public, $files -DestinationPath area-cliente-easypanel.zip
```

### **Passo 2: Upload no EasyPanel**

1. **Acesse o EasyPanel**
2. **Vá para File Manager**
3. **Faça upload do ZIP**
4. **Extraia o arquivo**
5. **Crie novo serviço apontando para o diretório**

---

## 📊 **Configurações Importantes no EasyPanel**

### **Environment Variables:**
```
TZ=America/Sao_Paulo
NODE_ENV=production
```

### **Volumes Persistentes:**
- `/data` → Dados da aplicação
- `/var/log/nginx` → Logs

### **Port Mapping:**
- Container Port: `80`
- Host Port: `3001`

### **Health Check:**
- Endpoint: `/health`
- Interval: `30s`
- Timeout: `3s`

### **Restart Policy:**
- `unless-stopped`

---

## 🔄 **Deploy Automático (CI/CD)**

### **Via GitHub Actions:**

Crie `.github/workflows/deploy.yml`:

```yaml
name: Deploy to EasyPanel

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to EasyPanel
        env:
          EASYPANEL_TOKEN: ${{ secrets.EASYPANEL_TOKEN }}
          EASYPANEL_URL: http://212.85.12.183:3000
        run: |
          curl -X POST $EASYPANEL_URL/api/deploy \
            -H "Authorization: Bearer $EASYPANEL_TOKEN" \
            -H "Content-Type: application/json" \
            -d '{"service": "area-cliente", "branch": "main"}'
```

---

## 🧪 **Teste Após Deploy:**

1. **EasyPanel Dashboard**: http://212.85.12.183:3000
2. **Aplicação**: http://212.85.12.183:3001
3. **Health Check**: http://212.85.12.183:3001/health
4. **Hostinger**: https://code-iq.com.br/area-do-cliente.html

---

## 🚨 **Troubleshooting:**

### **Build falha:**
- Verifique logs no EasyPanel
- Confira `Dockerfile` e `package.json`
- Certifique-se que `npm run build` funciona localmente

### **Container não inicia:**
- Verifique port mapping
- Confira health check
- Revise environment variables

### **Porta já em uso:**
- Pare o container manual: `docker stop area-cliente-app`
- Remova: `docker rm area-cliente-app`

---

## 📋 **Próximos Passos:**

1. ✅ **Escolher método de deploy** (GitHub, Docker Compose ou Manual)
2. ✅ **Configurar no EasyPanel**
3. ✅ **Fazer deploy**
4. ✅ **Testar aplicação**
5. ✅ **Configurar domínio customizado** (opcional)
6. ✅ **Configurar SSL** (opcional)

---

**🎉 Após configurar no EasyPanel, você terá gerenciamento visual completo da aplicação!**
