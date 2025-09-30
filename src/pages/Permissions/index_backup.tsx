import React, { useState, useEffect } from 'react'
import { callWebhook } from '../../utils/webhook-client'
import { useToastStore } from '../../store/toast'
import { Plus, Edit, Save, X, AlertCircle, ChevronDown, ChevronRight, Trash2 } from 'lucide-react'

interface PermissionItem {
  id: number
  nome: string
  descricao: string
}

interface ProfileItem {
  id: number
  nome_perfil: string
  descricao?: string
  permissoes?: string[] // Mudado de PermissionItem[] para string[]
  created_at?: string
  updated_at?: string
}

interface CreateProfileData {
  nome_perfil: string
  descricao: string
  permissoes: string[]
}

export default function Permissions() {
  const push = useToastStore((s) => s.push)
  
  const [profiles, setProfiles] = useState<ProfileItem[]>([])
  const [loading, setLoading] = useState(false)
  const [showCreateForm, setShowCreateForm] = useState(false)
  const [showEditForm, setShowEditForm] = useState(false)
  const [editingProfile, setEditingProfile] = useState<ProfileItem | null>(null)
  const [expandedProfiles, setExpandedProfiles] = useState<Set<number>>(new Set())
  const [searchTerm, setSearchTerm] = useState('')
  
  const [formData, setFormData] = useState<CreateProfileData>({
    nome_perfil: '',
    descricao: '',
    permissoes: []
  })

  // Estado para armazenar as permissões carregadas do webhook
  const [availablePermissions, setAvailablePermissions] = useState<PermissionItem[]>([])
  const [permissionsLoading, setPermissionsLoading] = useState(false)

  useEffect(() => {
    loadPermissions()
    loadProfiles()
  }, [])

  // Carregar permissões do webhook
  async function loadPermissions() {
    try {
      setPermissionsLoading(true)
      
      const { data: response } = await callWebhook('webhook/list-permission', {})
      
      if (Array.isArray(response) && response.length > 0) {
        const permissions = response.map((perm: any) => ({
          id: parseInt(perm.id),
          nome: perm.nome,
          descricao: perm.descricao
        }))
        
        setAvailablePermissions(permissions)
      } else {
        // Fallback para permissões básicas se o webhook falhar
        const fallbackPermissions = [
          { id: 53, nome: 'agente_execute', descricao: 'Iniciar agente de prospecção' },
          { id: 54, nome: 'saudacao_view', descricao: 'Visualizar saudações' },
          { id: 55, nome: 'saudacao_update', descricao: 'Editar saudação' },
          { id: 56, nome: 'saudacao_delete', descricao: 'Deletar saudação' },
          { id: 57, nome: 'saudacao_select', descricao: 'Selecionar saudação para agente' },
          { id: 58, nome: 'empresa_view', descricao: 'Visualizar empresas' },
          { id: 59, nome: 'empresa_create', descricao: 'Criar empresas' },
          { id: 60, nome: 'empresa_update', descricao: 'Editar empresas' },
          { id: 61, nome: 'empresa_delete', descricao: 'Deletar empresas' },
          { id: 62, nome: 'nav_empresas', descricao: 'Acesso ao gerenciamento de empresas' }
        ]
        setAvailablePermissions(fallbackPermissions)
      }
    } catch (error) {
      console.error('❌ Erro ao carregar permissões:', error)
      push({ 
        kind: 'error', 
        message: 'Erro ao carregar permissões. Usando permissões padrão.' 
      })
      // Fallback para permissões básicas
      const fallbackPermissions = [
        { id: 53, nome: 'agente_execute', descricao: 'Iniciar agente de prospecção' },
        { id: 54, nome: 'saudacao_view', descricao: 'Visualizar saudações' },
        { id: 55, nome: 'saudacao_update', descricao: 'Editar saudação' },
        { id: 56, nome: 'saudacao_delete', descricao: 'Deletar saudação' },
        { id: 57, nome: 'saudacao_select', descricao: 'Selecionar saudação para agente' },
        { id: 58, nome: 'empresa_view', descricao: 'Visualizar empresas' },
        { id: 59, nome: 'empresa_create', descricao: 'Criar empresas' },
        { id: 60, nome: 'empresa_update', descricao: 'Editar empresas' },
        { id: 61, nome: 'empresa_delete', descricao: 'Deletar empresas' },
        { id: 62, nome: 'nav_empresas', descricao: 'Acesso ao gerenciamento de empresas' }
      ]
      setAvailablePermissions(fallbackPermissions)
    } finally {
      setPermissionsLoading(false)
    }
  }

  // Scroll automático para o formulário quando abrir edição ou criação
  useEffect(() => {
    if (showEditForm || showCreateForm) {
      // Aguardar um pouco para o DOM ser atualizado
      setTimeout(() => {
        const editForm = document.querySelector('[data-edit-form]')
        const createForm = document.querySelector('[data-create-form]')
        const targetForm = editForm || createForm
        
        if (targetForm) {
          targetForm.scrollIntoView({ 
            behavior: 'smooth', 
            block: 'start',
            inline: 'nearest'
          })
        }
      }, 100)
    }
  }, [showEditForm, showCreateForm])

  async function loadProfiles() {
    try {
      setLoading(true)
      console.log('Carregando perfis...')
      
      const { data: response } = await callWebhook('webhook/list-profile', {})
      console.log('✅ Resposta BRUTA do webhook/list-profile:', response) // <--- NOVO LOG AQUI!
      console.log('✅ Tipo da resposta BRUTA:', typeof response, 'É array?', Array.isArray(response))
      console.log('Resposta do webhook/list-profile:', response)
      console.log('Tipo da resposta:', typeof response)
      console.log('É array?', Array.isArray(response))
      if (Array.isArray(response)) {
        console.log('Quantidade de perfis retornados:', response.length)
        console.log('IDs dos perfis:', response.map(p => p.id))
        console.log('Nomes dos perfis:', response.map(p => p.nome_perfil))
      }
      
      // Verificar se a resposta é HTML (erro 404 do n8n)
      if (typeof response === 'string' && response.includes('<!DOCTYPE html>')) {
        throw new Error('Webhook retornou HTML (404) - endpoint não existe no n8n')
      }
      
      // Processar a resposta do n8n: formato específico do n8n
      let profilesList: ProfileItem[] = []
      
      console.log('🔍 VERIFICANDO FORMATO DA RESPOSTA:')
      console.log('🔍 response:', response)
      console.log('🔍 Array.isArray(response):', Array.isArray(response))
      console.log('🔍 response.length:', response?.length)
      console.log('🔍 response[0]:', response?.[0])
      console.log('🔍 response[0]?.result:', response?.[0]?.result)
      console.log('🔍 response[0]?.result[0]:', response?.[0]?.result?.[0])
      console.log('🔍 response[0]?.result[0]?.profiles:', response?.[0]?.result?.[0]?.profiles)
      
      // CORREÇÃO: Verificar se response[0] existe e tem result[0].profiles
      if (Array.isArray(response) && response.length > 0 && response[0] && response[0].result && response[0].result[0] && response[0].result[0].profiles) {
        // Formato do n8n: [{ result: [{ profiles: [...] }] }]
        console.log('🔍 Formato n8n detectado! (result.profiles)')
        console.log('🔍 response[0]:', response[0])
        console.log('🔍 response[0].result:', response[0].result)
        console.log('🔍 response[0].result[0]:', response[0].result[0])
        console.log('🔍 response[0].result[0].profiles:', response[0].result[0].profiles)
        
        const profiles = response[0].result[0].profiles
        profilesList = profiles.map((profile: any) => {
          console.log(`🔍 Processando perfil: ${profile.nome_perfil}`)
          console.log(`🔍 Profile completo:`, profile)
          console.log(`🔍 Permissões originais:`, profile.permissions)
          console.log(`🔍 Quantidade:`, profile.permissions?.length || 0)
          
          return {
            id: parseInt(profile.id),
            nome_perfil: profile.nome_perfil,
            descricao: profile.description, // n8n usa 'description', frontend espera 'descricao'
            permissoes: profile.permissions || [] // n8n usa 'permissions', frontend espera 'permissoes'
          }
        })
        } else if (Array.isArray(response) && response.length === 1 && Array.isArray(response[0]) && response[0].length > 0 && response[0][0] && typeof response[0][0] === 'object' && Object.keys(response[0][0]).length > 0) {
          // Formato do n8n: [[{profiles: [...]}]]
          console.log('🔍 Formato n8n detectado! (Array com profiles)')
          console.log('🔍 response:', response)
          console.log('🔍 response[0]:', response[0])
          console.log('🔍 response[0][0]:', response[0][0])
          console.log('🔍 response[0][0].profiles:', response[0][0].profiles)
          
          // Verificar se tem a propriedade 'profiles'
          if (response[0][0].profiles && Array.isArray(response[0][0].profiles)) {
            console.log('🔍 Acessando profiles dentro do objeto!')
            const profiles = response[0][0].profiles
            profilesList = profiles.map((profile: any) => {
              console.log(`🔍 Processando perfil: ${profile.nome_perfil}`)
              console.log(`🔍 Profile completo:`, profile)
              console.log(`🔍 Permissões originais:`, profile.permissions)
              console.log(`🔍 Quantidade:`, profile.permissions?.length || 0)
              
              return {
                id: parseInt(profile.id),
                nome_perfil: profile.nome_perfil,
                descricao: profile.description, // n8n usa 'description'
                permissoes: profile.permissions || [] // n8n usa 'permissions'
              }
            })
          } else {
            // Fallback: tratar como array direto de perfis
            console.log('🔍 Tratando como array direto de perfis')
            const profiles = response[0]
            profilesList = profiles.map((profile: any) => {
              console.log(`🔍 Processando perfil: ${profile.nome_perfil}`)
              console.log(`🔍 Profile completo:`, profile)
              console.log(`🔍 Permissões originais:`, profile.permissoes)
              console.log(`🔍 Quantidade:`, profile.permissoes?.length || 0)
              
              return {
                id: parseInt(profile.id),
                nome_perfil: profile.nome_perfil,
                descricao: profile.descricao,
                permissoes: profile.permissoes || []
              }
            })
          }
      } else if (Array.isArray(response) && response.length === 4 && typeof response[0] === 'number' && typeof response[1] === 'string') {
        // Formato do n8n: [24, 'Somente Visualização', 'Acesso apenas para visualizar dados', Array(4)]
        console.log('🔍 Formato n8n detectado! (Array simples)')
        console.log('🔍 response:', response)
        
        const profile = {
          id: response[0],
          nome_perfil: response[1],
          descricao: response[2],
          permissoes: response[3] || []
        }
        
        console.log('🔍 Profile processado:', profile)
        console.log('🔍 Permissões:', profile.permissoes)
        console.log('🔍 Quantidade:', profile.permissoes?.length || 0)
        
        profilesList = [profile]
      } else if (Array.isArray(response) && response.length > 0 && response[0] && response[0].result && response[0].result[0] && response[0].result[0].profiles) {
        // Formato do n8n: [{ result: [{ profiles: [...] }] }]
        console.log('🔍 Formato n8n detectado!')
        console.log('🔍 response[0]:', response[0])
        console.log('🔍 response[0].result:', response[0].result)
        console.log('🔍 response[0].result[0]:', response[0].result[0])
        console.log('🔍 response[0].result[0].profiles:', response[0].result[0].profiles)
        
        const profiles = response[0].result[0].profiles
        profilesList = profiles.map((profile: any) => {
          console.log(`🔍 Processando perfil: ${profile.nome_perfil}`)
          console.log(`🔍 Profile completo:`, profile)
          console.log(`🔍 Permissões originais:`, profile.permissions)
          console.log(`🔍 Quantidade:`, profile.permissions?.length || 0)
          
          return {
            id: parseInt(profile.id),
            nome_perfil: profile.nome_perfil,
            descricao: profile.description, // n8n usa 'description', frontend espera 'descricao'
            permissoes: profile.permissions || [] // n8n usa 'permissions', frontend espera 'permissoes'
          }
        })
      } else if (Array.isArray(response)) {
        // Resposta direta: [{ id: 1, nome_perfil: "administrador", ... }, ...]
        console.log('🔍 Formato array direto detectado!')
        console.log('🔍 response[0] vazio detectado, usando dados de exemplo')
        
        // Se response[0] está vazio, usar dados de exemplo
        if (!response[0] || Object.keys(response[0]).length === 0 || (Array.isArray(response[0]) && response[0].length > 0 && Object.keys(response[0][0]).length === 0)) {
          console.log('🔍 Usando dados de exemplo devido a response vazio')
          profilesList = [
            {
              id: 1,
              nome_perfil: 'administrador',
              descricao: 'Acesso total ao sistema.',
              permissoes: ['dashboard_view', 'usuarios_view', 'empresas_view', 'perfil_view', 'config_view']
            },
            {
              id: 2,
              nome_perfil: 'gestor_empresa',
              descricao: 'Acesso para gerenciar usuários e configurações da sua própria empresa.',
              permissoes: ['dashboard_view', 'usuarios_view', 'empresas_view']
            },
            {
              id: 3,
              nome_perfil: 'usuario_comum',
              descricao: 'Acesso restrito a dados pessoais.',
              permissoes: ['dashboard_view']
            }
          ]
        } else {
          profilesList = response.map(profile => ({
            ...profile,
            permissoes: profile.permissoes || []
          }))
        }
      } else if (response && typeof response === 'object' && Array.isArray(response.profiles)) {
        // Resposta como objeto: { profiles: [...] }
        console.log('🔍 Formato objeto com profiles detectado!')
        profilesList = response.profiles.map((profile: any) => ({
          ...profile,
          permissoes: profile.permissoes || []
        }))
      } else {
        console.log('🔍 FORMATO NÃO RECONHECIDO!')
        console.log('🔍 Tipo da resposta:', typeof response)
        console.log('🔍 Resposta completa:', response)
      }
      
      console.log('Perfis processados do banco:', profilesList)
      console.log('Quantidade de perfis processados:', profilesList.length)
      console.log('IDs dos perfis processados:', profilesList.map(p => p.id))
      console.log('Nomes dos perfis processados:', profilesList.map(p => p.nome_perfil))
      
      // Log das permissões de cada perfil
      profilesList.forEach(profile => {
        console.log(`Perfil ${profile.nome_perfil} (ID: ${profile.id}):`, {
          permissoes: profile.permissoes,
          quantidade: profile.permissoes?.length || 0
        })
      })
      
      console.log('🔍 PROFILES FINAIS ANTES DE SALVAR NO ESTADO:')
      console.log('🔍 profilesList:', profilesList)
      console.log('🔍 profilesList[0]:', profilesList[0])
      console.log('🔍 profilesList[0].permissoes:', profilesList[0]?.permissoes)
      
      setProfiles(profilesList)
      
    } catch (error: any) {
      console.error('Erro ao carregar perfis:', error)
      
      // Verificar tipo de erro
      if (error.message?.includes('HTML') || error.message?.includes('404')) {
        push({ 
          kind: 'warning', 
          message: 'Webhook de perfis não encontrado (404). Usando dados de exemplo.' 
        })
      } else {
        push({ 
          kind: 'error', 
          message: `Erro ao carregar perfis: ${error.message || 'Erro desconhecido'}` 
        })
      }
      
      // Dados de exemplo com IDs reais do banco (conforme imagem)
      const mockProfiles: ProfileItem[] = [
        {
          id: 1,
          nome_perfil: 'administrador',
          descricao: 'Acesso total ao sistema.',
          permissoes: availablePermissions.map(p => p.nome) // Nomes das permissões
        },
        {
          id: 2,
          nome_perfil: 'gestor_empresa',
          descricao: 'Acesso para gerenciar usuários e configurações da sua própria empresa.',
          permissoes: availablePermissions.slice(0, 12).map(p => p.nome) // Nomes das permissões
        },
        {
          id: 3,
          nome_perfil: 'supervisor',
          descricao: 'Acesso limitado para visualização e edição.',
          permissoes: availablePermissions.slice(0, 8).map(p => p.nome) // Nomes das permissões
        },
        {
          id: 4,
          nome_perfil: 'usuario_comum',
          descricao: 'Acesso restrito a dados pessoais.',
          permissoes: availablePermissions.slice(0, 3).map(p => p.nome) // Nomes das permissões
        },
        {
          id: 12, // ID real do banco conforme imagem
          nome_perfil: 'Teste',
          descricao: 'Teste',
          permissoes: availablePermissions.slice(0, 5).map(p => p.nome) // Nomes das permissões
        }
      ]
      
      setProfiles(mockProfiles)
      push({ kind: 'info', message: 'Exibindo perfis de exemplo para demonstração.' })
    } finally {
      setLoading(false)
    }
  }

  async function createProfile(e: React.FormEvent) {
    e.preventDefault()
    
    // Verificar se está editando ou criando (fora do try para estar disponível no catch)
    const isEditing = editingProfile !== null
    const webhookEndpoint = isEditing ? 'webhook/edit-profile' : 'webhook/create-profile'
    const actionText = isEditing ? 'Editando' : 'Criando'
    
    try {
      setLoading(true)
      
      console.log(`${actionText} perfil:`, formData)
      
      // Converter IDs das permissões para números inteiros para enviar ao n8n
      const permissoesIds = formData.permissoes.map(id => {
        const permissionId = parseInt(id)
        console.log(`🔍 Convertendo string ${id} -> número ${permissionId}`)
        return permissionId
      }).filter(id => !isNaN(id)) // Remove IDs inválidos
      
      console.log('🔍 Permissões convertidas para IDs numéricos:', permissoesIds)
      
      // Preparar payload com os campos esperados pelo backend
      const payload: any = {
        name: formData.nome_perfil,
        description: formData.descricao,
        permissoes: permissoesIds
      }
      
      // Se estiver editando, adicionar o ID do perfil
      if (isEditing && editingProfile) {
        payload.id = editingProfile.id
      }
      
      console.log('Payload enviado:', payload)
      
      const response = await callWebhook(webhookEndpoint, { 
        method: 'POST', 
        data: payload 
      })
      console.log(`Resposta do ${webhookEndpoint}:`, response)
      
      // Verificar se a resposta é HTML (erro 404 do n8n)
      if (typeof response.data === 'string' && response.data.includes('<!DOCTYPE html>')) {
        console.warn('Webhook retornou HTML em vez de JSON - webhook pode não existir')
        push({ 
          kind: 'warning', 
          message: `Webhook de ${isEditing ? 'edição' : 'criação'} de perfil não está disponível. Verifique a configuração do n8n.` 
        })
        return
      }
      
      const result = response.data
      console.log('🔍 Resultado completo:', result)
      console.log('🔍 Tipo do resultado:', typeof result)
      console.log('🔍 É array?', Array.isArray(result))
      
      // Verificar se é array com sucesso
      let success = false
      if (Array.isArray(result) && result.length > 0 && result[0] && result[0].success) {
        success = true
        console.log('🔍 Sucesso detectado no array!')
      } else if (result && result.success) {
        success = true
        console.log('🔍 Sucesso detectado no objeto!')
      }
      
      if (success) {
        const successMessage = isEditing ? 'Perfil editado com sucesso!' : 'Perfil criado com sucesso!'
        push({ kind: 'success', message: successMessage })
        setFormData({ nome_perfil: '', descricao: '', permissoes: [] })
        setShowCreateForm(false)
        setShowEditForm(false)
        setEditingProfile(null)
        loadProfiles()
      } else {
        const errorMessage = isEditing ? 'Erro ao editar perfil.' : 'Erro ao criar perfil.'
        push({ kind: 'error', message: errorMessage })
      }
    } catch (error) {
      console.error('Erro ao processar perfil:', error)
      const errorMessage = isEditing ? 'Erro ao editar perfil.' : 'Erro ao criar perfil.'
      push({ kind: 'error', message: errorMessage })
    } finally {
      setLoading(false)
    }
  }

  function togglePermission(permissionId: string) {
    setFormData(prev => {
      const newPermissoes = prev.permissoes.includes(permissionId)
        ? prev.permissoes.filter(p => p !== permissionId)
        : [...prev.permissoes, permissionId]
      
      return {
        ...prev,
        permissoes: newPermissoes
      }
    })
  }

  function toggleCategoryPermissions(permissions: PermissionItem[], selectAll: boolean) {
    const permissionIds = permissions.map(p => p.id.toString())
    
    setFormData(prev => {
      let newPermissoes = [...prev.permissoes]
      
      if (selectAll) {
        // Adicionar todas as permissões da categoria que não estão selecionadas
        permissionIds.forEach(id => {
          if (!newPermissoes.includes(id)) {
            newPermissoes.push(id)
          }
        })
      } else {
        // Remover todas as permissões da categoria
        newPermissoes = newPermissoes.filter(id => !permissionIds.includes(id))
      }
      
      return {
        ...prev,
        permissoes: newPermissoes
      }
    })
  }


  // Organizar permissões por categoria
  function getPermissionCategories() {
    const categories: Record<string, PermissionItem[]> = {
      'Navegação': [],
      'Dashboard': [],
      'Upload': [],
      'Agente': [],
      'Saudações': [],
      'Empresas': [],
      'Usuários': [],
      'Perfis': [],
      'Configurações': [],
      'Webhooks': []
    }

    availablePermissions.forEach(permission => {
      const nome = permission.nome.toLowerCase()
      
      if (nome.includes('nav_')) {
        categories['Navegação'].push(permission)
      } else if (nome.includes('dashboard')) {
        categories['Dashboard'].push(permission)
      } else if (nome.includes('upload')) {
        categories['Upload'].push(permission)
      } else if (nome.includes('agente')) {
        categories['Agente'].push(permission)
      } else if (nome.includes('saudacao')) {
        categories['Saudações'].push(permission)
      } else if (nome.includes('empresa')) {
        categories['Empresas'].push(permission)
      } else if (nome.includes('usuario')) {
        categories['Usuários'].push(permission)
      } else if (nome.includes('perfil')) {
        categories['Perfis'].push(permission)
      } else if (nome.includes('config')) {
        categories['Configurações'].push(permission)
      } else if (nome.includes('webhook')) {
        categories['Webhooks'].push(permission)
      }
    })

    // Retornar apenas categorias que têm permissões
    return Object.entries(categories)
      .filter(([_, permissions]) => permissions.length > 0)
      .map(([name, permissions]) => ({
        name,
        permissions: permissions.sort((a, b) => a.descricao.localeCompare(b.descricao))
      }))
  }

  function toggleProfileExpansion(profileId: number) {
    setExpandedProfiles(prev => {
      const newSet = new Set(prev)
      if (newSet.has(profileId)) {
        newSet.delete(profileId)
      } else {
        newSet.add(profileId)
      }
      return newSet
    })
  }

  function editProfile(profile: ProfileItem) {
    // Mapear nomes das permissões para IDs
    const permissoesIds = (profile.permissoes || []).map(permissionName => {
      const permission = availablePermissions.find(p => p.nome === permissionName)
      return permission ? permission.id.toString() : null
    }).filter((id): id is string => id !== null) // Remove nulls
    
    setEditingProfile(profile)
    setFormData({
      nome_perfil: profile.nome_perfil,
      descricao: profile.descricao || '',
      permissoes: permissoesIds
    })
    setShowEditForm(true)
  }

  function cancelEdit() {
    setEditingProfile(null)
    setShowEditForm(false)
    setFormData({ nome_perfil: '', descricao: '', permissoes: [] })
  }

  async function deleteProfile(profile: ProfileItem) {
    if (!confirm(`Tem certeza que deseja deletar o perfil "${profile.nome_perfil}"? Esta ação não pode ser desfeita.`)) {
      return
    }

    try {
      setLoading(true)
      console.log('Deletando perfil:', profile.id)
      
      await callWebhook('webhook/delete-profile', {
        method: 'POST',
        data: { profileId: profile.id }
      })
      
      push({ kind: 'success', message: 'Perfil deletado com sucesso!' })
      
      // Recarregar lista de perfis
      await loadProfiles()
    } catch (error) {
      console.error('Erro ao deletar perfil:', error)
      push({ kind: 'error', message: 'Erro ao deletar perfil.' })
    } finally {
      setLoading(false)
    }
  }

  // Filtrar perfis baseado na busca
  const filteredProfiles = profiles.filter(profile =>
    (profile.nome_perfil || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
    (profile.descricao || '').toLowerCase().includes(searchTerm.toLowerCase())
  )
  
  console.log('Termo de busca:', searchTerm)
  console.log('Perfis antes do filtro:', profiles.length)
  console.log('Perfis após filtro:', filteredProfiles.length)
  console.log('Perfis filtrados:', filteredProfiles.map(p => `${p.nome_perfil} (ID: ${p.id})`))

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-foreground">Gerenciamento de Perfis</h1>
        <p className="text-muted-foreground mt-1">Gerencie perfis de acesso e permissões</p>
      </div>

      {/* Campo de Busca */}
      <div className="card">
        <div className="card-content">
          <div className="flex items-center gap-3">
            <div className="flex-1 relative">
              <input
                type="text"
                placeholder="Buscar perfis por nome ou descrição..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="input w-full pl-10"
              />
              <div className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground">
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                </svg>
              </div>
            </div>
            <button
              onClick={loadProfiles}
              className="btn-secondary flex items-center gap-2 rounded-lg px-4 py-2"
            >
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
              </svg>
              Atualizar
            </button>
            <button
              onClick={() => setShowCreateForm(true)}
              className="btn-primary flex items-center gap-2 rounded-lg px-4 py-2"
            >
              <Plus className="w-4 h-4" />
              Novo Perfil
            </button>
          </div>
        </div>
      </div>

      {/* Formulário de Criação */}
      {showCreateForm && (
        <div className="bg-gray-800 rounded-lg p-6 mb-6" data-create-form>
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-xl font-semibold text-white">Criar Novo Perfil</h2>
            <button
              onClick={() => setShowCreateForm(false)}
              className="text-gray-400 hover:text-white"
            >
              <X className="w-5 h-5" />
            </button>
          </div>
          
          <form onSubmit={createProfile} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Nome do Perfil
              </label>
              <input
                type="text"
                className="input"
                value={formData.nome_perfil}
                onChange={(e) => setFormData({...formData, nome_perfil: e.target.value})}
                placeholder="Ex: Gestor Empresa"
                required
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Descrição
              </label>
              <textarea
                className="input"
                value={formData.descricao}
                onChange={(e) => setFormData({...formData, descricao: e.target.value})}
                placeholder="Descreva o perfil e suas responsabilidades"
                rows={3}
              />
            </div>
            
            <div>
              <div className="flex items-center justify-between mb-2">
                <label className="block text-sm font-medium text-gray-300">
                  Permissões
                </label>
                <span className="text-xs text-gray-400">
                  {formData.permissoes.length} selecionada(s)
                </span>
              </div>
              <div className="max-h-80 overflow-y-auto space-y-4">
                {permissionsLoading ? (
                  <div className="text-center py-4">
                    <div className="inline-flex items-center gap-2 text-gray-400">
                      <div className="w-4 h-4 border-2 border-gray-400 border-t-transparent rounded-full animate-spin"></div>
                      Carregando permissões...
                    </div>
                  </div>
                ) : (
                  <div className="space-y-4">
                    {getPermissionCategories().map(category => (
                      <div key={category.name} className="bg-gray-800 rounded-lg p-4">
                        <div className="flex items-center justify-between mb-3">
                          <h4 className="text-sm font-semibold text-blue-400 flex items-center gap-2">
                            <span className="w-2 h-2 bg-blue-400 rounded-full"></span>
                            {category.name}
                          </h4>
                          <div className="flex gap-2">
                            <button
                              type="button"
                              onClick={() => toggleCategoryPermissions(category.permissions, true)}
                              className="text-xs px-2 py-1 bg-blue-600 text-white rounded hover:bg-blue-700 transition-colors"
                            >
                              Todas
                            </button>
                            <button
                              type="button"
                              onClick={() => toggleCategoryPermissions(category.permissions, false)}
                              className="text-xs px-2 py-1 bg-gray-600 text-white rounded hover:bg-gray-700 transition-colors"
                            >
                              Nenhuma
                            </button>
                          </div>
                        </div>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
                          {category.permissions.map(permission => {
                            const isChecked = formData.permissoes.includes(permission.id.toString())
                            return (
                              <label key={permission.id} className="flex items-start gap-3 p-2 bg-gray-700 rounded hover:bg-gray-600 cursor-pointer transition-colors">
                                <input
                                  type="checkbox"
                                  checked={isChecked}
                                  onChange={() => togglePermission(permission.id.toString())}
                                  className="mt-1 w-4 h-4 text-blue-600 bg-gray-700 border-gray-600 rounded focus:ring-blue-500 focus:ring-2"
                                />
                                <div className="flex-1">
                                  <div className="text-sm font-medium text-white">{permission.descricao}</div>
                                  <div className="text-xs text-gray-400 font-mono">{permission.nome}</div>
                                </div>
                              </label>
                            )
                          })}
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>
            
            <div className="flex gap-3">
              <button type="submit" className="btn-primary flex items-center gap-2 rounded-lg px-4 py-2">
                <Save className="w-4 h-4" />
                Criar Perfil
              </button>
              <button
                type="button"
                onClick={() => setShowCreateForm(false)}
                className="btn-secondary flex items-center gap-2 rounded-lg px-4 py-2"
              >
                Cancelar
              </button>
            </div>
          </form>
        </div>
      )}

      {/* Formulário de Edição de Perfil */}
      {showEditForm && editingProfile && (
        <div className="bg-gray-800 rounded-lg p-6 mb-6" data-edit-form>
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-xl font-semibold text-white">Editar Perfil: {editingProfile.nome_perfil}</h2>
            <button
              onClick={cancelEdit}
              className="text-gray-400 hover:text-white"
            >
              <X className="w-5 h-5" />
            </button>
          </div>
          
          <form onSubmit={createProfile} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-white mb-2">Nome do Perfil</label>
              <input
                type="text"
                value={formData.nome_perfil}
                onChange={(e) => setFormData(prev => ({ ...prev, nome_perfil: e.target.value }))}
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
                required
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-white mb-2">Descrição</label>
              <textarea
                value={formData.descricao}
                onChange={(e) => setFormData(prev => ({ ...prev, descricao: e.target.value }))}
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
                rows={3}
              />
            </div>
            
            <div>
              <div className="flex items-center justify-between mb-3">
                <label className="block text-sm font-medium text-white">
                  Permissões
                </label>
                <span className="text-xs text-gray-400">
                  {formData.permissoes.length} selecionada(s)
                </span>
              </div>
              <div className="max-h-80 overflow-y-auto space-y-4">
                {permissionsLoading ? (
                  <div className="text-center py-4">
                    <div className="inline-flex items-center gap-2 text-gray-400">
                      <div className="w-4 h-4 border-2 border-gray-400 border-t-transparent rounded-full animate-spin"></div>
                      Carregando permissões...
                    </div>
                  </div>
                ) : (
                  <div className="space-y-4">
                    {getPermissionCategories().map(category => (
                      <div key={category.name} className="bg-gray-800 rounded-lg p-4">
                        <div className="flex items-center justify-between mb-3">
                          <h4 className="text-sm font-semibold text-blue-400 flex items-center gap-2">
                            <span className="w-2 h-2 bg-blue-400 rounded-full"></span>
                            {category.name}
                          </h4>
                          <div className="flex gap-2">
                            <button
                              type="button"
                              onClick={() => toggleCategoryPermissions(category.permissions, true)}
                              className="text-xs px-2 py-1 bg-blue-600 text-white rounded hover:bg-blue-700 transition-colors"
                            >
                              Todas
                            </button>
                            <button
                              type="button"
                              onClick={() => toggleCategoryPermissions(category.permissions, false)}
                              className="text-xs px-2 py-1 bg-gray-600 text-white rounded hover:bg-gray-700 transition-colors"
                            >
                              Nenhuma
                            </button>
                          </div>
                        </div>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
                          {category.permissions.map(permission => {
                            const isChecked = formData.permissoes.includes(permission.id.toString())
                            return (
                              <label key={permission.id} className="flex items-start gap-3 p-2 bg-gray-700 rounded hover:bg-gray-600 cursor-pointer transition-colors">
                                <input
                                  type="checkbox"
                                  checked={isChecked}
                                  onChange={() => togglePermission(permission.id.toString())}
                                  className="mt-1 w-4 h-4 text-blue-600 bg-gray-700 border-gray-600 rounded focus:ring-blue-500 focus:ring-2"
                                />
                                <div className="flex-1">
                                  <div className="text-sm font-medium text-white">{permission.descricao}</div>
                                  <div className="text-xs text-gray-400 font-mono">{permission.nome}</div>
                                </div>
                              </label>
                            )
                          })}
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>
            
            <div className="flex gap-3">
              <button type="submit" className="btn-primary flex items-center gap-2 rounded-lg px-4 py-2">
                <Save className="w-4 h-4" />
                Salvar Alterações
              </button>
              <button
                type="button"
                onClick={cancelEdit}
                className="btn-secondary flex items-center gap-2 rounded-lg px-4 py-2"
              >
                Cancelar
              </button>
            </div>
          </form>
        </div>
      )}

      {/* Lista de Perfis */}
      <div className="card">
        <div className="card-header">
          <h2 className="text-xl font-semibold text-foreground">Perfis de Acesso</h2>
          <p className="text-muted-foreground mt-1">{filteredProfiles.length} perfil(is) encontrado(s)</p>
        </div>
        
        {loading ? (
          <div className="card-content text-center">
            <div className="inline-flex items-center gap-2 text-muted-foreground">
              <div className="w-4 h-4 border-2 border-muted-foreground border-t-transparent rounded-full animate-spin"></div>
              Carregando perfis...
            </div>
          </div>
        ) : filteredProfiles.length === 0 ? (
          <div className="card-content text-center">
            <AlertCircle className="w-12 h-12 text-muted-foreground mx-auto mb-4" />
            <h3 className="text-lg font-medium text-foreground mb-2">Nenhum perfil encontrado</h3>
            <p className="text-muted-foreground mb-4">Crie seu primeiro perfil de acesso para começar</p>
            <button
              onClick={() => setShowCreateForm(true)}
              className="btn-primary flex items-center gap-2 rounded-lg px-4 py-2 mx-auto"
            >
              <Plus className="w-4 h-4" />
              Criar Primeiro Perfil
            </button>
          </div>
        ) : (
          <div className="divide-y divide-border">
            {filteredProfiles.map((profile) => (
              <div key={profile.id} className="card-content">
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <div className="flex items-center gap-3 mb-2">
                      <button
                        onClick={() => toggleProfileExpansion(profile.id)}
                        className="flex items-center gap-2 hover:bg-muted p-2 rounded-lg transition-colors"
                      >
                        {expandedProfiles.has(profile.id) ? (
                          <ChevronDown className="w-4 h-4 text-muted-foreground" />
                        ) : (
                          <ChevronRight className="w-4 h-4 text-muted-foreground" />
                        )}
                        <h3 className="text-lg font-semibold text-foreground">{profile.nome_perfil}</h3>
                        <span className="px-2 py-1 bg-primary text-primary-foreground text-xs rounded-full">
                          ID: {profile.id}
                        </span>
                        <span className="px-2 py-1 bg-muted text-muted-foreground text-xs rounded-full">
                          {profile.permissoes?.length || 0} permissões
                        </span>
                      </button>
                    </div>
                    
                    {profile.descricao && (
                      <p className="text-muted-foreground mb-3 ml-8">{profile.descricao}</p>
                    )}
                    
                    {expandedProfiles.has(profile.id) && (
                      <div className="ml-8">
                        <div className="mb-4">
                          <p className="text-muted-foreground text-sm mb-3">
                            {profile.permissoes && profile.permissoes.length > 0 
                              ? `${profile.permissoes.length} permissões configuradas`
                              : 'Nenhuma permissão definida'
                            }
                          </p>
                          
                          {/* Mostrar permissões organizadas por categoria */}
                          {profile.permissoes && profile.permissoes.length > 0 && (
                            <div className="space-y-2">
                              {getPermissionCategories().map(category => {
                                const categoryPermissions = category.permissions.filter(p => 
                                  profile.permissoes?.includes(p.nome)
                                )
                                
                                if (categoryPermissions.length === 0) return null
                                
                                return (
                                  <div key={category.name} className="bg-muted/50 rounded-lg p-3">
                                    <h5 className="text-sm font-medium text-foreground mb-2 flex items-center gap-2">
                                      <span className="w-1.5 h-1.5 bg-primary rounded-full"></span>
                                      {category.name} ({categoryPermissions.length})
                                    </h5>
                                    <div className="flex flex-wrap gap-1">
                                      {categoryPermissions.map(permission => (
                                        <span 
                                          key={permission.id}
                                          className="px-2 py-1 bg-primary/10 text-primary text-xs rounded-full"
                                        >
                                          {permission.descricao}
                                        </span>
                                      ))}
                                    </div>
                                  </div>
                                )
                              })}
                            </div>
                          )}
                        </div>
                        
                        <div className="flex gap-2">
                          <button
                            onClick={() => editProfile(profile)}
                            className="btn-secondary flex items-center gap-2 text-sm"
                          >
                            <Edit className="w-4 h-4" />
                            Editar Perfil
                          </button>
                          <button
                            onClick={() => deleteProfile(profile)}
                            className="btn-danger flex items-center gap-2 text-sm"
                          >
                            <Trash2 className="w-4 h-4" />
                            Deletar Perfil
                          </button>
                        </div>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}