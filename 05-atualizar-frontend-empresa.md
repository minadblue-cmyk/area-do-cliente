# Atualização do Frontend para Isolamento por Empresa

## 🎯 Objetivo
Atualizar o frontend para incluir `empresa_id` em todas as requisições e garantir isolamento por empresa.

## 📋 Mudanças Necessárias

### 1. Atualizar Payload de Upload

**Arquivo:** `src/pages/Upload/index.tsx`

```typescript
// Na função de upload, incluir empresa_id no payload
const uploadData = {
  // ... outros campos existentes
  empresa_id: userData.empresa_id, // NOVO: ID da empresa do usuário
  usuario_id: userData.id
};
```

### 2. Atualizar Payload de Start do Agente

**Arquivo:** `src/pages/Upload/index.tsx`

```typescript
// Na função iniciarAgente, incluir empresa_id
const payload = {
  usuario_id: userData.id,
  action: 'start',
  logged_user: {
    id: userData.id,
    name: userData.nome,
    email: userData.email
  },
  agente_id: agente.id,
  perfil_id: userData.perfil_id,
  empresa_id: userData.empresa_id, // NOVO: ID da empresa
  perfis_permitidos: perfisPermitidos,
  usuarios_permitidos: usuariosPermitidos
};
```

### 3. Atualizar Payload de Lista de Prospecção

**Arquivo:** `src/pages/Upload/index.tsx`

```typescript
// Na função loadProspects, incluir empresa_id
const loadProspects = async (agente?: any, isAutoRefresh = false) => {
  // ... lógica existente
  
  const payload = {
    agente_id: agenteAtual.id,
    empresa_id: userData.empresa_id, // NOVO: ID da empresa
    usuario_id: userData.id,
    perfil_id: userData.perfil_id
  };
  
  // ... resto da lógica
};
```

### 4. Atualizar Validações de Permissão

**Arquivo:** `src/hooks/useUserPermissions.ts`

```typescript
// Adicionar validação de empresa nas permissões
const validateEmpresaAccess = (leadEmpresaId: number, userEmpresaId: number) => {
  return leadEmpresaId === userEmpresaId;
};

// Usar na validação de acesso a leads
const canAccessLead = (lead: any) => {
  return validateEmpresaAccess(lead.empresa_id, userData.empresa_id);
};
```

### 5. Atualizar Componentes de Exibição

**Arquivo:** `src/pages/Upload/index.tsx`

```typescript
// Adicionar informação da empresa na exibição
const renderLeadInfo = (lead: any) => {
  return (
    <div className="lead-info">
      <span className="lead-nome">{lead.nome}</span>
      <span className="lead-empresa">{lead.empresa_nome}</span>
      <span className="lead-status">{lead.status}</span>
    </div>
  );
};
```

## 🔧 Implementação Passo a Passo

### Passo 1: Verificar se userData tem empresa_id

```typescript
// No componente Upload, verificar se empresa_id está disponível
useEffect(() => {
  if (userData && !userData.empresa_id) {
    console.error('❌ Usuário não tem empresa_id definido');
    push({ 
      kind: 'error', 
      message: 'Erro: Usuário não está associado a uma empresa' 
    });
  }
}, [userData]);
```

### Passo 2: Atualizar Todas as Requisições

```typescript
// Função auxiliar para criar payload padrão
const createBasePayload = () => ({
  usuario_id: userData.id,
  empresa_id: userData.empresa_id,
  perfil_id: userData.perfil_id
});

// Usar em todas as requisições
const payload = {
  ...createBasePayload(),
  // ... outros campos específicos
};
```

### Passo 3: Adicionar Validações de Segurança

```typescript
// Validar se lead pertence à empresa do usuário
const validateLeadAccess = (lead: any) => {
  if (lead.empresa_id !== userData.empresa_id) {
    console.warn(`⚠️ Lead ${lead.id} não pertence à empresa do usuário`);
    return false;
  }
  return true;
};

// Filtrar leads por empresa antes de exibir
const filteredLeads = leads.filter(validateLeadAccess);
```

### Passo 4: Atualizar Mensagens de Erro

```typescript
// Adicionar mensagens específicas para problemas de empresa
const handleEmpresaError = (error: any) => {
  if (error.message?.includes('empresa')) {
    push({ 
      kind: 'error', 
      message: 'Erro de acesso: Lead não pertence à sua empresa' 
    });
  } else {
    push({ kind: 'error', message: 'Erro inesperado' });
  }
};
```

## 🧪 Testes de Validação

### Teste 1: Upload com Empresa
```typescript
// Verificar se upload inclui empresa_id
const testUpload = async () => {
  const payload = createUploadPayload();
  console.log('Payload de upload:', payload);
  // Deve incluir: empresa_id, usuario_id
};
```

### Teste 2: Lista Filtrada por Empresa
```typescript
// Verificar se lista só mostra leads da empresa
const testLista = async () => {
  const leads = await loadProspects();
  const allFromSameEmpresa = leads.every(lead => 
    lead.empresa_id === userData.empresa_id
  );
  console.log('Todos os leads são da mesma empresa:', allFromSameEmpresa);
};
```

### Teste 3: Validação de Acesso
```typescript
// Verificar se validação de acesso funciona
const testAccess = (lead: any) => {
  const canAccess = validateLeadAccess(lead);
  console.log(`Lead ${lead.id} - Pode acessar:`, canAccess);
};
```

## ⚠️ Considerações Importantes

1. **Backward Compatibility**: Garantir que sistema funcione com dados antigos
2. **Error Handling**: Tratar casos onde empresa_id não está definido
3. **Performance**: Índices adequados para consultas por empresa
4. **Segurança**: Validação no frontend E backend
5. **UX**: Mensagens claras sobre restrições de empresa

## 📝 Checklist de Implementação

- [ ] Atualizar payload de upload
- [ ] Atualizar payload de start do agente
- [ ] Atualizar payload de lista de prospecção
- [ ] Adicionar validações de empresa
- [ ] Atualizar componentes de exibição
- [ ] Adicionar mensagens de erro específicas
- [ ] Implementar testes de validação
- [ ] Testar com múltiplas empresas
- [ ] Documentar mudanças
- [ ] Deploy em ambiente de teste
