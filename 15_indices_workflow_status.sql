-- Script para criar índices otimizados para busca por workflow_id + status
-- Este script deve ser executado no PostgreSQL

-- Índice composto para busca por usuario_id + workflow_id + status
CREATE INDEX IF NOT EXISTS idx_agente_execucoes_usuario_workflow_status 
ON agente_execucoes (usuario_id, workflow_id, status);

-- Índice composto para busca por usuario_id + workflow_id (sem status)
CREATE INDEX IF NOT EXISTS idx_agente_execucoes_usuario_workflow 
ON agente_execucoes (usuario_id, workflow_id);

-- Índice para busca por workflow_id apenas
CREATE INDEX IF NOT EXISTS idx_agente_execucoes_workflow_id 
ON agente_execucoes (workflow_id);

-- Índice para ordenação por iniciado_em
CREATE INDEX IF NOT EXISTS idx_agente_execucoes_iniciado_em_desc 
ON agente_execucoes (iniciado_em DESC);

-- Verificar índices existentes
SELECT 
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename = 'agente_execucoes'
ORDER BY indexname;

-- Estatísticas de uso dos índices (executar após algumas consultas)
-- SELECT 
--     schemaname,
--     tablename,
--     indexname,
--     idx_tup_read,
--     idx_tup_fetch
-- FROM pg_stat_user_indexes 
-- WHERE tablename = 'agente_execucoes'
-- ORDER BY idx_tup_read DESC;
