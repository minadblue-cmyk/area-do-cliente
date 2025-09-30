import { create } from 'zustand'
import { secureStorage } from '../utils/storage'
import { callWebhook } from '../utils/webhook-client'
import type { LoginRequest } from '../lib/types'
import { z } from 'zod'

const AUTH_TOKEN_KEY = 'area:jwt'
const AUTH_USER_KEY = 'area:user'
const AUTH_USER_DATA_KEY = 'area:user_data'

const loginResponseSchema = z.object({ 
  token: z.string().min(1), 
  nome: z.string().min(1),
  usuario_id: z.string().optional(),
  email: z.string().optional(),
  perfil: z.string().optional(),
  perfil_id: z.union([z.string(), z.number()]).optional(),
  plano: z.string().optional(),
  empresa_id: z.union([z.string(), z.number()]).optional()
})

interface UserData {
  id: string
  name: string
  mail: string
  perfil?: string
  perfil_id?: number
  plano?: string
  permissions?: string[]
  empresa_id?: number
}

interface AuthState {
  token: string | null
  userName: string | null
  userData: UserData | null
  loading: boolean
  error: string | null
  login: (payload: LoginRequest) => Promise<boolean>
  logout: () => void
  hydrate: () => Promise<void>
}

export const useAuthStore = create<AuthState>((set) => ({
  token: null,
  userName: null,
  userData: null,
  loading: false,
  error: null,
  async login(payload) {
    set({ loading: true, error: null })
    try {
      console.log('🔐 Iniciando login com payload:', payload)
      console.log('🔗 Chamando webhook-login...')
      
      const { data } = await callWebhook('webhook-login', { method: 'POST', data: payload })
      console.log('✅ Resposta do webhook-login:', data)
      
      const parsed = loginResponseSchema.parse(data)
      
      // VALIDAÇÃO: Verificar se empresa_id existe (apenas warning, não bloqueia login)
      if (!parsed.empresa_id) {
        console.warn('⚠️ AVISO: empresa_id não encontrado na resposta do n8n')
        console.warn('Resposta completa:', data)
        console.warn('Usuário poderá fazer login, mas operações de agentes serão bloqueadas')
      }
      
      const userData: UserData = {
        id: parsed.usuario_id || 'unknown',
        name: parsed.nome,
        mail: parsed.email || payload.email,
        perfil: parsed.perfil,
        perfil_id: typeof parsed.perfil_id === 'string' ? parseInt(parsed.perfil_id) : parsed.perfil_id,
        plano: parsed.plano,
        empresa_id: typeof parsed.empresa_id === 'string' ? parseInt(parsed.empresa_id) : parsed.empresa_id
      }
      
      console.log('🔍 Login: userData criado:', userData)
      console.log('🔍 Login: perfil retornado do backend:', parsed.perfil)
      console.log('🔍 Login: perfil_id retornado do backend:', parsed.perfil_id)
      console.log('🔍 Login: parsed completo:', parsed)
      
      // Armazenar dados básicos do usuário primeiro
      await secureStorage.set(AUTH_TOKEN_KEY, parsed.token)
      await secureStorage.set(AUTH_USER_KEY, parsed.nome)
      await secureStorage.set(AUTH_USER_DATA_KEY, JSON.stringify(userData))
      
      set({ 
        token: parsed.token, 
        userName: parsed.nome, 
        userData,
        loading: false 
      })
      
      // Carregar permissões em background (não bloquear o login)
      console.log('🔑 Carregando permissões em background...')
      
      try {
        // Carregar lista de permissões
        const { data: permissionsResponse } = await callWebhook('webhook/list-permission', {
          method: 'GET'
        })
        
        // Carregar lista de perfis
        const { data: profilesResponse } = await callWebhook('webhook/list-profile', {
          method: 'GET'
        })
        
        const permissions = permissionsResponse.data || permissionsResponse || []
        const profiles = profilesResponse || []
        
        // Encontrar o perfil do usuário atual
        const userProfile = profiles.find((profile: any) => 
          profile.id === userData.perfil_id || 
          profile.nome_perfil === userData.perfil
        )
        
        console.log('🔍 Login: Perfil do usuário encontrado:', userProfile)
        console.log('🔍 Login: Permissões disponíveis:', permissions.length)
        
        let userPermissions: string[] = []
        
        if (userProfile) {
          // Mapear IDs das permissões para nomes
          const userPermissionIds = userProfile.permissoes.filter((id: any) => id !== null) as number[]
          userPermissions = userPermissionIds
            .map((id: number) => permissions.find((p: any) => p.id === id)?.nome)
            .filter(Boolean) as string[]
          
          console.log('🔍 Login: IDs das permissões do usuário:', userPermissionIds)
          console.log('🔍 Login: Nomes das permissões do usuário:', userPermissions)
          
          // Atualizar dados do usuário com permissões
          const userDataWithPermissions = {
            ...userData,
            permissions: userPermissions
          }
          
          await secureStorage.set(AUTH_USER_DATA_KEY, JSON.stringify(userDataWithPermissions))
          
          set({ 
            userData: userDataWithPermissions
          })
          
          console.log('✅ Login: Permissões carregadas com sucesso!')
        } else {
          console.warn('⚠️ Login: Perfil do usuário não encontrado no banco de dados')
        }
        
      } catch (permissionError) {
        console.error('❌ Login: Erro ao carregar permissões:', permissionError)
        console.log('⚠️ Login: Continuando sem permissões devido a erro')
      }
      
      return true
    } catch (e: any) {
      console.error('❌ Erro no login:', e)
      set({ error: 'Falha no login. Verifique suas credenciais.', loading: false })
      return false
    }
  },
  logout() {
    secureStorage.remove(AUTH_TOKEN_KEY)
    secureStorage.remove(AUTH_USER_KEY)
    secureStorage.remove(AUTH_USER_DATA_KEY)
    set({ token: null, userName: null, userData: null })
  },
  async hydrate() {
    const token = await secureStorage.get<string>(AUTH_TOKEN_KEY)
    const userName = await secureStorage.get<string>(AUTH_USER_KEY)
    const userDataStr = await secureStorage.get<string>(AUTH_USER_DATA_KEY)
    
    let userData: UserData | null = null
    if (userDataStr) {
      try {
        userData = JSON.parse(userDataStr)
      } catch {
        // Ignora erro de parsing
      }
    }
    
    if (token) set({ token })
    if (userName) set({ userName })
    if (userData) set({ userData })
  }
}))

// Hidrata imediatamente
void useAuthStore.getState().hydrate()
