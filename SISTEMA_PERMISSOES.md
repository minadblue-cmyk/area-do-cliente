# 🔐 Sistema de Permissões do Sistema

## 🎯 **Visão Geral:**

Sistema granular de permissões baseado em **módulos** e **ações**, com hierarquia de usuários e proteção de funcionalidades.

## 📋 **Padrão de Nomenclatura:**

### **Formato:** `{modulo}_{acao}`

| Módulo | Descrição | Ações Disponíveis |
|--------|-----------|-------------------|
| `upload` | Upload de arquivos | `view`, `create` |
| `agente` | Agente de prospecção | `execute` |
| `saudacao` | Saudações personalizadas | `view`, `create`, `update`, `delete`, `select` |
| `usuario` | Usuários do sistema | `view`, `create`, `update`, `delete` |
| `perfil` | Perfis e permissões | `view`, `create`, `update`, `delete` |
| `empresa` | Empresas do sistema | `view`, `create`, `update`, `delete` |
| `config` | Configurações gerais | `view`, `update` |

## 🔧 **Permissões Definidas:**

### **✅ Upload:**
- `upload_view` - Acessar a aba upload
- `upload_create` - Fazer upload de arquivos

### **✅ Agente:**
- `agente_execute` - Iniciar agente de prospecção

### **✅ Saudação:**
- `saudacao_view` - Visualizar saudações
- `saudacao_create` - Criação de saudação personalizada
- `saudacao_update` - Editar saudação
- `saudacao_delete` - Deleção de saudação
- `saudacao_select` - Seleção para o agente da saudação

### **✅ Usuários:**
- `usuario_view` - Visualizar usuários
- `usuario_create` - Criação de usuários do sistema
- `usuario_update` - Edição de usuários do sistema
- `usuario_delete` - Deleção de usuários do sistema

### **✅ Perfis e Permissões:**
- `perfil_view` - Visualizar perfis
- `perfil_create` - Criação de permissões e perfis
- `perfil_update` - Edição de permissões e perfis
- `perfil_delete` - Deleção de permissões e perfis

### **✅ Empresas:**
- `empresa_view` - Visualizar empresas
- `empresa_create` - Criação de empresas no sistema
- `empresa_update` - Edição de empresas no sistema
- `empresa_delete` - Deleção de empresas no sistema

### **✅ Configurações:**
- `config_view` - Visualizar configurações
- `config_update` - Configurações gerais do sistema, aba webhooks

## 👥 **Hierarquia de Usuários:**

### **🔴 ADMINISTRADOR:**
- **Todas as permissões** do sistema
- Acesso completo a configurações
- Pode gerenciar todos os usuários, empresas e perfis

### **🟡 GESTOR:**
- **Permissões de gestão** (sem configurações críticas)
- Pode gerenciar usuários da própria empresa
- Acesso limitado a perfis e empresas (apenas visualização)

### **🟢 USUÁRIO (Padrão):**
- **Permissões básicas** de uso
- Pode usar upload, agente e saudações
- Sem acesso a gestão de usuários, empresas ou configurações

## 🚀 **Como Usar no Frontend:**

### **✅ 1. Hook usePermissions:**

```typescript
import { usePermissions } from '../hooks/usePermissions'

function MyComponent() {
  const { can, canViewUpload, canCreateUsuario } = usePermissions()

  return (
    <div>
      {can('upload_view') && <UploadButton />}
      {canViewUpload() && <UploadSection />}
      {canCreateUsuario() && <CreateUserButton />}
    </div>
  )
}
```

### **✅ 2. Componente PermissionGuard:**

```typescript
import { PermissionGuard } from '../components/PermissionGuard'

function MyPage() {
  return (
    <div>
      <PermissionGuard permission="upload_view">
        <UploadSection />
      </PermissionGuard>
      
      <PermissionGuard permissions={['usuario_create', 'usuario_update']} requireAll={false}>
        <UserManagementSection />
      </PermissionGuard>
    </div>
  )
}
```

### **✅ 3. Componente PermissionButton:**

```typescript
import { PermissionButton } from '../components/PermissionGuard'

function MyComponent() {
  return (
    <div>
      <PermissionButton permission="usuario_create" className="btn btn-primary">
        Criar Usuário
      </PermissionButton>
      
      <PermissionButton permissions={['usuario_update', 'usuario_delete']} requireAll={false}>
        Gerenciar Usuários
      </PermissionButton>
    </div>
  )
}
```

## 🔧 **Implementação no Backend:**

### **✅ 1. Tabela de Permissões:**

```sql
CREATE TABLE permissions (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50) UNIQUE NOT NULL,
  description TEXT,
  module VARCHAR(20) NOT NULL,
  action VARCHAR(20) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### **✅ 2. Tabela de Perfis:**

```sql
CREATE TABLE profiles (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  permissions JSON, -- Array de permissões
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### **✅ 3. Relacionamento Usuário-Perfil:**

```sql
ALTER TABLE users ADD COLUMN profile_id INT;
ALTER TABLE users ADD FOREIGN KEY (profile_id) REFERENCES profiles(id);
```

### **✅ 4. Endpoints Sugeridos:**

```typescript
// Listar permissões
GET /api/permissions

// Listar perfis com permissões
GET /api/profiles

// Criar perfil
POST /api/profiles
{
  "name": "Gestor Empresa",
  "description": "Gerencia usuários da empresa",
  "permissions": ["usuario_view", "usuario_create", "usuario_update"]
}

// Atualizar perfil
PUT /api/profiles/:id
{
  "permissions": ["usuario_view", "usuario_create", "usuario_update", "usuario_delete"]
}

// Verificar permissões do usuário
GET /api/users/:id/permissions
```

## 🎯 **Exemplos de Uso:**

### **✅ 1. Proteger Aba de Upload:**

```typescript
// No Sidebar.tsx
<PermissionGuard permission="upload_view">
  <Link to="/upload">Upload</Link>
</PermissionGuard>
```

### **✅ 2. Proteger Botão de Criar Usuário:**

```typescript
// Na página de usuários
<PermissionButton permission="usuario_create" className="btn btn-primary">
  + Criar Usuário
</PermissionButton>
```

### **✅ 3. Proteger Seção de Configurações:**

```typescript
// Na página de configurações
<PermissionGuard permission="config_view">
  <ConfigSection />
</PermissionGuard>
```

### **✅ 4. Proteger Ações de Saudação:**

```typescript
// Na página de saudações
<div className="actions">
  <PermissionButton permission="saudacao_create">
    Nova Saudação
  </PermissionButton>
  
  <PermissionButton permission="saudacao_delete">
    Deletar
  </PermissionButton>
</div>
```

## 🔍 **Benefícios:**

### **✅ 1. Segurança:**
- **Controle granular** de acesso
- **Proteção em múltiplas camadas**
- **Prevenção de acesso não autorizado**

### **✅ 2. Flexibilidade:**
- **Permissões customizáveis** por perfil
- **Fácil adição** de novas permissões
- **Hierarquia configurável**

### **✅ 3. Manutenibilidade:**
- **Código organizado** e reutilizável
- **Padrão consistente** de nomenclatura
- **Fácil debugging** e testes

**Sistema de permissões implementado com sucesso!** 🎯✨
