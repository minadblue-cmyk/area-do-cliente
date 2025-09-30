-- Script 3: Implementar Row Level Security (RLS) para isolamento por empresa
-- Executar APÓS os Scripts 1 e 2

-- =====================================================
-- 1. HABILITAR ROW LEVEL SECURITY
-- =====================================================

-- Habilitar RLS na tabela lead
ALTER TABLE lead ENABLE ROW LEVEL SECURITY;

-- Habilitar RLS na tabela usuarios (opcional, para maior segurança)
-- ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;

RAISE NOTICE 'Row Level Security habilitado na tabela lead';

-- =====================================================
-- 2. CRIAR POLÍTICA DE SEGURANÇA PARA LEADS
-- =====================================================

-- Política: usuários só veem leads da própria empresa
CREATE POLICY leads_empresa_policy ON lead
    FOR ALL TO public
    USING (
        empresa_id = (
            SELECT empresa_id 
            FROM usuarios 
            WHERE id = current_setting('app.current_user_id')::INTEGER
        )
    );

-- Adicionar comentário na política
COMMENT ON POLICY leads_empresa_policy ON lead IS 
'Política de segurança: usuários só podem acessar leads da própria empresa';

RAISE NOTICE 'Política de segurança leads_empresa_policy criada';

-- =====================================================
-- 3. CRIAR FUNÇÃO AUXILIAR PARA DEFINIR USUÁRIO ATUAL
-- =====================================================

-- Função para definir usuário atual na sessão
CREATE OR REPLACE FUNCTION set_current_user_id(user_id INTEGER)
RETURNS VOID AS $$
BEGIN
    PERFORM set_config('app.current_user_id', user_id::TEXT, false);
END;
$$ LANGUAGE plpgsql;

-- Adicionar comentário
COMMENT ON FUNCTION set_current_user_id(INTEGER) IS 
'Define o ID do usuário atual para uso nas políticas RLS';

-- =====================================================
-- 4. CRIAR FUNÇÃO DE TESTE DE ISOLAMENTO
-- =====================================================

-- Função para testar isolamento entre empresas
CREATE OR REPLACE FUNCTION testar_isolamento_empresa()
RETURNS TABLE(
    empresa_id INTEGER,
    empresa_nome TEXT,
    total_leads BIGINT,
    usuarios_empresa BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.id as empresa_id,
        e.nome as empresa_nome,
        COUNT(l.id) as total_leads,
        COUNT(u.id) as usuarios_empresa
    FROM empresas e
    LEFT JOIN lead l ON e.id = l.empresa_id
    LEFT JOIN usuarios u ON e.id = u.empresa_id
    GROUP BY e.id, e.nome
    ORDER BY e.id;
END;
$$ LANGUAGE plpgsql;

-- Adicionar comentário
COMMENT ON FUNCTION testar_isolamento_empresa() IS 
'Testa o isolamento de dados entre empresas';

-- =====================================================
-- 5. CRIAR VIEWS SEGURAS PARA CONSULTAS
-- =====================================================

-- View para leads com informações de empresa (segura)
CREATE OR REPLACE VIEW vw_leads_empresa AS
SELECT 
    l.id,
    l.nome,
    l.telefone,
    l.email,
    l.status,
    l.empresa_id,
    e.nome as empresa_nome,
    l.created_at,
    l.updated_at
FROM lead l
JOIN empresas e ON l.empresa_id = e.id;

-- Adicionar comentário
COMMENT ON VIEW vw_leads_empresa IS 
'View segura para consultar leads com informações da empresa';

-- =====================================================
-- 6. CRIAR FUNÇÃO PARA CONSULTAS SEGURAS
-- =====================================================

-- Função para buscar leads do usuário atual (com RLS)
CREATE OR REPLACE FUNCTION buscar_leads_usuario_atual()
RETURNS TABLE(
    lead_id INTEGER,
    lead_nome TEXT,
    lead_telefone TEXT,
    lead_status TEXT,
    empresa_nome TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        l.id as lead_id,
        l.nome as lead_nome,
        l.telefone as lead_telefone,
        l.status as lead_status,
        e.nome as empresa_nome
    FROM lead l
    JOIN empresas e ON l.empresa_id = e.id
    WHERE l.empresa_id = (
        SELECT empresa_id 
        FROM usuarios 
        WHERE id = current_setting('app.current_user_id')::INTEGER
    );
END;
$$ LANGUAGE plpgsql;

-- Adicionar comentário
COMMENT ON FUNCTION buscar_leads_usuario_atual() IS 
'Busca leads do usuário atual respeitando isolamento por empresa';

-- =====================================================
-- 7. TESTAR ISOLAMENTO
-- =====================================================

-- Teste 1: Verificar estrutura de isolamento
SELECT 
    'Estrutura de isolamento' as teste,
    COUNT(DISTINCT empresa_id) as empresas_com_leads,
    COUNT(*) as total_leads
FROM lead;

-- Teste 2: Verificar distribuição por empresa
SELECT * FROM testar_isolamento_empresa();

-- =====================================================
-- 8. CRIAR ÍNDICES ADICIONAIS PARA PERFORMANCE
-- =====================================================

-- Índice composto para consultas por empresa e status
CREATE INDEX IF NOT EXISTS idx_lead_empresa_status 
ON lead(empresa_id, status);

-- Índice composto para consultas por empresa e data
CREATE INDEX IF NOT EXISTS idx_lead_empresa_created 
ON lead(empresa_id, created_at);

-- =====================================================
-- 9. DOCUMENTAÇÃO DAS POLÍTICAS
-- =====================================================

-- Criar tabela de documentação das políticas
CREATE TABLE IF NOT EXISTS politicas_seguranca (
    id SERIAL PRIMARY KEY,
    tabela TEXT NOT NULL,
    politica_nome TEXT NOT NULL,
    descricao TEXT NOT NULL,
    criada_em TIMESTAMP DEFAULT NOW()
);

-- Inserir documentação da política criada
INSERT INTO politicas_seguranca (tabela, politica_nome, descricao)
VALUES (
    'lead',
    'leads_empresa_policy',
    'Usuários só podem acessar leads da própria empresa. Baseada no campo empresa_id do usuário logado.'
);

-- =====================================================
-- 10. VERIFICAÇÃO FINAL
-- =====================================================

-- Verificar se RLS está ativo
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_ativo,
    hasrls as tem_rls
FROM pg_tables 
WHERE tablename = 'lead';

-- Verificar políticas criadas
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'lead';

-- Verificar funções criadas
SELECT 
    routine_name,
    routine_type,
    data_type as return_type
FROM information_schema.routines 
WHERE routine_name IN (
    'set_current_user_id',
    'testar_isolamento_empresa',
    'buscar_leads_usuario_atual'
);

RAISE NOTICE 'Script 3 executado com sucesso! Row Level Security implementado.';
RAISE NOTICE 'Para usar: SELECT set_current_user_id(1); -- antes de consultar leads';
