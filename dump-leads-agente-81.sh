#!/bin/bash

# =====================================================
# DUMP COMPLETO: LEADS DO AGENTE 81
# =====================================================

echo "🚀 Iniciando dump completo dos leads do agente 81..."

# Configurações do banco (ajuste conforme necessário)
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="seu_banco"
DB_USER="seu_usuario"

# 1. DUMP ESTRUTURAL DA TABELA LEAD
echo "📋 1. Exportando estrutura da tabela lead..."
pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME \
  --schema-only \
  --table=lead \
  --format=plain \
  --file=lead_structure.sql

# 2. DUMP DE DADOS DO AGENTE 81
echo "📊 2. Exportando dados do agente 81..."
pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME \
  --data-only \
  --table=lead \
  --where="agente_id = 81" \
  --format=plain \
  --file=leads_agente_81_data.sql

# 3. DUMP EM FORMATO CSV
echo "📄 3. Exportando para CSV..."
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "
COPY (
  SELECT 
    l.id, l.client_id, l.agente_id, l.nome, l.telefone, l.status, l.contatado,
    l.data_ultima_interacao, l.data_criacao
  FROM lead l
  WHERE l.agente_id = 81
  ORDER BY COALESCE(l.data_ultima_interacao, l.data_criacao) DESC,
    l.id DESC
) TO '/tmp/leads_agente_81.csv' WITH CSV HEADER;
"

# 4. DUMP EM FORMATO JSON
echo "🔗 4. Exportando para JSON..."
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "
SELECT json_agg(
  json_build_object(
    'id', l.id,
    'client_id', l.client_id,
    'agente_id', l.agente_id,
    'nome', l.nome,
    'telefone', l.telefone,
    'status', l.status,
    'contatado', l.contatado,
    'data_ultima_interacao', l.data_ultima_interacao,
    'data_criacao', l.data_criacao
  )
) as leads_json
FROM lead l
WHERE l.agente_id = 81
ORDER BY COALESCE(l.data_ultima_interacao, l.data_criacao) DESC,
  l.id DESC;
" > leads_agente_81.json

# 5. DUMP COMPLETO EM FORMATO CUSTOM
echo "💾 5. Exportando dump completo..."
pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME \
  --data-only \
  --table=lead \
  --where="agente_id = 81" \
  --format=custom \
  --file=leads_agente_81.dump

# 6. EXECUTAR DIAGNÓSTICO
echo "🔍 6. Executando diagnóstico..."
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f diagnostico-leads-agente-81.sql > diagnostico_resultado.txt

echo "✅ Dump completo finalizado!"
echo "📁 Arquivos gerados:"
echo "   - lead_structure.sql (estrutura da tabela)"
echo "   - leads_agente_81_data.sql (dados do agente 81)"
echo "   - /tmp/leads_agente_81.csv (dados em CSV)"
echo "   - leads_agente_81.json (dados em JSON)"
echo "   - leads_agente_81.dump (dump customizado)"
echo "   - diagnostico_resultado.txt (resultado do diagnóstico)"
