# ✅ Análise do Payload no Node "Normaliza"

## 🎯 **Payload Recebido (CORRETO):**

```json
{
  "action": "start",
  "agent_type": 81,
  "workflow_id": 81,
  "usuario_id": 6,
  "agente_id": 81,                    // ✅ PERFEITO: ID específico do agente
  "perfil_id": 3,                     // ✅ PERFEITO: Perfil do usuário
  "perfis_permitidos": [1, 3, 4],     // ✅ PERFEITO: Perfis que podem acessar
  "usuarios_permitidos": [6, 8, 10],  // ✅ PERFEITO: Usuários que podem acessar
  "body": {
    "logged_user": {
      "email": "rmacedo2005@hotmail.com",
      "name": "Usuario Elleve Padrao",
      "id": 6
    }
  }
}
```

## ✅ **Dados Disponíveis para o Fluxo:**

### **1. Identificação:**
- ✅ `usuario_id`: 6 (usuário que iniciou)
- ✅ `agente_id`: 81 (agente específico que vai executar)
- ✅ `perfil_id`: 3 (perfil do usuário)

### **2. Permissões:**
- ✅ `perfis_permitidos`: [1, 3, 4] (perfis que podem acessar)
- ✅ `usuarios_permitidos`: [6, 8, 10] (usuários que podem acessar)

### **3. Metadados:**
- ✅ `action`: "start"
- ✅ `agent_type`: 81
- ✅ `workflow_id`: 81

## 🚀 **Próximos Passos no Fluxo:**

### **1. Node "Busca leads não contatados" (Atualizar):**

**Query SQL:**
```sql
WITH pegar AS (
  SELECT id
  FROM public.lead
  WHERE contatado IS NOT TRUE
    AND (reservado_lote IS NULL
         OR COALESCE(reservado_em, NOW() - INTERVAL '100 years')
            < NOW() - INTERVAL '30 minutes')
  ORDER BY COALESCE(data_ultima_interacao, data_criacao) ASC, id ASC
  LIMIT 20
  FOR UPDATE SKIP LOCKED
)
UPDATE public.lead l
SET reservado_por  = $1,         -- {{$workflow.id}}
    reservado_em   = NOW(),
    reservado_lote = $2,         -- {{$execution.id}}
    agente_id      = $3,         -- {{$json.agente_id}} ✅ CORRETO
    permissoes_acesso = $4       -- ✅ NOVO: JSONB com permissões
FROM pegar p
WHERE l.id = p.id
RETURNING
  l.id,
  l.reservado_lote,
  l.reservado_por,
  l.reservado_em,
  l.agente_id,
  l.permissoes_acesso;  -- ✅ NOVO
```

**Parâmetros:**
```
{{$workflow.id}}, 
{{$execution.id}}, 
{{$json.agente_id}},  // ✅ CORRETO: usar agente_id específico
{{JSON.stringify({
  "agente_id": $json.agente_id,
  "reservado_por": "usuario_" + $json.usuario_id,
  "reservado_em": $now.toISO(),
  "perfis_permitidos": $json.perfis_permitidos,
  "usuarios_permitidos": $json.usuarios_permitidos,
  "permissoes_especiais": {
    "pode_editar": true,
    "pode_deletar": false,
    "pode_exportar": true
  }
})}}
```

### **2. Node "Buscar o lote reservado" (Atualizar):**

**Query SQL:**
```sql
SELECT
  l.id, l.client_id, l.nome_cliente, l.telefone, l.canal,
  l.status, l.data_ultima_interacao, l.reservado_por, l.reservado_lote,
  l.agente_id, l.permissoes_acesso
FROM public.lead l
WHERE l.reservado_lote = $1
  -- ✅ NOVO: Verificar permissões de acesso
  AND (
    l.permissoes_acesso->'usuarios_permitidos' @> $2::jsonb
    OR
    l.permissoes_acesso->'perfis_permitidos' @> $3::jsonb
    OR
    l.agente_id = $4
  )
ORDER BY COALESCE(l.data_ultima_interacao, l.data_criacao) ASC,
  l.id ASC;
```

**Parâmetros:**
```
{{$item(0).$json.reservado_lote}},  // reservado_lote
{{JSON.stringify($json.usuarios_permitidos)}},  // usuarios_permitidos
{{JSON.stringify($json.perfis_permitidos)}},  // perfis_permitidos
{{$json.agente_id}}  // agente_id (para verificar se é o próprio agente)
```

## 🎉 **Status: PRONTO PARA CONTINUAR!**

### **✅ Dados Disponíveis:**
- ✅ `agente_id`: 81 (específico do agente)
- ✅ `perfil_id`: 3 (perfil do usuário)
- ✅ `perfis_permitidos`: [1, 3, 4] (perfis que podem acessar)
- ✅ `usuarios_permitidos`: [6, 8, 10] (usuários que podem acessar)

### **⏳ Próximos Passos:**
1. **✅ ATUALIZAR** query "Busca leads não contatados"
2. **✅ ATUALIZAR** query "Buscar o lote reservado"
3. **✅ TESTAR** reserva de lotes com permissões
4. **✅ VALIDAR** funcionamento completo

**Payload perfeito para implementar a solução de permissões! 🚀**
