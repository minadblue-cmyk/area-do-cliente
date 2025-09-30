# 🔧 Limpar Cache de Webhooks

## 🚨 Problema Identificado

**O webhook `webhook/status-agente1` não está sendo encontrado no store!**

- ✅ Webhook corrigido nas constantes
- ❌ localStorage ainda tem versão antiga
- ❌ Store não está carregando a nova configuração

## 🛠️ Soluções Implementadas

### **1. Reset Automático do Store**
- ✅ Adicionado `reset()` no início de `loadAgentStatus()`
- ✅ Força reload das configurações do localStorage

### **2. Verificação de Webhook**
- ✅ Verifica se webhook existe antes de chamar
- ✅ Lista webhooks disponíveis em caso de erro
- ✅ Pula agentes sem webhook configurado

### **3. Logs de Debug**
- ✅ Mostra URL do webhook configurado
- ✅ Lista webhooks disponíveis
- ✅ Identifica problemas de configuração

## 🧪 Teste Agora

### **Passo 1: Recarregar a Página**
1. Acesse `http://localhost:5175/upload`
2. Abra DevTools (F12) → Console
3. Recarregue a página (Ctrl+F5)

### **Passo 2: Verificar Logs**
Procure por:
- `🔄 Configurações de webhook recarregadas`
- `🔗 Webhook configurado: https://n8n.code-iq.com.br/webhook/status-agente1`
- `📥 Resposta recebida para...`

### **Passo 3: Se Ainda Não Funcionar**
Execute no console do navegador:
```javascript
// Limpar localStorage manualmente
localStorage.removeItem('flowhub:webhooks')
// Recarregar página
location.reload()
```

## 🔍 Diagnóstico Adicional

### **Se aparecer "Webhook configurado: undefined":**
- O webhook não está nas constantes
- Verificar se `webhook/status-agente1` existe

### **Se aparecer "Webhooks disponíveis: [...]":**
- Verificar se `webhook/status-agente1` está na lista
- Se não estiver, há problema nas constantes

### **Se aparecer erro de CORS:**
- Problema de configuração no n8n
- Verificar se webhook está ativo

## ✅ Resultado Esperado

Após o reset:
- ✅ `🔄 Configurações de webhook recarregadas`
- ✅ `🔗 Webhook configurado: https://n8n.code-iq.com.br/webhook/status-agente1`
- ✅ `📥 Resposta recebida para...`
- ✅ Botões funcionando corretamente

## 🎯 Próximos Passos

1. **Teste o reset automático** (recarregar página)
2. **Se não funcionar**, execute o comando manual no console
3. **Me informe os resultados** dos logs
4. **Se necessário**, vamos corrigir as constantes
