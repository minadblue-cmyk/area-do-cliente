-- =====================================================
-- PARTE 3: PERMISSÕES DE UPLOAD
-- =====================================================

-- Adicionar permissões de upload
INSERT INTO permissoes (nome_permissao, descricao) VALUES
('upload_view', 'Visualizar página de upload'),
('upload_create', 'Fazer upload de arquivos'),
('upload_manage', 'Gerenciar arquivos enviados'),
('upload_delete', 'Deletar arquivos enviados'),
('upload_process', 'Processar arquivos enviados'),
('upload_validate', 'Validar formato dos arquivos'),
('upload_export', 'Exportar dados processados'),
('upload_config', 'Configurar parâmetros de upload'),
('upload_logs', 'Visualizar logs de upload'),
('upload_admin', 'Administrar uploads de outros usuários');

-- Verificar resultado
SELECT 'Permissões de upload adicionadas:' as info;
SELECT id, nome_permissao, descricao FROM permissoes WHERE nome_permissao LIKE 'upload_%' ORDER BY id;

SELECT 'Total de permissões após parte 3:' as info;
SELECT COUNT(*) as total_permissoes FROM permissoes;
