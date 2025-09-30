# Script para verificar estrutura da tabela lead
Write-Host "Verificando estrutura da tabela 'lead'..." -ForegroundColor Yellow

# Consulta SQL para verificar estrutura
$sqlQuery = @"
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'lead' 
  AND table_schema = 'public'
ORDER BY ordinal_position;
"@

Write-Host "Execute esta consulta no n8n ou cliente PostgreSQL:" -ForegroundColor Green
Write-Host ""
Write-Host $sqlQuery -ForegroundColor Cyan
Write-Host ""
Write-Host "Procure pela coluna 'agente_id' na lista de colunas retornadas." -ForegroundColor Yellow
Write-Host "Se nao existir, precisaremos adiciona-la a tabela." -ForegroundColor Red
