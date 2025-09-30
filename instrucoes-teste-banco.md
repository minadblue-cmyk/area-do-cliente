# 🔍 Instruções para Testar no Banco de Dados

## **Opções para Executar o Teste:**

### **1. Via n8n (Recomendado)**
1. Acesse o n8n
2. Crie um novo workflow
3. Adicione um nó PostgreSQL
4. Configure a conexão com o banco `consorcio`
5. Cole o conteúdo do arquivo `teste-rapido-agente-81.sql`
6. Execute o workflow

### **2. Via pgAdmin ou DBeaver**
1. Abra o pgAdmin ou DBeaver
2. Conecte no banco `consorcio` no host `n8n-lavo_postgres`
3. Cole e execute o conteúdo do arquivo `teste-rapido-agente-81.sql`

### **3. Via psql (se tiver instalado)**
```bash
# Instalar PostgreSQL client (se necessário)
# Ou usar Docker se disponível
docker run --rm -it postgres:15 psql -h n8n-lavo_postgres -U postgres -d consorcio -f teste-rapido-agente-81.sql
```

### **4. Via n8n - Teste Individual**
Execute estas queries uma por uma no n8n:

#### **Query 1: Verificar se existem leads do agente 81**
```sql
SELECT COUNT(*) as total_leads_agente_81 
FROM lead 
WHERE agente_id = 81;
```

#### **Query 2: Verificar quais agentes existem**
```sql
SELECT DISTINCT agente_id, COUNT(*) as quantidade_leads
FROM lead 
GROUP BY agente_id
ORDER BY agente_id;
```

#### **Query 3: Verificar status do agente 81**
```sql
SELECT DISTINCT status, COUNT(*) as quantidade
FROM lead 
WHERE agente_id = 81
GROUP BY status
ORDER BY quantidade DESC;
```

#### **Query 4: Testar query exata do n8n**
```sql
SELECT 
  l.id, l.client_id, l.nome, l.telefone, l.status, l.contatado,
  l.data_ultima_interacao, l.data_criacao
FROM lead l
WHERE l.agente_id = 81
  AND l.status IN ('prospectando', 'concluido')
  AND COALESCE(l.data_ultima_interacao, l.data_criacao) >= '2025-09-25 06:00:00'::timestamp
  AND COALESCE(l.data_ultima_interacao, l.data_criacao) < '2025-09-25 11:59:59'::timestamp
ORDER BY COALESCE(l.data_ultima_interacao, l.data_criacao) DESC,
  l.id DESC;
```

## **O que Esperar:**

- **Se retornar 0:** Não há leads do agente 81
- **Se retornar dados:** O problema está na configuração do n8n
- **Se der erro:** Problema de sintaxe ou conexão

## **Próximos Passos:**

1. Execute uma das opções acima
2. Me envie os resultados
3. Vamos identificar onde está o problema
