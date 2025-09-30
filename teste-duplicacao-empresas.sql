-- Teste para verificar se duplicação entre empresas funciona
-- Este teste deve FALHAR se a constraint estiver impedindo

-- 1. Verificar constraints existentes
SELECT 
    conname as constraint_name,
    contype as constraint_type,
    pg_get_constraintdef(oid) as definition
FROM pg_constraint 
WHERE conrelid = 'public.lead'::regclass
AND conname LIKE '%telefone%';

-- 2. Verificar índices únicos
SELECT 
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename = 'lead' 
AND indexdef LIKE '%UNIQUE%'
AND indexdef LIKE '%telefone%';

-- 3. Teste de duplicação entre empresas
-- Este INSERT deve FALHAR se a constraint estiver ativa
INSERT INTO public.lead (
    nome, telefone, email, profissao, idade, estado_civil, 
    filhos, qtd_filhos, status, fonte_prospec, contatado, 
    empresa_id, usuario_id, created_at, updated_at, data_ultima_interacao
) VALUES (
    'TESTE DUPLICACAO', 
    '5551984033242',  -- MESMO telefone do lead existente
    'teste@exemplo.com', 
    'Teste', 30, 'Solteiro', false, 0, 'novo', 
    'Teste', false, 
    2,  -- empresa_id DIFERENTE (empresa 2)
    6, NOW(), NOW(), NOW()
);

-- 4. Se chegou até aqui, a duplicação entre empresas FUNCIONA
SELECT 'DUPLICACAO ENTRE EMPRESAS FUNCIONA!' as resultado;

-- 5. Verificar leads por empresa
SELECT 
    empresa_id, 
    COUNT(*) as total_leads,
    COUNT(DISTINCT telefone) as telefones_unicos,
    COUNT(*) - COUNT(DISTINCT telefone) as telefones_duplicados
FROM public.lead 
GROUP BY empresa_id 
ORDER BY empresa_id;
