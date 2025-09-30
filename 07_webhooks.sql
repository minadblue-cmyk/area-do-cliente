-- =====================================================
-- PARTE 7: PERMISSÕES DE WEBHOOKS
-- =====================================================

-- Adicionar permissões de webhooks
INSERT INTO permissoes (nome_permissao, descricao) VALUES
('webhook_view', 'Visualizar webhooks'),
('webhook_create', 'Criar webhooks'),
('webhook_edit', 'Editar webhooks'),
('webhook_delete', 'Deletar webhooks'),
('webhook_test', 'Testar webhooks'),
('webhook_logs', 'Visualizar logs de webhooks');

-- Verificar resultado
SELECT 'Permissões de webhooks adicionadas:' as info;
SELECT id, nome_permissao, descricao FROM permissoes WHERE nome_permissao LIKE 'webhook_%' ORDER BY id;

SELECT 'Total de permissões após parte 7:' as info;
SELECT COUNT(*) as total_permissoes FROM permissoes;
