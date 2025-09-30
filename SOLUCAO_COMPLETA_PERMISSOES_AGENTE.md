# ✅ Solução Completa: Permissões de Acesso por Agente

## 🎯 **Arquitetura Identificada:**

### **📋 Fluxo Correto:**
1. **Upload:** `usuario_id` → `lead` (base comum, sem `agente_id`)
2. **Atribuição:** `agente_usuario_atribuicoes` (relaciona usuário ↔ agente)
3. **Início Prospecção:** Reserva leads + define permissões de acesso
4. **Lista Prospecção:** Cruza `usuario_id` com permissões do agente

## 🔧 **Implementação:**

### **✅ 1. Adicionar Coluna JSONB na Tabela `lead`:**

```sql
-- Adicionar coluna para permissões de acesso do agente
ALTER TABLE public.lead 
ADD COLUMN permissoes_acesso JSONB DEFAULT '{}'::jsonb;

-- Adicionar índice para performance
CREATE INDEX idx_lead_permissoes_acesso ON public.lead USING GIN (permissoes_acesso);
```

### **✅ 2. Estrutura do JSONB `permissoes_acesso`:**

```json
{
  "agente_id": 81,
  "reservado_por": "usuario_6",
  "reservado_em": "2025-09-25T15:30:00Z",
  "perfis_permitidos": [1, 3, 4],  // IDs dos perfis que podem acessar
  "usuarios_permitidos": [6, 8, 10],  // IDs dos usuários que podem acessar
  "permissoes_especiais": {
    "pode_editar": true,
    "pode_deletar": false,
    "pode_exportar": true
  }
}
```

### **✅ 3. Query de Reserva de Lotes (Atualizada):**

```sql
-- ✅ QUERY ATUALIZADA: Incluir permissões de acesso
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

### **✅ 4. Parâmetros para Reserva de Lotes:**

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

### **✅ 5. Query de Lista de Prospecção (Atualizada):**

```sql
-- ✅ QUERY ATUALIZADA: Verificar permissões de acesso
SELECT
  l.id, l.client_id, l.nome, l.telefone, l.status, l.contatado,
  l.data_ultima_interacao, l.data_criacao, l.agente_id,
  l.permissoes_acesso  -- ✅ NOVO: Incluir permissões
FROM lead l
WHERE l.agente_id = $3
  AND l.status IN ('prospectando', 'concluido')
  AND COALESCE(l.data_ultima_interacao, l.data_criacao) >= $1::timestamp
  AND COALESCE(l.data_ultima_interacao, l.data_criacao) < $2::timestamp
  -- ✅ NOVO: Verificar permissões de acesso
  AND (
    -- Usuário específico tem permissão
    l.permissoes_acesso->'usuarios_permitidos' @> $4::jsonb
    OR
    -- Perfil do usuário tem permissão
    l.permissoes_acesso->'perfis_permitidos' @> $5::jsonb
    OR
    -- Usuário é o próprio agente
    l.agente_id = $6
  )
ORDER BY COALESCE(l.data_ultima_interacao, l.data_criacao) DESC,
  l.id DESC;
```

### **✅ 6. Parâmetros para Lista de Prospecção:**

```
{{$1}},  -- data_inicio
{{$2}},  -- data_fim
{{$3}},  -- agente_id
{{JSON.stringify([$json.usuario_id])}},  -- usuarios_permitidos
{{JSON.stringify([$json.perfil_id])}},  -- perfis_permitidos
{{$json.usuario_id}}  -- usuario_id (para verificar se é o próprio agente)
```

## 🎉 **Fluxo Completo:**

### **✅ 1. Upload (Base Comum):**
```json
{
  "usuario_id": 6,
  "leads": [
    { "nome": "João", "telefone": "11999999999" },
    { "nome": "Maria", "telefone": "11888888888" }
  ]
}
```

**Resultado na tabela `lead`:**
```json
[
  { "id": 16015, "nome": "João", "agente_id": null, "permissoes_acesso": {} },
  { "id": 16016, "nome": "Maria", "agente_id": null, "permissoes_acesso": {} }
]
```

### **✅ 2. Início da Prospecção:**
```json
{
  "usuario_id": 6,
  "perfil_id": 3,
  "perfis_permitidos": [1, 3, 4],
  "usuarios_permitidos": [6, 8, 10]
}
```

**Resultado na tabela `lead` (após reserva):**
```json
[
  { 
    "id": 16015, 
    "nome": "João", 
    "agente_id": 6, 
    "permissoes_acesso": {
      "agente_id": 6,
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
  }
]
```

### **✅ 3. Lista de Prospecção:**
- Usuário 6: ✅ Pode ver (está em `usuarios_permitidos`)
- Usuário 8: ✅ Pode ver (está em `usuarios_permitidos`)
- Usuário 9: ❌ Não pode ver (não está em `usuarios_permitidos`)
- Usuário com perfil 3: ✅ Pode ver (perfil está em `perfis_permitidos`)

## 🚀 **Vantagens da Solução:**

1. **✅ Flexível:** Permissões por usuário e por perfil
2. **✅ Granular:** Controle fino de permissões especiais
3. **✅ Performante:** Índice GIN para consultas JSONB
4. **✅ Escalável:** Fácil adicionar novas permissões
5. **✅ Auditável:** Histórico de quem reservou e quando

## 🔧 **Próximos Passos:**

1. **Executar SQL:** Adicionar coluna `permissoes_acesso` na tabela `lead`
2. **Atualizar n8n:** Modificar queries de reserva e lista
3. **Testar:** Verificar permissões de acesso
4. **Frontend:** Implementar interface de permissões (opcional)

**Solução completa e flexível implementada! 🚀**
