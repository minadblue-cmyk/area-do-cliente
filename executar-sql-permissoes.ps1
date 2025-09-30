# Script para executar SQL de adicionar coluna permissoes_acesso
Write-Host "Executando SQL para adicionar coluna permissoes_acesso..." -ForegroundColor Yellow

# Ler o arquivo SQL
$sqlContent = Get-Content "adicionar-coluna-permissoes-acesso.sql" -Raw

Write-Host ""
Write-Host "SQL a ser executado:" -ForegroundColor Cyan
Write-Host $sqlContent -ForegroundColor White

Write-Host ""
Write-Host "INSTRUCOES PARA EXECUTAR:" -ForegroundColor Green
Write-Host "1. Copie o SQL acima" -ForegroundColor White
Write-Host "2. Execute no seu cliente PostgreSQL (pgAdmin, DBeaver, etc.)" -ForegroundColor White
Write-Host "3. Ou execute via n8n usando um node PostgreSQL" -ForegroundColor White

Write-Host ""
Write-Host "ALTERNATIVA - DOCKER:" -ForegroundColor Yellow
Write-Host "docker exec -i n8n-lavo_postgres psql -U postgres -d consorcio -c ""ALTER TABLE public.lead ADD COLUMN permissoes_acesso JSONB DEFAULT '{}'::jsonb;""" -ForegroundColor White

Write-Host ""
Write-Host "VERIFICACAO:" -ForegroundColor Green
Write-Host "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'lead' AND column_name = 'permissoes_acesso';" -ForegroundColor White
