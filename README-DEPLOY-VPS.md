# 🚀 Deploy da Aplicação React no VPS com Docker

## 📋 **Arquivos Criados:**

- ✅ `Dockerfile` - Build da aplicação React com Nginx
- ✅ `docker-compose.yml` - Orquestração do container com volumes persistentes
- ✅ `nginx.conf` - Configuração do Nginx para SPA
- ✅ `.dockerignore` - Arquivos excluídos do build
- ✅ `area-cliente-docker.tar.gz` - Projeto compactado (enviado para o VPS)

## 🔧 **Configurações Implementadas:**

### **Volumes Persistentes:**
- `area-cliente-data:/data` - Dados da aplicação
- `area-cliente-logs:/var/log/nginx` - Logs do Nginx

### **Recursos:**
- Health check endpoint: `/health`
- Compressão gzip
- Cache otimizado para assets estáticos
- SPA routing (fallback para index.html)
- Security headers
- Auto-restart em caso de falha

## 📌 **Deploy Manual no VPS:**

### **1. Conecte ao VPS via SSH:**
```bash
ssh root@212.85.12.183
# Senha: F0rm@T10011001
```

### **2. Extrair o arquivo:**
```bash
cd /root
mkdir -p /root/area-do-cliente-app
tar -xzf area-cliente-docker.tar.gz -C /root/area-do-cliente-app
cd /root/area-do-cliente-app
```

### **3. Verificar se Docker está instalado:**
```bash
docker --version
docker-compose --version
```

**Se não estiver instalado:**
```bash
# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Instalar Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

### **4. Parar containers existentes:**
```bash
# Listar containers rodando
docker ps

# Parar container antigo se existir
docker stop area-cliente-app
docker rm area-cliente-app
```

### **5. Build e Deploy:**
```bash
# Build da imagem
docker-compose build

# Iniciar container
docker-compose up -d

# Verificar status
docker-compose ps

# Ver logs
docker-compose logs -f
```

### **6. Verificar se está funcionando:**
```bash
# Teste local no VPS
curl http://localhost:3001

# Health check
curl http://localhost:3001/health

# Ver logs do Nginx
docker-compose logs nginx

# Ver containers rodando
docker ps
```

## 🧪 **Teste Externo:**

- **VPS direto**: http://212.85.12.183:3001
- **Health check**: http://212.85.12.183:3001/health
- **Hostinger (com redirecionamento)**: https://code-iq.com.br/area-do-cliente.html

## 🔄 **Comandos Úteis:**

### **Reiniciar container:**
```bash
cd /root/area-do-cliente-app
docker-compose restart
```

### **Ver logs em tempo real:**
```bash
docker-compose logs -f
```

### **Parar container:**
```bash
docker-compose down
```

### **Iniciar container:**
```bash
docker-compose up -d
```

### **Reconstruir imagem:**
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### **Ver volumes:**
```bash
docker volume ls
```

### **Limpar dados persistentes (CUIDADO!):**
```bash
docker-compose down -v
```

## 📊 **Estrutura dos Volumes:**

```
/var/lib/docker/volumes/
├── area-cliente-data/          # Dados da aplicação
└── area-cliente-logs/          # Logs do Nginx
    ├── access.log
    └── error.log
```

## 🔐 **Portas Expostas:**

- **3001** - Aplicação React (mapeada de 80 interno)

## 🎯 **Próximos Passos:**

1. ✅ Conectar ao VPS via SSH
2. ✅ Extrair o arquivo tar.gz
3. ✅ Verificar/Instalar Docker e Docker Compose
4. ✅ Build e deploy do container
5. ✅ Testar acesso externo
6. ✅ Configurar redirecionamento no Hostinger (já feito)

## 🚨 **Troubleshooting:**

### **Container não inicia:**
```bash
docker-compose logs
```

### **Porta 3001 já em uso:**
```bash
# Ver o que está usando a porta
lsof -i :3001

# Matar processo
kill -9 <PID>
```

### **Problemas de permissão:**
```bash
chmod -R 755 /root/area-do-cliente-app
chown -R root:root /root/area-do-cliente-app
```

---

**🎉 Após o deploy, a aplicação estará 100% funcional com dados persistentes e auto-restart!**
