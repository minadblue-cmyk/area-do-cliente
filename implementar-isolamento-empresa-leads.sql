-- Script para implementar isolamento de leads por empresa
-- e remover chaves únicas que impedem leads duplicados entre empresas

-- =====================================================
-- 1. REMOVER CHAVES ÚNICAS DE TELEFONE
-- =====================================================

-- Remover índice único de telefone (permite leads duplicados entre empresas)
DROP INDEX IF EXISTS lead_telefone_unique;

-- Remover índice único composto telefone + client_id
DROP INDEX IF EXISTS uq_lead_tel_client_idx;

-- =====================================================
-- 2. CRIAR ÍNDICES COMPOSTOS COM EMPRESA_ID
-- =====================================================

-- Índice único composto: empresa_id + telefone (permite mesmo telefone em empresas diferentes)
CREATE UNIQUE INDEX idx_lead_empresa_telefone_unique 
ON lead(empresa_id, telefone) 
WHERE telefone IS NOT NULL;

-- Índice para busca por telefone dentro de uma empresa
CREATE INDEX idx_lead_empresa_telefone 
ON lead(empresa_id, telefone);

-- =====================================================
-- 3. IMPLEMENTAR ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Habilitar RLS na tabela lead
ALTER TABLE lead ENABLE ROW LEVEL SECURITY;

-- Remover políticas existentes se houver
DROP POLICY IF EXISTS lead_empresa_policy ON lead;
DROP POLICY IF EXISTS lead_isolation_select_policy ON lead;
DROP POLICY IF EXISTS lead_isolation_insert_policy ON lead;
DROP POLICY IF EXISTS lead_isolation_update_policy ON lead;
DROP POLICY IF EXISTS lead_isolation_delete_policy ON lead;

-- Criar política de isolamento por empresa
CREATE POLICY lead_empresa_isolation_policy ON lead
    FOR ALL TO public
    USING (
        empresa_id = (
            SELECT empresa_id 
            FROM usuarios 
            WHERE id = current_setting('app.current_user_id')::INTEGER
        )
    )
    WITH CHECK (
        empresa_id = (
            SELECT empresa_id 
            FROM usuarios 
            WHERE id = current_setting('app.current_user_id')::INTEGER
        )
    );

-- =====================================================
-- 4. CRIAR FUNÇÃO AUXILIAR PARA DEFINIR USUÁRIO ATUAL
-- =====================================================

-- Função para definir o usuário atual na sessão
CREATE OR REPLACE FUNCTION set_current_user_id(user_id INTEGER)
RETURNS VOID AS $$
BEGIN
    PERFORM set_config('app.current_user_id', user_id::TEXT, false);
END;
$$ LANGUAGE plpgsql;

-- Função para obter o usuário atual da sessão
CREATE OR REPLACE FUNCTION get_current_user_id()
RETURNS INTEGER AS $$
BEGIN
    RETURN current_setting('app.current_user_id')::INTEGER;
END;
$$ LANGUAGE plpgsql;

-- Função para obter a empresa do usuário atual
CREATE OR REPLACE FUNCTION get_current_user_empresa_id()
RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT empresa_id 
        FROM usuarios 
        WHERE id = current_setting('app.current_user_id')::INTEGER
    );
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 5. ATUALIZAR QUERIES DE UPLOAD
-- =====================================================

-- Função para inserir lead com isolamento por empresa
CREATE OR REPLACE FUNCTION inserir_lead_com_empresa(
    p_nome TEXT,
    p_telefone TEXT,
    p_email TEXT,
    p_profissao TEXT,
    p_idade INTEGER,
    p_estado_civil TEXT,
    p_filhos BOOLEAN,
    p_qtd_filhos INTEGER,
    p_fonte_prospec TEXT,
    p_usuario_id INTEGER
)
RETURNS INTEGER AS $$
DECLARE
    v_empresa_id INTEGER;
    v_lead_id INTEGER;
BEGIN
    -- Obter empresa_id do usuário
    SELECT empresa_id INTO v_empresa_id
    FROM usuarios 
    WHERE id = p_usuario_id;
    
    IF v_empresa_id IS NULL THEN
        RAISE EXCEPTION 'Usuário não encontrado ou sem empresa associada';
    END IF;
    
    -- Definir usuário atual para RLS
    PERFORM set_current_user_id(p_usuario_id);
    
    -- Inserir lead
    INSERT INTO lead (
        nome, telefone, email, profissao, idade, estado_civil,
        filhos, qtd_filhos, fonte_prospec, empresa_id, usuario_id,
        status, contatado, created_at, updated_at
    ) VALUES (
        p_nome, p_telefone, p_email, p_profissao, p_idade, p_estado_civil,
        p_filhos, p_qtd_filhos, p_fonte_prospec, v_empresa_id, p_usuario_id,
        'novo', false, NOW(), NOW()
    ) RETURNING id INTO v_lead_id;
    
    RETURN v_lead_id;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 6. ATUALIZAR QUERIES DE PROSPECÇÃO
-- =====================================================

-- Função para buscar leads não contatados (filtrado por empresa)
CREATE OR REPLACE FUNCTION buscar_leads_nao_contatados_empresa(
    p_usuario_id INTEGER,
    p_quantidade INTEGER DEFAULT 10
)
RETURNS TABLE (
    id INTEGER,
    nome TEXT,
    telefone TEXT,
    email TEXT,
    status VARCHAR(20),
    empresa_id INTEGER,
    agente_id INTEGER,
    perfil_id INTEGER,
    reservado_por TEXT,
    reservado_em TIMESTAMP WITH TIME ZONE,
    reservado_lote TEXT,
    permissoes_acesso JSONB,
    contatado BOOLEAN,
    created_at TIMESTAMP
) AS $$
DECLARE
    v_empresa_id INTEGER;
BEGIN
    -- Obter empresa_id do usuário
    SELECT empresa_id INTO v_empresa_id
    FROM usuarios 
    WHERE id = p_usuario_id;
    
    IF v_empresa_id IS NULL THEN
        RAISE EXCEPTION 'Usuário não encontrado ou sem empresa associada';
    END IF;
    
    -- Definir usuário atual para RLS
    PERFORM set_current_user_id(p_usuario_id);
    
    -- Retornar leads não contatados da empresa
    RETURN QUERY
    SELECT 
        l.id, l.nome, l.telefone, l.email, l.status,
        l.empresa_id, l.agente_id, l.perfil_id,
        l.reservado_por, l.reservado_em, l.reservado_lote,
        l.permissoes_acesso, l.contatado, l.created_at
    FROM lead l
    WHERE l.empresa_id = v_empresa_id
        AND l.status = 'novo'
        AND l.agente_id IS NULL
    ORDER BY l.created_at ASC
    LIMIT p_quantidade;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 7. ATUALIZAR QUERIES DE RESERVA DE LOTE
-- =====================================================

-- Função para reservar lote de leads (filtrado por empresa)
CREATE OR REPLACE FUNCTION reservar_lote_leads_empresa(
    p_usuario_id INTEGER,
    p_agente_id INTEGER,
    p_perfil_id INTEGER,
    p_nome_usuario TEXT,
    p_lote_id TEXT,
    p_quantidade INTEGER DEFAULT 10
)
RETURNS TABLE (
    id INTEGER,
    nome TEXT,
    telefone TEXT,
    email TEXT,
    status VARCHAR(20),
    empresa_id INTEGER,
    agente_id INTEGER,
    perfil_id INTEGER,
    reservado_por TEXT,
    reservado_em TIMESTAMP WITH TIME ZONE,
    reservado_lote TEXT,
    permissoes_acesso JSONB,
    contatado BOOLEAN
) AS $$
DECLARE
    v_empresa_id INTEGER;
    v_permissoes JSONB;
BEGIN
    -- Obter empresa_id do usuário
    SELECT empresa_id INTO v_empresa_id
    FROM usuarios 
    WHERE id = p_usuario_id;
    
    IF v_empresa_id IS NULL THEN
        RAISE EXCEPTION 'Usuário não encontrado ou sem empresa associada';
    END IF;
    
    -- Definir usuário atual para RLS
    PERFORM set_current_user_id(p_usuario_id);
    
    -- Criar permissões de acesso
    v_permissoes := jsonb_build_object(
        'agente_id', p_agente_id,
        'reservado_por', p_nome_usuario,
        'reservado_em', NOW(),
        'perfis_permitidos', ARRAY[p_perfil_id],
        'usuarios_permitidos', ARRAY[p_usuario_id]
    );
    
    -- Reservar leads
    WITH leads_reservados AS (
        UPDATE lead 
        SET 
            status = 'prospectando',
            agente_id = p_agente_id,
            perfil_id = p_perfil_id,
            reservado_por = p_nome_usuario,
            reservado_em = NOW(),
            reservado_lote = p_lote_id,
            permissoes_acesso = v_permissoes,
            contatado = true,
            updated_at = NOW()
        WHERE id IN (
            SELECT l.id
            FROM lead l
            WHERE l.empresa_id = v_empresa_id
                AND l.status = 'novo'
                AND l.agente_id IS NULL
            ORDER BY l.created_at ASC
            LIMIT p_quantidade
        )
        RETURNING *
    )
    SELECT 
        lr.id, lr.nome, lr.telefone, lr.email, lr.status,
        lr.empresa_id, lr.agente_id, lr.perfil_id,
        lr.reservado_por, lr.reservado_em, lr.reservado_lote,
        lr.permissoes_acesso, lr.contatado
    FROM leads_reservados lr
    ORDER BY lr.created_at ASC;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 8. ATUALIZAR QUERIES DE LISTA DE PROSPECÇÃO
-- =====================================================

-- Função para buscar lote reservado (filtrado por empresa)
CREATE OR REPLACE FUNCTION buscar_lote_reservado_empresa(
    p_usuario_id INTEGER,
    p_agente_id INTEGER
)
RETURNS TABLE (
    id INTEGER,
    nome TEXT,
    telefone TEXT,
    email TEXT,
    status VARCHAR(20),
    empresa_id INTEGER,
    agente_id INTEGER,
    perfil_id INTEGER,
    reservado_por TEXT,
    reservado_em TIMESTAMP WITH TIME ZONE,
    reservado_lote TEXT,
    permissoes_acesso JSONB,
    contatado BOOLEAN,
    data_ultima_interacao TIMESTAMP,
    created_at TIMESTAMP,
    empresa_nome TEXT
) AS $$
DECLARE
    v_empresa_id INTEGER;
BEGIN
    -- Obter empresa_id do usuário
    SELECT empresa_id INTO v_empresa_id
    FROM usuarios 
    WHERE id = p_usuario_id;
    
    IF v_empresa_id IS NULL THEN
        RAISE EXCEPTION 'Usuário não encontrado ou sem empresa associada';
    END IF;
    
    -- Definir usuário atual para RLS
    PERFORM set_current_user_id(p_usuario_id);
    
    -- Retornar lote reservado da empresa
    RETURN QUERY
    SELECT 
        l.id, l.nome, l.telefone, l.email, l.status,
        l.empresa_id, l.agente_id, l.perfil_id,
        l.reservado_por, l.reservado_em, l.reservado_lote,
        l.permissoes_acesso, l.contatado, l.data_ultima_interacao,
        l.created_at, e.nome_empresa
    FROM lead l
    JOIN empresas e ON l.empresa_id = e.id
    WHERE l.empresa_id = v_empresa_id
        AND l.agente_id = p_agente_id
        AND l.status = 'prospectando'
        AND (
            l.permissoes_acesso->>'perfis_permitidos' IS NULL 
            OR p_perfil_id = ANY(
                SELECT jsonb_array_elements_text(l.permissoes_acesso->'perfis_permitidos')::INTEGER
            )
        )
        AND (
            l.permissoes_acesso->>'usuarios_permitidos' IS NULL 
            OR p_usuario_id = ANY(
                SELECT jsonb_array_elements_text(l.permissoes_acesso->'usuarios_permitidos')::INTEGER
            )
        )
    ORDER BY l.created_at ASC;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 9. CRIAR ÍNDICES ADICIONAIS PARA PERFORMANCE
-- =====================================================

-- Índice para busca por empresa e status
CREATE INDEX IF NOT EXISTS idx_lead_empresa_status_agente 
ON lead(empresa_id, status, agente_id);

-- Índice para busca por empresa e data de criação
CREATE INDEX IF NOT EXISTS idx_lead_empresa_created_status 
ON lead(empresa_id, created_at, status);

-- Índice para busca por lote reservado
CREATE INDEX IF NOT EXISTS idx_lead_empresa_lote 
ON lead(empresa_id, reservado_lote);

-- =====================================================
-- 10. VERIFICAR IMPLEMENTAÇÃO
-- =====================================================

-- Verificar se RLS está ativo
SELECT 
    'RLS_STATUS' as categoria,
    schemaname,
    tablename,
    rowsecurity as rls_ativo
FROM pg_tables 
WHERE tablename = 'lead';

-- Verificar políticas criadas
SELECT 
    'POLITICAS_RLS' as categoria,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'lead';

-- Verificar índices únicos
SELECT 
    'INDICES_UNICOS' as categoria,
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename = 'lead' 
    AND indexdef LIKE '%UNIQUE%';

-- Verificar funções criadas
SELECT 
    'FUNCOES_CRIADAS' as categoria,
    routine_name,
    routine_type
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

-- =====================================================
-- 11. TESTE DE ISOLAMENTO
-- =====================================================

-- Criar dados de teste para verificar isolamento
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

-- Testar inserção de leads com mesmo telefone em empresas diferentes
DO $$
DECLARE
    v_empresa_a_id INTEGER;
    v_empresa_b_id INTEGER;
    v_usuario_a_id INTEGER;
    v_usuario_b_id INTEGER;
    v_lead_a_id INTEGER;
    v_lead_b_id INTEGER;
BEGIN
    -- Obter IDs das empresas e usuários
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
    
    RAISE NOTICE 'Teste de isolamento executado com sucesso!';
    RAISE NOTICE 'Lead Empresa A ID: %', v_lead_a_id;
    RAISE NOTICE 'Lead Empresa B ID: %', v_lead_b_id;
    RAISE NOTICE 'Mesmo telefone em empresas diferentes: OK';
END $$;

-- Verificar isolamento
SELECT 
    'TESTE_ISOLAMENTO' as categoria,
    l.id,
    l.nome,
    l.telefone,
    e.nome_empresa,
    u.nome as usuario_nome
FROM lead l
JOIN empresas e ON l.empresa_id = e.id
JOIN usuarios u ON l.usuario_id = u.id
WHERE l.telefone = '11999999999'
ORDER BY e.nome_empresa;

-- Limpar dados de teste
DELETE FROM lead WHERE telefone = '11999999999';
DELETE FROM usuarios WHERE email LIKE '%teste%';
DELETE FROM empresas WHERE nome_empresa LIKE '%Teste%';

RAISE NOTICE 'Isolamento de leads por empresa implementado com sucesso!';
RAISE NOTICE 'Chaves únicas removidas - mesmo telefone pode existir em empresas diferentes';
RAISE NOTICE 'RLS ativo - usuários só veem leads da própria empresa';
RAISE NOTICE 'Funções criadas para upload e prospecção com isolamento';
