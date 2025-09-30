# 🔧 Correção do Payload do Frontend para n8n

## 🚨 Problema Identificado

O frontend está enviando um payload diferente do que o n8n espera:

### **❌ Payload Atual (Frontend):**
```json
{
  "action": "start",
  "agent_type": 81,
  "workflow_id": 81,
  "timestamp": "2025-09-25T19:06:23.574Z",
  "usuario_id": 6,
  "logged_user": {
    "id": 6,
    "name": "Usuário Elleve Padrão",
    "email": "rmacedo2005@hotmail.com"
  },
  "webhookUrl": "https://n8n.code-iq.com.br/webhook/start12-ze",
  "executionMode": "production"
}
```

### **✅ Payload Esperado (n8n):**
```json
{
  "usuario_id": 6,
  "action": "start",
  "logged_user": {
    "id": 6,
    "name": "Usuário Elleve Padrão",
    "email": "rmacedo2005@hotmail.com"
  },
  "agente_id": 5,
  "perfil_id": 2,
  "perfis_permitidos": [2, 3],
  "usuarios_permitidos": [6]
}
```

## 🔍 Campos Faltando

1. **`agente_id`** - ID do agente do usuário
2. **`perfil_id`** - ID do perfil do usuário
3. **`perfis_permitidos`** - Array com IDs dos perfis permitidos
4. **`usuarios_permitidos`** - Array com IDs dos usuários permitidos

## 🔧 Solução

### **1. Atualizar Frontend**
Modificar o componente que envia o webhook start para incluir os campos necessários:

```typescript
// Buscar dados do usuário logado
const usuario = getUsuarioLogado();
const agente = await buscarAgenteDoUsuario(usuario.id);
const perfis = await buscarPerfisDoUsuario(usuario.id);

// Montar payload correto
const payload = {
  usuario_id: usuario.id,
  action: "start",
  logged_user: {
    id: usuario.id,
    name: usuario.nome,
    email: usuario.email
  },
  agente_id: agente.id,
  perfil_id: perfis[0].id, // Perfil principal
  perfis_permitidos: perfis.map(p => p.id),
  usuarios_permitidos: [usuario.id]
};

// Enviar para n8n
await fetch('http://localhost:5678/webhook/start', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(payload)
});
```

### **2. Funções Necessárias no Frontend**

```typescript
// Buscar agente do usuário
async function buscarAgenteDoUsuario(usuarioId: number) {
  const response = await fetch(`/api/usuarios/${usuarioId}/agente`);
  return response.json();
}

// Buscar perfis do usuário
async function buscarPerfisDoUsuario(usuarioId: number) {
  const response = await fetch(`/api/usuarios/${usuarioId}/perfis`);
  return response.json();
}
```

### **3. Endpoints Necessários no Backend**

```typescript
// GET /api/usuarios/:id/agente
app.get('/api/usuarios/:id/agente', async (req, res) => {
  const agente = await db.query(`
    SELECT a.id, a.nome 
    FROM agentes a 
    WHERE a.usuario_id = $1
  `, [req.params.id]);
  
  res.json(agente.rows[0]);
});

// GET /api/usuarios/:id/perfis
app.get('/api/usuarios/:id/perfis', async (req, res) => {
  const perfis = await db.query(`
    SELECT p.id, p.descricao 
    FROM perfis p
    JOIN usuario_perfis up ON up.perfil_id = p.id
    WHERE up.usuario_id = $1
  `, [req.params.id]);
  
  res.json(perfis.rows);
});
```

## 🧪 Teste da Correção

Após implementar as correções, execute:

```powershell
# Teste com usuário 6
.\teste-webhook-start-usuario-6.ps1

# Teste com usuário 7
.\teste-webhook-start-usuario-7.ps1
```

## 📋 Checklist de Implementação

- [ ] Adicionar função `buscarAgenteDoUsuario()`
- [ ] Adicionar função `buscarPerfisDoUsuario()`
- [ ] Modificar payload do webhook start
- [ ] Criar endpoints no backend
- [ ] Testar com diferentes usuários
- [ ] Verificar se n8n recebe dados corretos
