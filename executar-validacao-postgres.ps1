# Script para executar validação de permissões no PostgreSQL
Write-Host "Executando validacao de permissoes no PostgreSQL..." -ForegroundColor Yellow

Write-Host ""
Write-Host "VALIDACOES A SEREM EXECUTADAS:" -ForegroundColor Green

Write-Host ""
Write-Host "1. VERIFICAR COLUNA:" -ForegroundColor Cyan
Write-Host "   - Confirmar se coluna permissoes_acesso existe" -ForegroundColor White
Write-Host "   - Verificar tipo de dados (JSONB)" -ForegroundColor White

Write-Host ""
Write-Host "2. VERIFICAR LEADS RECENTES:" -ForegroundColor Cyan
Write-Host "   - Buscar leads reservados nos ultimos 10 minutos" -ForegroundColor White
Write-Host "   - Verificar se agente_id esta sendo definido" -ForegroundColor White
Write-Host "   - Verificar se permissoes_acesso esta sendo preenchido" -ForegroundColor White

Write-Host ""
Write-Host "3. VERIFICAR ESTRUTURA JSONB:" -ForegroundColor Cyan
Write-Host "   - Extrair campos especificos do JSONB" -ForegroundColor White
Write-Host "   - Verificar agente_id, reservado_por, reservado_em" -ForegroundColor White
Write-Host "   - Verificar perfis_permitidos e usuarios_permitidos" -ForegroundColor White

Write-Host ""
Write-Host "4. VERIFICAR AGENTE 81:" -ForegroundColor Cyan
Write-Host "   - Buscar leads especificos do agente 81" -ForegroundColor White
Write-Host "   - Validar se permissoes estao corretas" -ForegroundColor White
Write-Host "   - Verificar se usuario 6 e perfil 3 estao permitidos" -ForegroundColor White

Write-Host ""
Write-Host "5. CONTAR LEADS COM PERMISSOES:" -ForegroundColor Cyan
Write-Host "   - Total de leads reservados" -ForegroundColor White
Write-Host "   - Leads com permissoes validas" -ForegroundColor White
Write-Host "   - Leads com campos obrigatorios preenchidos" -ForegroundColor White

Write-Host ""
Write-Host "6. EXEMPLO COMPLETO:" -ForegroundColor Cyan
Write-Host "   - Mostrar exemplo de permissoes completas" -ForegroundColor White
Write-Host "   - Formatar JSON para visualizacao" -ForegroundColor White

Write-Host ""
Write-Host "INSTRUCOES PARA EXECUTAR:" -ForegroundColor Yellow
Write-Host "1. Copie o SQL do arquivo validar-permissoes-postgres.sql" -ForegroundColor White
Write-Host "2. Execute no seu cliente PostgreSQL (pgAdmin, DBeaver, etc.)" -ForegroundColor White
Write-Host "3. Ou execute via n8n usando um node PostgreSQL" -ForegroundColor White

Write-Host ""
Write-Host "ALTERNATIVA - DOCKER:" -ForegroundColor Yellow
Write-Host "docker exec -i n8n-lavo_postgres psql -U postgres -d consorcio -f validar-permissoes-postgres.sql" -ForegroundColor White

Write-Host ""
Write-Host "RESULTADOS ESPERADOS:" -ForegroundColor Green
Write-Host "✅ Coluna permissoes_acesso existe e e do tipo JSONB" -ForegroundColor White
Write-Host "✅ Leads recentes tem agente_id definido" -ForegroundColor White
Write-Host "✅ Leads recentes tem permissoes_acesso preenchido" -ForegroundColor White
Write-Host "✅ Estrutura JSONB contem todos os campos necessarios" -ForegroundColor White
Write-Host "✅ Agente 81 tem permissoes corretas" -ForegroundColor White
Write-Host "✅ Usuario 6 e perfil 3 estao permitidos" -ForegroundColor White

Write-Host ""
Write-Host "Execute o SQL para validar as permissoes!" -ForegroundColor Green
