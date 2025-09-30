import { useUserPermissions } from './useUserPermissions'
import { useAuthStore } from '../store/auth'

export interface AgentPermissions {
  canView: boolean
  canCreate: boolean
  canUpdate: boolean
  canDelete: boolean
  canExecute: boolean
  canManage: boolean
  canViewAll: boolean
  canViewOwn: boolean
  canAssignAgents: boolean // NOVA PERMISSÃO
  canAccess: boolean
}

export function useAgentPermissions(): AgentPermissions {
  const { 
    hasPermission, 
    canViewAgent, 
    canStartAgent, 
    canStopAgent,
    isAdmin,
    loading 
  } = useUserPermissions()
  
  if (loading) {
    return {
      canView: false,
      canCreate: false,
      canUpdate: false,
      canDelete: false,
      canExecute: false,
      canManage: false,
      canViewAll: false,
      canViewOwn: false,
      canAssignAgents: false,
      canAccess: false
    }
  }

  // Verificar permissões reais baseadas no perfil do usuário
  const canViewAgentStatus = canViewAgent()
  const canExecuteAgent = canStartAgent() || canStopAgent()
  const canManageAgents = isAdmin() || hasPermission('administrar_agente_de_outros_usuários')
  
  return {
    canView: canViewAgentStatus,
    canCreate: canManageAgents,
    canUpdate: canManageAgents,
    canDelete: canManageAgents,
    canExecute: canExecuteAgent,
    canManage: canManageAgents,
    canViewAll: canManageAgents,
    canViewOwn: canExecuteAgent, // Usar canExecuteAgent em vez de canViewAgentStatus
    canAssignAgents: hasPermission('atribuir_agentes_usuarios'), // NOVA PERMISSÃO
    canAccess: canViewAgentStatus || canExecuteAgent
  }
}

export function useAgentAccess(agentUserId?: number): boolean {
  const { userData } = useAuthStore()
  const permissions = useAgentPermissions()
  
  if (!userData) return false
  
  // Se pode ver todos os agentes
  if (permissions.canViewAll || permissions.canManage) {
    return true
  }
  
  // Se pode ver apenas seus próprios agentes
  if (permissions.canViewOwn) {
    return agentUserId ? agentUserId === parseInt(userData.id) : true
  }
  
  // Se não tem permissão específica, não pode acessar
  return false
}
