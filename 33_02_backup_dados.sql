-- Script 2: Backup dos dados existentes
-- Execute este script para criar backup antes das alterações

CREATE TABLE empresas_backup AS SELECT * FROM empresas;

-- Verificar se o backup foi criado
SELECT COUNT(*) as total_registros_backup FROM empresas_backup;
