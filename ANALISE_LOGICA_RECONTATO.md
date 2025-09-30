# 🔄 Análise de Lógica para Recontato de Leads

## 🎯 **Cenário Atual:**
- Sistema reserva 20 leads para primeiro contato
- Leads são marcados como `contatado = true` e `status = 'prospectando'` ou `'concluído'`
- **Problema:** Como recontatar esses leads para campanhas futuras?

## 🔍 **Opções de Implementação:**

### **✅ Opção 1: Sistema de Campanhas (Recomendada)**

#### **Estrutura de Dados:**
```sql
-- Nova tabela para campanhas
CREATE TABLE campanhas (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  descricao TEXT,
  tipo VARCHAR(20) NOT NULL, -- 'primeiro_contato', 'follow_up', 'recontato'
  ativa BOOLEAN DEFAULT true,
  data_criacao TIMESTAMP DEFAULT NOW(),
  data_inicio TIMESTAMP,
  data_fim TIMESTAMP,
  usuario_id INTEGER,
  empresa_id INTEGER
);

-- Nova tabela para histórico de contatos
CREATE TABLE historico_contatos (
  id SERIAL PRIMARY KEY,
  lead_id INTEGER REFERENCES lead(id),
  campanha_id INTEGER REFERENCES campanhas(id),
  agente_id INTEGER,
  data_contato TIMESTAMP DEFAULT NOW(),
  status VARCHAR(20), -- 'enviado', 'entregue', 'lido', 'respondido'
  canal VARCHAR(20), -- 'whatsapp', 'sms', 'email'
  mensagem TEXT,
  resposta TEXT,
  observacoes TEXT
);
```

#### **Lógica de Recontato:**
1. **Criar nova campanha** de follow-up
2. **Filtrar leads** que já foram contatados anteriormente
3. **Aplicar regras de tempo** (ex: só recontatar após 7 dias)
4. **Reservar lote** para nova campanha
5. **Registrar histórico** de cada contato

### **✅ Opção 2: Campos de Controle na Tabela Lead**

#### **Adicionar campos na tabela `lead`:**
```sql
ALTER TABLE lead ADD COLUMN ultima_campanha_id INTEGER;
ALTER TABLE lead ADD COLUMN data_ultimo_contato TIMESTAMP;
ALTER TABLE lead ADD COLUMN total_contatos INTEGER DEFAULT 0;
ALTER TABLE lead ADD COLUMN pode_recontatar BOOLEAN DEFAULT true;
ALTER TABLE lead ADD COLUMN proximo_contato_em TIMESTAMP;
```

#### **Lógica de Recontato:**
1. **Verificar `pode_recontatar = true`**
2. **Verificar `proximo_contato_em <= NOW()`**
3. **Incrementar `total_contatos`**
4. **Atualizar `data_ultimo_contato`**
5. **Calcular próximo contato** (ex: +7 dias)

### **✅ Opção 3: Sistema Híbrido (Mais Completo)**

#### **Combinar ambas as abordagens:**
- **Tabela de campanhas** para controle de campanhas
- **Campos na tabela lead** para controle individual
- **Tabela de histórico** para auditoria completa

## 🎯 **Recomendação: Opção 1 - Sistema de Campanhas**

### **✅ Vantagens:**
1. **Flexibilidade:** Diferentes tipos de campanha
2. **Auditoria:** Histórico completo de contatos
3. **Controle:** Regras específicas por campanha
4. **Escalabilidade:** Fácil adicionar novas funcionalidades
5. **Relatórios:** Dados ricos para análise

### **✅ Estrutura Proposta:**

#### **1. Tabela `campanhas`:**
```sql
CREATE TABLE campanhas (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  descricao TEXT,
  tipo VARCHAR(20) NOT NULL, -- 'primeiro_contato', 'follow_up_7d', 'follow_up_30d'
  ativa BOOLEAN DEFAULT true,
  data_criacao TIMESTAMP DEFAULT NOW(),
  data_inicio TIMESTAMP,
  data_fim TIMESTAMP,
  usuario_id INTEGER,
  empresa_id INTEGER,
  regras JSONB -- Regras específicas da campanha
);
```

#### **2. Tabela `historico_contatos`:**
```sql
CREATE TABLE historico_contatos (
  id SERIAL PRIMARY KEY,
  lead_id INTEGER REFERENCES lead(id),
  campanha_id INTEGER REFERENCES campanhas(id),
  agente_id INTEGER,
  data_contato TIMESTAMP DEFAULT NOW(),
  status VARCHAR(20), -- 'enviado', 'entregue', 'lido', 'respondido', 'não_interessado'
  canal VARCHAR(20), -- 'whatsapp', 'sms', 'email'
  mensagem TEXT,
  resposta TEXT,
  observacoes TEXT,
  proximo_contato_em TIMESTAMP
);
```

#### **3. Query para Buscar Leads para Recontato:**
```sql
-- Buscar leads elegíveis para recontato
SELECT l.*
FROM public.lead l
WHERE l.contatado = true
  AND l.status IN ('prospectando', 'concluído')
  AND l.pode_recontatar = true
  AND (
    l.proximo_contato_em IS NULL 
    OR l.proximo_contato_em <= NOW()
  )
  AND NOT EXISTS (
    SELECT 1 FROM historico_contatos hc
    WHERE hc.lead_id = l.id
      AND hc.campanha_id = $1 -- ID da campanha atual
  )
ORDER BY l.data_ultimo_contato ASC
LIMIT 20;
```

## 🚀 **Implementação Sugerida:**

### **Fase 1: Estrutura Básica**
1. Criar tabelas `campanhas` e `historico_contatos`
2. Adicionar campos de controle na tabela `lead`
3. Atualizar queries existentes

### **Fase 2: Lógica de Recontato**
1. Criar webhook para criar campanhas
2. Modificar query de reserva de leads
3. Implementar regras de tempo

### **Fase 3: Interface e Controle**
1. Frontend para gerenciar campanhas
2. Relatórios de campanhas
3. Controle de permissões por campanha

## 🎯 **Próximos Passos:**

1. **Definir regras de negócio:** Quanto tempo entre contatos?
2. **Escolher abordagem:** Sistema de campanhas ou campos simples?
3. **Implementar estrutura:** Criar tabelas necessárias
4. **Atualizar queries:** Modificar lógica de reserva de leads
5. **Testar funcionalidade:** Validar com dados reais

## 🎉 **Benefícios da Solução:**

### **✅ Para o Negócio:**
- **Aumento de conversão:** Recontato sistemático
- **Melhor relacionamento:** Campanhas personalizadas
- **Controle de timing:** Respeitar preferências do lead
- **Auditoria completa:** Histórico de todas as interações

### **✅ Para o Sistema:**
- **Flexibilidade:** Diferentes tipos de campanha
- **Escalabilidade:** Fácil adicionar novas funcionalidades
- **Performance:** Queries otimizadas
- **Manutenibilidade:** Código organizado e documentado

**Qual abordagem você prefere? Sistema de campanhas completo ou solução mais simples com campos na tabela lead?**
