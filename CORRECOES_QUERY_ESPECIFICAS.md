# 🔧 Correções Específicas na Query

## ❌ **Problemas Identificados:**

### **1. FALTA linha no SET:**
```sql
-- ❌ ATUAL (INCORRETO):
SET reservado_por  = $1,         -- {{$workflow.id}}
    reservado_em   = NOW(),
    reservado_lote = $2,         -- {{$execution.id}}
    agente_id      = $3          -- {{$json.usuario_id}} ✅ NOVO
```

### **2. PARÂMETRO INCORRETO:**
```sql
-- ❌ ATUAL (INCORRETO):
agente_id      = $3          -- {{$json.usuario_id}} ✅ NOVO
```

## ✅ **Correções Necessárias:**

### **1. Adicionar linha no SET:**
```sql
-- ✅ CORRIGIDO:
SET reservado_por  = $1,         -- {{$workflow.id}}
    reservado_em   = NOW(),
    reservado_lote = $2,         -- {{$execution.id}}
    agente_id      = $3,         -- {{$json.agente_id}} ✅ CORRETO
    permissoes_acesso = $4       -- ✅ NOVO: JSONB com permissões
```

### **2. Corrigir parâmetro:**
```sql
-- ❌ ANTES:
agente_id      = $3          -- {{$json.usuario_id}} ✅ NOVO

-- ✅ DEPOIS:
agente_id      = $3,         -- {{$json.agente_id}} ✅ CORRETO
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
  l.reservado_lote,               -- <<< traga o lote
  l.reservado_por,
  l.reservado_em,
  l.agente_id,                    -- ✅ NOVO
  l.permissoes_acesso;            -- ✅ NOVO: Incluir permissões
```

## 📋 **Parâmetros Corretos:**

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

## 🚀 **Resumo das Correções:**

1. **✅ ADICIONAR:** `permissoes_acesso = $4` no SET
2. **✅ CORRIGIR:** `{{$json.usuario_id}}` para `{{$json.agente_id}}`
3. **✅ ADICIONAR:** 4º parâmetro com JSONB de permissões

**Essas são as 3 correções necessárias! 🔧**
