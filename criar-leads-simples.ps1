# Script para criar 20 leads fictícios para teste
$n8nCodeIqUrl = "https://n8n.code-iq.com.br"

# Lista de nomes fictícios
$nomes = @(
    "Ana Silva Santos", "Carlos Oliveira", "Maria Fernanda", "Joao Pedro", "Lucia Mendes",
    "Roberto Alves", "Patricia Costa", "Fernando Lima", "Camila Rodrigues", "Marcos Pereira",
    "Juliana Souza", "Rafael Martins", "Beatriz Nunes", "Diego Santos", "Gabriela Almeida",
    "Thiago Ferreira", "Larissa Gomes", "Andre Rocha", "Vanessa Barbosa", "Felipe Cardoso"
)

# Lista de profissões
$profissoes = @(
    "Engenheiro", "Medico", "Advogado", "Professor", "Contador",
    "Administrador", "Vendedor", "Analista", "Gerente", "Tecnico",
    "Designer", "Programador", "Enfermeiro", "Psicologo", "Arquiteto",
    "Dentista", "Farmaceutico", "Jornalista", "Publicitario", "Economista"
)

# Lista de estados civis
$estadosCivis = @("Solteiro", "Casado", "Divorciado", "Viuvo")

# Lista de fontes de prospecção
$fontes = @("Indicacao", "Facebook", "Instagram", "LinkedIn", "Google", "Site", "Evento", "Telefone")

Write-Host "CRIANDO 20 LEADS FICTICIOS PARA TESTE" -ForegroundColor Yellow
Write-Host "=" * 50 -ForegroundColor Yellow

$leadsCriados = 0
$erros = 0

for ($i = 0; $i -lt 20; $i++) {
    # Gerar dados aleatórios
    $nome = $nomes[$i]
    $telefone = "5551984" + (Get-Random -Minimum 100000 -Maximum 999999)
    $email = ($nome -replace " ", ".").ToLower() + "@exemplo.com"
    $profissao = $profissoes | Get-Random
    $idade = Get-Random -Minimum 25 -Maximum 65
    $estadoCivil = $estadosCivis | Get-Random
    $temFilhos = (Get-Random -Minimum 0 -Maximum 2) -eq 1
    $qtdFilhos = if ($temFilhos) { Get-Random -Minimum 1 -Maximum 4 } else { 0 }
    $fonte = $fontes | Get-Random
    
    # Payload para criar lead
    $payload = @{
        logged_user = @{
            id = 6
            name = "Usuario Elleve Padrao 1"
            email = "rmacedo2005@hotmail.com"
            empresa_id = 2
        }
        data = @(
            @{
                Nome = $nome
                Telefone = $telefone
                "Fonte de prospecao" = $fonte
                Idade = $idade.ToString()
                Profissao = $profissao
                "Estado Civil" = $estadoCivil
                Filhos = $temFilhos.ToString().ToLower()
                "Quantos filhos" = $qtdFilhos.ToString()
            }
        )
        file_info = @{
            name = "leads_teste.csv"
            size = 1024
            type = "text/csv"
            lastModified = (Get-Date).Ticks
        }
        empresa_id = 2
    }
    
    Write-Host "`nCriando lead $($i + 1)/20: $nome" -ForegroundColor Cyan
    
    try {
        $response = Invoke-WebRequest -Uri "$n8nCodeIqUrl/webhook/upload" -Method POST -ContentType "application/json" -Body ($payload | ConvertTo-Json -Depth 3) -UseBasicParsing -TimeoutSec 30
        
        if ($response.StatusCode -eq 200) {
            Write-Host "Lead criado com sucesso!" -ForegroundColor Green
            $leadsCriados++
        } else {
            Write-Host "Status inesperado: $($response.StatusCode)" -ForegroundColor Yellow
            $leadsCriados++
        }
        
    } catch {
        Write-Host "Erro ao criar lead: $($_.Exception.Message)" -ForegroundColor Red
        $erros++
    }
    
    # Pequena pausa entre requisições
    Start-Sleep -Milliseconds 500
}

Write-Host "`n" + "=" * 50 -ForegroundColor Yellow
Write-Host "RESUMO DA CRIACAO DE LEADS:" -ForegroundColor Yellow
Write-Host "Leads criados com sucesso: $leadsCriados" -ForegroundColor Green
Write-Host "Erros: $erros" -ForegroundColor Red
Write-Host "Taxa de sucesso: $([math]::Round(($leadsCriados / 20) * 100, 2))%" -ForegroundColor Cyan

Write-Host "`nAGORA TESTE O WEBHOOK START:" -ForegroundColor Yellow
Write-Host "Execute: powershell -ExecutionPolicy Bypass -File teste-start-final.ps1" -ForegroundColor White

Write-Host "`nDADOS DOS LEADS CRIADOS:" -ForegroundColor Yellow
Write-Host "- Todos com empresa_id = 2" -ForegroundColor White
Write-Host "- Status = 'novo'" -ForegroundColor White
Write-Host "- contatado = false" -ForegroundColor White
Write-Host "- Prontos para serem processados pelo webhook start" -ForegroundColor White
