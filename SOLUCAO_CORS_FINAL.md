# 🚨 SOLUÇÃO DEFINITIVA PARA CORS

## Problema
O frontend está sendo bloqueado pelo CORS ao tentar acessar o webhook do n8n.

## ✅ SOLUÇÃO RÁPIDA: Extensão do Navegador

### 1. Instalar extensão CORS
**Chrome:**
- Instale: "CORS Unblock" ou "Disable CORS"
- Ative a extensão

**Firefox:**
- Instale: "CORS Everywhere"
- Ative a extensão

### 2. Configurar extensão
- Clique no ícone da extensão
- Ative para o domínio `localhost`
- Ou ative globalmente (apenas para desenvolvimento)

### 3. Testar
- Recarregue a página
- Clique em "Iniciar Agente"
- Deve funcionar sem erro de CORS

## 🔧 SOLUÇÃO ALTERNATIVA: Proxy Manual

### 1. Instalar dependências
```bash
npm install express http-proxy-middleware cors
```

### 2. Executar proxy
```bash
node proxy-server.js
```

### 3. Verificar se está rodando
- Acesse: `http://localhost:3001`
- Deve mostrar uma mensagem de erro (normal)

## 📝 Status atual:
- ✅ Webhook configurado: `http://localhost:3001/n8n/webhook-test/agente-prospeccao-quente`
- ✅ Payload correto implementado
- ✅ Proxy server criado
- ❌ CORS ainda bloqueando requisições

## 🎯 Próximos passos:
1. **Instale uma extensão CORS** (mais rápido)
2. Ou execute o proxy server
3. Teste o botão "Iniciar Agente"
4. Verifique os logs no console

## ⚠️ IMPORTANTE:
- O webhook está em **modo de teste** no n8n
- Você precisa executar o workflow no n8n primeiro
- Depois testar o botão no frontend

## 🔗 Links úteis:
- n8n: `https://n8n.code-iq.com.br`
- Extensão Chrome: "CORS Unblock"
- Extensão Firefox: "CORS Everywhere"
