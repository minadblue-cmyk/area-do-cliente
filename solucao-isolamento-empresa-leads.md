# Solução para Isolamento de Leads por Empresa

## 🎯 Objetivo
Implementar isolamento completo de leads por empresa, garantindo que:
- Usuários de empresas diferentes não vejam leads uns dos outros
- Usuários da mesma empresa compartilhem acesso aos leads
- Sistema seja escalável e seguro

## 📊 Estrutura Atual Identificada
- `leads` - Tabela principal de leads
- `empresas` - Tabela de empresas
- `usuarios` - Tabela de usuários
- `perfil` - Tabela de perfis
- `permissoes` - Tabela de permissões
- `usuario_permissoes` - Relacionamento usuário-permissão
- `usuario_perfis` - Relacionamento usuário-perfil
- `perfil_permissoes` - Relacionamento perfil-permissão

## 🛠️ Solução Proposta

### 1. Adicionar Campo empresa_id na Tabela leads
```sql
-- Adicionar coluna empresa_id na tabela leads
ALTER TABLE lead ADD COLUMN empresa_id INTEGER;

-- Criar índice para performance
CREATE INDEX idx_lead_empresa_id ON lead(empresa_id);

-- Adicionar chave estrangeira
ALTER TABLE lead ADD CONSTRAINT fk_lead_empresa 
FOREIGN KEY (empresa_id) REFERENCES empresas(id);

-- Adicionar comentário
COMMENT ON COLUMN lead.empresa_id IS 'ID da empresa proprietária do lead';
```

### 2. Verificar/Adicionar Campo empresa_id na Tabela usuarios
```sql
-- Verificar se já existe
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'usuarios' AND column_name = 'empresa_id';

-- Se não existir, adicionar
ALTER TABLE usuarios ADD COLUMN empresa_id INTEGER;

-- Criar índice
CREATE INDEX idx_usuarios_empresa_id ON usuarios(empresa_id);

-- Adicionar chave estrangeira
ALTER TABLE usuarios ADD CONSTRAINT fk_usuarios_empresa 
FOREIGN KEY (empresa_id) REFERENCES empresas(id);

-- Adicionar comentário
COMMENT ON COLUMN usuarios.empresa_id IS 'ID da empresa do usuário';
```

### 3. Atualizar Fluxo de Upload
Modificar o n8n para incluir empresa_id no upload:

```javascript
// No webhook de upload, adicionar empresa_id do usuário logado
const payload = {
  // ... outros campos existentes
  empresa_id: userData.empresa_id, // ID da empresa do usuário
  usuario_id: userData.id
};
```

### 4. Atualizar Queries de Prospecção
Modificar todas as queries para filtrar por empresa:

```sql
-- Exemplo: Buscar leads não contatados (filtrado por empresa)
SELECT l.*, u.nome as usuario_nome, e.nome as empresa_nome
FROM lead l
JOIN usuarios u ON l.usuario_id = u.id
JOIN empresas e ON l.empresa_id = e.id
WHERE l.status = 'nao_contatado'
  AND l.empresa_id = $1  -- ID da empresa do usuário logado
  AND l.agente_id IS NULL
ORDER BY l.created_at ASC;
```

### 5. Implementar Middleware de Segurança
Criar função para validar acesso por empresa:

```sql
-- Função para validar se usuário pode acessar lead
CREATE OR REPLACE FUNCTION verificar_acesso_lead(
  p_lead_id INTEGER,
  p_usuario_id INTEGER
) RETURNS BOOLEAN AS $$
DECLARE
  lead_empresa_id INTEGER;
  usuario_empresa_id INTEGER;
BEGIN
  -- Buscar empresa do lead
  SELECT empresa_id INTO lead_empresa_id
  FROM lead WHERE id = p_lead_id;
  
  -- Buscar empresa do usuário
  SELECT empresa_id INTO usuario_empresa_id
  FROM usuarios WHERE id = p_usuario_id;
  
  -- Verificar se são da mesma empresa
  RETURN (lead_empresa_id = usuario_empresa_id);
END;
$$ LANGUAGE plpgsql;
```

## 🔒 Implementação de Segurança

### 1. Row Level Security (RLS)
```sql
-- Habilitar RLS na tabela leads
ALTER TABLE lead ENABLE ROW LEVEL SECURITY;

-- Política: usuários só veem leads da própria empresa
CREATE POLICY leads_empresa_policy ON lead
  FOR ALL TO public
  USING (
    empresa_id = (
      SELECT empresa_id 
      FROM usuarios 
      WHERE id = current_setting('app.current_user_id')::INTEGER
    )
  );
```

### 2. Validação no Frontend
```typescript
// No frontend, sempre incluir empresa_id nas requisições
const loadProspects = async (agente: any) => {
  const payload = {
    usuario_id: userData.id,
    empresa_id: userData.empresa_id, // Sempre incluir
    agente_id: agente.id
  };
  
  // ... resto da lógica
};
```

## 📋 Scripts de Migração

### Script 1: Estrutura Básica
```sql
-- 1. Adicionar empresa_id nas tabelas
ALTER TABLE lead ADD COLUMN empresa_id INTEGER;
ALTER TABLE usuarios ADD COLUMN empresa_id INTEGER;

-- 2. Criar índices
CREATE INDEX idx_lead_empresa_id ON lead(empresa_id);
CREATE INDEX idx_usuarios_empresa_id ON usuarios(empresa_id);

-- 3. Adicionar chaves estrangeiras
ALTER TABLE lead ADD CONSTRAINT fk_lead_empresa 
FOREIGN KEY (empresa_id) REFERENCES empresas(id);

ALTER TABLE usuarios ADD CONSTRAINT fk_usuarios_empresa 
FOREIGN KEY (empresa_id) REFERENCES empresas(id);
```

### Script 2: Migração de Dados Existentes
```sql
-- Atribuir empresa padrão para leads existentes
-- (assumindo que empresa_id = 1 é a empresa padrão)
UPDATE lead SET empresa_id = 1 WHERE empresa_id IS NULL;

-- Atribuir empresa padrão para usuários existentes
UPDATE usuarios SET empresa_id = 1 WHERE empresa_id IS NULL;

-- Tornar campos obrigatórios
ALTER TABLE lead ALTER COLUMN empresa_id SET NOT NULL;
ALTER TABLE usuarios ALTER COLUMN empresa_id SET NOT NULL;
```

### Script 3: Implementar RLS
```sql
-- Habilitar RLS
ALTER TABLE lead ENABLE ROW LEVEL SECURITY;

-- Criar política de segurança
CREATE POLICY leads_empresa_policy ON lead
  FOR ALL TO public
  USING (
    empresa_id = (
      SELECT empresa_id 
      FROM usuarios 
      WHERE id = current_setting('app.current_user_id')::INTEGER
    )
  );
```

## 🧪 Testes de Validação

### Teste 1: Isolamento Entre Empresas
```sql
-- Usuário da empresa 1 não deve ver leads da empresa 2
SELECT COUNT(*) FROM lead l
JOIN usuarios u ON l.usuario_id = u.id
WHERE u.empresa_id = 1 
  AND l.empresa_id = 2;
-- Resultado esperado: 0
```

### Teste 2: Compartilhamento Dentro da Empresa
```sql
-- Usuários da mesma empresa devem ver os mesmos leads
SELECT COUNT(DISTINCT l.id) FROM lead l
JOIN usuarios u ON l.usuario_id = u.id
WHERE u.empresa_id = 1 
  AND l.empresa_id = 1;
-- Resultado esperado: > 0 (todos os leads da empresa 1)
```

## 🚀 Próximos Passos

1. **Executar Script 1** - Adicionar estrutura básica
2. **Executar Script 2** - Migrar dados existentes
3. **Atualizar n8n** - Incluir empresa_id no upload
4. **Atualizar queries** - Filtrar por empresa
5. **Executar Script 3** - Implementar RLS
6. **Testar isolamento** - Validar funcionamento
7. **Atualizar frontend** - Incluir empresa_id nas requisições

## ⚠️ Considerações Importantes

- **Backup obrigatório** antes de executar migrações
- **Teste em ambiente de desenvolvimento** primeiro
- **Comunicação com usuários** sobre mudanças
- **Monitoramento** de performance após implementação
- **Documentação** das mudanças para a equipe
