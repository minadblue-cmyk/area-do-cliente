# Script para analisar estrutura das tabelas para isolamento por empresa
Write-Host "Analisando estrutura das tabelas para isolamento por empresa..." -ForegroundColor Yellow

$queries = @"
-- 1. Estrutura da tabela leads
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'lead' 
ORDER BY ordinal_position;

-- 2. Estrutura da tabela empresas
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'empresas' 
ORDER BY ordinal_position;

-- 3. Estrutura da tabela usuarios
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'usuarios' 
ORDER BY ordinal_position;

-- 4. Estrutura da tabela perfil
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'perfil' 
ORDER BY ordinal_position;

-- 5. Verificar se já existe relacionamento entre usuarios e empresas
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'usuarios' 
AND column_name LIKE '%empresa%'
ORDER BY ordinal_position;

-- 6. Verificar se já existe relacionamento entre leads e empresas
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'lead' 
AND column_name LIKE '%empresa%'
ORDER BY ordinal_position;
"@

Write-Host "Executando consultas de análise..." -ForegroundColor Cyan

try {
    # Usar docker para executar psql
    $result = docker run --rm -i postgres:13 psql -h n8n-lavo_postgres -U postgres -d consorcio -c $queries 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Resultado da análise:" -ForegroundColor Green
        Write-Host $result -ForegroundColor White
    } else {
        Write-Host "Erro ao executar consulta:" -ForegroundColor Red
        Write-Host $result -ForegroundColor Red
    }
} catch {
    Write-Host "Erro ao executar docker:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`nAnálise concluída!" -ForegroundColor Green
