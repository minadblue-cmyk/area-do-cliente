import { useUserPermissions } from './useUserPermissions'

/**
 * Hook para gerenciar permissões do usuário (compatibilidade com código existente)
 */
export function usePermissions() {
  const userPermissions = useUserPermissions()

  return {
    // Permissões do usuário
    permissions: userPermissions.userPermissions,
    
    // Verificar permissão específica
    can: (permission: string) => userPermissions.hasPermission(permission),
    
    // Verificar múltiplas permissões (AND)
    canAll: (permissions: string[]) => userPermissions.hasAllPermissions(permissions),
    
    // Verificar múltiplas permissões (OR)
    canAny: (permissions: string[]) => userPermissions.hasAnyPermission(permissions),
    
    // Permissões específicas do sistema
    canViewUpload: () => userPermissions.canViewUpload(),
    canCreateUpload: () => userPermissions.canCreateUpload(),
    
    canExecuteAgent: () => userPermissions.canStartAgent() || userPermissions.canStopAgent(),
    
    canViewSaudacao: () => userPermissions.canViewSaudacao(),
    canCreateSaudacao: () => userPermissions.canCreateSaudacao(),
    canUpdateSaudacao: () => userPermissions.canUpdateSaudacao(),
    canDeleteSaudacao: () => userPermissions.canDeleteSaudacao(),
    canSelectSaudacao: () => userPermissions.canSelectSaudacao(),
    
    canViewUsuario: () => userPermissions.canViewUsuario(),
    canCreateUsuario: () => userPermissions.canCreateUsuario(),
    canUpdateUsuario: () => userPermissions.canUpdateUsuario(),
    canDeleteUsuario: () => userPermissions.canDeleteUsuario(),
    
    canViewPerfil: () => userPermissions.canViewPerfil(),
    canCreatePerfil: () => userPermissions.canCreatePerfil(),
    canUpdatePerfil: () => userPermissions.canUpdatePerfil(),
    canDeletePerfil: () => userPermissions.canDeletePerfil(),
    
    canViewEmpresa: () => userPermissions.canViewEmpresa(),
    canCreateEmpresa: () => userPermissions.canCreateEmpresa(),
    canUpdateEmpresa: () => userPermissions.canUpdateEmpresa(),
    canDeleteEmpresa: () => userPermissions.canDeleteEmpresa(),
    
    canViewConfig: () => userPermissions.canViewConfig(),
    canUpdateConfig: () => userPermissions.canUpdateConfig(),
    
    // Verificar se é administrador
    isAdmin: () => userPermissions.isAdmin(),
    
    // Verificar se é gestor (baseado em permissões específicas)
    isGestor: () => userPermissions.hasPermission('gerenciar_usuários') && !userPermissions.isAdmin(),
    
    // Verificar se é usuário comum
    isUsuario: () => !userPermissions.isAdmin() && !userPermissions.hasPermission('gerenciar_usuários'),
    
    // Estado de carregamento
    loading: userPermissions.loading,
    error: userPermissions.error
  }
}
