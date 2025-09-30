# 🔧 Configuração de CORS no n8n

## ❌ Problema Atual
O frontend está rodando em `http://localhost:5175` mas o n8n está configurado para aceitar apenas `http://localhost:8080`.

**Erro no console:**
```
Access to XMLHttpRequest at 'https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/list-profile' 
from origin 'http://localhost:5175' has been blocked by CORS policy: 
Response to preflight request doesn't pass access control check: 
The 'Access-Control-Allow-Origin' header has a value 'http://localhost:8080' 
that is not equal to the supplied origin.
```

## ✅ Soluções

### 1. **Configurar CORS no n8n (Recomendado)**

No seu n8n, adicione as seguintes configurações de CORS:

```bash
# Variáveis de ambiente do n8n
N8N_CORS_ORIGIN=http://localhost:5175,http://localhost:8080,http://localhost:3000
N8N_CORS_CREDENTIALS=true
N8N_CORS_METHODS=GET,POST,PUT,DELETE,OPTIONS
N8N_CORS_ALLOWED_HEADERS=Content-Type,Authorization,X-Requested-With
```

### 2. **Configuração via Docker (se usando)**

```yaml
# docker-compose.yml
environment:
  - N8N_CORS_ORIGIN=http://localhost:5175,http://localhost:8080
  - N8N_CORS_CREDENTIALS=true
  - N8N_CORS_METHODS=GET,POST,PUT,DELETE,OPTIONS
```

### 3. **Configuração via Painel do n8n**

1. Acesse as configurações do n8n
2. Vá em **Settings** → **Security**
3. Configure:
   - **CORS Origin**: `http://localhost:5175`
   - **CORS Credentials**: `true`
   - **CORS Methods**: `GET,POST,PUT,DELETE,OPTIONS`

### 4. **Solução Temporária - Proxy Local**

Se não conseguir configurar o CORS no n8n, pode usar um proxy local:

```bash
# Instalar proxy
npm install -g cors-anywhere

# Executar proxy na porta 8080
cors-anywhere -p 8080
```

E depois alterar a URL do webhook para:
```
http://localhost:8080/https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/list-profile
```

## 🎯 Webhooks que precisam ser configurados

- `webhook/list-profile` - Listar perfis
- `webhook/list-users` - Listar usuários  
- `webhook/list-company` - Listar empresas
- `webhook/listar-saudacao` - Listar saudações
- `webhook/login` - Login
- `webhook/upload` - Upload de arquivos

## 📝 Verificação

Após configurar o CORS, verifique:

1. **Console do navegador** - Não deve ter erros de CORS
2. **Network tab** - Requisições devem retornar status 200
3. **Toast notifications** - Deve mostrar "X perfis carregados com sucesso!"

## 🚨 Importante

- **Nunca** configure `N8N_CORS_ORIGIN=*` em produção
- **Sempre** especifique os domínios exatos permitidos
- **Teste** todas as funcionalidades após a configuração
