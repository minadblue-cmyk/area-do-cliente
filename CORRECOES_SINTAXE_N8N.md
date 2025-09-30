# 🔧 Correções de Sintaxe para n8n - Node "Busca leads não contatados"

## 📋 **Correções Necessárias:**

### **1. Query SQL - Adicionar `permissoes_acesso` no SET:**

**❌ ATUAL (sem permissões):**
```sql
UPDATE public.lead l
SET reservado_por  = $1,         -- {{$workflow.id}}
    reservado_em   = NOW(),
    reservado_lote = $2,         -- {{$execution.id}}
    agente_id      = $3          -- {{$json.usuario_id}}
FROM pegar p
WHERE l.id = p.id
```

**✅ CORRIGIDO (com permissões):**
```sql
UPDATE public.lead l
SET reservado_por  = $1,         -- {{$workflow.id}}
    reservado_em   = NOW(),
    reservado_lote = $2,         -- {{$execution.id}}
    agente_id      = $3,         -- {{$json.usuario_id}}
    permissoes_acesso = $4       -- ✅ NOVO: JSONB com permissões
FROM pegar p
WHERE l.id = p.id
```

### **2. Query SQL - Adicionar `permissoes_acesso` no RETURNING:**

**❌ ATUAL (sem permissões):**
```sql
RETURNING
  l.id,
  l.reservado_lote,               -- <<< traga o lote
  l.reservado_por,
  l.reservado_em,
  l.agente_id;                    -- ✅ NOVO
```

**✅ CORRIGIDO (com permissões):**
```sql
RETURNING
  l.id,
  l.reservado_lote,               -- <<< traga o lote
  l.reservado_por,
  l.reservado_em,
  l.agente_id,                    -- ✅ NOVO
  l.permissoes_acesso;            -- ✅ NOVO: Incluir permissões
```

### **3. Query Parameters - Adicionar 4º parâmetro:**

**❌ ATUAL (3 parâmetros):**
```
{{$workflow.id}}, {{$execution.id}},{{ $json.body.usuario_id }}
```

**✅ CORRIGIDO (4 parâmetros):**
```
{{$workflow.id}}, {{$execution.id}}, {{$json.body.usuario_id}}, {{JSON.stringify({
  "agente_id": $json.body.usuario_id,
  "reservado_por": "usuario_" + $json.body.usuario_id,
  "reservado_em": $now.toISO(),
  "perfis_permitidos": $json.perfis_permitidos || [],
  "usuarios_permitidos": $json.usuarios_permitidos || [$json.body.usuario_id],
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
    agente_id      = $3,         -- {{$json.usuario_id}}
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

## 📊 **Estrutura do JSONB `permissoes_acesso`:**

```json
{
  "agente_id": 6,
  "reservado_por": "usuario_6",
  "reservado_em": "2025-09-25T17:26:35.766Z",
  "perfis_permitidos": [],
  "usuarios_permitidos": [6],
  "permissoes_especiais": {
    "pode_editar": true,
    "pode_deletar": false,
    "pode_exportar": true
  }
}
```

## 🚀 **Passos para Implementar:**

1. **✅ Adicionar linha no SET:** `permissoes_acesso = $4`
2. **✅ Adicionar linha no RETURNING:** `l.permissoes_acesso;`
3. **✅ Adicionar 4º parâmetro:** JSONB com permissões
4. **✅ Testar** a execução do node

**Implementação pronta para aplicar no n8n! 🚀**
