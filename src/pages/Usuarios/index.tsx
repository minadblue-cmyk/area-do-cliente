import { useEffect, useState } from 'react'
import { callWebhook } from '../../utils/webhook-client'
import { useToastStore } from '../../store/toast'
import { useAuthStore } from '../../store/auth'
import { Users, Plus, RefreshCw, Search, Edit, Trash2, Shield } from 'lucide-react'
import { cn } from '../../lib/utils'
import { UserProfiles } from './UserProfiles'
import { ProfileSelector } from './ProfileSelector'
import { ProfileModal } from './ProfileModal'

interface UsuarioItem {
  id: number
  email: string
  created_at: string
  nome: string
  ativo: boolean
  empresa: string
  plano: string
  empresa_id?: number
  perfil_id?: number
  perfis?: ProfileItem[] // Múltiplos perfis
}

interface EmpresaItem {
  id: number
  nome_empresa: string
  created_at: string
  cnpj: string
  email: string
  telefone: string
  endereco: string
  descricao: string
}

interface ProfileItem {
  id: number
  nome_perfil: string
  descricao?: string
  description?: string  // Campo alternativo
  permissions: string[]
}

export default function Usuarios() {
  const [items, setItems] = useState<UsuarioItem[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [showCreateForm, setShowCreateForm] = useState(false)
  const [showEditForm, setShowEditForm] = useState(false)
  const [editingUser, setEditingUser] = useState<UsuarioItem | null>(null)
  const [showUserProfiles, setShowUserProfiles] = useState(false)
  const [selectedUserForProfiles, setSelectedUserForProfiles] = useState<UsuarioItem | null>(null)
  const [empresas, setEmpresas] = useState<EmpresaItem[]>([])
  const [loadingEmpresas, setLoadingEmpresas] = useState(false)
  const [perfis, setPerfis] = useState<ProfileItem[]>([])
  const [loadingPerfis, setLoadingPerfis] = useState(false)
  const [usuariosLoaded, setUsuariosLoaded] = useState(false)
  const [lastRefresh, setLastRefresh] = useState<Date>(new Date())
  const [autoRefreshEnabled, setAutoRefreshEnabled] = useState(true)
  const [isAutoRefreshing, setIsAutoRefreshing] = useState(false)
  const [isManualRefreshing, setIsManualRefreshing] = useState(false)
  const [formData, setFormData] = useState({
    email: '',
    senha: '',
    nome: '',
    ativo: true,
    empresa_id: '',
    plano: 'basico',
    perfil_id: ''
  })
  const [selectedProfiles, setSelectedProfiles] = useState<number[]>([])
  const [showProfileSelector, setShowProfileSelector] = useState(false)
  
  const push = useToastStore((s) => s.push)

  // Debug: verificar estado das empresas
  console.log('Estado empresas no componente:', empresas)
  console.log('Quantidade de empresas:', empresas.length)
  
  // Debug: verificar se o dropdown está sendo renderizado
  console.log('🔍 DEBUG - Empresas para dropdown:', empresas)
  console.log('🔍 DEBUG - Empresas.length:', empresas.length)
  console.log('🔍 DEBUG - Empresas é array?', Array.isArray(empresas))
  
  // Debug: monitorar mudanças no formData
  useEffect(() => {
    console.log('🔄 FormData mudou:', formData)
    console.log('🔄 FormData.empresa_id:', formData.empresa_id)
    console.log('🔄 FormData.perfil_id:', formData.perfil_id)
    console.log('🔄 FormData.ativo:', formData.ativo)
    console.log('🔄 FormData.plano:', formData.plano)
  }, [formData])

  // Debug: monitorar mudanças no selectedProfiles
  useEffect(() => {
    console.log('🔄 SelectedProfiles mudou:', selectedProfiles)
  }, [selectedProfiles])

  // Debug: monitorar mudanças no editingUser
  useEffect(() => {
    console.log('🔄 EditingUser mudou:', editingUser)
  }, [editingUser])
  

  async function loadUsuarios(empresasParaMapear?: EmpresaItem[], perfisParaMapear?: ProfileItem[]) {
    setLoading(true)
    try {
      const { data } = await callWebhook<any>('webhook/list-users', { 
        method: 'GET'
      })
      
      console.log('Resposta completa do webhook/list-users:', data)
      
      // Verificar se data é um array ou se está dentro de uma propriedade
      let usuariosArray = []
      if (Array.isArray(data)) {
        usuariosArray = data
      } else if (data && Array.isArray(data.usuarios)) {
        usuariosArray = data.usuarios
      } else if (data && Array.isArray(data.data)) {
        usuariosArray = data.data
      } else if (data && Array.isArray(data.users)) {
        usuariosArray = data.users
      } else {
        console.warn('Resposta não é um array:', data)
        setItems([])
        return
      }
      
      console.log('🔍 Usuários carregados do webhook:', usuariosArray)
      
      // Usar empresas passadas como parâmetro ou do estado
      const empresasParaUsar = empresasParaMapear || empresas
      const perfisParaUsar = perfisParaMapear || perfis
      
      // Debug: verificar estado das empresas
      console.log('🔍 Estado empresas no loadUsuarios:', empresasParaUsar)
      console.log('🔍 Quantidade de empresas disponíveis:', empresasParaUsar.length)
      
      // Debug: verificar estrutura completa do primeiro usuário
      if (usuariosArray.length > 0) {
        console.log('🔍 Estrutura completa do primeiro usuário:', usuariosArray[0])
        console.log('🔍 Campos disponíveis:', Object.keys(usuariosArray[0]))
      }

      // Mapear usuários preservando IDs originais do banco
      const usuariosComEmpresa = usuariosArray.map((usuario: any) => {
        console.log('👤 Processando usuário:', usuario.nome)
        console.log('👤 Dados originais do webhook:', {
          empresa_id: usuario.empresa_id,
          perfil_id: usuario.perfil_id,
          empresa: usuario.empresa,
          perfil: usuario.perfil
        })
        
        // PRESERVAR os IDs originais do banco (empresa_id e perfil_id)
        const empresaIdOriginal = usuario.empresa_id
        const perfilIdOriginal = usuario.perfil_id
        
        // Buscar empresa pelo ID original (se existir)
        let empresa = null
        if (empresaIdOriginal) {
          empresa = empresasParaUsar.find(emp => emp.id === empresaIdOriginal || emp.id === Number(empresaIdOriginal))
          console.log('🏢 Empresa encontrada por ID:', empresaIdOriginal, '->', empresa)
        }
        
        // Se não encontrou por ID, tentar por nome (fallback)
        if (!empresa && usuario.empresa) {
          empresa = empresasParaUsar.find(emp => emp.nome_empresa === usuario.empresa)
          console.log('🏢 Empresa encontrada por nome (fallback):', usuario.empresa, '->', empresa)
        }
        
        const nomeEmpresa = empresa ? empresa.nome_empresa : (usuario.empresa || 'Sem empresa')
        console.log('📝 Nome da empresa final:', nomeEmpresa)
        
        // Buscar perfil pelo ID original (se existir)
        let perfilEncontrado = null
        if (perfilIdOriginal) {
          perfilEncontrado = perfisParaUsar.find(p => p.id === perfilIdOriginal || p.id === Number(perfilIdOriginal))
          console.log('👤 Perfil encontrado por ID:', perfilIdOriginal, '->', perfilEncontrado)
        }
        
        // Se não encontrou por ID, tentar por nome (fallback)
        if (!perfilEncontrado && usuario.perfil) {
          perfilEncontrado = perfisParaUsar.find(p => p.nome_perfil === usuario.perfil)
          console.log('👤 Perfil encontrado por nome (fallback):', usuario.perfil, '->', perfilEncontrado)
        }
        
        // Criar array de perfis
        let perfisArray: any[] = []
        if (perfilEncontrado) {
          perfisArray = [{
            ...perfilEncontrado,
            id: Number(perfilEncontrado.id)
          }]
        }
        
        const usuarioMapeado = {
          ...usuario,
          empresa: nomeEmpresa,
          empresa_id: empresaIdOriginal, // PRESERVAR ID original do banco
          ativo: usuario.ativo === true || usuario.ativo === 'true' || usuario.ativo === 1,
          perfis: perfisArray,
          perfil_id: perfilIdOriginal // PRESERVAR ID original do banco
        }
        
        console.log('✅ Usuário mapeado:', {
          nome: usuarioMapeado.nome,
          empresa_id: usuarioMapeado.empresa_id,
          perfil_id: usuarioMapeado.perfil_id,
          empresa: usuarioMapeado.empresa
        })
        
        return usuarioMapeado
      })
      setItems(usuariosComEmpresa)
    } catch (error) {
      console.error('Erro ao carregar usuários:', error)
      push({ kind: 'error', message: 'Erro ao carregar usuários.' })
    } finally {
      setLoading(false)
    }
  }

  async function loadEmpresas() {
    setLoadingEmpresas(true)
    try {
      console.log('Iniciando carregamento de empresas...')
      console.log('Chamando webhook: webhook/list-company')
      const { data } = await callWebhook<any>('webhook/list-company', {})
      
      console.log('Resposta completa do webhook/list-company:', data)
      console.log('Tipo da resposta:', typeof data)
      console.log('É array?', Array.isArray(data))
      
      // Verificar se data é um array ou se está dentro de uma propriedade
      let empresasArray = []
      if (Array.isArray(data)) {
        empresasArray = data
      } else if (data && Array.isArray(data.empresas)) {
        empresasArray = data.empresas
      } else if (data && Array.isArray(data.data)) {
        empresasArray = data.data
      } else if (data && Array.isArray(data.companies)) {
        empresasArray = data.companies
      } else {
        console.warn('Resposta não é um array:', data)
        setEmpresas([])
        return []
      }
      
      console.log('Empresas carregadas:', empresasArray)
      console.log('Quantidade de empresas:', empresasArray.length)
      setEmpresas(empresasArray)
      console.log('Estado empresas atualizado!')
      
      // Verificar se o estado foi atualizado
      setTimeout(() => {
        console.log('Estado empresas após setEmpresas:', empresasArray)
      }, 100)
      
      return empresasArray
    } catch (error) {
      console.error('Erro ao carregar empresas:', error)
      console.error('Detalhes do erro:', (error as any).message)
      push({ kind: 'error', message: 'Erro ao carregar empresas.' })
      return []
    } finally {
      setLoadingEmpresas(false)
    }
  }

  async function loadPerfis() {
    setLoadingPerfis(true)
    try {
      const { data } = await callWebhook<any>('webhook/list-profile', {})
      
      console.log('Resposta completa do webhook/list-profile:', data)
      
      // Verificar se data é um array ou se está dentro de uma propriedade
      let perfisArray = []
      if (Array.isArray(data)) {
        // Verificar se é array duplo [[{profiles: [...]}]]
        if (data.length > 0 && Array.isArray(data[0]) && data[0].length > 0 && data[0][0].profiles) {
          perfisArray = data[0][0].profiles
          console.log('✅ Detectado formato array duplo com profiles')
        } else {
          perfisArray = data
        }
      } else if (data && Array.isArray(data.perfis)) {
        perfisArray = data.perfis
      } else if (data && Array.isArray(data.data)) {
        perfisArray = data.data
      } else if (data && Array.isArray(data.profiles)) {
        perfisArray = data.profiles
      } else {
        console.warn('Resposta não é um array:', data)
        setPerfis([])
        return []
      }
      
      console.log('Perfis carregados:', perfisArray)
      console.log('Primeiro perfil:', perfisArray[0])
      console.log('Campos do primeiro perfil:', perfisArray[0] ? Object.keys(perfisArray[0]) : 'Nenhum perfil')
      
      // Verificar se há campo descricao
      if (perfisArray[0]) {
        console.log('Campo descricao:', perfisArray[0].descricao)
        console.log('Campo description:', perfisArray[0].description)
        console.log('Todos os campos:', perfisArray[0])
      }
      
        console.log('✅ Perfis carregados com sucesso:', perfisArray)
        console.log('✅ Quantidade de perfis:', perfisArray.length)
        console.log('✅ Primeiro perfil:', perfisArray[0])
        console.log('✅ Todos os perfis:', perfisArray.map((p: any) => ({ id: p.id, nome: p.nome_perfil })))
        setPerfis(perfisArray)
        return perfisArray
      } catch (error) {
        console.error('Erro ao carregar perfis:', error)
        console.error('Detalhes do erro:', (error as any).message)
        push({ kind: 'error', message: 'Erro ao carregar perfis.' })
        return []
      } finally {
        setLoadingPerfis(false)
      }
  }

  useEffect(() => {
    const loadData = async () => {
      console.log('🔄 Iniciando carregamento de dados...')
      
      // Carregar empresas e perfis primeiro
      console.log('📊 Carregando empresas...')
      await loadEmpresas()
      
      console.log('👥 Carregando perfis...')
      await loadPerfis()
      
      console.log('✅ Carregamento inicial concluído!')
    }
    loadData()
  }, [])

  // Carregar usuários quando as empresas estiverem disponíveis
  useEffect(() => {
    if (empresas.length > 0 && perfis.length > 0 && !usuariosLoaded) {
      console.log('🎯 Empresas e perfis carregados, carregando usuários...')
      console.log('🎯 Empresas disponíveis:', empresas.length)
      console.log('🎯 Perfis disponíveis:', perfis.length)
      loadUsuarios(empresas, perfis)
      setUsuariosLoaded(true)
    }
  }, [empresas, perfis, usuariosLoaded])

  // Monitorar mudanças no estado das empresas
  useEffect(() => {
    console.log('🔄 Estado empresas mudou:', empresas)
    console.log('📊 Quantidade de empresas no estado:', empresas.length)
    console.log('📊 Empresas são array?', Array.isArray(empresas))
    console.log('📊 Primeira empresa:', empresas[0])
  }, [empresas])

  // Monitorar mudanças no estado dos perfis
  useEffect(() => {
    console.log('🔄 Estado perfis mudou:', perfis)
    console.log('📊 Quantidade de perfis no estado:', perfis.length)
    console.log('📊 Perfis são array?', Array.isArray(perfis))
    console.log('📊 Primeiro perfil:', perfis[0])
    console.log('📊 Todos os perfis no estado:', perfis.map(p => ({ id: p.id, nome: p.nome_perfil })))
  }, [perfis])

  // Refresh automático a cada 30 segundos
  useEffect(() => {
    if (!autoRefreshEnabled) return

    const interval = setInterval(async () => {
      console.log('🔄 Refresh automático iniciado...')
      setIsAutoRefreshing(true)
      try {
        // Carregar empresas e perfis PRIMEIRO, depois usuários
        const empresasCarregadas = await loadEmpresas()
        const perfisCarregados = await loadPerfis()
        await loadUsuarios(empresasCarregadas, perfisCarregados)
        setLastRefresh(new Date())
        console.log('✅ Refresh automático concluído')
        // Toast discreto para refresh automático
        push({ kind: 'info', message: 'Dados atualizados automaticamente' })
      } catch (error) {
        console.error('❌ Erro no refresh automático:', error)
      } finally {
        setIsAutoRefreshing(false)
      }
    }, 30000) // 30 segundos

    return () => clearInterval(interval)
  }, [autoRefreshEnabled])

  // Função de refresh manual melhorada
  const refreshAll = async () => {
    console.log('🔄 Refresh manual iniciado...')
    setIsManualRefreshing(true)
    setLoading(true)
    try {
      // Carregar empresas e perfis PRIMEIRO, depois usuários
      const empresasCarregadas = await loadEmpresas()
      const perfisCarregados = await loadPerfis()
      await loadUsuarios(empresasCarregadas, perfisCarregados)
      setLastRefresh(new Date())
      push({ kind: 'success', message: 'Dados atualizados com sucesso!' })
      console.log('✅ Refresh manual concluído')
    } catch (error) {
      console.error('❌ Erro no refresh manual:', error)
      push({ kind: 'error', message: 'Erro ao atualizar dados.' })
    } finally {
      setLoading(false)
      setIsManualRefreshing(false)
    }
  }

  async function createUsuario(e: React.FormEvent) {
    e.preventDefault()
    try {
      setLoading(true)
      
      // Encontrar o nome do perfil baseado no perfil_id
      const perfilSelecionado = perfis.find(p => p.id.toString() === formData.perfil_id)
      const nomePerfil = perfilSelecionado ? perfilSelecionado.nome_perfil : ''
      
      // Se não encontrou por perfil_id, tentar pelos perfis selecionados
      let nomePerfilFinal = nomePerfil
      if (!nomePerfilFinal && selectedProfiles.length > 0) {
        const perfilSelecionadoPorArray = perfis.find(p => selectedProfiles.includes(p.id))
        nomePerfilFinal = perfilSelecionadoPorArray ? perfilSelecionadoPorArray.nome_perfil : ''
      }

      // Encontrar o nome da empresa baseado no empresa_id
      const empresaSelecionada = empresas.find(e => e.id.toString() === formData.empresa_id)
      const nomeEmpresa = empresaSelecionada ? empresaSelecionada.nome_empresa : ''

      // Construir payload com validações para evitar campos em branco
      const payload = {
        email: formData.email.trim() || '',
        senha: formData.senha && formData.senha.trim() !== '' ? formData.senha.trim() : '',
        nome: formData.nome.trim() || '',
        ativo: formData.ativo.toString(),
        empresa: nomeEmpresa || '',
        empresa_id: formData.empresa_id && formData.empresa_id !== '' ? parseInt(formData.empresa_id) : null,
        plano: formData.plano || 'basico',
        perfil: nomePerfilFinal || '',
        perfil_id: formData.perfil_id && formData.perfil_id !== '' ? parseInt(formData.perfil_id) : null,
        perfis: selectedProfiles.length > 0 ? selectedProfiles : []
      }
      
      // Log detalhado do payload
      console.log('📤 Payload de criação:', payload)
      console.log('📤 Campos validados:')
      console.log('  - email:', payload.email || 'VAZIO')
      console.log('  - senha:', payload.senha ? 'PREENCHIDA' : 'VAZIA')
      console.log('  - nome:', payload.nome || 'VAZIO')
      console.log('  - ativo:', payload.ativo)
      console.log('  - empresa:', payload.empresa || 'VAZIA')
      console.log('  - empresa_id:', payload.empresa_id)
      console.log('  - plano:', payload.plano)
      console.log('  - perfil:', payload.perfil || 'VAZIO')
      console.log('  - perfil_id:', payload.perfil_id)
      console.log('  - perfis:', payload.perfis)
      
      console.log('Payload enviado para webhook-criar-usuario:', payload)
      
      await callWebhook('webhook-criar-usuario', { 
        method: 'POST', 
        data: payload
      })
      
      // Limpar formulário
      setFormData({
        email: '',
        senha: '',
        nome: '',
        ativo: true,
        empresa_id: '',
        plano: 'basico',
        perfil_id: ''
      })
      setShowCreateForm(false)
      push({ kind: 'success', message: 'Usuário criado com sucesso!' })
      // Refresh automático após criação
      await refreshAll()
    } catch (error) {
      console.error('Erro ao criar usuário:', error)
      push({ kind: 'error', message: 'Erro ao criar usuário.' })
    }
  }

  async function editUsuario(id: string) {
    console.log('🚀 EDITAR USUÁRIO - ID:', id)
    try {
      // Encontrar o usuário pelo ID
      const userToEdit = items.find(user => user.id.toString() === id)
      if (!userToEdit) {
        push({ kind: 'error', message: 'Usuário não encontrado.' })
        return
      }
      
      console.log('✅ USUÁRIO ENCONTRADO:', userToEdit)
      console.log('🔍 DADOS COMPLETOS DO USUÁRIO:')
      console.log('  - ID:', userToEdit.id)
      console.log('  - Nome:', userToEdit.nome)
      console.log('  - Email:', userToEdit.email)
      console.log('  - empresa_id:', userToEdit.empresa_id, '(tipo:', typeof userToEdit.empresa_id, ')')
      console.log('  - perfil_id:', userToEdit.perfil_id, '(tipo:', typeof userToEdit.perfil_id, ')')
      console.log('  - empresa:', userToEdit.empresa)
      console.log('  - perfil:', userToEdit.perfis?.[0]?.nome_perfil)
      console.log('  - perfis array:', userToEdit.perfis)
      console.log('🔍 Empresas disponíveis:', empresas.length)
      console.log('🔍 Perfis disponíveis:', perfis.length)

      // Aguardar um pouco para garantir que empresas e perfis estão carregados
      if (empresas.length === 0 || perfis.length === 0) {
        console.log('⚠️ Empresas ou perfis não carregados ainda, aguardando...')
        setTimeout(() => editUsuario(id), 500)
        return
      }

      // Encontrar empresa_id correspondente
      let empresaIdParaForm = ''
      console.log('🔍 userToEdit.empresa_id:', userToEdit.empresa_id, 'Tipo:', typeof userToEdit.empresa_id)
      
      if (userToEdit.empresa_id && userToEdit.empresa_id !== null && userToEdit.empresa_id !== undefined) {
        // Verificar se o empresa_id existe nas empresas disponíveis
        // Tentar comparação com conversão de tipos
        const empresaExiste = empresas.find(emp => 
          emp.id === userToEdit.empresa_id || 
          emp.id === Number(userToEdit.empresa_id) ||
          Number(emp.id) === userToEdit.empresa_id
        )
        console.log('🔍 Empresa encontrada:', empresaExiste)
        console.log('🔍 Comparação de tipos - userToEdit.empresa_id:', userToEdit.empresa_id, typeof userToEdit.empresa_id)
        console.log('🔍 Empresas disponíveis com tipos:', empresas.map(e => ({ id: e.id, tipo: typeof e.id, nome: e.nome_empresa })))
        
        if (empresaExiste) {
          empresaIdParaForm = empresaExiste.id.toString()
          console.log('✅ Empresa encontrada por empresa_id:', empresaIdParaForm)
        } else {
          console.log('⚠️ Empresa_id não encontrado nas empresas disponíveis:', userToEdit.empresa_id)
          console.log('🔍 Empresas disponíveis:', empresas.map(e => ({ id: e.id, nome: e.nome_empresa })))
        }
      } else {
        console.log('⚠️ Usuário sem empresa_id definido')
      }

      // Mapear perfil_id
      let perfilIdParaForm = ''
      console.log('🔍 userToEdit.perfil_id:', userToEdit.perfil_id, 'Tipo:', typeof userToEdit.perfil_id)
      console.log('🔍 userToEdit.perfis:', userToEdit.perfis)
      
      if (userToEdit.perfil_id && userToEdit.perfil_id !== null && userToEdit.perfil_id !== undefined) {
        // Verificar se o perfil_id existe nos perfis disponíveis
        // Tentar comparação com conversão de tipos
        const perfilExiste = perfis.find(p => 
          p.id === userToEdit.perfil_id || 
          p.id === Number(userToEdit.perfil_id) ||
          Number(p.id) === userToEdit.perfil_id
        )
        console.log('🔍 Perfil encontrado:', perfilExiste)
        console.log('🔍 Comparação de tipos - userToEdit.perfil_id:', userToEdit.perfil_id, typeof userToEdit.perfil_id)
        console.log('🔍 Perfis disponíveis com tipos:', perfis.map(p => ({ id: p.id, tipo: typeof p.id, nome: p.nome_perfil })))
        
        if (perfilExiste) {
          perfilIdParaForm = perfilExiste.id.toString()
          console.log('✅ Perfil encontrado por perfil_id:', perfilIdParaForm)
        } else {
          console.log('⚠️ Perfil_id não encontrado nos perfis disponíveis:', userToEdit.perfil_id)
          console.log('🔍 Perfis disponíveis:', perfis.map(p => ({ id: p.id, nome: p.nome_perfil })))
        }
      } else if (userToEdit.perfis && userToEdit.perfis.length > 0) {
        // Tentar usar o primeiro perfil do array
        const primeiroPerfil = userToEdit.perfis[0]
        const perfilExiste = perfis.find(p => 
          p.id === primeiroPerfil.id || 
          p.id === Number(primeiroPerfil.id) ||
          Number(p.id) === primeiroPerfil.id
        )
        if (perfilExiste) {
          perfilIdParaForm = perfilExiste.id.toString()
          console.log('✅ Perfil encontrado pelo array perfis:', perfilIdParaForm)
        }
      } else {
        console.log('⚠️ Usuário sem perfil_id ou perfis definidos')
      }

      // Preencher o formulário com os dados do usuário
      const formDataToSet = {
        email: userToEdit.email || '',
        senha: '', // Sempre vazio na edição
        nome: userToEdit.nome || '',
        ativo: Boolean(userToEdit.ativo),
        empresa_id: empresaIdParaForm,
        plano: userToEdit.plano || 'basico',
        perfil_id: perfilIdParaForm
      }

      console.log('📝 FormData definido:', formDataToSet)
      console.log('📝 RESUMO DO FORM DATA:')
      console.log('  - email:', formDataToSet.email)
      console.log('  - nome:', formDataToSet.nome)
      console.log('  - ativo:', formDataToSet.ativo)
      console.log('  - empresa_id:', formDataToSet.empresa_id, '(string:', typeof formDataToSet.empresa_id, ')')
      console.log('  - plano:', formDataToSet.plano)
      console.log('  - perfil_id:', formDataToSet.perfil_id, '(string:', typeof formDataToSet.perfil_id, ')')
      
      // Carregar perfis selecionados do usuário
      const userProfiles = userToEdit.perfis || []
      const profileIds = userProfiles.map(p => p.id)
      
      // Verificar se os IDs dos perfis do usuário existem nos perfis disponíveis
      const validProfileIds = profileIds.filter(id => 
        perfis.some(p => p.id === id)
      ).map(id => Number(id))
      
      console.log('🔍 Perfis selecionados do usuário:', validProfileIds)
      console.log('🔍 userProfiles:', userProfiles)
      console.log('🔍 profileIds:', profileIds)
      
      // Definir todos os estados de uma vez
      setFormData(formDataToSet)
      setSelectedProfiles(validProfileIds)
      setEditingUser(userToEdit)
      setShowEditForm(true)
      setShowCreateForm(false)
      
      console.log('✅ Formulário de edição configurado com sucesso!')
      console.log('✅ Estados definidos:')
      console.log('  - formData:', formDataToSet)
      console.log('  - selectedProfiles:', validProfileIds)
      console.log('  - editingUser:', userToEdit.nome)
      console.log('  - showEditForm: true')
      
    } catch (error) {
      console.error('❌ Erro ao carregar dados do usuário:', error)
      push({ kind: 'error', message: 'Erro ao carregar dados do usuário.' })
    }
  }

  async function updateUsuario(e: React.FormEvent) {
    e.preventDefault()
    if (!editingUser) return

    try {
      // Encontrar o nome do perfil baseado no perfil_id
      const perfilSelecionado = perfis.find(p => p.id.toString() === formData.perfil_id)
      const nomePerfil = perfilSelecionado ? perfilSelecionado.nome_perfil : ''
      
      // Se não encontrou por perfil_id, tentar pelos perfis selecionados
      let nomePerfilFinal = nomePerfil
      if (!nomePerfilFinal && selectedProfiles.length > 0) {
        const perfilSelecionadoPorArray = perfis.find(p => selectedProfiles.includes(p.id))
        nomePerfilFinal = perfilSelecionadoPorArray ? perfilSelecionadoPorArray.nome_perfil : ''
      }

      // Encontrar o nome da empresa baseado no empresa_id
      const empresaSelecionada = empresas.find(e => e.id.toString() === formData.empresa_id)
      const nomeEmpresa = empresaSelecionada ? empresaSelecionada.nome_empresa : ''

      // Construir payload com validações para evitar campos em branco
      const payload = {
        id: editingUser.id,
        email: formData.email || '',
        senha: formData.senha && formData.senha.trim() !== '' ? formData.senha.trim() : '', // Sempre enviar, mesmo que vazio
        nome: formData.nome || '',
        ativo: formData.ativo.toString(), // Converter boolean para string
        empresa: nomeEmpresa || '', // Nome da empresa selecionada
        empresa_id: formData.empresa_id && formData.empresa_id !== '' ? parseInt(formData.empresa_id) : null,
        plano: formData.plano || 'basico',
        perfil: nomePerfilFinal || '', // Nome do perfil (não pode ser null)
        perfil_id: formData.perfil_id && formData.perfil_id !== '' ? parseInt(formData.perfil_id) : null, // Converter para número
        perfis: selectedProfiles.length > 0 ? selectedProfiles : [] // Array de IDs dos perfis selecionados
      }
      
      // Log detalhado do payload
      console.log('📤 Payload completo:', payload)
      console.log('📤 Campos validados:')
      console.log('  - email:', payload.email || 'VAZIO')
      console.log('  - senha:', payload.senha ? 'PREENCHIDA' : 'VAZIA')
      console.log('  - nome:', payload.nome || 'VAZIO')
      console.log('  - ativo:', payload.ativo)
      console.log('  - empresa:', payload.empresa || 'VAZIA')
      console.log('  - empresa_id:', payload.empresa_id)
      console.log('  - plano:', payload.plano)
      console.log('  - perfil:', payload.perfil || 'VAZIO')
      console.log('  - perfil_id:', payload.perfil_id)
      console.log('  - perfis:', payload.perfis)
      
      console.log('Payload enviado para webhook/edit-users:', payload)
      
      await callWebhook('webhook/edit-users', { 
        method: 'POST', 
        data: payload
      })
      
      push({ kind: 'success', message: 'Usuário atualizado com sucesso!' })
      
      // Limpar formulário e fechar modal
      setFormData({
        email: '',
        senha: '',
        nome: '',
        ativo: true,
        empresa_id: '',
        plano: 'basico',
        perfil_id: ''
      })
      setSelectedProfiles([])
      setEditingUser(null)
      setShowEditForm(false)
      
      // Refresh automático após edição
      await refreshAll()
    } catch (error) {
      console.error('Erro ao atualizar usuário:', error)
      push({ kind: 'error', message: 'Erro ao atualizar usuário.' })
    }
  }

  function cancelEdit() {
    setEditingUser(null)
    setShowEditForm(false)
    setSelectedProfiles([])
    setShowProfileSelector(false)
    setFormData({
      email: '',
      senha: '',
      nome: '',
      ativo: true,
      empresa_id: '',
      plano: 'basico',
      perfil_id: ''
    })
  }

  async function deleteUsuario(id: string) {
    // Obter dados do usuário logado
    const currentUser = useAuthStore.getState().userData
    
    // Verificar se o usuário está tentando deletar a si mesmo
    if (currentUser && currentUser.id === id) {
      push({ kind: 'error', message: 'Você não pode deletar sua própria conta!' })
      return
    }
    
    try {
      await callWebhook('webhook/delete-users', { 
        method: 'POST', 
        data: { usuario_id: parseInt(id) }
      })
      
      push({ kind: 'success', message: 'Usuário removido com sucesso!' })
      // Recarregar empresas e usuários para garantir mapeamento correto
      const empresasCarregadas = await loadEmpresas()
      const perfisCarregados = await loadPerfis()
      await loadUsuarios(empresasCarregadas, perfisCarregados)
    } catch (error) {
      console.error('Erro ao deletar usuário:', error)
      push({ kind: 'error', message: 'Erro ao remover usuário.' })
    }
  }

  function openUserProfiles(user: UsuarioItem) {
    setSelectedUserForProfiles(user)
    setShowUserProfiles(true)
  }

  function closeUserProfiles() {
    setSelectedUserForProfiles(null)
    setShowUserProfiles(false)
  }

  async function refreshUserProfiles() {
    await loadUsuarios(empresas, perfis)
  }

  function toggleProfile(profileId: number) {
    setSelectedProfiles(prev => {
      if (prev.includes(profileId)) {
        return prev.filter(id => id !== profileId)
      } else {
        return [...prev, profileId]
      }
    })
  }

  function openProfileSelector() {
    setShowProfileSelector(true)
  }

  function closeProfileSelector() {
    setShowProfileSelector(false)
  }


  const filteredItems = items.filter(item =>
    item.nome.toLowerCase().includes(searchTerm.toLowerCase()) ||
    item.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
    item.empresa.toLowerCase().includes(searchTerm.toLowerCase()) ||
    item.plano.toLowerCase().includes(searchTerm.toLowerCase())
  )

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-foreground">Usuários</h1>
          <p className="text-muted-foreground">Gerencie usuários do sistema</p>
        </div>
        <button
          onClick={() => setShowCreateForm(true)}
          className="btn btn-primary flex items-center gap-2"
        >
          <Plus className="w-4 h-4" />
          Criar Usuário
        </button>
      </div>

      {/* Search and Refresh */}
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-4">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground w-4 h-4" />
            <input
              type="text"
              placeholder="Buscar usuários..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="input pl-10"
            />
          </div>
          
          {/* Status de refresh */}
          <div className="flex items-center gap-2 text-sm text-muted-foreground">
            <div className={`w-2 h-2 rounded-full ${autoRefreshEnabled ? (isAutoRefreshing ? 'bg-yellow-500 animate-pulse' : 'bg-green-500') : 'bg-gray-400'}`}></div>
            <span>Auto-refresh: {autoRefreshEnabled ? (isAutoRefreshing ? 'Atualizando...' : 'Ativo') : 'Inativo'}</span>
            <span>•</span>
            <span>Última atualização: {lastRefresh.toLocaleTimeString()}</span>
          </div>
        </div>
        
        <div className="flex items-center gap-2">
          <button
            onClick={() => setAutoRefreshEnabled(!autoRefreshEnabled)}
            className={`btn btn-sm ${autoRefreshEnabled ? 'btn-outline' : 'btn-secondary'}`}
          >
            {autoRefreshEnabled ? 'Pausar Auto-refresh' : 'Ativar Auto-refresh'}
          </button>
          <button
            onClick={refreshAll}
            disabled={isManualRefreshing}
            className="btn btn-outline flex items-center gap-2"
          >
            <RefreshCw className={`w-4 h-4 ${isManualRefreshing ? 'animate-spin' : ''}`} />
            {isManualRefreshing ? 'Atualizando...' : 'Atualizar'}
          </button>
        </div>
      </div>

      {/* Formulário de Criação */}
      {showCreateForm && (
        <div className="card">
          <div className="card-header">Criar Novo Usuário</div>
          <div className="card-content">
            <form onSubmit={createUsuario} className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {/* Email (obrigatório) */}
                <div className="space-y-2">
                  <label className="text-sm font-medium text-foreground">
                    Email <span className="text-red-500">*</span>
                  </label>
                  <input
                    className="input"
                    type="email"
                    placeholder="Digite o email do usuário"
                    value={formData.email}
                    onChange={(e) => setFormData({...formData, email: e.target.value})}
                    required
                  />
                </div>
                
                {/* Senha (obrigatório na criação) */}
                <div className="space-y-2">
                  <label className="text-sm font-medium text-foreground">
                    Senha <span className="text-red-500">*</span>
                  </label>
                  <input
                    className="input"
                    type="password"
                    placeholder="Digite a senha do usuário"
                    value={formData.senha}
                    onChange={(e) => setFormData({...formData, senha: e.target.value})}
                    required
                  />
                </div>
                
                {/* Nome (opcional) */}
                <div className="space-y-2">
                  <label className="text-sm font-medium text-foreground">
                    Nome Completo
                  </label>
                  <input
                    className="input"
                    placeholder="Digite o nome completo do usuário"
                    value={formData.nome}
                    onChange={(e) => setFormData({...formData, nome: e.target.value})}
                  />
                </div>
                
                {/* Status Ativo (obrigatório) */}
                <div className="space-y-2">
                  <label className="text-sm font-medium text-foreground">
                    Status do Usuário
                  </label>
                  <div className="flex items-center gap-2">
                    <label className="flex items-center gap-2 cursor-pointer">
                      <input
                        type="checkbox"
                        checked={formData.ativo}
                        onChange={(e) => setFormData({...formData, ativo: e.target.checked})}
                        className="rounded border-border"
                      />
                      <span className="text-sm">Usuário ativo</span>
                    </label>
                  </div>
                </div>
                
                {/* Empresa (dropdown) */}
                <div className="space-y-2">
                  <label className="text-sm font-medium text-foreground">
                    Empresa <span className="text-red-500">*</span>
                  </label>
                  <select
                    className="input"
                    value={formData.empresa_id}
                    onChange={(e) => setFormData({...formData, empresa_id: e.target.value})}
                    disabled={loadingEmpresas}
                    required
                  >
                    <option value="">Selecione uma empresa</option>
                    {empresas.map((empresa) => {
                      console.log('Renderizando empresa no dropdown:', empresa)
                      return (
                        <option key={empresa.id} value={empresa.id}>
                          {empresa.nome_empresa}
                        </option>
                      )
                    })}
                  </select>
                </div>
                
                {/* Perfil (dropdown) */}
                <div className="space-y-2">
                  <label className="text-sm font-medium text-foreground">
                    Perfil de Acesso
                  </label>
                  <select
                    className="input"
                    value={formData.perfil_id}
                    onChange={(e) => setFormData({...formData, perfil_id: e.target.value})}
                    disabled={loadingPerfis}
                  >
                    <option value="">Selecione um perfil</option>
                    {perfis.map((perfil) => (
                      <option key={perfil.id} value={perfil.id}>
                        {perfil.nome_perfil} - {perfil.descricao || perfil.description || 'Sem descrição'}
                      </option>
                    ))}
                  </select>
                </div>
                
                {/* Plano (opcional) */}
                <div className="space-y-2">
                  <label className="text-sm font-medium text-foreground">
                    Plano
                  </label>
                  <select
                    className="input"
                    value={formData.plano}
                    onChange={(e) => setFormData({...formData, plano: e.target.value})}
                  >
                    <option value="">Selecione um plano</option>
                    <option value="basico">Básico</option>
                    <option value="premium">Premium</option>
                    <option value="enterprise">Enterprise</option>
                  </select>
                </div>
              </div>
              <div className="flex gap-2">
                <button type="submit" className="btn btn-primary">
                  Criar Usuário
                </button>
                <button 
                  type="button" 
                  onClick={() => setShowCreateForm(false)}
                  className="btn btn-outline"
                >
                  Cancelar
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Formulário de Edição */}
      {showEditForm && editingUser && (
        <div className="card">
          <div className="card-header">Editar Usuário: {editingUser.nome}</div>
          <div className="card-content">
            <form onSubmit={updateUsuario} className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {/* Email (obrigatório) */}
                <div className="space-y-2">
                  <label className="text-sm font-medium text-foreground">
                    Email <span className="text-red-500">*</span>
                  </label>
                  <input
                    className="input"
                    type="email"
                    placeholder="Digite o email do usuário"
                    value={formData.email}
                    onChange={(e) => setFormData({...formData, email: e.target.value})}
                    required
                  />
                </div>
                
                {/* Senha (opcional na edição) */}
                <div className="space-y-2">
                  <label className="text-sm font-medium text-foreground">
                    Nova Senha
                  </label>
                  <input
                    className="input"
                    type="password"
                    placeholder="Deixe em branco para manter a senha atual"
                    value={formData.senha}
                    onChange={(e) => setFormData({...formData, senha: e.target.value})}
                  />
                </div>
                
                {/* Nome (opcional) */}
                <div className="space-y-2">
                  <label className="text-sm font-medium text-foreground">
                    Nome Completo
                  </label>
                  <input
                    className="input"
                    placeholder="Digite o nome completo do usuário"
                    value={formData.nome}
                    onChange={(e) => setFormData({...formData, nome: e.target.value})}
                  />
                </div>
                
                
                {/* Status Ativo (obrigatório) */}
                <div className="space-y-2">
                  <label className="text-sm font-medium text-foreground">
                    Status do Usuário
                  </label>
                  <div className="flex items-center gap-2">
                    <label className="flex items-center gap-2 cursor-pointer">
                      <input
                        type="checkbox"
                        checked={formData.ativo}
                        onChange={(e) => setFormData({...formData, ativo: e.target.checked})}
                        className="rounded border-border"
                      />
                      <span className="text-sm">Usuário ativo</span>
                    </label>
                  </div>
                </div>
                
                {/* Empresa (dropdown) */}
                <div className="space-y-2">
                  <label className="text-sm font-medium text-foreground">
                    Empresa <span className="text-red-500">*</span>
                  </label>
                  <select
                    className="input"
                    value={formData.empresa_id}
                    onChange={(e) => setFormData({...formData, empresa_id: e.target.value})}
                    disabled={loadingEmpresas}
                    required
                  >
                    <option value="">Selecione uma empresa</option>
                    {empresas.map((empresa) => {
                      console.log('Renderizando empresa no dropdown EDITION:', empresa)
                      const isSelected = empresa.id.toString() === formData.empresa_id
                      console.log(`Empresa ${empresa.id} (${empresa.nome_empresa}) - Selecionada: ${isSelected}`)
                      return (
                        <option key={empresa.id} value={empresa.id}>
                          {empresa.nome_empresa}
                        </option>
                      )
                    })}
                  </select>
                  <div className="text-xs text-muted-foreground">
                    Debug EDITION: Valor atual = "{formData.empresa_id}", Total empresas = {empresas.length}
                  </div>
                </div>
                
                {/* Perfis Múltiplos */}
                <div className="space-y-2">
                  <label className="text-sm font-medium text-foreground">
                    Perfis de Acesso
                  </label>
                  <div className="text-xs text-muted-foreground">
                    Debug: {perfis.length} perfis disponíveis, {selectedProfiles.length} selecionados
                    <br />
                    IDs selecionados: {selectedProfiles.join(', ') || 'Nenhum'}
                  </div>
                  <ProfileSelector
                    selectedProfiles={selectedProfiles}
                    availableProfiles={perfis}
                    onToggleProfile={toggleProfile}
                    onOpenSelector={openProfileSelector}
                    disabled={loadingPerfis}
                  />
                </div>
                
                {/* Plano (opcional) */}
                <div className="space-y-2">
                  <label className="text-sm font-medium text-foreground">
                    Plano
                  </label>
                  <select
                    className="input"
                    value={formData.plano}
                    onChange={(e) => setFormData({...formData, plano: e.target.value})}
                  >
                    <option value="">Selecione um plano</option>
                    <option value="basico">Básico</option>
                    <option value="premium">Premium</option>
                    <option value="enterprise">Enterprise</option>
                  </select>
                  <div className="text-xs text-muted-foreground">
                    Debug EDITION: Plano atual = "{formData.plano}"
                  </div>
                </div>
              </div>
              <div className="flex gap-2">
                <button type="submit" className="btn btn-primary">
                  Atualizar Usuário
                </button>
                <button 
                  type="button" 
                  onClick={cancelEdit}
                  className="btn btn-outline"
                >
                  Cancelar
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Lista de Usuários */}
      <div className="card">
        <div className="card-header">
          <div className="flex items-center gap-2">
            <Users className="w-5 h-5" />
            Usuários ({filteredItems.length})
          </div>
        </div>
        <div className="card-content">
          {loading ? (
            <div className="text-center py-8">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto"></div>
              <p className="text-muted-foreground mt-2">Carregando usuários...</p>
            </div>
          ) : filteredItems.length === 0 ? (
            <div className="text-center py-8">
              <Users className="w-12 h-12 text-muted-foreground mx-auto mb-4" />
              <p className="text-muted-foreground">Nenhum usuário encontrado</p>
            </div>
          ) : (
            <div className="space-y-4">
              {filteredItems.map((usuario) => (
                <div key={usuario.id} className="border border-border rounded-lg p-4">
                  <div className="flex items-center justify-between">
                    <div className="space-y-2">
                      <div className="flex items-center gap-3">
                        <h3 className="font-semibold text-foreground">{usuario.nome}</h3>
                        <span className={cn(
                          "px-2 py-1 text-xs rounded-full",
                          usuario.ativo 
                            ? "bg-green-500/20 text-green-400" 
                            : "bg-red-500/20 text-red-400"
                        )}>
                          {usuario.ativo ? 'Ativo' : 'Inativo'}
                        </span>
                      </div>
                      <div className="text-sm text-muted-foreground space-y-1">
                        <div>
                          <span className="font-medium">Email:</span> {usuario.email}
                        </div>
                        <div>
                          <span className="font-medium">Empresa:</span> {usuario.empresa}
                        </div>
                        <div>
                          <span className="font-medium">Plano:</span> {usuario.plano}
                        </div>
                        <div>
                          <span className="font-medium">Criado em:</span> {new Date(usuario.created_at).toLocaleDateString('pt-BR')}
                        </div>
                      </div>
                    </div>
                    <div className="flex items-center gap-2">
                      <button
                        onClick={() => editUsuario(usuario.id.toString())}
                        className="p-2 rounded hover:bg-muted/50 transition-colors"
                        title="Editar usuário"
                      >
                        <Edit className="w-4 h-4 text-muted-foreground" />
                      </button>
                      <button
                        onClick={() => openUserProfiles(usuario)}
                        className="p-2 rounded hover:bg-primary/20 transition-colors"
                        title="Gerenciar perfis do usuário"
                      >
                        <Shield className="w-4 h-4 text-primary" />
                      </button>
                      <button
                        onClick={() => deleteUsuario(usuario.id.toString())}
                        disabled={useAuthStore.getState().userData?.id === usuario.id.toString()}
                        className={cn(
                          "p-2 rounded transition-colors",
                          useAuthStore.getState().userData?.id === usuario.id.toString()
                            ? "opacity-50 cursor-not-allowed"
                            : "hover:bg-destructive/20"
                        )}
                        title={
                          useAuthStore.getState().userData?.id === usuario.id.toString()
                            ? "Você não pode deletar sua própria conta"
                            : "Excluir usuário"
                        }
                      >
                        <Trash2 className={cn(
                          "w-4 h-4",
                          useAuthStore.getState().userData?.id === usuario.id.toString()
                            ? "text-muted-foreground"
                            : "text-destructive"
                        )} />
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Modal de Perfis do Usuário */}
      {showUserProfiles && selectedUserForProfiles && (
        <UserProfiles
          userId={selectedUserForProfiles.id.toString()}
          userName={selectedUserForProfiles.nome}
          currentProfiles={selectedUserForProfiles.perfis || []}
          onClose={closeUserProfiles}
          onUpdate={refreshUserProfiles}
        />
      )}
      

      {/* Modal de Seleção de Perfis */}
      <ProfileModal
        isOpen={showProfileSelector}
        onClose={closeProfileSelector}
        selectedProfiles={selectedProfiles}
        availableProfiles={perfis}
        onToggleProfile={toggleProfile}
        onSave={closeProfileSelector}
        loading={loadingPerfis}
      />
      
    </div>
  )
}
