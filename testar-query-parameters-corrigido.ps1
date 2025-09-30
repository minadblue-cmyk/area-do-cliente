# Script para testar query parameters do n8n
Write-Host "🧪 Testando query parameters para Insert Lead..." -ForegroundColor Yellow

# Dados de teste baseados na imagem
$dadosTeste = @{
    agente_id = 81
    nome = "Roger Macedo da Silva"
    telefone = "5551984033242"
    email = "roger@exemplo.com"
    profissao = "Analista de Suporte"
    idade = 40
    estado_civil = "Casado"
    filhos = $true
    qtd_filhos = 2
    fonte_prospec = "Márcio André"
}

Write-Host "`n📋 Dados de teste:" -ForegroundColor Cyan
$dadosTeste | ConvertTo-Json -Depth 1 | Write-Host

Write-Host "`n🔧 Query Parameters para configurar no n8n:" -ForegroundColor Yellow

$parametros = @(
    @{ Name = "usuario_id"; Value = "={{ `$json.agente_id }}"; Description = "ID do usuário que está fazendo o upload" },
    @{ Name = "nome"; Value = "={{ `$json.nome }}"; Description = "Nome do lead" },
    @{ Name = "telefone"; Value = "={{ `$json.telefone }}"; Description = "Telefone do lead" },
    @{ Name = "email"; Value = "={{ `$json.email || '' }}"; Description = "Email do lead (opcional)" },
    @{ Name = "profissao"; Value = "={{ `$json.profissao }}"; Description = "Profissão do lead" },
    @{ Name = "idade"; Value = "={{ `$json.idade }}"; Description = "Idade do lead" },
    @{ Name = "estado_civil"; Value = "={{ `$json.estado_civil }}"; Description = "Estado civil do lead" },
    @{ Name = "filhos"; Value = "={{ `$json.filhos }}"; Description = "Se tem filhos (boolean)" },
    @{ Name = "qtd_filhos"; Value = "={{ `$json.qtd_filhos }}"; Description = "Quantidade de filhos" },
    @{ Name = "fonte_prospec"; Value = "={{ `$json.fonte_prospec }}"; Description = "Fonte da prospecção" }
)

$contador = 1
foreach ($param in $parametros) {
    Write-Host "`n$contador. $($param.Name)" -ForegroundColor Green
    Write-Host "   Value: $($param.Value)" -ForegroundColor White
    Write-Host "   Description: $($param.Description)" -ForegroundColor Gray
    $contador++
}

Write-Host "`n📝 Instruções para configurar no n8n:" -ForegroundColor Yellow
Write-Host "1. Clique em 'Add option' na seção 'Query Parameters'" -ForegroundColor White
Write-Host "2. Adicione cada parâmetro com Name e Value conforme mostrado acima" -ForegroundColor White
Write-Host "3. A ordem dos parâmetros deve ser exatamente como mostrado" -ForegroundColor White
Write-Host "4. usuario_id deve ser o primeiro parâmetro" -ForegroundColor White
Write-Host "5. Teste com os dados de exemplo fornecidos" -ForegroundColor White

Write-Host "`n⚠️ Importante:" -ForegroundColor Red
Write-Host "• usuario_id será usado para definir o usuário atual (set_current_user_id)" -ForegroundColor White
Write-Host "• empresa_id será obtido automaticamente do usuário" -ForegroundColor White
Write-Host "• Email é opcional, por isso usamos || '' para evitar erros" -ForegroundColor White
Write-Host "• status será sempre 'novo' para novos leads" -ForegroundColor White
Write-Host "• contatado será sempre false para novos leads" -ForegroundColor White

Write-Host "`n✅ Configuração concluída!" -ForegroundColor Green
