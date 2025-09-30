# 🔄 Mapeamento de Permissões - Tabela Existente

## 🎯 **Estratégia:**

Utilizar a tabela `permissoes` existente, alterando apenas os valores dos campos `nome_permissao` e `descricao` para seguir o padrão definido.

## 📋 **Mapeamento Proposto:**

### **✅ Upload:**
| ID | Nome Atual | Novo Nome | Nova Descrição |
|----|------------|-----------|----------------|
| 4 | `upload_de_arquivo` | `upload_view` | Acessar a aba upload |
| 6 | `upload_de_arquivos` | `upload_create` | Fazer upload de arquivos |
| 5 | `gerenciar_uploads` | `upload_manage` | Gerenciar uploads da empresa |
| 22 | `nav_upload` | `nav_upload` | Acesso à funcionalidade de upload |

### **✅ Dashboard:**
| ID | Nome Atual | Novo Nome | Nova Descrição |
|----|------------|-----------|----------------|
| 18 | `nav_dashboard` | `nav_dashboard` | Acesso ao dashboard principal |
| 1 | `dashboard_completo` | `dashboard_view_all` | Acesso a todos os dados do dashboard |
| 2 | `dashboard_da_empresa` | `dashboard_view_company` | Acesso apenas aos dados da própria empresa |
| 3 | `dashboard_pessoal` | `dashboard_view_personal` | Acesso apenas aos próprios dados |

### **✅ Saudação:**
| ID | Nome Atual | Novo Nome | Nova Descrição |
|----|------------|-----------|----------------|
| 7 | `saudacao_personalizada` | `saudacao_create` | Criação de saudação personalizada |
| 25 | `nav_saudacao` | `nav_saudacao` | Acesso às configurações de saudação |

### **✅ Webhooks:**
| ID | Nome Atual | Novo Nome | Nova Descrição |
|----|------------|-----------|----------------|
| 8 | `configurar_webhooks` | `config_update` | Configurações gerais do sistema, aba webhooks |
| 9 | `gerenciar_webhooks` | `webhook_manage` | Configurar webhooks da empresa |
| 10 | `ver_todos_os_webhooks` | `webhook_view_all` | Visualizar webhooks de todas as empresas |
| 26 | `nav_webhooks` | `nav_webhooks` | Acesso às configurações de webhooks |

### **✅ Usuários:**
| ID | Nome Atual | Novo Nome | Nova Descrição |
|----|------------|-----------|----------------|
| 11 | `usuarios` | `usuario_view` | Visualizar usuários |
| 12 | `criar_usuarios` | `usuario_create` | Criação de usuários do sistema |
| 13 | `editar_usuarios` | `usuario_update` | Edição de usuários do sistema |
| 14 | `excluir_usuarios` | `usuario_delete` | Deleção de usuários do sistema |
| 15 | `ver_todos_os_usuarios` | `usuario_view_all` | Visualizar usuários de todas as empresas |
| 16 | `ver_usuarios_da_empresa` | `usuario_view_company` | Visualizar apenas usuários da própria empresa |
| 29 | `nav_usuarios` | `nav_usuarios` | Acesso ao gerenciamento de usuários |

### **✅ Perfis e Permissões:**
| ID | Nome Atual | Novo Nome | Nova Descrição |
|----|------------|-----------|----------------|
| 17 | `gerenciar_permissoes` | `perfil_manage` | Gerenciar perfis e permissões |
| 35 | `nav_permissoes` | `nav_permissoes` | Acesso ao sistema de permissões |

### **✅ Configurações:**
| ID | Nome Atual | Novo Nome | Nova Descrição |
|----|------------|-----------|----------------|
| 36 | `nav_auth_config` | `nav_auth_config` | Acesso às configurações de autenticação |
| 37 | `config_sistema` | `config_sistema` | Acesso às configurações gerais do sistema |

## 🔧 **Scripts SQL para Atualização:**

### **✅ 1. Upload:**
```sql
UPDATE permissoes SET 
  nome_permissao = 'upload_view',
  descricao = 'Acessar a aba upload'
WHERE id = 4;

UPDATE permissoes SET 
  nome_permissao = 'upload_create',
  descricao = 'Fazer upload de arquivos'
WHERE id = 6;

UPDATE permissoes SET 
  nome_permissao = 'upload_manage',
  descricao = 'Gerenciar uploads da empresa'
WHERE id = 5;
```

### **✅ 2. Dashboard:**
```sql
UPDATE permissoes SET 
  nome_permissao = 'dashboard_view_all',
  descricao = 'Acesso a todos os dados do dashboard'
WHERE id = 1;

UPDATE permissoes SET 
  nome_permissao = 'dashboard_view_company',
  descricao = 'Acesso apenas aos dados da própria empresa'
WHERE id = 2;

UPDATE permissoes SET 
  nome_permissao = 'dashboard_view_personal',
  descricao = 'Acesso apenas aos próprios dados'
WHERE id = 3;
```

### **✅ 3. Saudação:**
```sql
UPDATE permissoes SET 
  nome_permissao = 'saudacao_create',
  descricao = 'Criação de saudação personalizada'
WHERE id = 7;
```

### **✅ 4. Webhooks:**
```sql
UPDATE permissoes SET 
  nome_permissao = 'config_update',
  descricao = 'Configurações gerais do sistema, aba webhooks'
WHERE id = 8;

UPDATE permissoes SET 
  nome_permissao = 'webhook_manage',
  descricao = 'Configurar webhooks da empresa'
WHERE id = 9;

UPDATE permissoes SET 
  nome_permissao = 'webhook_view_all',
  descricao = 'Visualizar webhooks de todas as empresas'
WHERE id = 10;
```

### **✅ 5. Usuários:**
```sql
UPDATE permissoes SET 
  nome_permissao = 'usuario_view',
  descricao = 'Visualizar usuários'
WHERE id = 11;

UPDATE permissoes SET 
  nome_permissao = 'usuario_create',
  descricao = 'Criação de usuários do sistema'
WHERE id = 12;

UPDATE permissoes SET 
  nome_permissao = 'usuario_update',
  descricao = 'Edição de usuários do sistema'
WHERE id = 13;

UPDATE permissoes SET 
  nome_permissao = 'usuario_delete',
  descricao = 'Deleção de usuários do sistema'
WHERE id = 14;

UPDATE permissoes SET 
  nome_permissao = 'usuario_view_all',
  descricao = 'Visualizar usuários de todas as empresas'
WHERE id = 15;

UPDATE permissoes SET 
  nome_permissao = 'usuario_view_company',
  descricao = 'Visualizar apenas usuários da própria empresa'
WHERE id = 16;
```

### **✅ 6. Perfis:**
```sql
UPDATE permissoes SET 
  nome_permissao = 'perfil_manage',
  descricao = 'Gerenciar perfis e permissões'
WHERE id = 17;
```

## 🎯 **Permissões Adicionais Necessárias:**

Para completar o sistema, você pode adicionar estas permissões:

```sql
-- Agente de prospecção
INSERT INTO permissoes (nome_permissao, descricao) VALUES 
('agente_execute', 'Iniciar agente de prospecção');

-- Saudação (ações adicionais)
INSERT INTO permissoes (nome_permissao, descricao) VALUES 
('saudacao_view', 'Visualizar saudações'),
('saudacao_update', 'Editar saudação'),
('saudacao_delete', 'Deletar saudação'),
('saudacao_select', 'Selecionar saudação para agente');

-- Empresas
INSERT INTO permissoes (nome_permissao, descricao) VALUES 
('empresa_view', 'Visualizar empresas'),
('empresa_create', 'Criar empresas'),
('empresa_update', 'Editar empresas'),
('empresa_delete', 'Deletar empresas'),
('nav_empresas', 'Acesso ao gerenciamento de empresas');

-- Perfis (ações adicionais)
INSERT INTO permissoes (nome_permissao, descricao) VALUES 
('perfil_view', 'Visualizar perfis'),
('perfil_create', 'Criar perfis'),
('perfil_update', 'Editar perfis'),
('perfil_delete', 'Deletar perfis');

-- Configurações
INSERT INTO permissoes (nome_permissao, descricao) VALUES 
('config_view', 'Visualizar configurações');
```

## 🚀 **Vantagens desta Abordagem:**

### **✅ 1. Compatibilidade:**
- **Mantém IDs existentes** (sem quebrar relacionamentos)
- **Preserva estrutura** da tabela
- **Migração simples** (apenas UPDATEs)

### **✅ 2. Flexibilidade:**
- **Adiciona novas permissões** conforme necessário
- **Mantém permissões específicas** (como `nav_*`)
- **Suporte a hierarquias** (empresa vs global)

### **✅ 3. Manutenibilidade:**
- **Padrão consistente** de nomenclatura
- **Fácil identificação** de permissões
- **Documentação clara** de cada permissão

**Sistema adaptado para sua tabela existente!** 🎯✨
