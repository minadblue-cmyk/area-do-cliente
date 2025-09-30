# 🔧 Implementação Backend - Sistema de Permissões

## 🎯 **O que você já tem:**
- ✅ Fluxo que lista permissões
- ✅ Tabela `permissoes` com estrutura definida

## 🚀 **O que precisa implementar:**

### **✅ 1. Endpoint para Verificar Permissões do Usuário**

```typescript
// GET /api/users/:id/permissions
// Resposta esperada:
{
  "success": true,
  "data": {
    "userId": 123,
    "permissions": [
      "upload_view",
      "upload_create", 
      "usuario_view",
      "usuario_create",
      "usuario_update",
      "usuario_delete"
    ],
    "userType": "gestor",
    "profileId": 2
  }
}
```

### **✅ 2. Endpoint para Listar Perfis com Permissões**

```typescript
// GET /api/profiles
// Resposta esperada:
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Administrador",
      "description": "Acesso total ao sistema",
      "permissions": [
        "upload_view",
        "upload_create",
        "usuario_view",
        "usuario_create",
        "usuario_update",
        "usuario_delete",
        "perfil_view",
        "perfil_create",
        "perfil_update",
        "perfil_delete"
      ]
    },
    {
      "id": 2,
      "name": "Gestor Empresa",
      "description": "Gerencia usuários da empresa",
      "permissions": [
        "upload_view",
        "upload_create",
        "usuario_view",
        "usuario_create",
        "usuario_update",
        "usuario_delete"
      ]
    }
  ]
}
```

### **✅ 3. Endpoint para Criar/Atualizar Perfil**

```typescript
// POST /api/profiles
{
  "name": "Gestor Empresa",
  "description": "Gerencia usuários da empresa",
  "permissions": [
    "upload_view",
    "upload_create",
    "usuario_view",
    "usuario_create",
    "usuario_update",
    "usuario_delete"
  ]
}

// PUT /api/profiles/:id
{
  "name": "Gestor Empresa Atualizado",
  "description": "Gerencia usuários da empresa",
  "permissions": [
    "upload_view",
    "upload_create",
    "usuario_view",
    "usuario_create",
    "usuario_update",
    "usuario_delete",
    "perfil_view"
  ]
}
```

### **✅ 4. Middleware de Verificação de Permissões**

```typescript
// Middleware para verificar se usuário tem permissão específica
function checkPermission(permission: string) {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      const userId = req.user.id; // Do token JWT
      
      // Buscar permissões do usuário
      const userPermissions = await getUserPermissions(userId);
      
      if (!userPermissions.includes(permission)) {
        return res.status(403).json({
          success: false,
          message: 'Acesso negado. Permissão necessária: ' + permission
        });
      }
      
      next();
    } catch (error) {
      res.status(500).json({
        success: false,
        message: 'Erro ao verificar permissões'
      });
    }
  };
}

// Uso nas rotas:
app.get('/api/users', checkPermission('usuario_view'), getUsers);
app.post('/api/users', checkPermission('usuario_create'), createUser);
app.put('/api/users/:id', checkPermission('usuario_update'), updateUser);
app.delete('/api/users/:id', checkPermission('usuario_delete'), deleteUser);
```

### **✅ 5. Função para Buscar Permissões do Usuário**

```typescript
async function getUserPermissions(userId: number): Promise<string[]> {
  try {
    // Buscar usuário com perfil
    const user = await db.query(`
      SELECT u.id, u.tipo, u.perfil_id, p.permissions 
      FROM users u 
      LEFT JOIN profiles p ON u.perfil_id = p.id 
      WHERE u.id = ?
    `, [userId]);

    if (!user) {
      return [];
    }

    // Se usuário tem perfil personalizado, usar permissões do perfil
    if (user.perfil_id && user.permissions) {
      return JSON.parse(user.permissions);
    }

    // Senão, usar permissões baseadas no tipo de usuário
    return getPermissionsByUserType(user.tipo);
  } catch (error) {
    console.error('Erro ao buscar permissões do usuário:', error);
    return [];
  }
}

function getPermissionsByUserType(userType: string): string[] {
  const permissionGroups = {
    'admin': [
      'upload_view', 'upload_create', 'upload_manage',
      'usuario_view', 'usuario_create', 'usuario_update', 'usuario_delete',
      'perfil_view', 'perfil_create', 'perfil_update', 'perfil_delete',
      'empresa_view', 'empresa_create', 'empresa_update', 'empresa_delete',
      'config_view', 'config_update'
    ],
    'gestor': [
      'upload_view', 'upload_create', 'upload_manage',
      'usuario_view', 'usuario_create', 'usuario_update', 'usuario_delete',
      'perfil_view'
    ],
    'usuario': [
      'upload_view', 'upload_create',
      'saudacao_view', 'saudacao_create', 'saudacao_update', 'saudacao_delete'
    ]
  };

  return permissionGroups[userType] || permissionGroups['usuario'];
}
```

### **✅ 6. Endpoint para Verificar Permissão Específica**

```typescript
// GET /api/check-permission/:permission
// Resposta esperada:
{
  "success": true,
  "data": {
    "permission": "usuario_create",
    "hasPermission": true,
    "userId": 123
  }
}
```

## 🔧 **Estrutura de Banco de Dados Necessária:**

### **✅ Tabela de Perfis (se não existir):**

```sql
CREATE TABLE profiles (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  permissions JSON, -- Array de permissões
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### **✅ Relacionamento Usuário-Perfil:**

```sql
-- Adicionar coluna perfil_id na tabela users (se não existir)
ALTER TABLE users ADD COLUMN perfil_id INT;
ALTER TABLE users ADD FOREIGN KEY (perfil_id) REFERENCES profiles(id);
```

## 🚀 **Fluxos n8n Necessários:**

### **✅ 1. webhook/get-user-permissions**
- **Input:** `{ "userId": 123 }`
- **Output:** `{ "permissions": ["upload_view", "usuario_create", ...] }`

### **✅ 2. webhook/list-profiles**
- **Input:** `{}`
- **Output:** `{ "profiles": [{ "id": 1, "name": "Admin", "permissions": [...] }] }`

### **✅ 3. webhook/create-profile**
- **Input:** `{ "name": "Gestor", "permissions": ["upload_view", ...] }`
- **Output:** `{ "success": true, "profileId": 5 }`

### **✅ 4. webhook/update-profile**
- **Input:** `{ "profileId": 5, "permissions": ["upload_view", "usuario_create", ...] }`
- **Output:** `{ "success": true }`

### **✅ 5. webhook/check-permission**
- **Input:** `{ "userId": 123, "permission": "usuario_create" }`
- **Output:** `{ "hasPermission": true }`

## 🎯 **Resumo do que implementar:**

### **✅ Prioridade Alta:**
1. **Endpoint para buscar permissões do usuário** (`/api/users/:id/permissions`)
2. **Função para verificar permissões** (`getUserPermissions`)
3. **Middleware de verificação** (`checkPermission`)

### **✅ Prioridade Média:**
4. **Endpoint para listar perfis** (`/api/profiles`)
5. **Endpoint para criar/atualizar perfis** (`/api/profiles`)

### **✅ Prioridade Baixa:**
6. **Endpoint para verificar permissão específica** (`/api/check-permission/:permission`)

## 🔍 **Como testar:**

### **✅ 1. Testar permissões do usuário:**
```bash
curl -H "Authorization: Bearer TOKEN" \
  http://localhost:3000/api/users/123/permissions
```

### **✅ 2. Testar middleware:**
```bash
curl -H "Authorization: Bearer TOKEN" \
  http://localhost:3000/api/users
```

### **✅ 3. Testar criação de perfil:**
```bash
curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{"name":"Gestor","permissions":["upload_view","usuario_create"]}' \
  http://localhost:3000/api/profiles
```

**Implementação backend especificada!** 🎯✨
