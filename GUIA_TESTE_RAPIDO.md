# 🚀 Guia de Teste Rápido - Webhooks de Permissões

## 🎯 **Teste em 3 Passos:**

### **✅ Passo 1: Acesse a Página**
```
http://localhost:5173/permissions
```

### **✅ Passo 2: Ative o Painel de Testes**
- Clique no botão **"Mostrar Testes"** (ícone de tubo de ensaio)
- O painel de testes aparecerá abaixo do título

### **✅ Passo 3: Execute os Testes**
- **Teste Individual:** Clique em cada botão de teste
- **Teste Completo:** Clique em **"Executar Todos os Testes"**

## 🔍 **O que Testar:**

### **✅ 1. Listar Perfis**
- **Webhook:** `webhook/list-profile`
- **Payload:** `{}`
- **Resultado Esperado:** Lista de perfis ou array vazio

### **✅ 2. Criar Perfil Válido**
- **Webhook:** `webhook/create-profile`
- **Payload:** 
  ```json
  {
    "nome_perfil": "Teste Frontend",
    "descricao": "Perfil criado via teste",
    "permissoes": ["upload_view", "usuario_create"]
  }
  ```
- **Resultado Esperado:** `{ "success": true, "profileId": X }`

### **✅ 3. Criar Perfil Inválido**
- **Webhook:** `webhook/create-profile`
- **Payload:** 
  ```json
  {
    "nome_perfil": "",
    "descricao": "Teste com dados inválidos",
    "permissoes": ["permissao_inexistente"]
  }
  ```
- **Resultado Esperado:** Erro de validação

## 📊 **Interpretando os Resultados:**

### **✅ Sucesso (Verde)**
- ✅ Webhook funcionando
- ✅ Dados sendo processados
- ✅ Resposta no formato esperado

### **❌ Erro (Vermelho)**
- ❌ Webhook não encontrado (404)
- ❌ Erro de validação
- ❌ Erro de servidor (500)
- ❌ Timeout de conexão

### **⏳ Pendente (Azul)**
- ⏳ Teste em execução
- ⏳ Aguardando resposta

## 🚨 **Problemas Comuns:**

### **❌ "Resposta vazia"**
- **Causa:** Webhook não está retornando dados
- **Solução:** Verificar se webhook está ativo no n8n

### **❌ "Formato de resposta inválido"**
- **Causa:** Webhook retorna HTML 404 em vez de JSON
- **Solução:** Verificar URL do webhook no n8n

### **❌ "Falha ao criar perfil"**
- **Causa:** Webhook retorna `success: false`
- **Solução:** Verificar validação no backend

### **❌ "Deveria ter falhado com dados inválidos"**
- **Causa:** Webhook aceita dados inválidos
- **Solução:** Implementar validação no backend

## 🔧 **Debug Avançado:**

### **✅ Console do Navegador (F12)**
```javascript
// Ver logs detalhados
console.log('Carregando perfis...')
console.log('Resposta do webhook/list-profile:', response)
console.log('Perfis carregados:', profiles)
```

### **✅ Network Tab (F12)**
- Ver requisições HTTP
- Verificar status codes (200, 404, 500)
- Verificar payloads enviados
- Verificar respostas recebidas

### **✅ Teste Manual via Console**
```javascript
// Teste direto no console
fetch('https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/list-profile', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({})
})
.then(response => response.json())
.then(data => console.log('Resposta:', data))
```

## 🎯 **Checklist de Validação:**

### **✅ Funcionalidade Básica:**
- [ ] Página carrega sem erros
- [ ] Painel de testes aparece
- [ ] Botões de teste funcionam
- [ ] Resultados são exibidos
- [ ] Logs aparecem no console

### **✅ Webhooks:**
- [ ] `webhook/list-profile` retorna dados
- [ ] `webhook/create-profile` cria perfil
- [ ] Validação funciona corretamente
- [ ] Erros são tratados adequadamente

### **✅ Interface:**
- [ ] Formulário de criação funciona
- [ ] Lista de perfis é exibida
- [ ] Permissões são selecionáveis
- [ ] Toasts de feedback aparecem

## 🚀 **Próximos Passos:**

1. **Execute os testes** usando o painel
2. **Verifique os resultados** e logs
3. **Reporte problemas** encontrados
4. **Valide funcionalidades** no frontend
5. **Teste diferentes cenários** de dados

**Sistema de teste integrado e pronto!** 🎯✨
