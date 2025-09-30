-- Script 6: Testar isolamento de leads por empresa
-- Executar APÓS todos os scripts anteriores

-- =====================================================
-- 1. PREPARAR DADOS DE TESTE
-- =====================================================

-- Criar empresas de teste se não existirem
INSERT INTO empresas (nome_empresa, descricao, created_at)
VALUES 
    ('Empresa A', 'Empresa de teste A', NOW()),
    ('Empresa B', 'Empresa de teste B', NOW())
ON CONFLICT (nome_empresa) DO NOTHING;

-- Criar usuários de teste se não existirem
INSERT INTO usuarios (email, nome, perfil, ativo, empresa_id, created_at)
SELECT 
    'usuario_a@empresa-a.com',
    'Usuário Empresa A',
    'admin',
    true,
    e.id,
    NOW()
FROM empresas e WHERE e.nome_empresa = 'Empresa A'
ON CONFLICT (email) DO NOTHING;

INSERT INTO usuarios (email, nome, perfil, ativo, empresa_id, created_at)
SELECT 
    'usuario_b@empresa-b.com',
    'Usuário Empresa B',
    'admin',
    true,
    e.id,
    NOW()
FROM empresas e WHERE e.nome_empresa = 'Empresa B'
ON CONFLICT (email) DO NOTHING;

-- Criar leads de teste para cada empresa
INSERT INTO lead (nome, telefone, email, status, empresa_id, usuario_id, created_at)
SELECT 
    'Lead Empresa A ' || generate_series(1, 5),
    '1190000000' || generate_series(1, 5),
    'lead' || generate_series(1, 5) || '@empresa-a.com',
    'novo',
    e.id,
    u.id,
    NOW()
FROM empresas e
CROSS JOIN usuarios u
WHERE e.nome_empresa = 'Empresa A' 
    AND u.email = 'usuario_a@empresa-a.com';

INSERT INTO lead (nome, telefone, email, status, empresa_id, usuario_id, created_at)
SELECT 
    'Lead Empresa B ' || generate_series(1, 5),
    '119000000' || generate_series(6, 10),
    'lead' || generate_series(6, 10) || '@empresa-b.com',
    'novo',
    e.id,
    u.id,
    NOW()
FROM empresas e
CROSS JOIN usuarios u
WHERE e.nome_empresa = 'Empresa B' 
    AND u.email = 'usuario_b@empresa-b.com';

-- =====================================================
-- 2. TESTE 1: ISOLAMENTO ENTRE EMPRESAS
-- =====================================================

RAISE NOTICE '=== TESTE 1: ISOLAMENTO ENTRE EMPRESAS ===';

-- Simular usuário da Empresa A
SELECT set_current_user_id(
    (SELECT id FROM usuarios WHERE email = 'usuario_a@empresa-a.com')
);

-- Usuário A deve ver apenas leads da Empresa A
SELECT 
    'Empresa A' as empresa_usuario,
    COUNT(*) as total_leads_visiveis,
    COUNT(CASE WHEN l.empresa_id = e.id THEN 1 END) as leads_propria_empresa,
    COUNT(CASE WHEN l.empresa_id != e.id THEN 1 END) as leads_outras_empresas
FROM lead l
CROSS JOIN empresas e
WHERE e.nome_empresa = 'Empresa A';

-- Simular usuário da Empresa B
SELECT set_current_user_id(
    (SELECT id FROM usuarios WHERE email = 'usuario_b@empresa-b.com')
);

-- Usuário B deve ver apenas leads da Empresa B
SELECT 
    'Empresa B' as empresa_usuario,
    COUNT(*) as total_leads_visiveis,
    COUNT(CASE WHEN l.empresa_id = e.id THEN 1 END) as leads_propria_empresa,
    COUNT(CASE WHEN l.empresa_id != e.id THEN 1 END) as leads_outras_empresas
FROM lead l
CROSS JOIN empresas e
WHERE e.nome_empresa = 'Empresa B';

-- =====================================================
-- 3. TESTE 2: FUNÇÃO DE VALIDAÇÃO DE ACESSO
-- =====================================================

RAISE NOTICE '=== TESTE 2: VALIDAÇÃO DE ACESSO ===';

-- Testar acesso a leads da própria empresa
SELECT 
    'Acesso próprio' as teste,
    l.id as lead_id,
    l.nome as lead_nome,
    e_lead.nome_empresa as empresa_lead,
    e_user.nome_empresa as empresa_usuario,
    verificar_acesso_lead(l.id, u.id) as pode_acessar
FROM lead l
CROSS JOIN usuarios u
JOIN empresas e_lead ON l.empresa_id = e_lead.id
JOIN empresas e_user ON u.empresa_id = e_user.id
WHERE e_lead.nome_empresa = 'Empresa A'
    AND e_user.nome_empresa = 'Empresa A'
LIMIT 3;

-- Testar acesso a leads de outra empresa (deve ser false)
SELECT 
    'Acesso outra empresa' as teste,
    l.id as lead_id,
    l.nome as lead_nome,
    e_lead.nome_empresa as empresa_lead,
    e_user.nome_empresa as empresa_usuario,
    verificar_acesso_lead(l.id, u.id) as pode_acessar
FROM lead l
CROSS JOIN usuarios u
JOIN empresas e_lead ON l.empresa_id = e_lead.id
JOIN empresas e_user ON u.empresa_id = e_user.id
WHERE e_lead.nome_empresa = 'Empresa A'
    AND e_user.nome_empresa = 'Empresa B'
LIMIT 3;

-- =====================================================
-- 4. TESTE 3: ROW LEVEL SECURITY
-- =====================================================

RAISE NOTICE '=== TESTE 3: ROW LEVEL SECURITY ===';

-- Simular usuário da Empresa A
SELECT set_current_user_id(
    (SELECT id FROM usuarios WHERE email = 'usuario_a@empresa-a.com')
);

-- Deve retornar apenas leads da Empresa A
SELECT 
    'RLS Empresa A' as teste,
    COUNT(*) as leads_visiveis,
    STRING_AGG(DISTINCT e.nome_empresa, ', ') as empresas_visiveis
FROM lead l
JOIN empresas e ON l.empresa_id = e.id;

-- Simular usuário da Empresa B
SELECT set_current_user_id(
    (SELECT id FROM usuarios WHERE email = 'usuario_b@empresa-b.com')
);

-- Deve retornar apenas leads da Empresa B
SELECT 
    'RLS Empresa B' as teste,
    COUNT(*) as leads_visiveis,
    STRING_AGG(DISTINCT e.nome_empresa, ', ') as empresas_visiveis
FROM lead l
JOIN empresas e ON l.empresa_id = e.id;

-- =====================================================
-- 5. TESTE 4: QUERIES DE PROSPECÇÃO
-- =====================================================

RAISE NOTICE '=== TESTE 4: QUERIES DE PROSPECÇÃO ===';

-- Simular usuário da Empresa A
SELECT set_current_user_id(
    (SELECT id FROM usuarios WHERE email = 'usuario_a@empresa-a.com')
);

-- Testar query de busca de leads não contatados
SELECT 
    'Leads não contatados Empresa A' as teste,
    COUNT(*) as total_leads,
    COUNT(CASE WHEN l.status = 'novo' THEN 1 END) as leads_novos
FROM lead l
WHERE l.empresa_id = (
    SELECT empresa_id FROM usuarios WHERE email = 'usuario_a@empresa-a.com'
);

-- =====================================================
-- 6. TESTE 5: ESTATÍSTICAS POR EMPRESA
-- =====================================================

RAISE NOTICE '=== TESTE 5: ESTATÍSTICAS POR EMPRESA ===';

-- Estatísticas gerais
SELECT 
    e.nome_empresa,
    COUNT(l.id) as total_leads,
    COUNT(CASE WHEN l.status = 'novo' THEN 1 END) as leads_novos,
    COUNT(CASE WHEN l.status = 'prospectando' THEN 1 END) as leads_prospectando,
    COUNT(CASE WHEN l.status = 'concluido' THEN 1 END) as leads_concluidos
FROM empresas e
LEFT JOIN lead l ON e.id = l.empresa_id
GROUP BY e.id, e.nome_empresa
ORDER BY total_leads DESC;

-- =====================================================
-- 7. TESTE 6: PERFORMANCE DOS ÍNDICES
-- =====================================================

RAISE NOTICE '=== TESTE 6: PERFORMANCE DOS ÍNDICES ===';

-- Verificar uso de índices
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM lead 
WHERE empresa_id = 1 
    AND status = 'novo'
ORDER BY created_at ASC;

-- =====================================================
-- 8. LIMPEZA DOS DADOS DE TESTE
-- =====================================================

RAISE NOTICE '=== LIMPEZA DOS DADOS DE TESTE ===';

-- Remover leads de teste
DELETE FROM lead 
WHERE nome LIKE 'Lead Empresa A%' 
    OR nome LIKE 'Lead Empresa B%';

-- Remover usuários de teste
DELETE FROM usuarios 
WHERE email IN (
    'usuario_a@empresa-a.com',
    'usuario_b@empresa-b.com'
);

-- Remover empresas de teste (opcional)
-- DELETE FROM empresas 
-- WHERE nome_empresa IN ('Empresa A', 'Empresa B');

-- =====================================================
-- 9. RELATÓRIO FINAL
-- =====================================================

RAISE NOTICE '=== RELATÓRIO FINAL ===';

-- Verificar estrutura final
SELECT 
    'Estrutura final' as item,
    COUNT(DISTINCT empresa_id) as empresas_com_leads,
    COUNT(*) as total_leads,
    COUNT(CASE WHEN empresa_id IS NOT NULL THEN 1 END) as leads_com_empresa
FROM lead;

-- Verificar políticas ativas
SELECT 
    'Políticas RLS' as item,
    COUNT(*) as total_politicas
FROM pg_policies 
WHERE tablename = 'lead';

-- Verificar funções criadas
SELECT 
    'Funções criadas' as item,
    COUNT(*) as total_funcoes
FROM information_schema.routines 
WHERE routine_name IN (
    'verificar_acesso_lead',
    'set_current_user_id',
    'testar_isolamento_empresa'
);

RAISE NOTICE 'Script 6 executado com sucesso! Testes de isolamento concluídos.';
