# Script PowerShell para analisar estrutura da tabela lead
Write-Host "Analisando estrutura da tabela lead..." -ForegroundColor Yellow

$queries = Get-Content "obter-estrutura-tabela-lead.sql" -Raw

Write-Host "Executando análise completa da tabela lead..." -ForegroundColor Cyan

try {
    # Usar docker para executar psql
    $result = docker run --rm -i postgres:13 psql -h n8n-lavo_postgres -U postgres -d consorcio -c $queries 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n=== ESTRUTURA DA TABELA LEAD ===" -ForegroundColor Green
        Write-Host $result -ForegroundColor White
        
        # Salvar resultado em arquivo
        $result | Out-File -FilePath "estrutura-tabela-lead-resultado.txt" -Encoding UTF8
        Write-Host "`nResultado salvo em: estrutura-tabela-lead-resultado.txt" -ForegroundColor Green
    } else {
        Write-Host "Erro ao executar análise:" -ForegroundColor Red
        Write-Host $result -ForegroundColor Red
    }
} catch {
    Write-Host "Erro ao executar docker:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    # Alternativa: mostrar estrutura baseada na imagem fornecida
    Write-Host "`n=== ESTRUTURA BASEADA NA IMAGEM FORNECIDA ===" -ForegroundColor Yellow
    Write-Host @"
CAMPOS IDENTIFICADOS NA TABELA LEAD:

1. nome (text, NULL)
2. canal (text, NULL) 
3. estagio_funnel (text, NULL, default: 'topo')
4. pergunta_index (integer, NULL, default: 0)
5. ultima_pergunta (text, NULL)
6. ultima_resposta (text, NULL)
7. respostas (text, NULL, default: '[]'::jsonb)
8. data_criacao (timestamp, NULL, default: now())
9. data_ultima_interacao (timestamp, NULL, default: now())
10. telefone (text, NULL)
11. id (integer, NOT NULL) - CHAVE PRIMÁRIA
12. contatado (boolean, NULL)
13. client_id (integer, NULL)
14. status (varchar(20), NULL, default: 'novo')
15. nome_cliente (text, NULL)
16. fonte_prospec (text, NULL)
17. idade (integer, NULL)
18. profissao (text, NULL)
19. estado_civil (text, NULL)
20. filhos (boolean, NULL)
21. qtd_filhos (integer, NULL)
22. data_insercao (timestamp, NULL)
23. reservado_por (text, NULL)
24. reservado_em (timestamp with time zone, NULL)
25. reservado_lote (text, NULL)
26. agente_id (integer, NULL)
27. perfil_id (integer, NULL)
28. permissoes_acesso (jsonb, NULL, default: '{}'::jsonb)
29. proximo_contato_em (timestamp, NULL)

CAMPOS REDUNDANTES IDENTIFICADOS:
- nome vs nome_cliente (possível redundância)
- data_criacao vs data_insercao (possível redundância)
- respostas (text) vs respostas (jsonb) - inconsistência de tipo
"@ -ForegroundColor White
}

Write-Host "`nAnálise concluída!" -ForegroundColor Green
