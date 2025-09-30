# Script para debugar permissões de acesso
Write-Host "Debugando permissões de acesso..." -ForegroundColor Yellow

Write-Host ""
Write-Host "PROBLEMA IDENTIFICADO:" -ForegroundColor Red
Write-Host "O campo permissoes_acesso esta presente no output, mas esta colapsado" -ForegroundColor White
Write-Host "Precisamos verificar se as permissões estao sendo criadas corretamente" -ForegroundColor White

Write-Host ""
Write-Host "VERIFICACOES NECESSARIAS:" -ForegroundColor Yellow

Write-Host ""
Write-Host "1. VERIFICAR QUERY SQL:" -ForegroundColor Cyan
Write-Host "   - Confirmar se permissoes_acesso = $4 esta no SET" -ForegroundColor White
Write-Host "   - Confirmar se l.permissoes_acesso esta no RETURNING" -ForegroundColor White

Write-Host ""
Write-Host "2. VERIFICAR PARAMETROS:" -ForegroundColor Cyan
Write-Host "   - Confirmar se o 4º parametro esta sendo passado" -ForegroundColor White
Write-Host "   - Verificar se JSON.stringify esta funcionando" -ForegroundColor White

Write-Host ""
Write-Host "3. VERIFICAR ESTRUTURA JSONB:" -ForegroundColor Cyan
Write-Host "   - Verificar se o JSON esta sendo criado corretamente" -ForegroundColor White
Write-Host "   - Confirmar se as permissões estao sendo incluídas" -ForegroundColor White

Write-Host ""
Write-Host "QUERY SQL CORRETA:" -ForegroundColor Green
Write-Host "UPDATE public.lead l" -ForegroundColor White
Write-Host "SET reservado_por  = $1," -ForegroundColor White
Write-Host "    reservado_em   = NOW()," -ForegroundColor White
Write-Host "    reservado_lote = $2," -ForegroundColor White
Write-Host "    agente_id      = $3," -ForegroundColor White
Write-Host "    permissoes_acesso = $4  -- ✅ NOVO: JSONB com permissões" -ForegroundColor Green
Write-Host "FROM pegar p" -ForegroundColor White
Write-Host "WHERE l.id = p.id" -ForegroundColor White
Write-Host "RETURNING" -ForegroundColor White
Write-Host "  l.id," -ForegroundColor White
Write-Host "  l.reservado_lote," -ForegroundColor White
Write-Host "  l.reservado_por," -ForegroundColor White
Write-Host "  l.reservado_em," -ForegroundColor White
Write-Host "  l.agente_id," -ForegroundColor White
Write-Host "  l.permissoes_acesso;  -- ✅ NOVO: Incluir permissões" -ForegroundColor Green

Write-Host ""
Write-Host "PARAMETROS CORRETOS:" -ForegroundColor Green
Write-Host "{{$workflow.id}}, {{$execution.id}}, {{$json.agente_id}}, {{JSON.stringify({" -ForegroundColor White
Write-Host "  \"agente_id\": $json.agente_id," -ForegroundColor White
Write-Host "  \"reservado_por\": \"usuario_\" + $json.usuario_id," -ForegroundColor White
Write-Host "  \"reservado_em\": $now.toISO()," -ForegroundColor White
Write-Host "  \"perfis_permitidos\": $json.perfis_permitidos," -ForegroundColor White
Write-Host "  \"usuarios_permitidos\": $json.usuarios_permitidos," -ForegroundColor White
Write-Host "  \"permissoes_especiais\": {" -ForegroundColor White
Write-Host "    \"pode_editar\": true," -ForegroundColor White
Write-Host "    \"pode_deletar\": false," -ForegroundColor White
Write-Host "    \"pode_exportar\": true" -ForegroundColor White
Write-Host "  }" -ForegroundColor White
Write-Host "})}}" -ForegroundColor White

Write-Host ""
Write-Host "ESTRUTURA ESPERADA DO JSONB:" -ForegroundColor Green
Write-Host "{" -ForegroundColor White
Write-Host "  \"agente_id\": 81," -ForegroundColor White
Write-Host "  \"reservado_por\": \"usuario_6\"," -ForegroundColor White
Write-Host "  \"reservado_em\": \"2025-09-25T17:42:50.823Z\"," -ForegroundColor White
Write-Host "  \"perfis_permitidos\": [1, 3, 4]," -ForegroundColor White
Write-Host "  \"usuarios_permitidos\": [6, 8, 10]," -ForegroundColor White
Write-Host "  \"permissoes_especiais\": {" -ForegroundColor White
Write-Host "    \"pode_editar\": true," -ForegroundColor White
Write-Host "    \"pode_deletar\": false," -ForegroundColor White
Write-Host "    \"pode_exportar\": true" -ForegroundColor White
Write-Host "  }" -ForegroundColor White
Write-Host "}" -ForegroundColor White

Write-Host ""
Write-Host "PROXIMOS PASSOS:" -ForegroundColor Yellow
Write-Host "1. Verificar se o 4º parametro esta sendo passado corretamente" -ForegroundColor White
Write-Host "2. Confirmar se a query SQL inclui permissoes_acesso = $4" -ForegroundColor White
Write-Host "3. Testar a execução e verificar o output" -ForegroundColor White
Write-Host "4. Expandir o campo permissoes_acesso no output para ver o conteudo" -ForegroundColor White

Write-Host ""
Write-Host "O campo esta presente, mas precisa ser expandido para ver o conteudo!" -ForegroundColor Green
