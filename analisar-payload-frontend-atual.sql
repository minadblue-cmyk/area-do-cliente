-- =====================================================
-- ANALISAR PAYLOAD ATUAL DO FRONTEND
-- =====================================================

-- O payload atual do frontend tem:
-- {
--   "action": "start",
--   "agent_type": 81,
--   "workflow_id": 81,
--   "timestamp": "2025-09-25T19:06:23.574Z",
--   "usuario_id": 6,
--   "logged_user": {
--     "id": 6,
--     "name": "Usuário Elleve Padrão",
--     "email": "rmacedo2005@hotmail.com"
--   },
--   "webhookUrl": "https://n8n.code-iq.com.br/webhook/start12-ze",
--   "executionMode": "production"
-- }

-- Mas o n8n espera:
-- {
--   "usuario_id": 6,
--   "action": "start",
--   "logged_user": {
--     "id": 6,
--     "name": "Usuário Elleve Padrão",
--     "email": "rmacedo2005@hotmail.com"
--   },
--   "agente_id": 5,
--   "perfil_id": 2,
--   "perfis_permitidos": [2, 3],
--   "usuarios_permitidos": [6]
-- }

-- Verificar se existe agente para o usuário 6
SELECT 
    u.id as usuario_id,
    u.nome as usuario_nome,
    a.id as agente_id,
    a.nome as agente_nome
FROM usuarios u
LEFT JOIN agentes a ON a.usuario_id = u.id
WHERE u.id = 6;

-- Verificar perfis do usuário 6
SELECT 
    u.id as usuario_id,
    u.nome as usuario_nome,
    p.id as perfil_id,
    p.descricao as perfil_nome
FROM usuarios u
LEFT JOIN usuario_perfis up ON up.usuario_id = u.id
LEFT JOIN perfis p ON p.id = up.perfil_id
WHERE u.id = 6;
