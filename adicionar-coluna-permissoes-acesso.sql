-- ✅ ADICIONAR COLUNA DE PERMISSÕES DE ACESSO NA TABELA LEAD
-- Esta coluna armazenará as permissões de acesso por agente em formato JSONB

-- 1. Adicionar coluna permissoes_acesso
ALTER TABLE public.lead 
ADD COLUMN permissoes_acesso JSONB DEFAULT '{}'::jsonb;

-- 2. Adicionar comentário explicativo
COMMENT ON COLUMN public.lead.permissoes_acesso IS 'Permissões de acesso por agente em formato JSONB. Contém usuários e perfis que podem acessar os leads reservados por este agente.';

-- 3. Criar índice GIN para performance em consultas JSONB
CREATE INDEX idx_lead_permissoes_acesso ON public.lead USING GIN (permissoes_acesso);

-- 4. Criar índice composto para consultas otimizadas
CREATE INDEX idx_lead_agente_permissoes ON public.lead (agente_id, permissoes_acesso) 
WHERE agente_id IS NOT NULL;

-- 5. Exemplo de estrutura do JSONB (para referência)
/*
{
  "agente_id": 81,
  "reservado_por": "usuario_6",
  "reservado_em": "2025-09-25T15:30:00Z",
  "perfis_permitidos": [1, 3, 4],
  "usuarios_permitidos": [6, 8, 10],
  "permissoes_especiais": {
    "pode_editar": true,
    "pode_deletar": false,
    "pode_exportar": true
  }
}
*/

-- 6. Verificar se a coluna foi adicionada corretamente
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'lead' 
  AND table_schema = 'public'
  AND column_name = 'permissoes_acesso';
