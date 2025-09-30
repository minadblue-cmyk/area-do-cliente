-- =====================================================
-- TESTE: CRIAR TABELA AGENDAMENTOS_RECONTATO
-- =====================================================

-- Verificar se a tabela lead tem chave primária antes de criar a foreign key
SELECT 
    constraint_name, 
    constraint_type 
FROM information_schema.table_constraints 
WHERE table_name = 'lead' 
  AND table_schema = 'public' 
  AND constraint_type = 'PRIMARY KEY';

-- Se a query acima retornar uma linha, a chave primária existe
-- Então podemos criar a tabela agendamentos_recontato
