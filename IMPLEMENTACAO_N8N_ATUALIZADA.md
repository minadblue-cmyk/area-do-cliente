# 🚀 Implementação n8n Atualizada - Permissões de Acesso

## ✅ **Status:**
- ✅ Coluna `permissoes_acesso` adicionada na tabela `lead`
- ⏳ **PRÓXIMO:** Atualizar queries no n8n

## 🔧 **Queries para Atualizar no n8n:**

### **1. Node "Busca leads não contatados" (Atualizar)**

**Query Atualizada:**
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
  l.reservado_lote,
  l.reservado_por,
  l.reservado_em,
  l.agente_id,
  l.permissoes_acesso;  -- ✅ NOVO
```

**Parâmetros Atualizados:**
```
{{$workflow.id}}, 
{{$execution.id}}, 
{{$json.usuario_id}}, 
{{JSON.stringify({
  "agente_id": $json.usuario_id,
  "reservado_por": "usuario_" + $json.usuario_id,
  "reservado_em": $now.toISO(),
  "perfis_permitidos": $json.perfis_permitidos || [],
  "usuarios_permitidos": $json.usuarios_permitidos || [$json.usuario_id],
  "permissoes_especiais": {
    "pode_editar": true,
    "pode_deletar": false,
    "pode_exportar": true
  }
})}}
```

### **2. Node "Buscar o lote reservado" (Atualizar)**

**Query Atualizada:**
```sql
SELECT
  l.id, l.client_id, l.nome_cliente, l.telefone, l.canal,
  l.status, l.data_ultima_interacao, l.reservado_por, l.reservado_lote,
  l.agente_id, l.permissoes_acesso  -- ✅ NOVO
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

**Parâmetros Atualizados:**
```
{{$item(0).$json.reservado_lote}},  -- reservado_lote
{{JSON.stringify([$json.usuario_id])}},  -- usuarios_permitidos
{{JSON.stringify([$json.perfil_id])}},  -- perfis_permitidos
{{$json.usuario_id}}  -- usuario_id (para verificar se é o próprio agente)
```

### **3. Node "Lista de Prospecção" (Atualizar)**

**Query Atualizada:**
```sql
SELECT
  l.id, l.client_id, l.nome, l.telefone, l.status, l.contatado,
  l.data_ultima_interacao, l.data_criacao, l.agente_id,
  l.permissoes_acesso  -- ✅ NOVO
FROM lead l
WHERE l.agente_id = $3
  AND l.status IN ('prospectando', 'concluido')
  AND COALESCE(l.data_ultima_interacao, l.data_criacao) >= $1::timestamp
  AND COALESCE(l.data_ultima_interacao, l.data_criacao) < $2::timestamp
  -- ✅ NOVO: Verificar permissões de acesso
  AND (
    l.permissoes_acesso->'usuarios_permitidos' @> $4::jsonb
    OR
    l.permissoes_acesso->'perfis_permitidos' @> $5::jsonb
    OR
    l.agente_id = $6
  )
ORDER BY COALESCE(l.data_ultima_interacao, l.data_criacao) DESC,
  l.id DESC;
```

**Parâmetros Atualizados:**
```
{{$1}},  -- data_inicio
{{$2}},  -- data_fim
{{$3}},  -- agente_id
{{JSON.stringify([$json.usuario_id])}},  -- usuarios_permitidos
{{JSON.stringify([$json.perfil_id])}},  -- perfis_permitidos
{{$json.usuario_id}}  -- usuario_id (para verificar se é o próprio agente)
```

## 🎯 **Estrutura do JSONB `permissoes_acesso`:**

```json
{
  "agente_id": 81,
  "reservado_por": "usuario_6",
  "reservado_em": "2025-09-25T15:30:00Z",
  "perfis_permitidos": [1, 3, 4],
  "usuarios_permitidos": [6, 8, 10],
  "permissoes_especiais": {
    "pode_editar": true,
    "pode_deletar": false,
    "pode_exportar": true
  }
}
```

## 🔄 **Fluxo Atualizado:**

### **1. Upload (Base Comum):**
- ✅ Leads inseridos sem `agente_id`
- ✅ `permissoes_acesso = {}` (vazio)

### **2. Início da Prospecção:**
- ⏳ Sistema reserva lote de 20 leads
- ⏳ Define `agente_id = usuario_id`
- ⏳ Cria `permissoes_acesso` JSONB com permissões

### **3. Lista de Prospecção:**
- ⏳ Verifica permissões de acesso
- ⏳ Retorna apenas leads que usuário pode ver

## 🚀 **Próximos Passos:**

1. **✅ EXECUTAR SQL** - Coluna `permissoes_acesso` adicionada
2. **⏳ ATUALIZAR N8N** - Modificar queries conforme acima
3. **⏳ TESTAR** - Verificar permissões de acesso
4. **⏳ VALIDAR** - Confirmar funcionamento completo

**Implementação n8n pronta para atualização! 🚀**
