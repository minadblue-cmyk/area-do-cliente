# 🚨 SOLUÇÃO PARA ERRO DE CORS

## Problema
O frontend está sendo bloqueado pelo CORS ao tentar acessar o webhook do n8n.

## ✅ SOLUÇÃO: Configurar CORS no n8n

### 1. Acesse o n8n
- Vá para: `https://n8n.code-iq.com.br`
- Faça login no n8n

### 2. Configure CORS
- Vá para **Settings** (Configurações)
- Procure por **Security** ou **CORS**
- Adicione os domínios permitidos:

```
http://localhost:5173
http://localhost:5174
http://localhost:5175
http://localhost:5176
http://localhost:5177
http://localhost:5178
http://localhost:5179
http://localhost:5180
http://localhost:5181
```

### 3. Ou configure para aceitar todos os domínios (apenas para desenvolvimento)
```
*
```

### 4. Salve as configurações

## 🔧 Alternativa: Usar extensão do navegador

Se não conseguir configurar o CORS no n8n, instale uma extensão como:
- **CORS Unblock** (Chrome)
- **Disable CORS** (Firefox)

## 📝 Status atual:
- ✅ Webhook configurado: `https://n8n.code-iq.com.br/webhook-test/agente-prospeccao-quente`
- ✅ Payload correto implementado
- ❌ CORS bloqueando requisições

## 🎯 Próximos passos:
1. **Execute o workflow no n8n primeiro** (clique em "Execute workflow" no canvas)
2. Configure CORS no n8n (se necessário)
3. Teste o botão "Iniciar Agente"
4. Verifique os logs no console

## ⚠️ IMPORTANTE:
O webhook está em **modo de teste** no n8n. Você precisa:
1. Ir para o n8n: `https://n8n.code-iq.com.br`
2. Encontrar o workflow "Agente prospeccao..."
3. Clicar em **"Execute workflow"** ou **"Listen for test event"**
4. Depois testar o botão no frontend
