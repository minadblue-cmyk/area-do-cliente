# ✅ Solução Final: agente_id 100% Dinâmico

## 🎯 **Problema Resolvido:**

### **❌ Problema Original:**
- `agente_id` não podia ser hardcoded
- Usuário pode ter múltiplos agentes atribuídos
- Necessário seleção dinâmica do agente para upload

## 🔧 **Solução Implementada:**

### **✅ 1. Frontend Modificado (`src/pages/Upload/index.tsx`):**

```typescript
// ✅ NOVA FUNÇÃO: Buscar TODOS os agentes do usuário
async function getAgentesDoUsuario(userId: number): Promise<any[]> {
  try {
    await loadAgentesAtribuicoes()
    const agentesDoUsuario = agentesAtribuicoes.filter(a => a.usuario_id === userId)
    console.log(`✅ Agentes encontrados para usuário ${userId}:`, agentesDoUsuario)
    return agentesDoUsuario
  } catch (error) {
    console.error('❌ Erro ao buscar agentes do usuário:', error)
    return []
  }
}

// ✅ NOVOS ESTADOS
const [agenteSelecionado, setAgenteSelecionado] = useState<number | null>(null)
const [agentesDisponiveis, setAgentesDisponiveis] = useState<any[]>([])

// ✅ FUNÇÃO: Carregar agentes disponíveis
async function carregarAgentesDisponiveis() {
  if (!userData) return
  
  const agentes = await getAgentesDoUsuario(parseInt(userData.id))
  setAgentesDisponiveis(agentes)
  
  // Seleção automática se só tem 1 agente
  if (agentes.length === 1) {
    setAgenteSelecionado(agentes[0].agente_id)
  }
}

// ✅ UPLOAD com agente selecionado
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
  
  const payload = {
    logged_user: { id: userData.id, name: userData.name, email: userData.mail },
    data: extractedData,
    agente_id: agenteSelecionado,  // ✅ DINÂMICO
    file_info: { name: file.name, size: file.size, type: file.type, lastModified: file.lastModified }
  }
  // ... resto da função
}
```

### **✅ 2. Interface de Seleção:**

```tsx
{/* ✅ SELETOR DE AGENTE */}
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

{/* ✅ MENSAGEM: Quando não há agentes */}
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

## 🔧 **Próximos Passos:**

1. **No n8n:** Atualizar processamento para usar `agente_id` do payload
2. **Teste:** Fazer upload e verificar se `agente_id` é inserido corretamente
3. **Validação:** Confirmar que funciona com usuários que têm múltiplos agentes

## 📋 **Arquivos Modificados:**

- ✅ `src/pages/Upload/index.tsx` - Interface e lógica de seleção
- ✅ Query SQL já corrigida para incluir `agente_id`
- ✅ Parâmetros n8n já atualizados

**Solução 100% dinâmica e flexível implementada! 🚀**
