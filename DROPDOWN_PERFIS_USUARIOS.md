# ✅ Dropdown de Perfis Adicionado ao Formulário de Usuários

## 🎯 **Implementação Completa:**

### **🔧 Funcionalidades Adicionadas:**

#### **1. Interface ProfileItem:**
```typescript
interface ProfileItem {
  id: string
  nome_perfil: string
  description: string
  permissions: string[]
}
```

#### **2. Estado para Perfis:**
```typescript
const [perfis, setPerfis] = useState<ProfileItem[]>([])
const [loadingPerfis, setLoadingPerfis] = useState(false)
```

#### **3. Campo perfil_id no FormData:**
```typescript
const [formData, setFormData] = useState({
  email: '',
  senha: '',
  nome: '',
  tipo: 'usuario',
  ativo: true,
  empresa_id: '',
  plano: 'basico',
  perfil_id: ''  // ✅ Novo campo
})
```

#### **4. Função loadPerfis():**
```typescript
async function loadPerfis() {
  setLoadingPerfis(true)
  try {
    const { data } = await callWebhook<any[]>('webhook/list-profile', { 
      method: 'GET'
    })
    
    // Verificar se a resposta é HTML (erro 404 do n8n)
    if (typeof data === 'string' && data.includes('<!DOCTYPE html>')) {
      throw new Error('Webhook retornou HTML (404) - endpoint não existe no n8n')
    }

    let profiles: ProfileItem[] = []

    if (Array.isArray(data)) {
      // Resposta direta como array de perfis
      profiles = data
    } else if (data && typeof data === 'object' && Array.isArray(data.profiles)) {
      // Resposta como objeto: { profiles: [...] }
      profiles = data.profiles
    }

    setPerfis(profiles)
    
    if (profiles.length > 0) {
      push({ kind: 'success', message: `${profiles.length} perfis carregados!` })
    }
  } catch (error: any) {
    // Tratamento de erro com fallback para dados mock
    const mockPerfis: ProfileItem[] = [
      {
        id: "1",
        nome_perfil: "administrador",
        description: "Acesso total ao sistema.",
        permissions: ["upload_de_arquivo", "saudacao_personalizada", ...]
      },
      // ... mais perfis
    ]
    
    setPerfis(mockPerfis)
    push({ kind: 'info', message: 'Exibindo perfis de exemplo para demonstração.' })
  } finally {
    setLoadingPerfis(false)
  }
}
```

#### **5. Dropdown no Formulário:**
```typescript
{/* Perfil (dropdown) */}
<select
  className="input"
  value={formData.perfil_id}
  onChange={(e) => setFormData({...formData, perfil_id: e.target.value})}
  disabled={loadingPerfis}
>
  <option value="">Selecione um perfil</option>
  {perfis.map((perfil) => (
    <option key={perfil.id} value={perfil.id}>
      {perfil.nome_perfil} - {perfil.description}
    </option>
  ))}
</select>
```

#### **6. Payload Atualizado:**
```typescript
const payload = {
  email: formData.email,
  senha: formData.senha,
  nome: formData.nome,
  tipo: formData.tipo,
  ativo: formData.ativo,
  empresa_id: formData.empresa_id ? parseInt(formData.empresa_id) : null,
  plano: formData.plano,
  perfil_id: formData.perfil_id ? parseInt(formData.perfil_id) : null  // ✅ Novo campo
}
```

#### **7. Carregamento Automático:**
```typescript
useEffect(() => {
  loadUsuarios()
  loadEmpresas()
  loadPerfis()  // ✅ Carrega perfis automaticamente
}, [])
```

## 🎉 **Resultado:**

### **✅ Formulário de Criação de Usuário Agora Inclui:**

1. **Email** (obrigatório)
2. **Senha** (obrigatório)
3. **Nome completo** (opcional)
4. **Tipo** (dropdown: Usuário, Supervisor, Administrador, Padrão)
5. **Status: Ativo** (checkbox)
6. **Empresa** (dropdown com empresas do n8n)
7. **Perfil** (dropdown com perfis do n8n) ✅ **NOVO**
8. **Plano** (dropdown: Básico, Premium, Enterprise)

### **🔧 Comportamento:**

- **Se webhook funciona:** Carrega perfis reais do n8n
- **Se webhook falha:** Usa perfis mock com aviso
- **Dropdown desabilitado:** Durante carregamento
- **Formato das opções:** "nome_perfil - description"
- **Payload enviado:** Inclui `perfil_id` para o n8n

## 🚀 **Teste Agora:**

1. **Acesse `/usuarios`**
2. **Clique em "+ Criar Usuário"**
3. **Veja o novo dropdown "Selecione um perfil"**
4. **Opções disponíveis:**
   - administrador - Acesso total ao sistema.
   - gestor_empresa - Acesso para gerenciar usuários...
   - supervisor - Acesso limitado para visualização...
   - usuario_comum - Acesso restrito a dados pessoais.

**Formulário completo com perfis funcionando!** 🎯✨
