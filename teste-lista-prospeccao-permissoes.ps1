# Teste da Lista de Prospecção com Verificação de Permissões
Write-Host "🔍 Testando Lista de Prospecção com Permissões..." -ForegroundColor Green

# Simular diferentes cenários de usuário
$cenarios = @(
    @{
        nome = "Usuário com Acesso Direto"
        usuario_id = 6
        perfil_id = 1
        agente_id = 81
        perfis_permitidos = @(1, 2)
        usuarios_permitidos = @(6, 7)
    },
    @{
        nome = "Usuário com Acesso por Perfil"
        usuario_id = 7
        perfil_id = 2
        agente_id = 82
        perfis_permitidos = @(1, 2)
        usuarios_permitidos = @(6, 7)
    },
    @{
        nome = "Usuário Sem Acesso"
        usuario_id = 9
        perfil_id = 3
        agente_id = 83
        perfis_permitidos = @(1, 2)
        usuarios_permitidos = @(6, 7)
    }
)

foreach ($cenario in $cenarios) {
    Write-Host "`n🧪 Testando: $($cenario.nome)" -ForegroundColor Yellow
    Write-Host "Usuário ID: $($cenario.usuario_id)" -ForegroundColor Cyan
    Write-Host "Perfil ID: $($cenario.perfil_id)" -ForegroundColor Cyan
    Write-Host "Agente ID: $($cenario.agente_id)" -ForegroundColor Cyan
    
    # Simular query SQL com os parâmetros
    $query = @"
SELECT
  l.id, l.client_id, l.nome_cliente, l.telefone, l.canal,
  l.status, l.data_ultima_interacao, l.reservado_por, l.reservado_lote,
  l.agente_id, l.permissoes_acesso
FROM public.lead l
WHERE l.reservado_lote = '117858'
  AND (
    l.permissoes_acesso->'usuarios_permitidos' @> '$($cenario.usuario_id)'::jsonb
    OR
    l.permissoes_acesso->'perfis_permitidos' @> '$($cenario.perfil_id)'::jsonb
    OR
    l.agente_id = $($cenario.agente_id)
  )
ORDER BY COALESCE(l.data_ultima_interacao, l.data_criacao) ASC,
  l.id ASC;
"@
    
    Write-Host "`n📝 Query SQL:" -ForegroundColor Blue
    Write-Host $query -ForegroundColor White
    
    # Verificar se usuário tem acesso
    $temAcesso = $false
    $motivo = ""
    
    if ($cenario.usuarios_permitidos -contains $cenario.usuario_id) {
        $temAcesso = $true
        $motivo = "Usuário está na lista de usuários permitidos"
    } elseif ($cenario.perfis_permitidos -contains $cenario.perfil_id) {
        $temAcesso = $true
        $motivo = "Perfil está na lista de perfis permitidos"
    } elseif ($cenario.agente_id -eq 81) {
        $temAcesso = $true
        $motivo = "É o agente responsável pelo lead"
    } else {
        $motivo = "Usuário não tem acesso - não está em nenhuma lista"
    }
    
    if ($temAcesso) {
        Write-Host "✅ ACESSO PERMITIDO: $motivo" -ForegroundColor Green
    } else {
        Write-Host "❌ ACESSO NEGADO: $motivo" -ForegroundColor Red
    }
    
    Write-Host "─" * 50 -ForegroundColor Gray
}

Write-Host "`n🎯 Resumo dos Testes:" -ForegroundColor Yellow
Write-Host "✅ Usuário ID 6: Deve ter acesso (está em usuarios_permitidos)" -ForegroundColor Green
Write-Host "✅ Usuário ID 7: Deve ter acesso (perfil 2 está em perfis_permitidos)" -ForegroundColor Green
Write-Host "❌ Usuário ID 9: NÃO deve ter acesso (não está em nenhuma lista)" -ForegroundColor Red

Write-Host "`n🏁 Teste de Permissões Concluído!" -ForegroundColor Green
