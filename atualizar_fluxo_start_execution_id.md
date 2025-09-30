# Atualizar Fluxo de Start para Salvar Execution ID

## Problema
O fluxo de start não está salvando o `execution_id` da execução atual na tabela `agente_execucoes`, dificultando o controle dos botões de parar.

## Solução
Adicionar uma etapa no fluxo de start para salvar o `execution_id` na coluna `execution_id_da_ultima_execucao`.

## Script SQL para Adicionar Coluna
```sql
-- Adicionar coluna execution_id_da_ultima_execucao na tabela agente_execucoes
ALTER TABLE agente_execucoes 
ADD COLUMN execution_id_da_ultima_execucao VARCHAR(50);

-- Adicionar comentário para documentar a coluna
COMMENT ON COLUMN agente_execucoes.execution_id_da_ultima_execucao IS 'Execution ID da última execução ativa do agente';

-- Criar índice para melhor performance nas consultas
CREATE INDEX idx_agente_execucoes_execution_id_ultima 
ON agente_execucoes(execution_id_da_ultima_execucao);
```

## Atualização do Fluxo de Start no N8N

### 1. Adicionar Nó "PostgreSQL - Update Execution ID"
**Posição**: Após o nó que inicia a execução, antes do "Respond Success"

**Configuração**:
```sql
UPDATE agente_execucoes 
SET execution_id_da_ultima_execucao = $1,
    updated_at = NOW()
WHERE workflow_id = $2 
AND usuario_id = $3 
AND status = 'running'
```

**Parâmetros**:
- `$1`: `{{ $execution.id }}` (execution_id da execução atual)
- `$2`: `{{ $json.workflowId }}` (workflow_id do agente)
- `$3`: `{{ $json.usuarioId }}` (usuario_id)

### 2. Adicionar Nó "PostgreSQL - Insert/Update Execution"
**Posição**: Após o nó anterior

**Configuração**:
```sql
INSERT INTO agente_execucoes (
    execution_id,
    workflow_id,
    usuario_id,
    usuario_nome,
    usuario_email,
    status,
    iniciado_em,
    payload_inicial,
    execution_id_da_ultima_execucao,
    created_at,
    updated_at
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, NOW(), NOW()
)
ON CONFLICT (workflow_id, usuario_id, status) 
DO UPDATE SET
    execution_id = EXCLUDED.execution_id,
    execution_id_da_ultima_execucao = EXCLUDED.execution_id,
    iniciado_em = EXCLUDED.iniciado_em,
    payload_inicial = EXCLUDED.payload_inicial,
    updated_at = NOW()
```

**Parâmetros**:
- `$1`: `{{ $execution.id }}`
- `$2`: `{{ $json.workflowId }}`
- `$3`: `{{ $json.usuarioId }}`
- `$4`: `{{ $json.usuarioNome || 'Usuário' }}`
- `$5`: `{{ $json.usuarioEmail || 'usuario@exemplo.com' }}`
- `$6`: `'running'`
- `$7`: `{{ $now.toISO() }}`
- `$8`: `{{ JSON.stringify($json) }}`
- `$9`: `{{ $execution.id }}`

## Atualização do Webhook de Status

### Modificar Query de Status
```sql
SELECT 
    status,
    iniciado_em,
    parado_em,
    execution_id,
    execution_id_da_ultima_execucao,
    workflow_id,
    usuario_nome,
    usuario_email,
    finalizado_em,
    erro_em,
    mensagem_erro,
    duracao_segundos
FROM agente_execucoes 
WHERE workflow_id = $1 
AND usuario_id = $2 
ORDER BY created_at DESC 
LIMIT 1
```

## Atualização do Frontend

### Modificar Captura de Execution ID
```javascript
// No webhook de status, priorizar execution_id_da_ultima_execucao
executionId = responseData?.execution_id_da_ultima_execucao || 
              responseData?.execution_id_ativo || 
              responseData?.execution_id || 
              responseData?.executionId || 
              null
```

## Benefícios

1. **Controle preciso** do execution_id ativo
2. **Histórico completo** das execuções
3. **Botões funcionais** (start/stop) baseados no execution_id real
4. **Status correto** sempre atualizado
5. **Rastreabilidade** completa das execuções

## Ordem de Implementação

1. **Executar SQL** para adicionar coluna
2. **Atualizar fluxo de start** no N8N
3. **Atualizar webhook de status** no N8N
4. **Atualizar frontend** para usar novo campo
5. **Testar** funcionalidade completa
