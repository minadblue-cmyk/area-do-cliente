# 🎯 Sistema de Controle Manual de Recontato

## 🎯 **Objetivo:**
Permitir que você escolha manualmente quando recontatar cada lead, sem datas fixas automáticas.

## 🔧 **Estrutura de Dados Proposta:**

### **✅ 1. Adicionar Campos na Tabela `lead`:**

```sql
-- Campos para controle manual de recontato
ALTER TABLE lead ADD COLUMN proximo_contato_em TIMESTAMP NULL;
ALTER TABLE lead ADD COLUMN pode_recontatar BOOLEAN DEFAULT true;
ALTER TABLE lead ADD COLUMN observacoes_recontato TEXT;
ALTER TABLE lead ADD COLUMN prioridade_recontato INTEGER DEFAULT 1; -- 1=baixa, 2=média, 3=alta
ALTER TABLE lead ADD COLUMN agendado_por_usuario_id INTEGER;
ALTER TABLE lead ADD COLUMN data_agendamento TIMESTAMP;
```

### **✅ 2. Tabela para Histórico de Agendamentos:**

```sql
CREATE TABLE agendamentos_recontato (
  id SERIAL PRIMARY KEY,
  lead_id INTEGER REFERENCES lead(id),
  usuario_id INTEGER,
  data_agendamento TIMESTAMP DEFAULT NOW(),
  proximo_contato_em TIMESTAMP NOT NULL,
  observacoes TEXT,
  prioridade INTEGER DEFAULT 1,
  status VARCHAR(20) DEFAULT 'agendado', -- 'agendado', 'executado', 'cancelado'
  created_at TIMESTAMP DEFAULT NOW()
);
```

## 🎯 **Fluxo de Funcionamento:**

### **✅ 1. Após Primeiro Contato:**
- Lead fica com `status = 'prospectando'` ou `'concluído'`
- Campo `proximo_contato_em` fica `NULL` (não agendado)
- Campo `pode_recontatar = true`

### **✅ 2. Agendamento Manual:**
- Você escolhe quais leads recontatar
- Define data/hora específica para cada lead
- Adiciona observações personalizadas
- Define prioridade (baixa/média/alta)

### **✅ 3. Busca de Leads para Recontato:**
- Sistema busca leads com `proximo_contato_em <= NOW()`
- Respeita permissões e filtros existentes
- Ordena por prioridade e data

## 🔧 **Implementação Técnica:**

### **✅ 1. Query para Buscar Leads Agendados:**

```sql
-- Buscar leads agendados para recontato
SELECT
  l.id, l.client_id, l.nome_cliente, l.telefone, l.canal,
  l.status, l.data_ultima_interacao, l.reservado_por, l.reservado_lote,
  l.agente_id, l.contatado, l.proximo_contato_em, l.observacoes_recontato,
  l.prioridade_recontato, l.agendado_por_usuario_id
FROM public.lead l
WHERE l.contatado = true
  AND l.pode_recontatar = true
  AND l.proximo_contato_em IS NOT NULL
  AND l.proximo_contato_em <= NOW()
  AND (
    l.permissoes_acesso->'usuarios_permitidos' @> $1::jsonb
    OR
    l.permissoes_acesso->'perfis_permitidos' @> $2::jsonb
    OR
    l.agente_id = $3
  )
ORDER BY 
  l.prioridade_recontato DESC,  -- Prioridade alta primeiro
  l.proximo_contato_em ASC,     -- Mais antigo primeiro
  l.id ASC
LIMIT 20;
```

### **✅ 2. Webhook para Agendar Recontato:**

```typescript
// POST /webhook/agendar-recontato
{
  "lead_id": 18017,
  "proximo_contato_em": "2025-01-27T14:30:00.000Z",
  "observacoes": "Cliente pediu para ligar na segunda-feira",
  "prioridade": 2,
  "usuario_id": 6
}
```

### **✅ 3. Webhook para Listar Leads Agendáveis:**

```typescript
// GET /webhook/leads-para-agendamento
// Retorna leads que podem ser agendados para recontato
{
  "leads": [
    {
      "id": 18017,
      "nome_cliente": "Roger Macedo da Silva",
      "telefone": "5551984033242",
      "status": "prospectando",
      "data_ultimo_contato": "2025-01-25T18:17:55.805Z",
      "pode_recontatar": true,
      "proximo_contato_em": null
    }
  ]
}
```

## 🎨 **Interface do Frontend:**

### **✅ 1. Lista de Leads com Ações:**

```tsx
// Componente para agendar recontato
function AgendarRecontato({ lead, onAgendar }) {
  const [dataAgendamento, setDataAgendamento] = useState('')
  const [observacoes, setObservacoes] = useState('')
  const [prioridade, setPrioridade] = useState(1)

  const handleAgendar = () => {
    onAgendar({
      lead_id: lead.id,
      proximo_contato_em: dataAgendamento,
      observacoes,
      prioridade
    })
  }

  return (
    <div className="p-4 border rounded-lg">
      <h3>Agendar Recontato - {lead.nome_cliente}</h3>
      
      <div className="mb-4">
        <label>Data/Hora do Próximo Contato:</label>
        <input
          type="datetime-local"
          value={dataAgendamento}
          onChange={(e) => setDataAgendamento(e.target.value)}
          className="w-full p-2 border rounded"
        />
      </div>

      <div className="mb-4">
        <label>Prioridade:</label>
        <select
          value={prioridade}
          onChange={(e) => setPrioridade(Number(e.target.value))}
          className="w-full p-2 border rounded"
        >
          <option value={1}>Baixa</option>
          <option value={2}>Média</option>
          <option value={3}>Alta</option>
        </select>
      </div>

      <div className="mb-4">
        <label>Observações:</label>
        <textarea
          value={observacoes}
          onChange={(e) => setObservacoes(e.target.value)}
          className="w-full p-2 border rounded"
          rows={3}
        />
      </div>

      <button
        onClick={handleAgendar}
        className="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600"
      >
        Agendar Recontato
      </button>
    </div>
  )
}
```

### **✅ 2. Lista de Leads Agendados:**

```tsx
// Componente para mostrar leads agendados
function LeadsAgendados({ leads }) {
  return (
    <div className="space-y-4">
      <h2 className="text-xl font-bold">Leads Agendados para Recontato</h2>
      
      {leads.map(lead => (
        <div key={lead.id} className="p-4 border rounded-lg">
          <div className="flex justify-between items-start">
            <div>
              <h3 className="font-semibold">{lead.nome_cliente}</h3>
              <p className="text-gray-600">{lead.telefone}</p>
              <p className="text-sm text-gray-500">
                Próximo contato: {new Date(lead.proximo_contato_em).toLocaleString()}
              </p>
              {lead.observacoes_recontato && (
                <p className="text-sm text-blue-600">
                  Obs: {lead.observacoes_recontato}
                </p>
              )}
            </div>
            
            <div className="flex space-x-2">
              <span className={`px-2 py-1 rounded text-xs ${
                lead.prioridade_recontato === 3 ? 'bg-red-100 text-red-800' :
                lead.prioridade_recontato === 2 ? 'bg-yellow-100 text-yellow-800' :
                'bg-green-100 text-green-800'
              }`}>
                {lead.prioridade_recontato === 3 ? 'Alta' :
                 lead.prioridade_recontato === 2 ? 'Média' : 'Baixa'}
              </span>
              
              <button className="text-blue-500 hover:text-blue-700">
                Editar
              </button>
            </div>
          </div>
        </div>
      ))}
    </div>
  )
}
```

## 🚀 **Fluxo Completo:**

### **✅ 1. Primeiro Contato:**
1. Lead é contatado normalmente
2. Status vira "prospectando" ou "concluído"
3. Campo `contatado = true`

### **✅ 2. Agendamento de Recontato:**
1. Você acessa lista de leads contatados
2. Escolhe quais leads recontatar
3. Define data/hora específica para cada um
4. Adiciona observações e prioridade
5. Sistema salva agendamento

### **✅ 3. Execução do Recontato:**
1. Sistema busca leads com `proximo_contato_em <= NOW()`
2. Reserva lote de 20 leads agendados
3. Executa campanha de recontato
4. Atualiza histórico e agenda próximo contato se necessário

## 🎯 **Benefícios:**

### **✅ Controle Total:**
- Você decide quando recontatar cada lead
- Flexibilidade para diferentes estratégias
- Observações personalizadas por lead

### **✅ Organização:**
- Priorização de leads importantes
- Histórico completo de agendamentos
- Interface intuitiva para gerenciar

### **✅ Eficiência:**
- Sistema automático para execução
- Respeita permissões existentes
- Integração com workflow atual

**Esta abordagem te dá controle total sobre quando recontatar cada lead. O que acha? Quer que eu implemente alguma parte específica primeiro?**
