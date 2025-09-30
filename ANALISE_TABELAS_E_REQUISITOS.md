# 📋 Análise das Tabelas e Requisitos

## 🗄️ **Tabelas Identificadas:**

### **1. `usuarios` (11 colunas)**
- `id` (PK), `email`, `senha`, `created_at`, `nome`, `perfil`, `ativo`, `empresa`, `plano`, `empresa_id`, `perfil_id`

### **2. `agentes_config` (17 colunas)**
- `id` (PK), `nome`, `descricao`, `icone`, `cor`, `ativo`, `created_at`, `updated_at`
- **Workflows:** `workflow_start_id`, `workflow_status_id`, `workflow_lista_id`, `workflow_stop_id`
- **Webhooks:** `webhook_start_url`, `webhook_status_url`, `webhook_lista_url`, `webhook_stop_url`
- `usuario_id` (FK para usuarios)

### **3. `agente_usuario_atribuicoes` (6 colunas)**
- `id` (PK), `agente_id` (FK), `usuario_id` (FK), `atribuido_por`, `created_at`, `updated_at`

### **4. `lead` (26 colunas)**
- `id` (PK), `nome`, `canal`, `estagio_funnel`, `pergunta_index`, `ultima_pergunta`, `ultima_resposta`, `respostas`
- `data_criacao`, `data_ultima_interacao`, `telefone`, `contatado`, `client_id`, `status`, `nome_cliente`
- `fonte_prospec`, `idade`, `profissao`, `estado_civil`, `filhos`, `qtd_filhos`, `data_insercao`
- **Reserva:** `reservado_por`, `reservado_em`, `reservado_lote`
- **Agente:** `agente_id`, `perfil_id`

## 🎯 **Requisitos Identificados:**

### **✅ 1. Upload de Leads:**
- `usuario_id` faz upload na tabela `lead`
- **NÃO** precisa de `agente_id` no momento do upload
- Leads vão para base comum

### **✅ 2. Atribuição de Agentes:**
- Usuário tem agentes atribuídos via `agente_usuario_atribuicoes`
- Relacionamento: `usuario_id` ↔ `agente_id`

### **✅ 3. Início da Prospecção:**
- Quando usuário clica "iniciar prospecção"
- Sistema reserva leads para o agente
- **NOVO:** Adicionar JSONB com perfis que podem acessar o agente

### **✅ 4. Lista de Prospecção:**
- Cruzar `usuario_id` com permissões de acesso do agente
- Verificar se usuário tem permissão para ver leads do agente

## 🔧 **Solução Proposta:**

### **✅ 1. Adicionar Coluna JSONB na Tabela `lead`:**

```sql
-- Adicionar coluna para permissões de acesso
ALTER TABLE public.lead 
ADD COLUMN permissoes_acesso JSONB DEFAULT '[]'::jsonb;
```

### **✅ 2. Estrutura do JSONB `permissoes_acesso`:**

```json
{
  "perfis_permitidos": [1, 3, 4],  // IDs dos perfis que podem acessar
  "usuarios_permitidos": [6, 8, 10],  // IDs dos usuários que podem acessar
  "agente_id": 81,  // ID do agente que reservou
  "reservado_em": "2025-09-25T15:30:00Z",
  "reservado_por": "usuario_6"
}
```

### **✅ 3. Query de Reserva de Lotes (Atualizada):**

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

### **✅ 4. Query de Lista de Prospecção (Atualizada):**

```sql
SELECT
  l.id, l.client_id, l.nome, l.telefone, l.status, l.contatado,
  l.data_ultima_interacao, l.data_criacao, l.agente_id
FROM lead l
WHERE l.agente_id = $3
  AND l.status IN ('prospectando', 'concluido')
  AND COALESCE(l.data_ultima_interacao, l.data_criacao) >= $1::timestamp
  AND COALESCE(l.data_ultima_interacao, l.data_criacao) < $2::timestamp
  -- ✅ NOVO: Verificar permissões de acesso
  AND (
    l.permissoes_acesso->>'usuarios_permitidos' @> $4::jsonb  -- Usuário tem permissão
    OR l.permissoes_acesso->>'perfis_permitidos' @> $5::jsonb  -- Perfil tem permissão
  )
ORDER BY COALESCE(l.data_ultima_interacao, l.data_criacao) DESC,
  l.id DESC;
```

## 🚀 **Fluxo Completo:**

### **1. Upload (Base Comum):**
```json
{
  "usuario_id": 6,
  "leads": [...],
  "agente_id": null,  // Não definido ainda
  "permissoes_acesso": null  // Não definido ainda
}
```

### **2. Início da Prospecção:**
```json
{
  "agente_id": 81,
  "permissoes_acesso": {
    "perfis_permitidos": [1, 3, 4],
    "usuarios_permitidos": [6, 8, 10],
    "agente_id": 81,
    "reservado_em": "2025-09-25T15:30:00Z",
    "reservado_por": "usuario_6"
  }
}
```

### **3. Lista de Prospecção:**
- Verificar se `usuario_id` está em `usuarios_permitidos`
- Verificar se `perfil_id` do usuário está em `perfis_permitidos`
- Retornar apenas leads que o usuário tem permissão para ver

**Solução completa e flexível! 🚀**
