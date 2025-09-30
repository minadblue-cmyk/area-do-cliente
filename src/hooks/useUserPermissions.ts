import { useState, useEffect } from 'react'
import { useAuthStore } from '../store/auth'
import { callWebhook } from '../utils/webhook-client'

interface Permission {
  id: number
  nome: string
  descricao: string
}

interface Profile {
  id: number
  nome_perfil: string
  descricao: string
  permissoes: (number | null)[]
}

interface UserPermissionsState {
  permissions: Permission[]
  userProfile: Profile | null
  userPermissions: string[]
  loading: boolean
  error: string | null
}

export function useUserPermissions() {
  const { userData } = useAuthStore()
  const [state, setState] = useState<UserPermissionsState>({
    permissions: [],
    userProfile: null,
    userPermissions: userData?.permissions || [], // Usar permissões do login
    loading: false, // Começar como false para evitar loops
    error: null
  })

  // Carregar permissões e perfil do usuário
  useEffect(() => {
    const loadUserPermissions = async () => {
      if (!userData) {
        console.log('🔍 useUserPermissions: userData não disponível')
        setState(prev => ({ ...prev, loading: false }))
        return
      }

      // Se as permissões já foram carregadas no login, não recarregar
      if (userData.permissions && userData.permissions.length > 0) {
        console.log('🔍 useUserPermissions: Permissões já carregadas no login, usando cache')
        setState(prev => ({ 
          ...prev, 
          loading: false, 
          userPermissions: userData.permissions || [] 
        }))
        return
      }

      // Carregar permissões do banco de dados para TODOS os usuários
      console.log('🔍 useUserPermissions: Carregando permissões do banco de dados...')

      try {
        console.log('🔍 useUserPermissions: Iniciando carregamento de permissões...')
        setState(prev => ({ ...prev, loading: true, error: null }))

        // Carregar lista de permissões
        console.log('🔍 useUserPermissions: Carregando permissões...')
        const { data: permissionsResponse } = await callWebhook('webhook/list-permission', {
          method: 'GET'
        })

        // Carregar lista de perfis
        console.log('🔍 useUserPermissions: Carregando perfis...')
        const { data: profilesResponse } = await callWebhook('webhook/list-profile', {
          method: 'GET'
        })

        console.log('🔍 useUserPermissions: Permissões carregadas:', permissionsResponse)
        console.log('🔍 useUserPermissions: Perfis carregados:', profilesResponse)

        // Ajustar estrutura de dados baseada na resposta real dos webhooks
        // permissionsResponse tem estrutura: { success: true, data: [...], total: 57 }
        const permissions = permissionsResponse.data || permissionsResponse || []
        // profilesResponse é um array direto: [{ id: 28, nome_perfil: "Administrador", ... }]
        const profiles = profilesResponse || []
        
        console.log('🔍 useUserPermissions: Estrutura permissionsResponse:', permissionsResponse)
        console.log('🔍 useUserPermissions: Estrutura profilesResponse:', profilesResponse)
        console.log('🔍 useUserPermissions: Permissões extraídas:', permissions.length)
        console.log('🔍 useUserPermissions: Perfis extraídos:', profiles.length)
        console.log('🔍 useUserPermissions: Primeira permissão:', permissions[0])
        console.log('🔍 useUserPermissions: Primeiro perfil:', profiles[0])

        // Encontrar o perfil do usuário atual
        // Primeiro tentar por ID, depois por nome do perfil
        let userProfile = profiles.find((profile: Profile) => profile.id === userData.perfil_id)
        
        if (!userProfile) {
          // Se não encontrou por ID, tentar por nome do perfil
          userProfile = profiles.find((profile: Profile) => 
            profile.nome_perfil === userData.perfil ||
            profile.nome_perfil === 'Administrador'
          )
        }

        console.log('🔍 useUserPermissions: Perfil do usuário encontrado:', userProfile)
        console.log('🔍 useUserPermissions: userData.perfil_id:', userData.perfil_id)
        console.log('🔍 useUserPermissions: userData.perfil:', userData.perfil)

        if (!userProfile) {
          console.warn('⚠️ useUserPermissions: Perfil do usuário não encontrado no banco de dados')
          console.log('🔍 useUserPermissions: userData.perfil_id:', userData.perfil_id)
          console.log('🔍 useUserPermissions: userData.perfil:', userData.perfil)
          console.log('🔍 useUserPermissions: Perfis disponíveis:', profiles.map((p: any) => ({ id: p.id, nome: p.nome_perfil })))
          
          // FALLBACK TEMPORÁRIO: Se for administrador, dar todas as permissões
          if (userData.perfil_id === 28 || userData.perfil === 'Administrador') {
            console.log('🔧 useUserPermissions: FALLBACK - Usuário é administrador, dando todas as permissões')
            const allPermissions = permissions.map((p: any) => p.nome).filter(Boolean)
            setState(prev => ({
              ...prev,
              permissions,
              userProfile: null,
              userPermissions: allPermissions,
              loading: false
            }))
            return
          }
          
          setState(prev => ({
            ...prev,
            permissions,
            userProfile: null,
            userPermissions: [],
            loading: false
          }))
          return
        }

        // Mapear IDs das permissões para nomes
        const userPermissionIds = userProfile.permissoes.filter((id: any) => id !== null) as number[]
        console.log('🔍 useUserPermissions: IDs das permissões do usuário:', userPermissionIds)
        console.log('🔍 useUserPermissions: Total de permissões disponíveis:', permissions.length)
        
        const userPermissionNames = userPermissionIds
          .map((id: number) => {
            const permission = permissions.find((p: any) => p.id === id)
            console.log(`🔍 useUserPermissions: Mapeando ID ${id} → ${permission?.nome || 'NÃO ENCONTRADO'}`)
            return permission?.nome
          })
          .filter(Boolean) as string[]

        console.log('🔍 useUserPermissions: Nomes das permissões do usuário:', userPermissionNames)
        console.log('🔍 useUserPermissions: Total de permissões mapeadas:', userPermissionNames.length)

        setState(prev => ({
          ...prev,
          permissions,
          userProfile,
          userPermissions: userPermissionNames,
          loading: false
        }))

        console.log('✅ useUserPermissions: Permissões carregadas com sucesso!')

      } catch (error: any) {
        console.error('❌ useUserPermissions: Erro ao carregar permissões do banco de dados:', error)
        console.log('🔍 useUserPermissions: Verificando se os webhooks estão funcionando...')
        
        // FALLBACK TEMPORÁRIO: Se for administrador e houver erro, dar todas as permissões
        if (userData.perfil_id === 28 || userData.perfil === 'Administrador') {
          console.log('🔧 useUserPermissions: FALLBACK - Erro no carregamento, dando todas as permissões para administrador')
          setState(prev => ({
            ...prev,
            loading: false,
            userPermissions: [
              'visualizar_dashboard',
              'visualizar_pgina_de_upload', 
              'visualizar_status_do_agente',
              'visualizar_saudaes',
              'visualizar_usurios',
              'visualizar_empresas',
              'visualizar_perfis',
              'configurar_webhooks',
              'configurar_parmetros_do_agente'
            ],
            error: null
          }))
        } else {
          setState(prev => ({
            ...prev,
            loading: false,
            error: error.message || 'Erro ao carregar permissões do banco de dados'
          }))
        }
      }
    }

    loadUserPermissions()
  }, [userData])

  // Função para verificar se o usuário tem uma permissão específica
  const hasPermission = (permissionName: string): boolean => {
    // Usar permissões carregadas durante o login (mais eficiente)
    if (userData?.permissions) {
      const hasAccess = userData.permissions.includes(permissionName)
      console.log(`🔍 useUserPermissions: Usuário ${userData?.perfil} - permissão "${permissionName}" = ${hasAccess} (do login)`)
      return hasAccess
    }
    
    // Fallback para permissões carregadas posteriormente
    const hasAccess = state.userPermissions.includes(permissionName)
    console.log(`🔍 useUserPermissions: Usuário ${userData?.perfil} - permissão "${permissionName}" = ${hasAccess} (do hook)`)
    return hasAccess
  }

  // Função para verificar múltiplas permissões (AND)
  const hasAllPermissions = (permissionNames: string[]): boolean => {
    return permissionNames.every(name => hasPermission(name))
  }

  // Função para verificar múltiplas permissões (OR)
  const hasAnyPermission = (permissionNames: string[]): boolean => {
    return permissionNames.some(name => hasPermission(name))
  }

  return {
    ...state,
    hasPermission,
    hasAllPermissions,
    hasAnyPermission,
    
    // Permissões específicas do sistema baseadas nos nomes reais do banco
    canViewDashboard: () => hasPermission('visualizar_dashboard'),
    canViewDashboardCompleto: () => hasPermission('visualizar_dashboard_completo'),
    canExportDashboard: () => hasPermission('exportar_dados_do_dashboard'),
    
    canViewUpload: () => hasPermission('visualizar_pgina_de_upload'),
    canCreateUpload: () => hasPermission('fazer_upload_de_arquivos'),
    canManageUpload: () => hasPermission('gerenciar_arquivos_enviados'),
    
    canViewAgent: () => hasPermission('visualizar_status_do_agente'),
    canStartAgent: () => hasPermission('iniciar_agente'),
    canStopAgent: () => hasPermission('parar_agente'),
    canPauseAgent: () => hasPermission('pausar_agente'),
    canResumeAgent: () => hasPermission('retomar_agente'),
    
    canViewSaudacao: () => hasPermission('visualizar_saudaes'),
    canCreateSaudacao: () => hasPermission('editar_saudao'),
    canUpdateSaudacao: () => hasPermission('editar_saudao'),
    canDeleteSaudacao: () => hasPermission('deletar_saudao'),
    canSelectSaudacao: () => hasPermission('selecionar_saudao_para_agente'),
    
    canViewUsuario: () => hasPermission('visualizar_usurios'),
    canCreateUsuario: () => hasPermission('criar_usurios'),
    canUpdateUsuario: () => hasPermission('editar_usurios'),
    canDeleteUsuario: () => hasPermission('deletar_usurios'),
    canViewAllUsuarios: () => hasPermission('visualizar_todos_os_usurios'),
    
    canViewPerfil: () => hasPermission('visualizar_perfis'),
    canCreatePerfil: () => hasPermission('criar_perfis'),
    canUpdatePerfil: () => hasPermission('editar_perfis'),
    canDeletePerfil: () => hasPermission('deletar_perfis'),
    
    canViewEmpresa: () => hasPermission('visualizar_empresas'),
    canCreateEmpresa: () => hasPermission('criar_empresas'),
    canUpdateEmpresa: () => hasPermission('editar_empresas'),
    canDeleteEmpresa: () => hasPermission('deletar_empresas'),
    
    canViewConfig: () => hasPermission('visualizar_configuraes'),
    canUpdateConfig: () => hasPermission('editar_configuraes'),
    canManageWebhooks: () => hasPermission('configurar_webhooks'),
    
    // Verificar se é administrador baseado nas permissões
    isAdmin: () => hasPermission('administrar_dashboard_de_outros_usurios') || 
                   hasPermission('administrar_uploads_de_outros_usurios') ||
                   hasPermission('administrar_agente_de_outros_usurios'),
  }
}
