# 📋 Análise do Payload do Fluxo Start

## 🔍 **Payload Atual Recebido:**

```json
{
  "body": {
    "action": "start",
    "agent_type": 81,
    "workflow_id": 81,
    "timestamp": "2025-09-25T12:18:16.532Z",
    "usuario_id": 6,
    "logged_user": {
      "id": 6,
      "name": "Usuário Elleve Padrão",
      "email": "rmacedo2005@hotmail.com"
    }
  },
  "webhookUrl": "https://n8n.code-iq.com.br/webhook/start12-ze"
}
```

## ❌ **Problemas Identificados:**

### **1. Falta `agente_id` específico:**
- ✅ Tem `usuario_id`: 6
- ❌ **FALTA:** `agente_id` específico do agente que vai executar
- ❌ **FALTA:** `perfil_id` do usuário para verificar permissões

### **2. Falta informações de permissões:**
- ❌ **FALTA:** `perfis_permitidos` (array de IDs de perfis que podem acessar)
- ❌ **FALTA:** `usuarios_permitidos` (array de IDs de usuários que podem acessar)

## ✅ **Payload Correto Necessário:**

```json
{
  "body": {
    "action": "start",
    "agent_type": 81,
    "workflow_id": 81,
    "timestamp": "2025-09-25T12:18:16.532Z",
    "usuario_id": 6,
    "agente_id": 81,                    // ✅ NOVO: ID específico do agente
    "perfil_id": 3,                     // ✅ NOVO: Perfil do usuário
    "perfis_permitidos": [1, 3, 4],     // ✅ NOVO: Perfis que podem acessar
    "usuarios_permitidos": [6, 8, 10],  // ✅ NOVO: Usuários que podem acessar
    "logged_user": {
      "id": 6,
      "name": "Usuário Elleve Padrão",
      "email": "rmacedo2005@hotmail.com"
    }
  },
  "webhookUrl": "https://n8n.code-iq.com.br/webhook/start12-ze"
}
```

## 🔧 **Correções Necessárias:**

### **1. Frontend - Adicionar campos no payload:**
```javascript
const payload = {
  action: "start",
  agent_type: 81,
  workflow_id: 81,
  timestamp: new Date().toISOString(),
  usuario_id: user.id,
  agente_id: selectedAgent.id,           // ✅ NOVO
  perfil_id: user.perfil_id,             // ✅ NOVO
  perfis_permitidos: [1, 3, 4],          // ✅ NOVO
  usuarios_permitidos: [6, 8, 10],       // ✅ NOVO
  logged_user: {
    id: user.id,
    name: user.name,
    email: user.email
  }
};
```

### **2. n8n - Atualizar parâmetros da query:**
```
{{$workflow.id}}, 
{{$execution.id}}, 
{{$json.body.agente_id}},  // ✅ CORRIGIDO: usar agente_id específico
{{JSON.stringify({
  "agente_id": $json.body.agente_id,
  "reservado_por": "usuario_" + $json.body.usuario_id,
  "reservado_em": $now.toISO(),
  "perfis_permitidos": $json.body.perfis_permitidos || [],
  "usuarios_permitidos": $json.body.usuarios_permitidos || [$json.body.usuario_id],
  "permissoes_especiais": {
    "pode_editar": true,
    "pode_deletar": false,
    "pode_exportar": true
  }
})}}
```

## 🎯 **Fluxo Correto:**

### **1. Frontend:**
- Usuário seleciona agente específico
- Frontend envia `agente_id` + permissões no payload

### **2. n8n:**
- Recebe `agente_id` específico
- Usa `agente_id` para reservar leads
- Cria `permissoes_acesso` com permissões recebidas

### **3. Banco:**
- Leads reservados com `agente_id` específico
- `permissoes_acesso` JSONB com permissões

## 🚀 **Próximos Passos:**

1. **✅ CORRIGIR FRONTEND** - Adicionar `agente_id` e permissões no payload
2. **✅ CORRIGIR N8N** - Usar `agente_id` específico na query
3. **✅ TESTAR** - Verificar funcionamento completo

**Payload atual está incompleto para a solução de permissões! 🔧**
