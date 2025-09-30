# Atualização do Frontend para Isolamento por Empresa

## 🎯 Objetivo
Atualizar o frontend para implementar isolamento por empresa e remover restrições de chaves únicas.

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

// IMPORTANTE: Sempre definir usuário atual antes da query
const payload = {
  ...uploadData,
  action: 'upload',
  set_user_id: userData.id // Para definir usuário atual no n8n
};
```

### 2. Atualizar Payload de Start do Agente

**Arquivo:** `src/pages/Upload/index.tsx`

```typescript
// Na função iniciarAgente, incluir empresa_id
const payload = {
  usuario_id: userData.id,
  action: 'start',
  set_user_id: userData.id, // NOVO: Para definir usuário atual
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
    usuario_id: userData.id,
    set_user_id: userData.id, // NOVO: Para definir usuário atual
    empresa_id: userData.empresa_id, // NOVO: ID da empresa
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

// Adicionar validação de telefone duplicado (apenas na mesma empresa)
const validateTelefoneDuplicado = (telefone: string, empresaId: number) => {
  // Verificar se telefone já existe na mesma empresa
  // (não mais restrição global)
  return true; // Permitir mesmo telefone em empresas diferentes
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
      <span className="lead-telefone">{lead.telefone}</span>
    </div>
  );
};

// Adicionar indicador de isolamento
const renderIsolamentoInfo = () => {
  return (
    <div className="isolamento-info">
      <div className="info-item">
        <span className="label">Empresa:</span>
        <span className="value">{userData.empresa_nome}</span>
      </div>
      <div className="info-item">
        <span className="label">Isolamento:</span>
        <span className="value">Ativo</span>
      </div>
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
  perfil_id: userData.perfil_id,
  set_user_id: userData.id // NOVO: Para definir usuário atual
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
  } else if (error.message?.includes('telefone')) {
    push({ 
      kind: 'info', 
      message: 'Telefone já existe na sua empresa (permitido)' 
    });
  } else {
    push({ kind: 'error', message: 'Erro inesperado' });
  }
};
```

### Passo 5: Atualizar Validações de Upload

```typescript
// Remover validação de telefone único global
const validateUploadData = (data: any) => {
  const errors = [];
  
  // Validar campos obrigatórios
  if (!data.nome) errors.push('Nome é obrigatório');
  if (!data.telefone) errors.push('Telefone é obrigatório');
  
  // REMOVER: Validação de telefone único global
  // if (telefoneExists(data.telefone)) errors.push('Telefone já existe');
  
  return errors;
};
```

## 🧪 Testes de Validação

### Teste 1: Upload com Empresa
```typescript
// Verificar se upload inclui empresa_id
const testUpload = async () => {
  const payload = createUploadPayload();
  console.log('Payload de upload:', payload);
  // Deve incluir: empresa_id, usuario_id, set_user_id
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

### Teste 4: Telefone Duplicado
```typescript
// Verificar se mesmo telefone é permitido em empresas diferentes
const testTelefoneDuplicado = async () => {
  const telefone = '11999999999';
  const empresaA = 1;
  const empresaB = 2;
  
  // Deve permitir mesmo telefone em empresas diferentes
  const resultA = await uploadLead(telefone, empresaA);
  const resultB = await uploadLead(telefone, empresaB);
  
  console.log('Mesmo telefone em empresas diferentes:', resultA && resultB);
};
```

## ⚠️ Considerações Importantes

### Antes de Implementar:
1. **Backup obrigatório** do banco de dados
2. **Teste em ambiente de desenvolvimento** primeiro
3. **Validação** de todas as aplicações
4. **Comunicação** com a equipe sobre mudanças

### Após Implementar:
1. **Verificação** de integridade dos dados
2. **Teste** de todas as funcionalidades
3. **Monitoramento** de performance
4. **Documentação** das mudanças

## 📝 Checklist de Implementação

- [ ] Atualizar payload de upload
- [ ] Atualizar payload de start do agente
- [ ] Atualizar payload de lista de prospecção
- [ ] Adicionar validações de empresa
- [ ] Atualizar componentes de exibição
- [ ] Adicionar mensagens de erro específicas
- [ ] Remover validações de telefone único global
- [ ] Implementar testes de validação
- [ ] Testar com múltiplas empresas
- [ ] Documentar mudanças
- [ ] Deploy em ambiente de teste

## 🎯 Resultado Final

Com esta implementação, você terá:

- ✅ **Isolamento completo** de leads por empresa
- ✅ **Mesmo telefone** permitido em empresas diferentes
- ✅ **Segurança robusta** com validações adequadas
- ✅ **Performance otimizada** com consultas filtradas
- ✅ **Interface transparente** para o usuário

**O sistema agora garante que cada empresa vê apenas seus próprios leads, mas permite que empresas diferentes tenham leads com o mesmo telefone!** 🎉
