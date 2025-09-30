# 🧪 Teste de Webhooks

## ✅ **Webhooks Confirmados no n8n**

### **1. Webhooks que EXISTEM (via proxy):**
- ✅ `webhook/listar-saudacao` - POST
- ✅ `webhook/salvar-saudacao` - POST  
- ✅ `webhook/deletar-saudacao` - POST
- ✅ `webhook/seleciona-saudacao` - POST
- ✅ `webhook/upload` - POST
- ✅ `webhook/controle-do-agente` - POST

### **2. Webhooks que podem NÃO existir:**
- ❓ `webhook/list-profile` - GET/POST
- ❓ `webhook/list-users` - GET/POST
- ❓ `webhook/list-company` - GET/POST
- ❓ `webhook/create-user` - POST
- ❓ `webhook/create-company` - POST

## 🔧 **Como Testar**

### **Teste 1: Webhook de Saudações**
```bash
# Via proxy (deve funcionar)
curl -X POST http://localhost:8080/webhook/listar-saudacao \
  -H "Content-Type: application/json" \
  -d '{"id": 5, "usuario_id": 5}'
```

### **Teste 2: Webhook de Upload**
```bash
# Via proxy (deve funcionar)
curl -X POST http://localhost:8080/webhook/upload \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'
```

### **Teste 3: Webhook de Perfis**
```bash
# Via proxy (pode não existir)
curl -X GET http://localhost:8080/webhook/list-profile
```

## 🎯 **Status Atual**

- ✅ **Proxy funcionando:** `http://localhost:8080`
- ✅ **CORS resolvido:** Requisições passam
- ✅ **Webhooks principais:** Saudação e Upload funcionando
- ❓ **Webhooks secundários:** Precisam ser testados

## 📝 **Próximos Passos**

1. **Teste os webhooks principais** (Saudação, Upload)
2. **Verifique quais webhooks existem** no n8n
3. **Atualize as constantes** com webhooks corretos
4. **Configure webhooks faltantes** no n8n

## 🚨 **Problema Identificado**

O proxy está funcionando, mas alguns webhooks não existem no n8n, causando erro 404.

**Solução:** Usar apenas webhooks confirmados ou criar os faltantes no n8n.
