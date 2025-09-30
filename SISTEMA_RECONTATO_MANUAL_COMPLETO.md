# Sistema de Controle Manual de Recontato - Implementação Completa

## 🎯 Objetivo
Implementar um sistema completo para controle manual de recontatos de leads, permitindo que agentes agendem follow-ups personalizados.

## 📋 Estrutura da Solução

### 1. **Correção da Tabela Lead**
```sql
-- Primeiro, corrigir a chave primária da tabela lead
ALTER TABLE public.lead ADD CONSTRAINT pk_lead PRIMARY KEY (id);
```

### 2. **Novos Campos na Tabela Lead**
```sql
ALTER TABLE public.lead 
ADD COLUMN proximo_contato_em TIMESTAMP NULL,
ADD COLUMN pode_recontatar BOOLEAN DEFAULT true,
ADD COLUMN observacoes_recontato TEXT,
ADD COLUMN prioridade_recontato INTEGER DEFAULT 1 CHECK (prioridade_recontato IN (1, 2, 3)),
ADD COLUMN agendado_por_usuario_id INTEGER,
ADD COLUMN data_agendamento TIMESTAMP;
```

### 3. **Tabela de Agendamentos Detalhados**
```sql
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
  
  CONSTRAINT fk_agendamentos_lead 
    FOREIGN KEY (lead_id) 
    REFERENCES public.lead(id) 
    ON DELETE CASCADE
);
```

## 🔄 Fluxos de Trabalho

### **Fluxo 1: Agendamento de Recontato**
1. **Agente visualiza lead** na lista de prospecção
2. **Clica em "Agendar Recontato"** 
3. **Preenche formulário:**
   - Data/hora do próximo contato
   - Prioridade (1=baixa, 2=média, 3=alta)
   - Observações
4. **Sistema atualiza:**
   - `lead.proximo_contato_em`
   - `lead.prioridade_recontato`
   - `lead.observacoes_recontato`
   - `lead.agendado_por_usuario_id`
   - Cria registro em `agendamentos_recontato`

### **Fluxo 2: Execução de Recontato**
1. **Sistema busca leads agendados** (query específica)
2. **Filtra por:**
   - `proximo_contato_em <= NOW()`
   - `pode_recontatar = true`
   - Permissões do usuário
3. **Executa campanha** com leads agendados
4. **Atualiza status** após contato

## 📊 Queries Principais

### **Buscar Leads Agendados para Recontato**
```sql
SELECT l.*, l.proximo_contato_em, l.observacoes_recontato, l.prioridade_recontato
FROM public.lead l
WHERE l.contatado = true
  AND l.pode_recontatar = true
  AND l.proximo_contato_em IS NOT NULL
  AND l.proximo_contato_em <= NOW()
  AND (permissões do usuário)
ORDER BY l.prioridade_recontato DESC, l.proximo_contato_em ASC;
```

### **Atualizar Lead Após Recontato**
```sql
UPDATE public.lead 
SET status = 'prospectando',
    data_ultima_interacao = NOW(),
    proximo_contato_em = NULL,
    observacoes_recontato = $observacoes
WHERE id = $lead_id;
```

## 🎨 Interface do Usuário

### **Botão "Agendar Recontato"**
- Aparece em cada lead da lista de prospecção
- Abre modal com formulário de agendamento

### **Formulário de Agendamento**
```html
<div class="modal-agendamento">
  <h3>Agendar Recontato</h3>
  
  <label>Data e Hora:</label>
  <input type="datetime-local" name="proximo_contato_em" required>
  
  <label>Prioridade:</label>
  <select name="prioridade">
    <option value="1">Baixa</option>
    <option value="2">Média</option>
    <option value="3">Alta</option>
  </select>
  
  <label>Observações:</label>
  <textarea name="observacoes" rows="3"></textarea>
  
  <button type="submit">Agendar</button>
</div>
```

## 🔧 Implementação no n8n

### **Node: "Buscar Leads Agendados"**
- Substitui "Buscar o lote reservado" quando executando recontatos
- Usa query específica para leads agendados
- Filtra por data e permissões

### **Node: "Atualizar Lead Após Recontato"**
- Limpa campos de agendamento após contato
- Atualiza observações
- Mantém histórico na tabela `agendamentos_recontato`

## 📈 Benefícios

1. **Controle Total**: Agentes decidem quando recontatar
2. **Priorização**: Sistema de prioridades para leads importantes
3. **Histórico**: Rastreamento completo de agendamentos
4. **Flexibilidade**: Diferentes estratégias por lead
5. **Eficiência**: Leads agendados aparecem automaticamente

## 🚀 Próximos Passos

1. **Executar scripts SQL** para criar estrutura
2. **Atualizar frontend** com botão de agendamento
3. **Modificar n8n** para suportar recontatos
4. **Testar fluxo completo** de agendamento e execução
5. **Treinar agentes** no novo sistema

## 📝 Observações

- **Compatibilidade**: Sistema funciona com estrutura atual
- **Escalabilidade**: Suporta milhares de agendamentos
- **Auditoria**: Histórico completo de todas as ações
- **Performance**: Índices otimizados para consultas rápidas
