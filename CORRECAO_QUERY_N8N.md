# 🔧 Correção da Query n8n - Problema Identificado

## ❌ **Problema Identificado:**

Pelos resultados do PostgreSQL:
- ✅ Coluna `permissoes_acesso` existe (tipo JSONB)
- ❌ Campo está vazio `{}` em todos os leads
- ❌ Validações falhando (agente_id, usuários, perfis)
- ❌ Contadores zerados (0 leads com permissões)

## 🔍 **Causa do Problema:**

A query do n8n **NÃO está incluindo o 4º parâmetro** `permissoes_acesso = $4` no SET!

### **❌ Query Atual (INCORRETA):**
```sql
UPDATE public.lead l
SET reservado_por  = $1,         -- {{$workflow.id}}
    reservado_em   = NOW(),
    reservado_lote = $2,         -- {{$execution.id}}
    agente_id      = $3          -- {{$json.usuario_id}} ✅ NOVO
FROM pegar p
WHERE l.id = p.id
```

### **✅ Query Corrigida (CORRETA):**
```sql
UPDATE public.lead l
SET reservado_por  = $1,         -- {{$workflow.id}}
    reservado_em   = NOW(),
    reservado_lote = $2,         -- {{$execution.id}}
    agente_id      = $3,         -- {{$json.agente_id}} ✅ CORRETO
    permissoes_acesso = $4       -- ✅ NOVO: JSONB com permissões
FROM pegar p
WHERE l.id = p.id
```

## 🔧 **Correções Necessárias no n8n:**

### **1. Adicionar linha no SET:**
```sql
permissoes_acesso = $4       -- ✅ NOVO: JSONB com permissões
```

### **2. Corrigir parâmetro agente_id:**
```sql
agente_id = $3,         -- {{$json.agente_id}} ✅ CORRETO (não usuario_id)
```

### **3. Adicionar 4º parâmetro:**
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

## 🎯 **Query SQL Completa Corrigida:**

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
  l.permissoes_acesso;  -- ✅ NOVO: Incluir permissões
```

## 🚀 **Próximos Passos:**

1. **✅ CORRIGIR** query no n8n (adicionar `permissoes_acesso = $4`)
2. **✅ CORRIGIR** parâmetros (usar `agente_id` e adicionar 4º parâmetro)
3. **✅ TESTAR** execução do workflow
4. **✅ VALIDAR** se permissões estão sendo criadas

**O problema está na query do n8n - falta o 4º parâmetro! 🔧**
