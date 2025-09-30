-- =====================================================
-- ATUALIZAÇÃO DOS USUÁRIOS PARA PERFIL ADMINISTRADOR
-- =====================================================

-- Verificar usuários atuais
SELECT 'Usuários atuais:' as info;
SELECT id, nome, email, perfil, empresa FROM usuarios ORDER BY id;

-- Verificar perfis disponíveis
SELECT 'Perfis disponíveis:' as info;
SELECT id, nome_perfil, descricao FROM perfis ORDER BY id;

-- =====================================================
-- ATUALIZAR USUÁRIOS PARA PERFIL ADMINISTRADOR
-- =====================================================

-- 1. Atualizar Administrator Code-IQ (ID: 5)
UPDATE usuarios 
SET perfil = 'Administrador',
    perfil_id = (SELECT id FROM perfis WHERE nome_perfil = 'Administrador')
WHERE id = 5;

-- 2. Atualizar Marcio André Macedo da Silva (ID: 15)
UPDATE usuarios 
SET perfil = 'Administrador',
    perfil_id = (SELECT id FROM perfis WHERE nome_perfil = 'Administrador')
WHERE id = 15;

-- 3. Atualizar Teste de Dashboard (ID: 6)
UPDATE usuarios 
SET perfil = 'Administrador',
    perfil_id = (SELECT id FROM perfis WHERE nome_perfil = 'Administrador')
WHERE id = 6;

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================
SELECT 'Usuários após atualização:' as info;
SELECT 
  id, 
  nome, 
  email, 
  perfil, 
  perfil_id,
  empresa
FROM usuarios 
ORDER BY id;

-- Verificar se todos têm o mesmo perfil_id
SELECT 'Verificação de consistência:' as info;
SELECT 
  perfil,
  perfil_id,
  COUNT(*) as total_usuarios
FROM usuarios 
GROUP BY perfil, perfil_id
ORDER BY perfil_id;

SELECT 'Atualização de usuários para Administrador concluída!' as status;
