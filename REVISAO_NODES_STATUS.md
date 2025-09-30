# 🔍 Revisão dos Nodes de Status - Prospectando e Concluído

## 🎯 **Objetivo:**
Revisar e atualizar os nodes que alteram status para "prospectando" e "concluído" para garantir que respeitem as permissões de acesso.

## 📋 **Nodes que Precisam ser Revisados:**

### **1. Node "Atualiza status do lead - prospectando"**
- **Função:** Altera status para "prospectando"
- **Localização:** No fluxo de início da prospecção
- **Necessário:** Verificar permissões antes de alterar

### **2. Node "Atualiza status do lead - prospectando1"**
- **Função:** Altera status para "concluído"
- **Localização:** No fluxo de finalização
- **Necessário:** Verificar permissões antes de alterar

## 🔧 **Queries Atuais (Precisam ser Atualizadas):**

### **❌ Query Atual - "Atualiza status do lead - prospectando":**
```sql
WITH upd AS (
  UPDATE public.lead AS l
  SET
    status                = 'prospectando',
    data_ultima_interacao = NOW(),
    agente_id             = $5
  WHERE l.id = $1
    AND l.reservado_por  = $2
    AND l.reservado_lote = $3
  RETURNING
    l.id, l.client_id, l.nome_cliente, l.telefone, l.canal,
    l.status, l.data_ultima_interacao, l.reservado_por, l.reservado_lote,
    l.agente_id
),
fb AS (
  SELECT
    l.id, l.client_id, l.nome_cliente, l.telefone, l.canal,
    l.status, l.data_ultima_interacao, l.reservado_por, l.reservado_lote,
    l.agente_id
  FROM public.lead l
  WHERE l.id = $1
  LIMIT 1
),
row_out AS (
  SELECT * FROM upd
  UNION ALL
  SELECT * FROM fb WHERE NOT EXISTS (SELECT 1 FROM upd)
)
SELECT
  row_out.id,
  row_out.client_id,
  row_out.nome_cliente,
  row_out.telefone,
  row_out.canal,
  row_out.status,
  row_out.data_ultima_interacao,
  row_out.reservado_por,
  row_out.reservado_lote,
  row_out.agente_id,
  p.mensagem,
  COALESCE(p.turno, 'indefinido') AS turno
FROM row_out
CROSS JOIN LATERAL jsonb_to_record($4::jsonb) AS p(
  mensagem text,
  turno     text
);
```

## ✅ **Queries Corrigidas (Com Verificação de Permissões):**

### **1. Node "Atualiza status do lead - prospectando" (Corrigido):**
```sql
WITH upd AS (
  UPDATE public.lead AS l
  SET
    status                = 'prospectando',
    data_ultima_interacao = NOW(),
    agente_id             = $5
  WHERE l.id = $1
    AND l.reservado_por  = $2
    AND l.reservado_lote = $3
    -- ✅ NOVO: Verificar permissões de acesso
    AND (
      l.permissoes_acesso->'usuarios_permitidos' @> $6::jsonb
      OR
      l.permissoes_acesso->'perfis_permitidos' @> $7::jsonb
      OR
      l.agente_id = $8
    )
  RETURNING
    l.id, l.client_id, l.nome_cliente, l.telefone, l.canal,
    l.status, l.data_ultima_interacao, l.reservado_por, l.reservado_lote,
    l.agente_id, l.permissoes_acesso
),
fb AS (
  SELECT
    l.id, l.client_id, l.nome_cliente, l.telefone, l.canal,
    l.status, l.data_ultima_interacao, l.reservado_por, l.reservado_lote,
    l.agente_id, l.permissoes_acesso
  FROM public.lead l
  WHERE l.id = $1
  LIMIT 1
),
row_out AS (
  SELECT * FROM upd
  UNION ALL
  SELECT * FROM fb WHERE NOT EXISTS (SELECT 1 FROM upd)
)
SELECT
  row_out.id,
  row_out.client_id,
  row_out.nome_cliente,
  row_out.telefone,
  row_out.canal,
  row_out.status,
  row_out.data_ultima_interacao,
  row_out.reservado_por,
  row_out.reservado_lote,
  row_out.agente_id,
  row_out.permissoes_acesso,
  p.mensagem,
  COALESCE(p.turno, 'indefinido') AS turno
FROM row_out
CROSS JOIN LATERAL jsonb_to_record($4::jsonb) AS p(
  mensagem text,
  turno     text
);
```

### **2. Node "Atualiza status do lead - prospectando1" (Corrigido):**
```sql
WITH upd AS (
  UPDATE public.lead AS l
  SET
    status                = 'concluido',
    data_ultima_interacao = NOW(),
    agente_id             = $5
  WHERE l.id = $1
    AND l.reservado_por  = $2
    AND l.reservado_lote = $3
    -- ✅ NOVO: Verificar permissões de acesso
    AND (
      l.permissoes_acesso->'usuarios_permitidos' @> $6::jsonb
      OR
      l.permissoes_acesso->'perfis_permitidos' @> $7::jsonb
      OR
      l.agente_id = $8
    )
  RETURNING
    l.id, l.client_id, l.nome_cliente, l.telefone, l.canal,
    l.status, l.data_ultima_interacao, l.reservado_por, l.reservado_lote,
    l.agente_id, l.permissoes_acesso
),
fb AS (
  SELECT
    l.id, l.client_id, l.nome_cliente, l.telefone, l.canal,
    l.status, l.data_ultima_interacao, l.reservado_por, l.reservado_lote,
    l.agente_id, l.permissoes_acesso
  FROM public.lead l
  WHERE l.id = $1
  LIMIT 1
),
row_out AS (
  SELECT * FROM upd
  UNION ALL
  SELECT * FROM fb WHERE NOT EXISTS (SELECT 1 FROM upd)
)
SELECT
  row_out.id,
  row_out.client_id,
  row_out.nome_cliente,
  row_out.telefone,
  row_out.canal,
  row_out.status,
  row_out.data_ultima_interacao,
  row_out.reservado_por,
  row_out.reservado_lote,
  row_out.agente_id,
  row_out.permissoes_acesso,
  p.mensagem,
  COALESCE(p.turno, 'indefinido') AS turno
FROM row_out
CROSS JOIN LATERAL jsonb_to_record($4::jsonb) AS p(
  mensagem text,
  turno     text
);
```

## 📋 **Parâmetros Atualizados:**

### **Para ambos os nodes:**
```
{{$json.id}},  // $1 - id do lead
{{$json.reservado_por}},  // $2 - reservado_por
{{$json.reservado_lote}},  // $3 - reservado_lote
{{JSON.stringify({ mensagem: $json.mensagem, turno: $json.turno })}},  // $4 - mensagem e turno
{{$json.agente_id}},  // $5 - agente_id
{{JSON.stringify($json.usuarios_permitidos)}},  // $6 - usuarios_permitidos (NOVO)
{{JSON.stringify($json.perfis_permitidos)}},  // $7 - perfis_permitidos (NOVO)
{{$json.agente_id}}  // $8 - agente_id para verificação (NOVO)
```

## 🎯 **Principais Mudanças:**

1. **✅ Adicionar verificação de permissões** no WHERE
2. **✅ Incluir `l.permissoes_acesso`** no RETURNING
3. **✅ Adicionar 3 novos parâmetros** para verificação
4. **✅ Manter compatibilidade** com fluxo existente

## 🚀 **Próximos Passos:**

1. **✅ ATUALIZAR** query "Atualiza status do lead - prospectando"
2. **✅ ATUALIZAR** query "Atualiza status do lead - prospectando1"
3. **✅ ATUALIZAR** parâmetros de ambos os nodes
4. **✅ TESTAR** funcionamento com permissões

**Sim, precisamos revisar esses nodes para garantir segurança! 🔒**
