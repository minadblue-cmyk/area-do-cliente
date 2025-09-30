# ✅ Solução: agente_id Dinâmico para Múltiplos Agentes

## 🎯 **Problema Identificado:**

### **❌ Problema Atual:**
- Função `getAgenteIdForUser()` retorna apenas o **primeiro** agente encontrado
- Usuário pode ter **múltiplos agentes** atribuídos
- Não há seleção de qual agente usar para o upload
- `agente_id` deve ser **100% dinâmico**

## 🔧 **Solução Completa:**

### **✅ 1. Modificar Frontend para Seleção de Agente:**

```typescript
// ✅ NOVA FUNÇÃO: Obter TODOS os agentes do usuário
async function getAgentesDoUsuario(userId: number): Promise<any[]> {
  try {
    // Carregar atribuições de agentes
    await loadAgentesAtribuicoes()
    
    // Encontrar TODOS os agentes atribuídos para o usuário
    const agentesDoUsuario = agentesAtribuicoes.filter(a => a.usuario_id === userId)
    
    console.log(`✅ Agentes encontrados para usuário ${userId}:`, agentesDoUsuario)
    return agentesDoUsuario
  } catch (error) {
    console.error('❌ Erro ao buscar agentes do usuário:', error)
    return []
  }
}

// ✅ NOVO ESTADO: Agente selecionado para upload
const [agenteSelecionado, setAgenteSelecionado] = useState<number | null>(null)
const [agentesDisponiveis, setAgentesDisponiveis] = useState<any[]>([])

// ✅ FUNÇÃO: Carregar agentes disponíveis
async function carregarAgentesDisponiveis() {
  if (!userData) return
  
  const agentes = await getAgentesDoUsuario(parseInt(userData.id))
  setAgentesDisponiveis(agentes)
  
  // Se só tem um agente, selecionar automaticamente
  if (agentes.length === 1) {
    setAgenteSelecionado(agentes[0].agente_id)
  }
}

// ✅ FUNÇÃO: Upload com agente selecionado
async function handleUpload(e: React.FormEvent) {
  e.preventDefault()
  if (!file || !userData || extractedData.length === 0) return
  
  // Validar se agente foi selecionado
  if (!agenteSelecionado) {
    push({ 
      kind: 'error', 
      message: 'Selecione um agente para fazer o upload dos leads.' 
    })
    return
  }
  
  setUploading(true)
  try {
    // Criar payload com agente selecionado
    const payload = {
      logged_user: {
        id: userData.id,
        name: userData.name,
        email: userData.mail
      },
      data: extractedData,
      agente_id: agenteSelecionado,  // ✅ AGENTE SELECIONADO
      file_info: {
        name: file.name,
        size: file.size,
        type: file.type,
        lastModified: file.lastModified
      }
    }

    console.log('📦 Payload de upload com agente selecionado:', payload)
    // ... resto da função
  }
}
```

### **✅ 2. Interface de Seleção de Agente:**

```tsx
// ✅ COMPONENTE: Seletor de Agente
{agentesDisponiveis.length > 0 && (
  <div className="mb-4">
    <label className="block text-sm font-medium text-gray-700 mb-2">
      Selecione o Agente para Upload:
    </label>
    <select
      value={agenteSelecionado || ''}
      onChange={(e) => setAgenteSelecionado(parseInt(e.target.value))}
      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
    >
      <option value="">Selecione um agente...</option>
      {agentesDisponiveis.map((agente) => (
        <option key={agente.agente_id} value={agente.agente_id}>
          Agente {agente.agente_id} - {agente.nome || 'Sem nome'}
        </option>
      ))}
    </select>
  </div>
)}

// ✅ MENSAGEM: Quando não há agentes
{agentesDisponiveis.length === 0 && (
  <div className="mb-4 p-4 bg-yellow-50 border border-yellow-200 rounded-md">
    <p className="text-yellow-800">
      ⚠️ Nenhum agente atribuído para seu usuário. 
      Entre em contato com o administrador.
    </p>
  </div>
)}
```

### **✅ 3. useEffect para Carregar Agentes:**

```typescript
// ✅ CARREGAR AGENTES quando componente monta
useEffect(() => {
  if (userData) {
    carregarAgentesDisponiveis()
  }
}, [userData])
```

## 🎉 **Resultado Final:**

### **✅ Cenário 1: Usuário com 1 Agente**
- Agente é selecionado automaticamente
- Upload funciona normalmente
- `agente_id` é dinâmico (não hardcoded)

### **✅ Cenário 2: Usuário com Múltiplos Agentes**
- Dropdown mostra todos os agentes disponíveis
- Usuário seleciona qual agente usar
- `agente_id` é o selecionado pelo usuário

### **✅ Cenário 3: Usuário sem Agentes**
- Mensagem de erro explicativa
- Upload bloqueado até ter agente atribuído

## 🚀 **Vantagens da Solução:**

1. **✅ 100% Dinâmico:** Nunca hardcoded
2. **✅ Flexível:** Suporta múltiplos agentes
3. **✅ Intuitivo:** Interface clara para seleção
4. **✅ Seguro:** Validação de agente antes do upload
5. **✅ Automático:** Seleção automática quando só há 1 agente

## 🔧 **Implementação:**

1. **Modificar `src/pages/Upload/index.tsx`** com as funções acima
2. **Adicionar interface** de seleção de agente
3. **Testar** com usuários que têm múltiplos agentes
4. **Verificar** que `agente_id` é sempre dinâmico

**Solução 100% dinâmica e flexível! 🚀**
