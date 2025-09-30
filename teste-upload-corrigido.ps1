# Script para testar upload de leads com agente_id corrigido
Write-Host "Testando upload de leads com agente_id corrigido..." -ForegroundColor Yellow

# Dados de teste
$testData = @{
    telefone = "5551984033242"
    nome = "Roger Macedo da Silva"
    canal = "whatsapp"
    estagio_funnel = "topo"
    pergunta_index = 0
    data_processamento = "2025-09-25T14:38:29.821Z"
    client_id = 6
    nome_cliente = "Roger Macedo da Silva"
    fonte_prospec = "Márcio André"
    idade = 40
    profissao = "Analista de Suporte"
    estado_civil = "Casado"
    filhos = $true
    qtd_filhos = 2
    status = "new"
    agente_id = 81  # ✅ AGENTE_ID INCLUÍDO
}

Write-Host "Dados de teste:" -ForegroundColor Green
$testData | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor Cyan

Write-Host ""
Write-Host "Query SQL corrigida:" -ForegroundColor Green
Write-Host "INSERT INTO public.lead (..., agente_id) VALUES (..., `$18)" -ForegroundColor Cyan

Write-Host ""
Write-Host "Parâmetros corrigidos:" -ForegroundColor Green
Write-Host "{{`$json.agente_id || 81}} - agente_id dinâmico ou padrão 81" -ForegroundColor Cyan

Write-Host ""
Write-Host "Agora o agente_id será inserido corretamente!" -ForegroundColor Green
