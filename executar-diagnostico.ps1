# =====================================================
# DIAGNÓSTICO COMPLETO: LEADS DO AGENTE 81 (PowerShell)
# =====================================================

Write-Host "🚀 Iniciando diagnóstico completo dos leads do agente 81..." -ForegroundColor Green

# Configurações do banco (ajuste conforme necessário)
$DB_HOST = "localhost"
$DB_PORT = "5432"
$DB_NAME = "seu_banco"
$DB_USER = "seu_usuario"

# 1. EXECUTAR DIAGNÓSTICO SQL
Write-Host "🔍 1. Executando diagnóstico SQL..." -ForegroundColor Yellow
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f diagnostico-leads-agente-81.sql > diagnostico_resultado.txt

# 2. DUMP ESTRUTURAL DA TABELA LEAD
Write-Host "📋 2. Exportando estrutura da tabela lead..." -ForegroundColor Yellow
pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME --schema-only --table=lead --format=plain --file=lead_structure.sql

# 3. DUMP DE DADOS DO AGENTE 81
Write-Host "📊 3. Exportando dados do agente 81..." -ForegroundColor Yellow
pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME --data-only --table=lead --where="agente_id = 81" --format=plain --file=leads_agente_81_data.sql

# 4. DUMP EM FORMATO CSV
Write-Host "📄 4. Exportando para CSV..." -ForegroundColor Yellow
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "COPY (SELECT l.id, l.client_id, l.agente_id, l.nome, l.telefone, l.status, l.contatado, l.data_ultima_interacao, l.data_criacao FROM lead l WHERE l.agente_id = 81 ORDER BY COALESCE(l.data_ultima_interacao, l.data_criacao) DESC, l.id DESC) TO 'leads_agente_81.csv' WITH CSV HEADER;"

# 5. DUMP EM FORMATO JSON
Write-Host "🔗 5. Exportando para JSON..." -ForegroundColor Yellow
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT json_agg(json_build_object('id', l.id, 'client_id', l.client_id, 'agente_id', l.agente_id, 'nome', l.nome, 'telefone', l.telefone, 'status', l.status, 'contatado', l.contatado, 'data_ultima_interacao', l.data_ultima_interacao, 'data_criacao', l.data_criacao)) as leads_json FROM lead l WHERE l.agente_id = 81 ORDER BY COALESCE(l.data_ultima_interacao, l.data_criacao) DESC, l.id DESC;" > leads_agente_81.json

# 6. DUMP COMPLETO EM FORMATO CUSTOM
Write-Host "💾 6. Exportando dump completo..." -ForegroundColor Yellow
pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME --data-only --table=lead --where="agente_id = 81" --format=custom --file=leads_agente_81.dump

# 7. MOSTRAR RESULTADOS
Write-Host "✅ Diagnóstico completo finalizado!" -ForegroundColor Green
Write-Host "📁 Arquivos gerados:" -ForegroundColor Cyan
Write-Host "   - diagnostico_resultado.txt (resultado do diagnóstico)" -ForegroundColor White
Write-Host "   - lead_structure.sql (estrutura da tabela)" -ForegroundColor White
Write-Host "   - leads_agente_81_data.sql (dados do agente 81)" -ForegroundColor White
Write-Host "   - leads_agente_81.csv (dados em CSV)" -ForegroundColor White
Write-Host "   - leads_agente_81.json (dados em JSON)" -ForegroundColor White
Write-Host "   - leads_agente_81.dump (dump customizado)" -ForegroundColor White

# 8. MOSTRAR CONTEÚDO DO DIAGNÓSTICO
Write-Host "`n🔍 Resultado do diagnóstico:" -ForegroundColor Yellow
Get-Content diagnostico_resultado.txt
