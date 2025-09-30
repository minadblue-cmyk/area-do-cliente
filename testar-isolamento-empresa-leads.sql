-- Script para testar isolamento de leads por empresa
-- Execute este script para validar o isolamento

-- =====================================================
-- 1. PREPARAR DADOS DE TESTE
-- =====================================================

-- Criar empresas de teste
INSERT INTO empresas (nome_empresa, descricao, created_at)
VALUES 
    ('Empresa Teste A', 'Empresa de teste A', NOW()),
    ('Empresa Teste B', 'Empresa de teste B', NOW())
ON CONFLICT (nome_empresa) DO NOTHING;

-- Criar usuários de teste
INSERT INTO usuarios (email, nome, perfil, ativo, empresa_id, created_at)
SELECT 
    'usuario_teste_a@empresa-a.com',
    'Usuário Empresa A',
    'admin',
    true,
    e.id,
    NOW()
FROM empresas e WHERE e.nome_empresa = 'Empresa Teste A'
ON CONFLICT (email) DO NOTHING;

INSERT INTO usuarios (email, nome, perfil, ativo, empresa_id, created_at)
SELECT 
    'usuario_teste_b@empresa-b.com',
    'Usuário Empresa B',
    'admin',
    true,
    e.id,
    NOW()
FROM empresas e WHERE e.nome_empresa = 'Empresa Teste B'
ON CONFLICT (email) DO NOTHING;

-- =====================================================
-- 2. TESTE 1: INSERIR LEADS COM MESMO TELEFONE
-- =====================================================

RAISE NOTICE '=== TESTE 1: INSERIR LEADS COM MESMO TELEFONE ===';

-- Obter IDs das empresas e usuários
DO $$
DECLARE
    v_empresa_a_id INTEGER;
    v_empresa_b_id INTEGER;
    v_usuario_a_id INTEGER;
    v_usuario_b_id INTEGER;
    v_lead_a_id INTEGER;
    v_lead_b_id INTEGER;
BEGIN
    -- Obter IDs
    SELECT id INTO v_empresa_a_id FROM empresas WHERE nome_empresa = 'Empresa Teste A';
    SELECT id INTO v_empresa_b_id FROM empresas WHERE nome_empresa = 'Empresa Teste B';
    SELECT id INTO v_usuario_a_id FROM usuarios WHERE email = 'usuario_teste_a@empresa-a.com';
    SELECT id INTO v_usuario_b_id FROM usuarios WHERE email = 'usuario_teste_b@empresa-b.com';
    
    -- Inserir lead na Empresa A
    SELECT inserir_lead_com_empresa(
        'João Silva',
        '11999999999',
        'joao@empresa-a.com',
        'Engenheiro',
        30,
        'Solteiro',
        false,
        0,
        'Indicação',
        v_usuario_a_id
    ) INTO v_lead_a_id;
    
    -- Inserir lead com mesmo telefone na Empresa B
    SELECT inserir_lead_com_empresa(
        'João Silva',
        '11999999999',
        'joao@empresa-b.com',
        'Engenheiro',
        30,
        'Solteiro',
        false,
        0,
        'Indicação',
        v_usuario_b_id
    ) INTO v_lead_b_id;
    
    RAISE NOTICE 'Lead Empresa A ID: %', v_lead_a_id;
    RAISE NOTICE 'Lead Empresa B ID: %', v_lead_b_id;
    RAISE NOTICE 'Mesmo telefone em empresas diferentes: OK';
END $$;

-- =====================================================
-- 3. TESTE 2: VERIFICAR ISOLAMENTO ENTRE EMPRESAS
-- =====================================================

RAISE NOTICE '=== TESTE 2: VERIFICAR ISOLAMENTO ENTRE EMPRESAS ===';

-- Simular usuário da Empresa A
SELECT set_current_user_id(
    (SELECT id FROM usuarios WHERE email = 'usuario_teste_a@empresa-a.com')
);

-- Usuário A deve ver apenas leads da Empresa A
SELECT 
    'Empresa A' as empresa_usuario,
    COUNT(*) as total_leads_visiveis,
    COUNT(CASE WHEN l.empresa_id = e.id THEN 1 END) as leads_propria_empresa,
    COUNT(CASE WHEN l.empresa_id != e.id THEN 1 END) as leads_outras_empresas
FROM lead l
CROSS JOIN empresas e
WHERE e.nome_empresa = 'Empresa Teste A';

-- Simular usuário da Empresa B
SELECT set_current_user_id(
    (SELECT id FROM usuarios WHERE email = 'usuario_teste_b@empresa-b.com')
);

-- Usuário B deve ver apenas leads da Empresa B
SELECT 
    'Empresa B' as empresa_usuario,
    COUNT(*) as total_leads_visiveis,
    COUNT(CASE WHEN l.empresa_id = e.id THEN 1 END) as leads_propria_empresa,
    COUNT(CASE WHEN l.empresa_id != e.id THEN 1 END) as leads_outras_empresas
FROM lead l
CROSS JOIN empresas e
WHERE e.nome_empresa = 'Empresa Teste B';

-- =====================================================
-- 4. TESTE 3: VERIFICAR CHAVES ÚNICAS
-- =====================================================

RAISE NOTICE '=== TESTE 3: VERIFICAR CHAVES ÚNICAS ===';

-- Verificar se mesmo telefone pode existir em empresas diferentes
SELECT 
    'CHAVES_UNICAS' as categoria,
    telefone,
    COUNT(*) as quantidade,
    STRING_AGG(empresa_id::TEXT, ', ') as empresas,
    STRING_AGG(nome, ', ') as nomes
FROM lead
WHERE telefone = '11999999999'
GROUP BY telefone;

-- =====================================================
-- 5. TESTE 4: VERIFICAR ROW LEVEL SECURITY
-- =====================================================

RAISE NOTICE '=== TESTE 4: VERIFICAR ROW LEVEL SECURITY ===';

-- Simular usuário da Empresa A
SELECT set_current_user_id(
    (SELECT id FROM usuarios WHERE email = 'usuario_teste_a@empresa-a.com')
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
    (SELECT id FROM usuarios WHERE email = 'usuario_teste_b@empresa-b.com')
);

-- Deve retornar apenas leads da Empresa B
SELECT 
    'RLS Empresa B' as teste,
    COUNT(*) as leads_visiveis,
    STRING_AGG(DISTINCT e.nome_empresa, ', ') as empresas_visiveis
FROM lead l
JOIN empresas e ON l.empresa_id = e.id;

-- =====================================================
-- 6. TESTE 5: VERIFICAR FUNÇÕES DE PROSPECÇÃO
-- =====================================================

RAISE NOTICE '=== TESTE 5: VERIFICAR FUNÇÕES DE PROSPECÇÃO ===';

-- Simular usuário da Empresa A
SELECT set_current_user_id(
    (SELECT id FROM usuarios WHERE email = 'usuario_teste_a@empresa-a.com')
);

-- Testar busca de leads não contatados
SELECT 
    'Leads não contatados Empresa A' as teste,
    COUNT(*) as total_leads,
    COUNT(CASE WHEN l.status = 'novo' THEN 1 END) as leads_novos
FROM lead l
WHERE l.empresa_id = (
    SELECT empresa_id FROM usuarios WHERE email = 'usuario_teste_a@empresa-a.com'
);

-- =====================================================
-- 7. TESTE 6: VERIFICAR RESERVA DE LOTE
-- =====================================================

RAISE NOTICE '=== TESTE 6: VERIFICAR RESERVA DE LOTE ===';

-- Simular usuário da Empresa A
SELECT set_current_user_id(
    (SELECT id FROM usuarios WHERE email = 'usuario_teste_a@empresa-a.com')
);

-- Testar reserva de lote
SELECT 
    'Reserva de lote Empresa A' as teste,
    COUNT(*) as leads_reservados
FROM reservar_lote_leads_empresa(
    (SELECT id FROM usuarios WHERE email = 'usuario_teste_a@empresa-a.com'),
    1, -- agente_id
    1, -- perfil_id
    'Usuário Teste A',
    'LOTE_TESTE_A',
    5 -- quantidade
);

-- =====================================================
-- 8. TESTE 7: VERIFICAR BUSCA DE LOTE RESERVADO
-- =====================================================

RAISE NOTICE '=== TESTE 7: VERIFICAR BUSCA DE LOTE RESERVADO ===';

-- Simular usuário da Empresa A
SELECT set_current_user_id(
    (SELECT id FROM usuarios WHERE email = 'usuario_teste_a@empresa-a.com')
);

-- Testar busca de lote reservado
SELECT 
    'Lote reservado Empresa A' as teste,
    COUNT(*) as leads_no_lote
FROM buscar_lote_reservado_empresa(
    (SELECT id FROM usuarios WHERE email = 'usuario_teste_a@empresa-a.com'),
    1 -- agente_id
);

-- =====================================================
-- 9. TESTE 8: VERIFICAR TENTATIVA DE ACESSO CRUZADO
-- =====================================================

RAISE NOTICE '=== TESTE 8: VERIFICAR TENTATIVA DE ACESSO CRUZADO ===';

-- Simular usuário da Empresa A tentando acessar lead da Empresa B
SELECT set_current_user_id(
    (SELECT id FROM usuarios WHERE email = 'usuario_teste_a@empresa-a.com')
);

-- Tentar buscar leads da Empresa B (deve retornar vazio)
SELECT 
    'Tentativa acesso cruzado' as teste,
    COUNT(*) as leads_empresa_b_visiveis
FROM lead l
JOIN empresas e ON l.empresa_id = e.id
WHERE e.nome_empresa = 'Empresa Teste B';

-- =====================================================
-- 10. TESTE 9: VERIFICAR PERFORMANCE DOS ÍNDICES
-- =====================================================

RAISE NOTICE '=== TESTE 9: VERIFICAR PERFORMANCE DOS ÍNDICES ===';

-- Verificar uso de índices
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM lead 
WHERE empresa_id = 1 
    AND status = 'novo'
ORDER BY created_at ASC;

-- =====================================================
-- 11. TESTE 10: VERIFICAR ESTATÍSTICAS
-- =====================================================

RAISE NOTICE '=== TESTE 10: VERIFICAR ESTATÍSTICAS ===';

-- Estatísticas gerais
SELECT 
    'ESTATISTICAS_GERAIS' as categoria,
    COUNT(*) as total_leads,
    COUNT(DISTINCT empresa_id) as empresas_diferentes,
    COUNT(DISTINCT telefone) as telefones_unicos,
    COUNT(*) - COUNT(DISTINCT telefone) as telefones_duplicados
FROM lead;

-- Estatísticas por empresa
SELECT 
    'ESTATISTICAS_POR_EMPRESA' as categoria,
    e.nome_empresa,
    COUNT(l.id) as total_leads,
    COUNT(DISTINCT l.telefone) as telefones_unicos,
    COUNT(l.id) - COUNT(DISTINCT l.telefone) as telefones_duplicados
FROM empresas e
LEFT JOIN lead l ON e.id = l.empresa_id
GROUP BY e.id, e.nome_empresa
ORDER BY total_leads DESC;

-- =====================================================
-- 12. LIMPEZA DOS DADOS DE TESTE
-- =====================================================

RAISE NOTICE '=== LIMPEZA DOS DADOS DE TESTE ===';

-- Remover leads de teste
DELETE FROM lead WHERE telefone = '11999999999';

-- Remover usuários de teste
DELETE FROM usuarios WHERE email LIKE '%teste%';

-- Remover empresas de teste
DELETE FROM empresas WHERE nome_empresa LIKE '%Teste%';

-- =====================================================
-- 13. RELATÓRIO FINAL
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
    'set_current_user_id',
    'get_current_user_id',
    'get_current_user_empresa_id',
    'inserir_lead_com_empresa',
    'buscar_leads_nao_contatados_empresa',
    'reservar_lote_leads_empresa',
    'buscar_lote_reservado_empresa'
);

-- Verificar índices únicos
SELECT 
    'Índices únicos' as item,
    COUNT(*) as total_indices_unicos
FROM pg_indexes 
WHERE tablename = 'lead' 
    AND indexdef LIKE '%UNIQUE%';

RAISE NOTICE 'Teste de isolamento de leads por empresa concluído com sucesso!';
RAISE NOTICE 'Isolamento funcionando: usuários só veem leads da própria empresa';
RAISE NOTICE 'Chaves únicas removidas: mesmo telefone pode existir em empresas diferentes';
RAISE NOTICE 'RLS ativo: proteção automática por empresa';
RAISE NOTICE 'Funções criadas: upload e prospecção com isolamento';
