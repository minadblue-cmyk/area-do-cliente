-- =====================================================
-- CRIAR TABELA AGENDAMENTOS_RECONTATO (VERSÃO CORRIGIDA)
-- =====================================================

-- 1. Primeiro, garantir que a tabela lead tem chave primária
-- (Execute o script corrigir-tabela-lead-chave-primaria.sql primeiro)

-- 2. Criar tabela agendamentos_recontato
CREATE TABLE agendamentos_recontato (
  id SERIAL PRIMARY KEY,
  lead_id INTEGER NOT NULL,
  proximo_contato_em TIMESTAMP NOT NULL,
  observacoes TEXT,
  prioridade INTEGER DEFAULT 1 CHECK (prioridade IN (1, 2, 3)),
  status VARCHAR(20) DEFAULT 'agendado' CHECK (status IN ('agendado', 'executado', 'cancelado')),
  usuario_id INTEGER,
  data_agendamento TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW(),
  
  -- Chave estrangeira para a tabela lead
  CONSTRAINT fk_agendamentos_lead 
    FOREIGN KEY (lead_id) 
    REFERENCES public.lead(id) 
    ON DELETE CASCADE
);

-- 3. Criar índices para melhor performance
CREATE INDEX idx_agendamentos_lead_id ON agendamentos_recontato(lead_id);
CREATE INDEX idx_agendamentos_proximo_contato ON agendamentos_recontato(proximo_contato_em);
CREATE INDEX idx_agendamentos_status ON agendamentos_recontato(status);
CREATE INDEX idx_agendamentos_prioridade ON agendamentos_recontato(prioridade);

-- 4. Comentários para documentação
COMMENT ON TABLE agendamentos_recontato IS 'Tabela para agendamento manual de recontatos de leads';
COMMENT ON COLUMN agendamentos_recontato.lead_id IS 'ID do lead que será recontatado';
COMMENT ON COLUMN agendamentos_recontato.proximo_contato_em IS 'Data e hora agendada para o próximo contato';
COMMENT ON COLUMN agendamentos_recontato.observacoes IS 'Observações sobre o agendamento';
COMMENT ON COLUMN agendamentos_recontato.prioridade IS 'Prioridade do recontato: 1=baixa, 2=média, 3=alta';
COMMENT ON COLUMN agendamentos_recontato.status IS 'Status do agendamento: agendado, executado, cancelado';
COMMENT ON COLUMN agendamentos_recontato.usuario_id IS 'ID do usuário que fez o agendamento';
