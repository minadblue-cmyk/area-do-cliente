# 🧪 Teste Completo - Webhooks de Permissões

## 🎯 **Webhooks Disponíveis:**
- ✅ `/webhook/list-profiles` - Listar perfis
- ✅ `/webhook/list-profile` - Listar perfis (alternativo)
- ✅ `/webhook/create-profile` - Criar perfil

## 🚀 **Como Testar:**

### **✅ 1. Teste Manual no Frontend**

1. **Acesse a página de Perfis:**
   ```
   http://localhost:5173/permissions
   ```

2. **Teste de Listagem:**
   - A página deve carregar automaticamente
   - Verifique o console do navegador para logs
   - Deve mostrar lista de perfis ou mensagem "Nenhum perfil encontrado"

3. **Teste de Criação:**
   - Clique em "Novo Perfil"
   - Preencha os campos:
     - **Nome:** "Gestor Empresa"
     - **Descrição:** "Gerencia usuários da empresa"
     - **Permissões:** Selecione algumas permissões
   - Clique em "Criar Perfil"
   - Verifique se aparece toast de sucesso
   - Verifique se o perfil aparece na lista

### **✅ 2. Teste via Console do Navegador**

Abra o console (F12) e execute:

```javascript
// Teste de listagem
fetch('https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/list-profile', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({})
})
.then(response => response.json())
.then(data => console.log('Lista de perfis:', data))
.catch(error => console.error('Erro:', error));

// Teste de criação
fetch('https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/create-profile', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    nome_perfil: 'Teste Frontend',
    descricao: 'Perfil criado via teste',
    permissoes: ['upload_view', 'usuario_create']
  })
})
.then(response => response.json())
.then(data => console.log('Perfil criado:', data))
.catch(error => console.error('Erro:', error));
```

### **✅ 3. Teste via cURL**

```bash
# Teste de listagem
curl -X POST "https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/list-profile" \
  -H "Content-Type: application/json" \
  -d '{}'

# Teste de criação
curl -X POST "https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/create-profile" \
  -H "Content-Type: application/json" \
  -d '{
    "nome_perfil": "Teste cURL",
    "descricao": "Perfil criado via cURL",
    "permissoes": ["upload_view", "usuario_create", "usuario_update"]
  }'
```

## 🔍 **Formatos de Resposta Esperados:**

### **✅ Listagem de Perfis:**
```json
// Formato 1: Array direto
[
  {
    "id": 1,
    "nome_perfil": "Administrador",
    "descricao": "Acesso total ao sistema",
    "permissoes": ["upload_view", "upload_create", "usuario_view", "usuario_create"],
    "created_at": "2024-01-15T10:30:00Z"
  },
  {
    "id": 2,
    "nome_perfil": "Gestor Empresa",
    "descricao": "Gerencia usuários da empresa",
    "permissoes": ["upload_view", "usuario_view", "usuario_create"],
    "created_at": "2024-01-15T11:00:00Z"
  }
]

// Formato 2: Com wrapper
{
  "success": true,
  "profiles": [
    {
      "id": 1,
      "nome_perfil": "Administrador",
      "descricao": "Acesso total ao sistema",
      "permissoes": ["upload_view", "upload_create", "usuario_view", "usuario_create"]
    }
  ]
}
```

### **✅ Criação de Perfil:**
```json
{
  "success": true,
  "message": "Perfil criado com sucesso",
  "profileId": 3,
  "profile": {
    "id": 3,
    "nome_perfil": "Gestor Empresa",
    "descricao": "Gerencia usuários da empresa",
    "permissoes": ["upload_view", "usuario_view", "usuario_create"]
  }
}
```

## 🚨 **Cenários de Teste:**

### **✅ 1. Teste de Sucesso:**
- ✅ Listar perfis existentes
- ✅ Criar perfil com dados válidos
- ✅ Verificar se perfil aparece na lista

### **✅ 2. Teste de Validação:**
- ❌ Criar perfil sem nome
- ❌ Criar perfil com nome duplicado
- ❌ Criar perfil com permissões inválidas

### **✅ 3. Teste de Erro:**
- ❌ Webhook não encontrado (404)
- ❌ Erro de servidor (500)
- ❌ Timeout de conexão

## 🔧 **Logs de Debug:**

### **✅ No Frontend:**
```javascript
// Verificar logs no console
console.log('Carregando perfis...')
console.log('Resposta do webhook/list-profile:', response)
console.log('Perfis carregados:', profiles)
```

### **✅ No n8n:**
- Verificar logs do workflow
- Verificar se webhook está ativo
- Verificar se dados estão sendo processados

## 🎯 **Checklist de Testes:**

### **✅ Funcionalidade Básica:**
- [ ] Página carrega sem erros
- [ ] Lista de perfis é exibida
- [ ] Formulário de criação abre
- [ ] Permissões são selecionáveis
- [ ] Perfil é criado com sucesso
- [ ] Toast de sucesso é exibido
- [ ] Novo perfil aparece na lista

### **✅ Validação de Dados:**
- [ ] Nome é obrigatório
- [ ] Permissões são válidas
- [ ] Dados são salvos corretamente
- [ ] Formato de resposta é correto

### **✅ Tratamento de Erros:**
- [ ] Erro de rede é tratado
- [ ] Erro de validação é tratado
- [ ] Erro de servidor é tratado
- [ ] Mensagens de erro são exibidas

## 🚀 **Próximos Passos:**

1. **Execute os testes** acima
2. **Verifique os logs** no console
3. **Teste diferentes cenários** de dados
4. **Valide as respostas** dos webhooks
5. **Reporte problemas** encontrados

**Sistema de teste completo criado!** 🎯✨
