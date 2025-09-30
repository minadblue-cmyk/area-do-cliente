# 🔧 Correção: Query de Prospecção para Supervisor

## **Problema Identificado:**

A query atual está filtrando por `client_id = $3`, impedindo que supervisores vejam leads de outros usuários:

```sql
-- ❌ QUERY ATUAL (PROBLEMA):
WHERE l.client_id = $3
AND l.agente_id = $3 -- USAR client_id como agente_id
```

## **Solução:**

Modificar a query para permitir acesso baseado em permissões:

### **1. Query SQL Corrigida:**

```sql
-- ✅ QUERY CORRIGIDA:
SELECT
    l.id, l.client_id, l.nome, l.telefone, l.status, l.contatado,
    l.data_ultima_interacao, l.data_criacao,
    -- ✅ ADICIONAR CONTADOR DE CLIENTES CONTATADOS
    COUNT(CASE WHEN l.contatado = true THEN 1 END) OVER() as total_contatados,
    COUNT(*) OVER() as total_leads
FROM lead l
WHERE l.agente_id = $3 -- ✅ APENAS agente_id (não client_id)
AND l.status IN ('prospectando', 'concluido')
AND COALESCE(l.data_ultima_interacao, l.data_criacao) >= $1::timestamp
AND COALESCE(l.data_ultima_interacao, l.data_criacao) < $2::timestamp
ORDER BY COALESCE(l.data_ultima_interacao, l.data_criacao) DESC,
l.id DESC;
```

### **2. Parâmetros da Query:**

- `$1` = `startDateTime` (período início)
- `$2` = `endDateTime` (período fim)  
- `$3` = `agente_id` (ID do agente específico)

### **3. Controle de Acesso no n8n:**

Adicionar validação de permissões no nó de webhook:

```javascript
// No nó de webhook da lista de prospecção
const userPermissions = $json.permissions || [];
const hasViewPermission = userPermissions.includes('visualizar_status_do_agente') || 
                         userPermissions.includes('administrar_agente_de_outros_usuários');

if (!hasViewPermission) {
  return {
    success: false,
    message: "Usuário não tem permissão para visualizar leads deste agente",
    data: [],
    total_leads: 0,
    total_contatados: 0
  };
}

// Continuar com a query normal...
```

### **4. Frontend - Enviar Permissões:**

No `src/pages/Upload/index.tsx`, modificar a chamada do webhook:

```typescript
const response = await callWebhook(agenteAtual.webhook_lista_url, {
  method: 'POST',
  data: {
    startDateTime: periodoInicio,
    endDateTime: periodoFim,
    // ✅ ADICIONAR PERMISSÕES DO USUÁRIO
    userPermissions: userData.permissions || []
  },
  params: {
    agente_id: agenteAtual.id // ✅ APENAS agente_id
  }
});
```

## **Resultado Esperado:**

- ✅ **Supervisor** com `visualizar_status_do_agente = true` pode ver leads de qualquer agente
- ✅ **Usuário comum** só vê seus próprios leads (se não tiver permissão)
- ✅ **Administrador** vê todos os leads
- ✅ **Controle granular** baseado em permissões

## **Implementação:**

1. **Atualizar query SQL** no n8n (remover filtro `client_id`)
2. **Adicionar validação de permissões** no webhook
3. **Modificar frontend** para enviar permissões do usuário
4. **Testar** com diferentes perfis de usuário
