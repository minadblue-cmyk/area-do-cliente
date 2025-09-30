# 📋 Parâmetros para "Buscar o lote reservado"

## 🎯 **Query Parameters Corretos:**

### **Para o node "Buscar o lote reservado":**

```
{{$item(0).$json.reservado_lote}},  // $1 - reservado_lote
{{JSON.stringify($json.usuarios_permitidos)}},  // $2 - usuarios_permitidos
{{JSON.stringify($json.perfis_permitidos)}},  // $3 - perfis_permitidos
{{$json.agente_id}}  // $4 - agente_id
```

## 🔍 **Explicação dos Parâmetros:**

### **$1 - reservado_lote:**
- **Valor:** `{{$item(0).$json.reservado_lote}}`
- **Exemplo:** `"117624"`
- **Origem:** Do node anterior "Busca leads não contatados"

### **$2 - usuarios_permitidos:**
- **Valor:** `{{JSON.stringify($json.usuarios_permitidos)}}`
- **Exemplo:** `"[6, 8, 10]"`
- **Origem:** Do payload do webhook start

### **$3 - perfis_permitidos:**
- **Valor:** `{{JSON.stringify($json.perfis_permitidos)}}`
- **Exemplo:** `"[1, 3, 4]"`
- **Origem:** Do payload do webhook start

### **$4 - agente_id:**
- **Valor:** `{{$json.agente_id}}`
- **Exemplo:** `81`
- **Origem:** Do payload do webhook start

## 📊 **Exemplo Completo dos Parâmetros:**

```
{{$item(0).$json.reservado_lote}}, {{JSON.stringify($json.usuarios_permitidos)}}, {{JSON.stringify($json.perfis_permitidos)}}, {{$json.agente_id}}
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

**Use esses parâmetros no node "Buscar o lote reservado"! 🚀**
