-- =====================================================
-- VERIFICAR CAMPOS EXISTENTES NA TABELA LEAD
-- =====================================================

-- Verificar quais campos já existem na tabela lead
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'lead' 
  AND table_schema = 'public'
  AND column_name IN (
    'proximo_contato_em',
    'pode_recontatar', 
    'observacoes_recontato',
    'prioridade_recontato',
    'agendado_por_usuario_id',
    'data_agendamento'
  )
ORDER BY column_name;
