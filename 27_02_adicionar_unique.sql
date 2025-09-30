-- Script 2: Adicionar constraint UNIQUE no campo nome
-- Execute este script após criar a tabela

ALTER TABLE agentes_config 
ADD CONSTRAINT unique_nome UNIQUE (nome);
