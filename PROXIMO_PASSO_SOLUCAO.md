# 🚀 Próximo Passo: Implementar Solução de Permissões

## 📋 **Status Atual:**
- ✅ Upload corrigido (base comum, sem agente_id)
- ✅ Permissões organizadas em português
- ✅ Scripts SQL criados
- ⏳ **PRÓXIMO:** Executar SQL para adicionar coluna `permissoes_acesso`

## 🎯 **Próximo Passo Imediato:**

### **1. Executar SQL no Banco de Dados:**
```sql
-- Adicionar coluna permissoes_acesso
ALTER TABLE public.lead 
ADD COLUMN permissoes_acesso JSONB DEFAULT '{}'::jsonb;

-- Criar índices para performance
CREATE INDEX idx_lead_permissoes_acesso ON public.lead USING GIN (permissoes_acesso);
CREATE INDEX idx_lead_agente_permissoes ON public.lead (agente_id, permissoes_acesso) 
WHERE agente_id IS NOT NULL;
```

### **2. Verificar se Coluna Foi Adicionada:**
```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'lead' 
  AND column_name = 'permissoes_acesso';
```

## 🔄 **Fluxo Completo da Solução:**

### **📤 1. UPLOAD (Já Implementado):**
- ✅ Frontend envia leads sem `agente_id`
- ✅ Leads inseridos na base comum
- ✅ `permissoes_acesso = {}` (vazio)

### **🤖 2. INÍCIO DA PROSPECÇÃO (Próximo a Implementar):**
- ⏳ Usuário clica "Iniciar Prospecção"
- ⏳ Sistema reserva lote de 20 leads
- ⏳ Define `agente_id = usuario_id`
- ⏳ Cria `permissoes_acesso` JSONB com permissões

### **📋 3. LISTA DE PROSPECÇÃO (Próximo a Implementar):**
- ⏳ Verifica permissões de acesso
- ⏳ Retorna apenas leads que usuário pode ver

## 🛠️ **Implementação no n8n:**

### **Node 1: "Busca leads não contatados" (Atualizar)**
```sql
-- Query atualizada para incluir permissões
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

### **Node 2: "Buscar o lote reservado" (Atualizar)**
```sql
-- Query atualizada para verificar permissões
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

## 📊 **Parâmetros para n8n:**

### **Reserva de Lotes:**
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

### **Lista de Prospecção:**
```
{{$1}},  -- data_inicio
{{$2}},  -- data_fim
{{$3}},  -- agente_id
{{JSON.stringify([$json.usuario_id])}},  -- usuarios_permitidos
{{JSON.stringify([$json.perfil_id])}},  -- perfis_permitidos
{{$json.usuario_id}}  -- usuario_id (para verificar se é o próprio agente)
```

## 🎯 **Próximos Passos:**

1. **✅ EXECUTAR SQL** - Adicionar coluna `permissoes_acesso`
2. **⏳ ATUALIZAR N8N** - Modificar queries de reserva e lista
3. **⏳ TESTAR** - Verificar permissões de acesso
4. **⏳ VALIDAR** - Confirmar funcionamento completo

**Solução pronta para implementação! 🚀**
