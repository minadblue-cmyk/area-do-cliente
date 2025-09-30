# Teste do botão Stop SEM execution_id
Write-Host "Teste do botao Stop SEM execution_id" -ForegroundColor Yellow

# Simular agente SEM execution_id
$agente = @{
    id = 82
    nome = "Agente 2 Elleve"
    status_atual = "stopped"
    execution_id_ativo = $null
    execution_id = $null
}

Write-Host "Dados do agente (sem execution_id):" -ForegroundColor Cyan
$agente | ConvertTo-Json

# Simular lógica do frontend
$executionId = $agente.execution_id_ativo
if (-not $executionId) {
    $executionId = $agente.execution_id
}

Write-Host "Execution ID extraido: '$executionId'" -ForegroundColor Green

if ($executionId) {
    Write-Host "SUCESSO: Execution ID encontrado!" -ForegroundColor Green
} else {
    Write-Host "AVISO: Execution ID nao encontrado - agente nao esta rodando" -ForegroundColor Yellow
    Write-Host "O frontend deve mostrar mensagem de aviso e nao enviar webhook" -ForegroundColor Yellow
}

Write-Host "`nTeste concluido!" -ForegroundColor Green
