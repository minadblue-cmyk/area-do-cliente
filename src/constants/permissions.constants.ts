/**
 * Sistema de Permissões do Sistema
 * 
 * Padrão de nomenclatura:
 * - Formato: {modulo}_{acao}
 * - Módulos: upload, agente, saudacao, usuario, perfil, empresa, config
 * - Ações: view, create, update, delete, execute
 */

export const PERMISSIONS = {
  // ===== UPLOAD =====
  UPLOAD_VIEW: 'upload_view',           // Acessar a aba upload (ID: 4)
  UPLOAD_CREATE: 'upload_create',       // Fazer upload de arquivos (ID: 6)
  UPLOAD_MANAGE: 'upload_manage',        // Gerenciar uploads da empresa (ID: 5)
  NAV_UPLOAD: 'nav_upload',             // Acesso à funcionalidade de upload (ID: 22)

  // ===== DASHBOARD =====
  NAV_DASHBOARD: 'nav_dashboard',       // Acesso ao dashboard principal (ID: 18)
  DASHBOARD_VIEW_ALL: 'dashboard_view_all',     // Acesso a todos os dados (ID: 1)
  DASHBOARD_VIEW_COMPANY: 'dashboard_view_company', // Acesso dados da empresa (ID: 2)
  DASHBOARD_VIEW_PERSONAL: 'dashboard_view_personal', // Acesso dados pessoais (ID: 3)

  // ===== AGENTE =====
  AGENTE_VIEW: 'agente_view',           // Visualizar agentes
  AGENTE_CREATE: 'agente_create',       // Criar novos agentes
  AGENTE_UPDATE: 'agente_update',       // Editar agentes
  AGENTE_DELETE: 'agente_delete',       // Deletar agentes
  AGENTE_EXECUTE: 'agente_execute',     // Iniciar/parar agentes
  AGENTE_MANAGE: 'agente_manage',       // Gerenciar todos os agentes
  AGENTE_VIEW_ALL: 'agente_view_all',   // Ver agentes de todos os usuários
  AGENTE_VIEW_OWN: 'agente_view_own',   // Ver apenas seus próprios agentes
  NAV_AGENTE: 'nav_agente',             // Acesso à funcionalidade de agentes

  // ===== SAUDAÇÃO =====
  SAUDACAO_VIEW: 'saudacao_view',       // Visualizar saudações
  SAUDACAO_CREATE: 'saudacao_create',   // Criação de saudação personalizada (ID: 7)
  SAUDACAO_UPDATE: 'saudacao_update',   // Editar saudação
  SAUDACAO_DELETE: 'saudacao_delete',   // Deleção de saudação
  SAUDACAO_SELECT: 'saudacao_select',   // Seleção para o agente da saudação
  NAV_SAUDACAO: 'nav_saudacao',         // Acesso às configurações de saudação (ID: 25)

  // ===== USUÁRIOS =====
  USUARIO_VIEW: 'usuario_view',         // Visualizar usuários (ID: 11)
  USUARIO_CREATE: 'usuario_create',     // Criação de usuários do sistema (ID: 12)
  USUARIO_UPDATE: 'usuario_update',     // Edição de usuários do sistema (ID: 13)
  USUARIO_DELETE: 'usuario_delete',     // Deleção de usuários do sistema (ID: 14)
  USUARIO_VIEW_ALL: 'usuario_view_all', // Visualizar usuários de todas as empresas (ID: 15)
  USUARIO_VIEW_COMPANY: 'usuario_view_company', // Visualizar usuários da empresa (ID: 16)
  NAV_USUARIOS: 'nav_usuarios',         // Acesso ao gerenciamento de usuários (ID: 29)

  // ===== PERFIS E PERMISSÕES =====
  PERFIL_VIEW: 'perfil_view',           // Visualizar perfis
  PERFIL_CREATE: 'perfil_create',       // Criação de permissões e perfis
  PERFIL_UPDATE: 'perfil_update',       // Edição de permissões e perfis
  PERFIL_DELETE: 'perfil_delete',       // Deleção de permissões e perfis
  PERFIL_MANAGE: 'perfil_manage',       // Gerenciar perfis e permissões (ID: 17)
  NAV_PERMISSOES: 'nav_permissoes',     // Acesso ao sistema de permissões (ID: 35)

  // ===== EMPRESAS =====
  EMPRESA_VIEW: 'empresa_view',         // Visualizar empresas
  EMPRESA_CREATE: 'empresa_create',      // Criação de empresas no sistema
  EMPRESA_UPDATE: 'empresa_update',     // Edição de empresas no sistema
  EMPRESA_DELETE: 'empresa_delete',     // Deleção de empresas no sistema
  NAV_EMPRESAS: 'nav_empresas',         // Acesso ao gerenciamento de empresas

  // ===== WEBHOOKS =====
  WEBHOOK_MANAGE: 'webhook_manage',      // Configurar webhooks da empresa (ID: 9)
  WEBHOOK_VIEW_ALL: 'webhook_view_all', // Visualizar webhooks de todas as empresas (ID: 10)
  NAV_WEBHOOKS: 'nav_webhooks',         // Acesso às configurações de webhooks (ID: 26)

  // ===== CONFIGURAÇÕES =====
  CONFIG_VIEW: 'config_view',           // Visualizar configurações
  CONFIG_UPDATE: 'config_update',       // Configurações gerais do sistema, aba webhooks (ID: 8)
  NAV_AUTH_CONFIG: 'nav_auth_config',   // Acesso às configurações de autenticação (ID: 36)
  CONFIG_SISTEMA: 'config_sistema',     // Acesso às configurações gerais do sistema (ID: 37)
} as const

/**
 * Grupos de Permissões por Tipo de Usuário
 * 
 * Hierarquia:
 * - ADMINISTRADOR: Todas as permissões
 * - GESTOR: Permissões de gestão (sem configurações críticas)
 * - USUARIO: Permissões básicas de uso
 */

export const PERMISSION_GROUPS = {
  ADMINISTRADOR: [
    // Dashboard
    PERMISSIONS.NAV_DASHBOARD,
    PERMISSIONS.DASHBOARD_VIEW_ALL,
    
    // Upload
    PERMISSIONS.NAV_UPLOAD,
    PERMISSIONS.UPLOAD_VIEW,
    PERMISSIONS.UPLOAD_CREATE,
    PERMISSIONS.UPLOAD_MANAGE,
    
    // Agente
    PERMISSIONS.AGENTE_EXECUTE,
    
    // Saudação
    PERMISSIONS.NAV_SAUDACAO,
    PERMISSIONS.SAUDACAO_VIEW,
    PERMISSIONS.SAUDACAO_CREATE,
    PERMISSIONS.SAUDACAO_UPDATE,
    PERMISSIONS.SAUDACAO_DELETE,
    PERMISSIONS.SAUDACAO_SELECT,
    
    // Usuários
    PERMISSIONS.NAV_USUARIOS,
    PERMISSIONS.USUARIO_VIEW,
    PERMISSIONS.USUARIO_CREATE,
    PERMISSIONS.USUARIO_UPDATE,
    PERMISSIONS.USUARIO_DELETE,
    PERMISSIONS.USUARIO_VIEW_ALL,
    
    // Perfis
    PERMISSIONS.NAV_PERMISSOES,
    PERMISSIONS.PERFIL_VIEW,
    PERMISSIONS.PERFIL_CREATE,
    PERMISSIONS.PERFIL_UPDATE,
    PERMISSIONS.PERFIL_DELETE,
    PERMISSIONS.PERFIL_MANAGE,
    
    // Empresas
    PERMISSIONS.NAV_EMPRESAS,
    PERMISSIONS.EMPRESA_VIEW,
    PERMISSIONS.EMPRESA_CREATE,
    PERMISSIONS.EMPRESA_UPDATE,
    PERMISSIONS.EMPRESA_DELETE,
    
    // Webhooks
    PERMISSIONS.NAV_WEBHOOKS,
    PERMISSIONS.WEBHOOK_MANAGE,
    PERMISSIONS.WEBHOOK_VIEW_ALL,
    
    // Configurações
    PERMISSIONS.CONFIG_VIEW,
    PERMISSIONS.CONFIG_UPDATE,
    PERMISSIONS.NAV_AUTH_CONFIG,
    PERMISSIONS.CONFIG_SISTEMA,
  ],

  GESTOR: [
    // Dashboard
    PERMISSIONS.NAV_DASHBOARD,
    PERMISSIONS.DASHBOARD_VIEW_COMPANY,
    
    // Upload
    PERMISSIONS.NAV_UPLOAD,
    PERMISSIONS.UPLOAD_VIEW,
    PERMISSIONS.UPLOAD_CREATE,
    PERMISSIONS.UPLOAD_MANAGE,
    
    // Agente
    PERMISSIONS.AGENTE_EXECUTE,
    
    // Saudação
    PERMISSIONS.NAV_SAUDACAO,
    PERMISSIONS.SAUDACAO_VIEW,
    PERMISSIONS.SAUDACAO_CREATE,
    PERMISSIONS.SAUDACAO_UPDATE,
    PERMISSIONS.SAUDACAO_DELETE,
    PERMISSIONS.SAUDACAO_SELECT,
    
    // Usuários (limitado à própria empresa)
    PERMISSIONS.NAV_USUARIOS,
    PERMISSIONS.USUARIO_VIEW,
    PERMISSIONS.USUARIO_CREATE,
    PERMISSIONS.USUARIO_UPDATE,
    PERMISSIONS.USUARIO_DELETE,
    PERMISSIONS.USUARIO_VIEW_COMPANY,
    
    // Perfis (apenas visualização)
    PERMISSIONS.NAV_PERMISSOES,
    PERMISSIONS.PERFIL_VIEW,
    
    // Empresas (apenas visualização)
    PERMISSIONS.NAV_EMPRESAS,
    PERMISSIONS.EMPRESA_VIEW,
    
    // Webhooks (limitado à empresa)
    PERMISSIONS.NAV_WEBHOOKS,
    PERMISSIONS.WEBHOOK_MANAGE,
  ],

  USUARIO: [
    // Upload
    PERMISSIONS.NAV_UPLOAD,
    PERMISSIONS.UPLOAD_VIEW,
    PERMISSIONS.UPLOAD_CREATE,
    
    // Agente
    PERMISSIONS.AGENTE_EXECUTE,
    
    // Saudação
    PERMISSIONS.NAV_SAUDACAO,
    PERMISSIONS.SAUDACAO_VIEW,
    PERMISSIONS.SAUDACAO_CREATE,
    PERMISSIONS.SAUDACAO_UPDATE,
    PERMISSIONS.SAUDACAO_DELETE,
    PERMISSIONS.SAUDACAO_SELECT,
  ],
} as const

/**
 * Mapeamento de Permissões para Interface
 */
export const PERMISSION_LABELS = {
  // Upload
  [PERMISSIONS.UPLOAD_VIEW]: 'Visualizar Upload',
  [PERMISSIONS.UPLOAD_CREATE]: 'Fazer Upload de Arquivos',

  // Agente
  [PERMISSIONS.AGENTE_EXECUTE]: 'Iniciar Agente de Prospecção',

  // Saudação
  [PERMISSIONS.SAUDACAO_VIEW]: 'Visualizar Saudações',
  [PERMISSIONS.SAUDACAO_CREATE]: 'Criar Saudação Personalizada',
  [PERMISSIONS.SAUDACAO_UPDATE]: 'Editar Saudação',
  [PERMISSIONS.SAUDACAO_DELETE]: 'Deletar Saudação',
  [PERMISSIONS.SAUDACAO_SELECT]: 'Selecionar Saudação para Agente',

  // Usuários
  [PERMISSIONS.USUARIO_VIEW]: 'Visualizar Usuários',
  [PERMISSIONS.USUARIO_CREATE]: 'Criar Usuários',
  [PERMISSIONS.USUARIO_UPDATE]: 'Editar Usuários',
  [PERMISSIONS.USUARIO_DELETE]: 'Deletar Usuários',

  // Perfis
  [PERMISSIONS.PERFIL_VIEW]: 'Visualizar Perfis',
  [PERMISSIONS.PERFIL_CREATE]: 'Criar Perfis',
  [PERMISSIONS.PERFIL_UPDATE]: 'Editar Perfis',
  [PERMISSIONS.PERFIL_DELETE]: 'Deletar Perfis',

  // Empresas
  [PERMISSIONS.EMPRESA_VIEW]: 'Visualizar Empresas',
  [PERMISSIONS.EMPRESA_CREATE]: 'Criar Empresas',
  [PERMISSIONS.EMPRESA_UPDATE]: 'Editar Empresas',
  [PERMISSIONS.EMPRESA_DELETE]: 'Deletar Empresas',

  // Configurações
  [PERMISSIONS.CONFIG_VIEW]: 'Visualizar Configurações',
  [PERMISSIONS.CONFIG_UPDATE]: 'Editar Configurações',
} as const

/**
 * Função para verificar se usuário tem permissão
 */
export function hasPermission(userPermissions: string[], requiredPermission: string): boolean {
  return userPermissions.includes(requiredPermission)
}

/**
 * Função para verificar múltiplas permissões (AND)
 */
export function hasAllPermissions(userPermissions: string[], requiredPermissions: string[]): boolean {
  return requiredPermissions.every(permission => userPermissions.includes(permission))
}

/**
 * Função para verificar múltiplas permissões (OR)
 */
export function hasAnyPermission(userPermissions: string[], requiredPermissions: string[]): boolean {
  return requiredPermissions.some(permission => userPermissions.includes(permission))
}

/**
 * Função para obter permissões por tipo de usuário
 */
export function getPermissionsByUserType(userType: string): string[] {
  switch (userType.toLowerCase()) {
    case 'admin':
    case 'administrador':
      return [...PERMISSION_GROUPS.ADMINISTRADOR]
    case 'gestor':
      return [...PERMISSION_GROUPS.GESTOR]
    case 'usuario':
    case 'padrao':
      return [...PERMISSION_GROUPS.USUARIO]
    default:
      return [...PERMISSION_GROUPS.USUARIO]
  }
}
