# 🔧 Correções Necessárias no n8n - Status Agente

## 🚨 Problemas Identificados

### 1. **Node "Normalização" - workflow_id Incorreto**

**❌ Configuração Atual:**
```
workflow_id: {{ $workflow.id }}
```

**✅ Configuração Correta:**
```
workflow_id: {{ $json.query.workflow_id }}
```

**📝 Explicação:**
- `$workflow.id` retorna o ID do workflow n8n atual (ex: `AwYrhj5Z6z4K0Mgv`)
- `$json.query.workflow_id` retorna o ID do agente da requisição (ex: `prospeccao-quente`)

---

### 2. **Node PostgreSQL - Campos Inexistentes**

**❌ Query Atual (com erro):**
```sql
SELECT
    id,
    execution_id,
    workflow_id,
    usuario_id,
    usuario_nome,        -- ❌ COLUNA NÃO EXISTE
    usuario_email,      -- ❌ COLUNA NÃO EXISTE
    status,
    iniciado_em,
    parado_em,
    payload_inicial,
    payload_parada,
    CASE
        WHEN status = 'running' THEN 'Agente em execução'
        WHEN status = 'stopped' THEN 'Agente parado'
        WHEN status = 'error' THEN 'Agente com erro'
        WHEN status = 'completed' THEN 'Agente concluído'
        ELSE 'Status desconhecido'
    END as message
FROM agente_execucoes
WHERE usuario_id = $1
AND workflow_id = $2
AND ($3 IS NULL OR status = $3)
ORDER BY iniciado_em DESC;
```

**✅ Query Corrigida:**
```sql
SELECT
    id,
    execution_id,
    workflow_id,
    usuario_id,
    status,
    iniciado_em,
    parado_em,
    payload_inicial,
    payload_parada,
    CASE
        WHEN status = 'running' THEN 'Agente em execução'
        WHEN status = 'stopped' THEN 'Agente parado'
        WHEN status = 'error' THEN 'Agente com erro'
        WHEN status = 'completed' THEN 'Agente concluído'
        ELSE 'Status desconhecido'
    END as message,
    EXTRACT(EPOCH FROM (NOW() - iniciado_em)) as tempo_execucao_segundos
FROM agente_execucoes
WHERE usuario_id = $1
AND workflow_id = $2
AND ($3 IS NULL OR status = $3)
ORDER BY iniciado_em DESC
LIMIT 10;
```

---

### 3. **Parâmetros PostgreSQL - Limpeza**

**❌ Configuração Atual:**
```
$1 = {{ $json.usuario_id }}
$2 = {{ $json.workflow_id }}
$3 = {{ $json.status }}
=5                           -- ❌ PARÂMETRO EXTRA
=AwYrhj5Z6z4K0Mgv =         -- ❌ PARÂMETRO EXTRA
```

**✅ Configuração Correta:**
```
$1 = {{ $json.usuario_id }}
$2 = {{ $json.workflow_id }}
$3 = {{ $json.status }}
```

---

### 4. **Node Response - Adicionar se Não Existir**

**❌ Problema:** Workflow não tem node de resposta

**✅ Solução:** Adicionar node "Respond to Webhook" após PostgreSQL

**Configuração:**
- **Response Code:** `200`
- **Response Headers:**
```json
{
  "Content-Type": "application/json",
  "Access-Control-Allow-Origin": "*"
}
```
- **Response Body:**
```json
{
  "success": "{{ $json.length > 0 }}",
  "message": "{{ $json.length > 0 ? 'Consulta realizada com sucesso' : 'Nenhuma execução encontrada' }}",
  "data": {
    "usuario_id": "{{ $('Normalização').item.json.usuario_id }}",
    "workflow_id": "{{ $('Normalização').item.json.workflow_id }}",
    "count": "{{ $json.length }}",
    "executions": "{{ $json }}"
  },
  "timestamp": "{{ $now }}"
}
```

---

## 🎯 Passos para Corrigir

### **Passo 1: Corrigir Node "Normalização"**
1. Abra o node "Normalização"
2. Encontre o campo `workflow_id`
3. Altere de `{{ $workflow.id }}` para `{{ $json.query.workflow_id }}`
4. Salve as alterações

### **Passo 2: Corrigir Node PostgreSQL**
1. Abra o node "Buscar Status Agente"
2. Substitua a query SQL pela versão corrigida
3. Remova os parâmetros extras (`=5` e `=AwYrhj5Z6z4K0Mgv =`)
4. Mantenha apenas os 3 parâmetros necessários
5. Salve as alterações

### **Passo 3: Adicionar Node Response (se necessário)**
1. Adicione um node "Respond to Webhook" após o PostgreSQL
2. Configure conforme especificado acima
3. Conecte o PostgreSQL ao Response
4. Salve o workflow

### **Passo 4: Testar**
1. Ative o workflow
2. Teste com uma requisição GET
3. Verifique se retorna dados corretos

---

## 🔍 Verificação Final

Após as correções, o workflow deve:
- ✅ Receber `workflow_id` correto da query
- ✅ Executar query SQL sem erros
- ✅ Retornar dados em formato JSON
- ✅ Permitir que botões "Parar" sejam habilitados quando agente estiver rodando

---

## 📋 Checklist de Correções

- [ ] Node "Normalização": `workflow_id` corrigido
- [ ] Node PostgreSQL: Query SQL corrigida
- [ ] Node PostgreSQL: Parâmetros limpos
- [ ] Node Response: Adicionado e configurado
- [ ] Workflow: Salvo e ativado
- [ ] Teste: Requisição GET funcionando
- [ ] Frontend: Botões funcionando corretamente
