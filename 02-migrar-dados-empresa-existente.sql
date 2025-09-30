-- Script 2: Migrar dados existentes para incluir empresa_id
-- Executar APÓS o Script 1

-- =====================================================
-- 1. VERIFICAR DADOS EXISTENTES
-- =====================================================

-- Contar leads sem empresa_id
SELECT 
    COUNT(*) as leads_sem_empresa,
    'leads' as tabela
FROM lead 
WHERE empresa_id IS NULL

UNION ALL

-- Contar usuarios sem empresa_id
SELECT 
    COUNT(*) as usuarios_sem_empresa,
    'usuarios' as tabela
FROM usuarios 
WHERE empresa_id IS NULL;

-- =====================================================
-- 2. CRIAR EMPRESA PADRÃO SE NÃO EXISTIR
-- =====================================================

-- Verificar se existe empresa padrão
DO $$
DECLARE
    empresa_padrao_id INTEGER;
BEGIN
    -- Buscar empresa padrão (assumindo ID 1 ou nome específico)
    SELECT id INTO empresa_padrao_id 
    FROM empresas 
    WHERE id = 1 OR nome ILIKE '%padrão%' OR nome ILIKE '%default%'
    LIMIT 1;
    
    -- Se não existir, criar empresa padrão
    IF empresa_padrao_id IS NULL THEN
        INSERT INTO empresas (nome, descricao, ativo, created_at, updated_at)
        VALUES (
            'Empresa Padrão',
            'Empresa padrão para migração de dados existentes',
            true,
            NOW(),
            NOW()
        )
        RETURNING id INTO empresa_padrao_id;
        
        RAISE NOTICE 'Empresa padrão criada com ID: %', empresa_padrao_id;
    ELSE
        RAISE NOTICE 'Empresa padrão encontrada com ID: %', empresa_padrao_id;
    END IF;
    
    -- Armazenar ID da empresa padrão em uma variável de sessão
    PERFORM set_config('app.empresa_padrao_id', empresa_padrao_id::TEXT, false);
END $$;

-- =====================================================
-- 3. MIGRAR LEADS EXISTENTES
-- =====================================================

-- Atribuir empresa padrão para leads sem empresa_id
UPDATE lead 
SET empresa_id = (
    SELECT id FROM empresas 
    WHERE id = 1 OR nome ILIKE '%padrão%' OR nome ILIKE '%default%'
    LIMIT 1
)
WHERE empresa_id IS NULL;

-- Verificar quantos leads foram migrados
SELECT 
    COUNT(*) as leads_migrados,
    'leads migrados para empresa padrão' as descricao
FROM lead 
WHERE empresa_id IS NOT NULL;

-- =====================================================
-- 4. MIGRAR USUARIOS EXISTENTES
-- =====================================================

-- Atribuir empresa padrão para usuarios sem empresa_id
UPDATE usuarios 
SET empresa_id = (
    SELECT id FROM empresas 
    WHERE id = 1 OR nome ILIKE '%padrão%' OR nome ILIKE '%default%'
    LIMIT 1
)
WHERE empresa_id IS NULL;

-- Verificar quantos usuarios foram migrados
SELECT 
    COUNT(*) as usuarios_migrados,
    'usuarios migrados para empresa padrão' as descricao
FROM usuarios 
WHERE empresa_id IS NOT NULL;

-- =====================================================
-- 5. TORNAR CAMPOS OBRIGATÓRIOS
-- =====================================================

-- Tornar empresa_id obrigatório na tabela lead
ALTER TABLE lead ALTER COLUMN empresa_id SET NOT NULL;

-- Tornar empresa_id obrigatório na tabela usuarios
ALTER TABLE usuarios ALTER COLUMN empresa_id SET NOT NULL;

-- =====================================================
-- 6. VERIFICAR INTEGRIDADE DOS DADOS
-- =====================================================

-- Verificar se todos os leads têm empresa_id
SELECT 
    COUNT(*) as total_leads,
    COUNT(empresa_id) as leads_com_empresa,
    COUNT(*) - COUNT(empresa_id) as leads_sem_empresa
FROM lead;

-- Verificar se todos os usuarios têm empresa_id
SELECT 
    COUNT(*) as total_usuarios,
    COUNT(empresa_id) as usuarios_com_empresa,
    COUNT(*) - COUNT(empresa_id) as usuarios_sem_empresa
FROM usuarios;

-- Verificar relacionamentos
SELECT 
    'Leads por empresa' as tipo,
    e.nome as empresa_nome,
    COUNT(l.id) as quantidade
FROM empresas e
LEFT JOIN lead l ON e.id = l.empresa_id
GROUP BY e.id, e.nome
ORDER BY quantidade DESC;

SELECT 
    'Usuarios por empresa' as tipo,
    e.nome as empresa_nome,
    COUNT(u.id) as quantidade
FROM empresas e
LEFT JOIN usuarios u ON e.id = u.empresa_id
GROUP BY e.id, e.nome
ORDER BY quantidade DESC;

-- =====================================================
-- 7. CRIAR FUNÇÃO DE VALIDAÇÃO
-- =====================================================

-- Função para verificar se usuário pode acessar lead
CREATE OR REPLACE FUNCTION verificar_acesso_lead(
    p_lead_id INTEGER,
    p_usuario_id INTEGER
) RETURNS BOOLEAN AS $$
DECLARE
    lead_empresa_id INTEGER;
    usuario_empresa_id INTEGER;
BEGIN
    -- Buscar empresa do lead
    SELECT empresa_id INTO lead_empresa_id
    FROM lead WHERE id = p_lead_id;
    
    -- Buscar empresa do usuário
    SELECT empresa_id INTO usuario_empresa_id
    FROM usuarios WHERE id = p_usuario_id;
    
    -- Verificar se são da mesma empresa
    RETURN (lead_empresa_id = usuario_empresa_id AND lead_empresa_id IS NOT NULL);
END;
$$ LANGUAGE plpgsql;

-- Adicionar comentário na função
COMMENT ON FUNCTION verificar_acesso_lead(INTEGER, INTEGER) IS 
'Verifica se um usuário pode acessar um lead baseado na empresa';

-- =====================================================
-- 8. TESTE DA FUNÇÃO
-- =====================================================

-- Testar função com dados existentes
SELECT 
    l.id as lead_id,
    u.id as usuario_id,
    e_lead.nome as empresa_lead,
    e_user.nome as empresa_usuario,
    verificar_acesso_lead(l.id, u.id) as pode_acessar
FROM lead l
CROSS JOIN usuarios u
JOIN empresas e_lead ON l.empresa_id = e_lead.id
JOIN empresas e_user ON u.empresa_id = e_user.id
LIMIT 10;

RAISE NOTICE 'Script 2 executado com sucesso! Dados migrados e validações criadas.';
