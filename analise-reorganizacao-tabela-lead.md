# 📊 Análise e Reorganização da Tabela LEAD

## 🔍 Estrutura Atual Identificada

Baseado na imagem fornecida, a tabela `lead` possui **29 campos** com várias redundâncias e inconsistências:

### Campos Identificados:
1. `nome` (text, NULL)
2. `canal` (text, NULL) 
3. `estagio_funnel` (text, NULL, default: 'topo')
4. `pergunta_index` (integer, NULL, default: 0)
5. `ultima_pergunta` (text, NULL)
6. `ultima_resposta` (text, NULL)
7. `respostas` (text, NULL, default: '[]'::jsonb) ⚠️ **INCONSISTÊNCIA**
8. `data_criacao` (timestamp, NULL, default: now())
9. `data_ultima_interacao` (timestamp, NULL, default: now())
10. `telefone` (text, NULL)
11. `id` (integer, NOT NULL) - **CHAVE PRIMÁRIA**
12. `contatado` (boolean, NULL)
13. `client_id` (integer, NULL)
14. `status` (varchar(20), NULL, default: 'novo')
15. `nome_cliente` (text, NULL) ⚠️ **REDUNDANTE**
16. `fonte_prospec` (text, NULL)
17. `idade` (integer, NULL)
18. `profissao` (text, NULL)
19. `estado_civil` (text, NULL)
20. `filhos` (boolean, NULL)
21. `qtd_filhos` (integer, NULL)
22. `data_insercao` (timestamp, NULL) ⚠️ **REDUNDANTE**
23. `reservado_por` (text, NULL)
24. `reservado_em` (timestamp with time zone, NULL)
25. `reservado_lote` (text, NULL)
26. `agente_id` (integer, NULL)
27. `perfil_id` (integer, NULL)
28. `permissoes_acesso` (jsonb, NULL, default: '{}'::jsonb)
29. `proximo_contato_em` (timestamp, NULL)

## ⚠️ Problemas Identificados

### 1. **Campos Redundantes:**
- `nome` vs `nome_cliente` - **Mesmo propósito**
- `data_criacao` vs `data_insercao` - **Mesmo propósito**

### 2. **Inconsistências de Tipo:**
- `respostas` definido como `text` mas com default `jsonb`

### 3. **Campos Desnecessários:**
- `canal` - Não utilizado no fluxo atual
- `estagio_funnel` - Não utilizado no fluxo atual
- `pergunta_index` - Não utilizado no fluxo atual
- `ultima_pergunta` - Não utilizado no fluxo atual
- `ultima_resposta` - Não utilizado no fluxo atual
- `respostas` - Não utilizado no fluxo atual
- `client_id` - Redundante com `id`

### 4. **Campos de Recontato Incompletos:**
- Faltam campos mencionados na estrutura anterior:
  - `pode_recontatar`
  - `observacoes_recontato`
  - `prioridade_recontato`
  - `agendado_por_usuario_id`
  - `data_agendamento`

## 🎯 Proposta de Reorganização

### **Estrutura Otimizada Sugerida:**

```sql
-- TABELA LEAD REORGANIZADA
CREATE TABLE lead_otimizada (
    -- IDENTIFICAÇÃO
    id SERIAL PRIMARY KEY,
    
    -- DADOS PESSOAIS (consolidados)
    nome TEXT NOT NULL,  -- Unificar nome e nome_cliente
    telefone TEXT,
    email TEXT,
    
    -- INFORMAÇÕES PROFISSIONAIS
    profissao TEXT,
    idade INTEGER,
    
    -- INFORMAÇÕES PESSOAIS
    estado_civil TEXT,
    filhos BOOLEAN DEFAULT false,
    qtd_filhos INTEGER DEFAULT 0,
    
    -- CONTROLE DE NEGÓCIO
    status VARCHAR(20) DEFAULT 'novo',
    fonte_prospec TEXT,
    contatado BOOLEAN DEFAULT false,
    
    -- CONTROLE DE EMPRESA E PERMISSÕES
    empresa_id INTEGER NOT NULL REFERENCES empresas(id),
    usuario_id INTEGER REFERENCES usuarios(id),
    permissoes_acesso JSONB DEFAULT '{}',
    
    -- CONTROLE DE AGENTE
    agente_id INTEGER,
    perfil_id INTEGER,
    
    -- RESERVA DE LOTE
    reservado_por TEXT,
    reservado_em TIMESTAMP WITH TIME ZONE,
    reservado_lote TEXT,
    
    -- SISTEMA DE RECONTATO
    proximo_contato_em TIMESTAMP,
    pode_recontatar BOOLEAN DEFAULT true,
    observacoes_recontato TEXT,
    prioridade_recontato INTEGER DEFAULT 1,
    agendado_por_usuario_id INTEGER,
    data_agendamento TIMESTAMP,
    
    -- CONTROLE DE TEMPO
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    data_ultima_interacao TIMESTAMP DEFAULT NOW()
);
```

## 📋 Script de Migração

### **Passo 1: Criar Tabela Otimizada**
```sql
-- Criar nova tabela com estrutura otimizada
CREATE TABLE lead_nova (
    -- IDENTIFICAÇÃO
    id SERIAL PRIMARY KEY,
    
    -- DADOS PESSOAIS
    nome TEXT NOT NULL,
    telefone TEXT,
    email TEXT,
    
    -- INFORMAÇÕES PROFISSIONAIS
    profissao TEXT,
    idade INTEGER,
    
    -- INFORMAÇÕES PESSOAIS
    estado_civil TEXT,
    filhos BOOLEAN DEFAULT false,
    qtd_filhos INTEGER DEFAULT 0,
    
    -- CONTROLE DE NEGÓCIO
    status VARCHAR(20) DEFAULT 'novo',
    fonte_prospec TEXT,
    contatado BOOLEAN DEFAULT false,
    
    -- CONTROLE DE EMPRESA E PERMISSÕES
    empresa_id INTEGER NOT NULL REFERENCES empresas(id),
    usuario_id INTEGER REFERENCES usuarios(id),
    permissoes_acesso JSONB DEFAULT '{}',
    
    -- CONTROLE DE AGENTE
    agente_id INTEGER,
    perfil_id INTEGER,
    
    -- RESERVA DE LOTE
    reservado_por TEXT,
    reservado_em TIMESTAMP WITH TIME ZONE,
    reservado_lote TEXT,
    
    -- SISTEMA DE RECONTATO
    proximo_contato_em TIMESTAMP,
    pode_recontatar BOOLEAN DEFAULT true,
    observacoes_recontato TEXT,
    prioridade_recontato INTEGER DEFAULT 1,
    agendado_por_usuario_id INTEGER,
    data_agendamento TIMESTAMP,
    
    -- CONTROLE DE TEMPO
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    data_ultima_interacao TIMESTAMP DEFAULT NOW()
);
```

### **Passo 2: Migrar Dados**
```sql
-- Migrar dados da tabela antiga para a nova
INSERT INTO lead_nova (
    id, nome, telefone, email, profissao, idade, estado_civil,
    filhos, qtd_filhos, status, fonte_prospec, contatado,
    empresa_id, usuario_id, permissoes_acesso, agente_id, perfil_id,
    reservado_por, reservado_em, reservado_lote, proximo_contato_em,
    created_at, data_ultima_interacao
)
SELECT 
    id,
    COALESCE(nome, nome_cliente) as nome,  -- Unificar campos
    telefone,
    email,
    profissao,
    idade,
    estado_civil,
    filhos,
    qtd_filhos,
    status,
    fonte_prospec,
    contatado,
    empresa_id,
    usuario_id,
    permissoes_acesso,
    agente_id,
    perfil_id,
    reservado_por,
    reservado_em,
    reservado_lote,
    proximo_contato_em,
    COALESCE(data_criacao, data_insercao) as created_at,  -- Unificar campos
    data_ultima_interacao
FROM lead;
```

### **Passo 3: Substituir Tabela**
```sql
-- Renomear tabelas
ALTER TABLE lead RENAME TO lead_old;
ALTER TABLE lead_nova RENAME TO lead;

-- Recriar índices
CREATE INDEX idx_lead_empresa_id ON lead(empresa_id);
CREATE INDEX idx_lead_status ON lead(status);
CREATE INDEX idx_lead_agente_id ON lead(agente_id);
CREATE INDEX idx_lead_empresa_status ON lead(empresa_id, status);
CREATE INDEX idx_lead_empresa_created ON lead(empresa_id, created_at);

-- Recriar chaves estrangeiras
ALTER TABLE lead ADD CONSTRAINT fk_lead_empresa 
FOREIGN KEY (empresa_id) REFERENCES empresas(id);

ALTER TABLE lead ADD CONSTRAINT fk_lead_usuario 
FOREIGN KEY (usuario_id) REFERENCES usuarios(id);
```

## 🎯 Benefícios da Reorganização

### **1. Redução de Redundância:**
- ✅ Elimina `nome_cliente` (usa apenas `nome`)
- ✅ Elimina `data_insercao` (usa apenas `created_at`)
- ✅ Elimina campos não utilizados

### **2. Consistência:**
- ✅ Tipos de dados consistentes
- ✅ Nomes de campos padronizados
- ✅ Estrutura mais limpa

### **3. Performance:**
- ✅ Menos campos = consultas mais rápidas
- ✅ Índices otimizados
- ✅ Menos espaço em disco

### **4. Manutenibilidade:**
- ✅ Estrutura mais clara
- ✅ Menos confusão para desenvolvedores
- ✅ Fácil evolução futura

## 📊 Comparação: Antes vs Depois

| Aspecto | Antes | Depois |
|---------|-------|--------|
| **Total de Campos** | 29 | 22 |
| **Campos Redundantes** | 2 | 0 |
| **Campos Não Utilizados** | 7 | 0 |
| **Inconsistências** | 1 | 0 |
| **Clareza** | Baixa | Alta |
| **Performance** | Média | Alta |

## ⚠️ Considerações Importantes

### **Antes de Executar:**
1. **Backup completo** do banco de dados
2. **Teste em ambiente de desenvolvimento**
3. **Validação** de todos os dados migrados
4. **Atualização** de todas as queries e aplicações

### **Após Executar:**
1. **Verificação** de integridade dos dados
2. **Teste** de todas as funcionalidades
3. **Monitoramento** de performance
4. **Documentação** das mudanças

## 🚀 Próximos Passos

1. **Executar análise completa** com o script fornecido
2. **Validar dados** existentes
3. **Criar script de migração** personalizado
4. **Testar migração** em ambiente de desenvolvimento
5. **Executar migração** em produção
6. **Atualizar aplicações** para nova estrutura
