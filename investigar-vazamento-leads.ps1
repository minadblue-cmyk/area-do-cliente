# Script para investigar vazamento de leads entre empresas
Write-Host "🔍 INVESTIGANDO VAZAMENTO DE LEADS ENTRE EMPRESAS" -ForegroundColor Yellow
Write-Host ""

# 1. Verificar dados do usuário ID 18
Write-Host "1. DADOS DO USUÁRIO ID 18:" -ForegroundColor Cyan
$userQuery = "SELECT id, nome, email, empresa_id, perfil_id, ativo FROM usuarios WHERE id = 18 OR email = 'fith@fithinvestimento';"

try {
    $userResult = Invoke-Sqlcmd -Query $userQuery -ServerInstance "localhost" -Database "consorcio" -Username "postgres" -Password "postgres"
    $userResult | Format-Table -AutoSize
} catch {
    Write-Host "❌ Erro ao consultar usuário: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# 2. Verificar leads da empresa 2 que foram prospectados pelo usuário 18
Write-Host "2. LEADS DA EMPRESA 2 PROSPECTADOS PELO USUÁRIO 18:" -ForegroundColor Cyan
$leadsQuery = "SELECT l.id, l.nome, l.telefone, l.email, l.empresa_id, l.agente_id, l.reservado_por, l.reservado_em, l.status, l.contatado, u.nome as agente_nome, u.email as agente_email, u.empresa_id as agente_empresa_id FROM lead l LEFT JOIN usuarios u ON l.agente_id = u.id WHERE l.empresa_id = 2 AND (l.agente_id = 18 OR l.reservado_por LIKE '%usuario_18%') ORDER BY l.reservado_em DESC;"

try {
    $leadsResult = Invoke-Sqlcmd -Query $leadsQuery -ServerInstance "localhost" -Database "consorcio" -Username "postgres" -Password "postgres"
    if ($leadsResult) {
        $leadsResult | Format-Table -AutoSize
    } else {
        Write-Host "✅ Nenhum lead da empresa 2 foi prospectado pelo usuário 18" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Erro ao consultar leads: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# 3. Verificar permissões do usuário 18
Write-Host "3. PERMISSÕES DO USUÁRIO 18:" -ForegroundColor Cyan
$permQuery = "SELECT up.usuario_id, up.perfil_id, p.nome_perfil, p.permissoes, u.empresa_id as usuario_empresa_id FROM usuario_perfis up JOIN perfil p ON up.perfil_id = p.id JOIN usuarios u ON up.usuario_id = u.id WHERE up.usuario_id = 18;"

try {
    $permResult = Invoke-Sqlcmd -Query $permQuery -ServerInstance "localhost" -Database "consorcio" -Username "postgres" -Password "postgres"
    if ($permResult) {
        $permResult | Format-Table -AutoSize
    } else {
        Write-Host "❌ Nenhuma permissão encontrada para o usuário 18" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erro ao consultar permissões: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# 4. Verificar leads recentes da empresa 2
Write-Host "4. LEADS RECENTES DA EMPRESA 2:" -ForegroundColor Cyan
$recentQuery = "SELECT l.id, l.nome, l.telefone, l.empresa_id, l.agente_id, l.reservado_por, l.reservado_em, l.status, u.nome as agente_nome, u.empresa_id as agente_empresa_id FROM lead l LEFT JOIN usuarios u ON l.agente_id = u.id WHERE l.empresa_id = 2 AND l.reservado_em IS NOT NULL ORDER BY l.reservado_em DESC LIMIT 10;"

try {
    $recentResult = Invoke-Sqlcmd -Query $recentQuery -ServerInstance "localhost" -Database "consorcio" -Username "postgres" -Password "postgres"
    if ($recentResult) {
        $recentResult | Format-Table -AutoSize
    } else {
        Write-Host "❌ Nenhum lead recente encontrado" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erro ao consultar leads recentes: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# 5. Verificar se há vazamento de dados entre empresas
Write-Host "5. VERIFICAÇÃO DE VAZAMENTO ENTRE EMPRESAS:" -ForegroundColor Cyan
$leakQuery = "SELECT l.id as lead_id, l.nome as lead_nome, l.empresa_id as lead_empresa_id, l.agente_id, u.nome as agente_nome, u.empresa_id as agente_empresa_id, l.reservado_por, l.reservado_em, l.status FROM lead l JOIN usuarios u ON l.agente_id = u.id WHERE l.empresa_id != u.empresa_id AND l.agente_id IS NOT NULL ORDER BY l.reservado_em DESC;"

try {
    $leakResult = Invoke-Sqlcmd -Query $leakQuery -ServerInstance "localhost" -Database "consorcio" -Username "postgres" -Password "postgres"
    if ($leakResult) {
        Write-Host "🚨 VAZAMENTO DETECTADO! Agentes de uma empresa prospectando leads de outra:" -ForegroundColor Red
        $leakResult | Format-Table -AutoSize
    } else {
        Write-Host "✅ Nenhum vazamento detectado entre empresas" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Erro ao verificar vazamento: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "🔍 INVESTIGAÇÃO CONCLUÍDA" -ForegroundColor Yellow