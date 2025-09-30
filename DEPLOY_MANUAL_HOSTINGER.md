# 🚀 Deploy Manual para Hostinger - Área do Cliente

## ✅ Status Atual
- **Build gerado com sucesso** ✅
- **Arquivo ZIP criado** ✅ (`area-do-cliente-deploy.zip` - 390KB)
- **Aplicação React pronta** ✅

## 📦 Arquivo Pronto para Upload

**Arquivo**: `area-do-cliente-deploy.zip` (390KB)  
**Localização**: `C:\Users\rmace\area-do-cliente\area-do-cliente-deploy.zip`

## 🎯 Passos para Deploy Manual

### 1. **Acessar Painel da Hostinger**
1. Acesse [hpanel.hostinger.com](https://hpanel.hostinger.com)
2. Faça login com suas credenciais
3. Selecione seu domínio `code-iq.com.br`

### 2. **Acessar Gerenciador de Arquivos**
1. No painel, vá em **"Arquivos"** ou **"File Manager"**
2. Navegue até `/public_html/`

### 3. **Criar Diretório**
1. Crie uma nova pasta chamada `area-do-cliente`
2. Entre na pasta `area-do-cliente`

### 4. **Upload do Arquivo ZIP**
1. Clique em **"Upload"** ou **"Enviar arquivos"**
2. Selecione o arquivo `area-do-cliente-deploy.zip`
3. Aguarde o upload completar

### 5. **Extrair Arquivos**
1. Clique com o botão direito no arquivo ZIP
2. Selecione **"Extract"** ou **"Extrair"**
3. Aguarde a extração completar

### 6. **Verificar Estrutura**
Após a extração, você deve ter:
```
public_html/area-do-cliente/
├── index.html
├── favicon.svg
├── vite.svg
└── assets/
    ├── index-BAPDVwdl.css
    ├── index-DNiEnL8r.js
    └── [outros 21 arquivos]
```

### 7. **Configurar .htaccess (Opcional)**
Crie um arquivo `.htaccess` na pasta `area-do-cliente` com:

```apache
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

## 🎉 Resultado Final

**URL da aplicação**: `https://code-iq.com.br/area-do-cliente/`

## 🔍 Verificação

### Checklist de Teste
- [ ] Site carregando: `https://code-iq.com.br/area-do-cliente/`
- [ ] Página inicial funcionando
- [ ] Navegação entre páginas funcionando
- [ ] CSS carregando (estilos aplicados)
- [ ] JavaScript funcionando (interações)
- [ ] Responsividade (teste no mobile)

### Funcionalidades Principais
- [ ] Login de usuários
- [ ] Upload de arquivos
- [ ] Listagem de agentes
- [ ] Configurações
- [ ] Dashboard

## 🚨 Troubleshooting

### Problema: Página em branco
**Solução**: Verificar se o arquivo `index.html` está na pasta correta

### Problema: Assets não carregam
**Solução**: Verificar se a pasta `assets/` foi extraída corretamente

### Problema: Erro 404 em rotas
**Solução**: Verificar se o arquivo `.htaccess` está configurado

### Problema: CORS errors
**Solução**: Verificar configurações de API no código

## 📊 Alternativa: Deploy via FTP

Se preferir usar FTP, você pode usar um cliente como FileZilla:

### Configurações FTP
- **Host**: `195.200.3.228`
- **Usuário**: `u535869980`
- **Senha**: `F0rm@T1001`
- **Porta**: `21`

### Estrutura de Upload
```
/public_html/area-do-cliente/
├── index.html
├── favicon.svg
├── vite.svg
└── assets/
    └── [todos os arquivos JS/CSS]
```

## 🎯 Próximos Passos

1. **Deploy** → Siga os passos acima
2. **Teste** → Verifique todas as funcionalidades
3. **Monitor** → Configure logs se necessário
4. **Backup** → Mantenha backup dos arquivos
5. **Atualize** → Configure deploy automático para futuras atualizações

---

## 📞 Suporte

Se encontrar problemas:
1. Verifique se todos os arquivos foram extraídos
2. Teste localmente primeiro (`npm run preview`)
3. Verifique as configurações de DNS
4. Confirme que o arquivo `.htaccess` está correto

---

**Tempo estimado**: 5-10 minutos  
**Dificuldade**: Fácil  
**Custo**: Gratuito (já pago)

*Seu projeto está pronto para o mundo! 🌍*
