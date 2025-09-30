# 📋 Parâmetros Corretos para "Buscar o lote reservado"

## 🎯 **Payload Recebido:**
- **10 leads** com `reservado_lote: "117624"`
- **Permissões completas** em cada lead
- **Dados prontos** para verificação de permissões

## 🔧 **Query Parameters Corretos:**

### **Para o node "Buscar o lote reservado":**

```
{{$item(0).$json.reservado_lote}},  // $1 - reservado_lote
{{JSON.stringify($item(0).$json.permissoes_acesso.usuarios_permitidos)}},  // $2 - usuarios_permitidos
{{JSON.stringify($item(0).$json.permissoes_acesso.perfis_permitidos)}},  // $3 - perfis_permitidos
{{$item(0).$json.agente_id}}  // $4 - agente_id
```

## 🔍 **Explicação dos Parâmetros:**

### **$1 - reservado_lote:**
- **Valor:** `{{$item(0).$json.reservado_lote}}`
- **Resultado:** `"117624"`
- **Origem:** Do payload recebido

### **$2 - usuarios_permitidos:**
- **Valor:** `{{JSON.stringify($item(0).$json.permissoes_acesso.usuarios_permitidos)}}`
- **Resultado:** `"[6, 8, 10]"`
- **Origem:** Do campo `permissoes_acesso.usuarios_permitidos`

### **$3 - perfis_permitidos:**
- **Valor:** `{{JSON.stringify($item(0).$json.permissoes_acesso.perfis_permitidos)}}`
- **Resultado:** `"[1, 3, 4]"`
- **Origem:** Do campo `permissoes_acesso.perfis_permitidos`

### **$4 - agente_id:**
- **Valor:** `{{$item(0).$json.agente_id}}`
- **Resultado:** `81`
- **Origem:** Do campo `agente_id`

## 📊 **Exemplo Completo dos Parâmetros:**

```
{{$item(0).$json.reservado_lote}}, {{JSON.stringify($item(0).$json.permissoes_acesso.usuarios_permitidos)}}, {{JSON.stringify($item(0).$json.permissoes_acesso.perfis_permitidos)}}, {{$item(0).$json.agente_id}}
```

**Resultado esperado:**
```
117624, [6, 8, 10], [1, 3, 4], 81
```

## 🎯 **Query SQL Completa:**

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

## ✅ **Validação dos Parâmetros:**

### **Teste de Permissões:**
- **Usuário 6:** ✅ Deve ter acesso (está em `usuarios_permitidos`)
- **Usuário 8:** ✅ Deve ter acesso (está em `usuarios_permitidos`)
- **Usuário 9:** ❌ Não deve ter acesso (não está em `usuarios_permitidos`)
- **Perfil 3:** ✅ Deve ter acesso (está em `perfis_permitidos`)
- **Perfil 5:** ❌ Não deve ter acesso (não está em `perfis_permitidos`)

## 🚀 **Diferença Importante:**

### **❌ ANTES (Incorreto):**
```
{{$json.usuarios_permitidos}}  // Vem do payload inicial
```

### **✅ AGORA (Correto):**
```
{{$item(0).$json.permissoes_acesso.usuarios_permitidos}}  // Vem do payload processado
```

**Use esses parâmetros corretos no node "Buscar o lote reservado"! 🚀**
