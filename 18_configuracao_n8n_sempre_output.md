# 🔧 Configuração n8n para Sempre Retornar Dados

## 🚨 Problema Atual
- **"No output data returned"** quando não há registros na tabela
- Workflow para de executar quando PostgreSQL não retorna dados

## ✅ Soluções

### **Solução 1: Configurar n8n para Sempre Retornar Dados**

1. **Acesse as Configurações do n8n:**
   - Vá para **Settings** (Configurações)
   - Procure por **"Always Output Data"**
   - **Ative** esta opção

2. **Configuração do Node PostgreSQL:**
   - Abra o node "Buscar Status Agente"
   - Vá para a aba **"Settings"**
   - Procure por **"Continue on Fail"** ou **"Always Output Data"**
   - **Ative** esta opção

### **Solução 2: Modificar a Query SQL**

**Substitua a query atual por esta versão que sempre retorna dados:**

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
LIMIT 10

UNION ALL

-- Se não houver resultados, retorna uma linha vazia
SELECT
    NULL as id,
    NULL as execution_id,
    $2 as workflow_id,
    $1 as usuario_id,
    'disconnected' as status,
    NULL as iniciado_em,
    NULL as parado_em,
    NULL as payload_inicial,
    NULL as payload_parada,
    'Agente não iniciado' as message,
    0 as tempo_execucao_segundos
WHERE NOT EXISTS (
    SELECT 1 FROM agente_execucoes 
    WHERE usuario_id = $1 
    AND workflow_id = $2
    AND ($3 IS NULL OR status = $3)
);
```

### **Solução 3: Adicionar Node de Fallback**

1. **Adicione um node "Set" após o PostgreSQL:**
   - Nome: "Fallback Status"
   - Configuração:
   ```json
   {
     "success": "{{ $json.length > 0 }}",
     "message": "{{ $json.length > 0 ? 'Consulta realizada com sucesso' : 'Nenhuma execução encontrada' }}",
     "data": {
       "usuario_id": "{{ $('Normalização').item.json.usuario_id }}",
       "workflow_id": "{{ $('Normalização').item.json.workflow_id }}",
       "count": "{{ $json.length }}",
       "executions": "{{ $json.length > 0 ? $json : [] }}"
     },
     "timestamp": "{{ $now }}"
   }
   ```

2. **Conecte os nodes:**
   - PostgreSQL → Fallback Status → Response

### **Solução 4: Testar com Dados de Exemplo**

**Execute este script para inserir dados de teste:**

```sql
-- Inserir dados de teste
INSERT INTO agente_execucoes (
    execution_id,
    workflow_id,
    usuario_id,
    status,
    iniciado_em,
    payload_inicial
) VALUES (
    'test-execution-123',
    'agente-prospeccao-quente',
    5,
    'running',
    NOW(),
    '{"action": "start", "usuario_id": 5}'::jsonb
);
```

## 🎯 Passos Recomendados

1. **Primeiro**: Execute o script `16_verificar_dados_agente_execucoes.sql` para ver se há dados
2. **Se não houver dados**: Execute o script de inserção de teste
3. **Se houver dados**: Use a Solução 1 (configurar n8n)
4. **Teste**: Faça uma requisição GET para o webhook

## 🔍 Verificação

Após implementar uma das soluções:
- ✅ Webhook deve retornar dados (mesmo que vazios)
- ✅ Frontend deve receber resposta válida
- ✅ Botões devem funcionar corretamente
