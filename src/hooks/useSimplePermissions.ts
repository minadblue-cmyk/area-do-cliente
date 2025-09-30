import { useAuthStore } from '../store/auth'
import { useUserPermissions } from './useUserPermissions'

/**
 * Hook simples de permissões que não bloqueia o carregamento
 * Usa permissões reais quando disponíveis, fallback para permissões básicas
 */
export function useSimplePermissions() {
  const { userData } = useAuthStore()
  const { hasPermission: hasRealPermission, loading: permissionsLoading } = useUserPermissions()
  
  // Função para verificar permissão com fallback
  const hasPermission = (permission: string): boolean => {
    if (!userData) {
      return false
    }
    
    console.log(`🔍 useSimplePermissions: Verificando permissão "${permission}" para usuário:`, userData.perfil, userData.perfil_id)
    
    // Se as permissões reais já foram carregadas, usar elas
    if (!permissionsLoading && hasRealPermission) {
      const realPermission = hasRealPermission(permission)
      console.log(`🔍 useSimplePermissions: Usando permissão real - "${permission}" = ${realPermission}`)
      return realPermission
    }
    
    // Fallback: usar permissões básicas baseadas no perfil
    console.log(`🔍 useSimplePermissions: Usando fallback - permissões ainda carregando`)
    
    // Se é admin, tem todas as permissões
    if (userData.perfil === 'Administrador' || userData.perfil === 'administrador' || userData.perfil_id === 1) {
      console.log(`✅ useSimplePermissions: Admin - acesso liberado para "${permission}"`)
      return true
    }
    
    // Permissões básicas para todos os usuários (apenas visualização básica)
    const basicPermissions = [
      'dashboard_view',
      'upload_view',
      'agente_view',
      'saudacao_view',
      'agente_start',
      'agente_stop'
    ]
    
    if (basicPermissions.includes(permission)) {
      console.log(`✅ useSimplePermissions: Permissão básica - acesso liberado para "${permission}"`)
      return true
    }
    
    // Permissões de gestor (apenas se for realmente gestor)
    if (userData.perfil === 'Gestor' || userData.perfil === 'gestor' || userData.perfil_id === 27) {
      const gestorPermissions = [
        'usuario_view',
        'usuario_create',
        'usuario_update',
        'empresa_view',
        'empresa_create',
        'empresa_update',
        'perfil_view',
        'perfil_create',
        'perfil_update',
        'perfil_delete'
      ]
      const hasAccess = gestorPermissions.includes(permission)
      console.log(`🔍 useSimplePermissions: Gestor - "${permission}" = ${hasAccess}`)
      return hasAccess
    }
    
    // Permissões de supervisor (apenas se for realmente supervisor)
    if (userData.perfil === 'Supervisor' || userData.perfil === 'supervisor' || userData.perfil_id === 35) {
      const supervisorPermissions = [
        'usuario_view',
        'empresa_view',
        'perfil_view',
        'usuario_manage'
      ]
      const hasAccess = supervisorPermissions.includes(permission)
      console.log(`🔍 useSimplePermissions: Supervisor - "${permission}" = ${hasAccess}`)
      return hasAccess
    }
    
    // Para usuários básicos, apenas permissões essenciais
    if (userData.perfil === 'Usuario Basico' || userData.perfil === 'usuario_basico' || userData.perfil_id === 33) {
      const basicUserPermissions = [
        'dashboard_view',
        'upload_view',
        'agente_view'
      ]
      const hasAccess = basicUserPermissions.includes(permission)
      console.log(`🔍 useSimplePermissions: Usuário Básico - "${permission}" = ${hasAccess}`)
      return hasAccess
    }
    
    // Perfil específico "User Elleve Consorsios 1 - Atualizado" (ID 32) - permissões limitadas
    if (userData.perfil === 'User Elleve Consorsios 1 - Atualizado' || userData.perfil_id === 32) {
      const limitedPermissions = [
        'saudacao_view',
        'saudacao_update',
        'saudacao_delete',
        'upload_create',
        'upload_view',
        'upload_logs',
        'agente_view',
        'agente_stop',
        'agente_resume',
        'agente_execute',
        'agente_pause',
        'saudacao_select',
        'agente_start'
      ]
      const hasAccess = limitedPermissions.includes(permission)
      console.log(`🔍 useSimplePermissions: User Elleve Consorsios - "${permission}" = ${hasAccess}`)
      return hasAccess
    }
    
    // Para outros perfis, ser mais restritivo
    console.log(`❌ useSimplePermissions: Acesso negado para "${permission}" - perfil: ${userData.perfil} (ID: ${userData.perfil_id})`)
    return false
  }
  
  const isAdmin = () => {
    return userData?.perfil === 'Administrador' || userData?.perfil === 'administrador' || userData?.perfil_id === 1
  }
  
  return {
    hasPermission,
    isAdmin,
    loading: permissionsLoading,
    error: null
  }
}
