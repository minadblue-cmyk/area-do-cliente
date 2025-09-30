import { useState, useEffect, useRef } from 'react'
import { useToastStore } from '../../store/toast'
import { useAuthStore } from '../../store/auth'
import { callWebhook } from '../../utils/webhook-client'
import { useAgentPermissions } from '../../hooks/useAgentPermissions'
import { Upload as UploadIcon, Users, Play, AlertCircle, Zap, ChevronDown, ChevronUp, X, Plus, RefreshCw } from 'lucide-react'
import * as XLSX from 'xlsx'
import { CreateAgentModal } from '../../components/CreateAgentModal'
import { AgentSyncManager } from '../../components/AgentSyncManager'
import { useAgentSyncWebhooks } from '../../hooks/useAgentSyncWebhooks'

// Estado global para armazenar atribuições de agentes
let agentesAtribuicoes: any[] = []

// Função para carregar atribuições de agentes
async function loadAgentesAtribuicoes(): Promise<any[]> {
  try {
    const response = await callWebhook('webhook/list-agente-atribuicoes')
    if (response && response.data) {
      let atribuicoes = []
      if (Array.isArray(response.data)) {
        // Formato: [{ success: "true", data: { agente_id: 74, usuario_id: 6 } }]
        atribuicoes = response.data.map(item => item.data).filter(Boolean)
      } else if (response.data.data && Array.isArray(response.data.data)) {
        // Formato: { data: [{ agente_id: 74, usuario_id: 6 }] }
        atribuicoes = response.data.data
      }
      agentesAtribuicoes = atribuicoes
      console.log('📋 Atribuições carregadas:', agentesAtribuicoes)
      return atribuicoes
    }
    return []
  } catch (error) {
    console.error('❌ Erro ao carregar atribuições:', error)
    return []
  }
}

// Função para verificar se um agente está atribuído para um usuário
function isAgenteAtribuidoParaUsuario(agenteId: number, userId: number): boolean {
  return agentesAtribuicoes.some(atribuicao => 
    atribuicao.agente_id === agenteId && atribuicao.usuario_id === userId
  )
}

// Função para ler arquivo Excel e extrair dados
async function readExcelFile(file: File): Promise<any[]> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader()
    reader.onload = (e) => {
      try {
        const data = new Uint8Array(e.target?.result as ArrayBuffer)
        const workbook = XLSX.read(data, { type: 'array' })
        
        // Pega a primeira planilha
        const firstSheetName = workbook.SheetNames[0]
        const worksheet = workbook.Sheets[firstSheetName]
        
        // Converte para JSON usando os headers do Excel
        const jsonData = XLSX.utils.sheet_to_json(worksheet, { 
          header: 1, // Usar índices numéricos como header
          defval: '' // Valor padrão para células vazias
        })
        
        // Pega os headers (primeira linha) e os dados (resto)
        const headers = jsonData[0] as string[]
        const rows = jsonData.slice(1) as any[][]
        
        console.log('Colunas detectadas no Excel:', headers)
        
        // Mapeia os dados usando os nomes das colunas do Excel
        const processedData = rows
          .filter(row => row.some(cell => cell !== '')) // Remove linhas completamente vazias
          .map((row, index) => {
            const rowData: any = { ID: index + 1 } // Adiciona ID sequencial
            
            // Mapeia cada coluna usando o nome do header do Excel
            headers.forEach((header, colIndex) => {
              if (header && header.trim()) {
                rowData[header.trim()] = row[colIndex] || ''
              }
            })
            
            return rowData
          })
        
        resolve(processedData)
      } catch (error) {
        console.error('Erro ao processar Excel:', error)
        reject(new Error('Formato de arquivo inválido ou corrompido'))
      }
    }
    reader.onerror = () => reject(new Error('Erro ao ler arquivo'))
    reader.readAsArrayBuffer(file)
  })
}

export default function UploadPage() {
  const { userData } = useAuthStore()
  const push = useToastStore((s) => s.push)
  const agentPermissions = useAgentPermissions()
  
  const [file, setFile] = useState<File | null>(null)
  const [uploading, setUploading] = useState(false)
  // Estados para múltiplos agentes
  const [agents, setAgents] = useState<Record<string, {
    id: string
    name: string
    type: string
    status: 'disconnected' | 'running' | 'paused' | 'error' | 'completed'
    executionId: string | null
    startedAt: string | null
    stoppedAt: string | null
    progress?: number
    message?: string
  }>>({})
  
  const [agentLoading, setAgentLoading] = useState<Record<string, boolean>>({})
  const [dynamicAgentTypes, setDynamicAgentTypes] = useState<Record<string, any>>({})
  const [extractedData, setExtractedData] = useState<any[]>([])
  const [showAllData, setShowAllData] = useState(false)
  const [isStartingAllAgents, setIsStartingAllAgents] = useState(false)
  const [isStoppingAllAgents, setIsStoppingAllAgents] = useState(false)
  const [prospects, setProspects] = useState<Record<string, Array<{
    id: number
    client_id: number
    nome: string
    telefone: string
    status: string
    contatado: boolean
    data_ultima_interacao: string
    data_criacao: string
  }>>>({})
  const [showCreateAgentModal, setShowCreateAgentModal] = useState(false)
  
  // Estados adicionais da página de teste
  const [agentes, setAgentes] = useState<any[]>([])
  const [startingAgent, setStartingAgent] = useState<string | null>(null)
  const [stoppingAgent, setStoppingAgent] = useState<string | null>(null)
  const [autoRefreshActive, setAutoRefreshActive] = useState(false)
  const [autoRefreshEnabled, setAutoRefreshEnabled] = useState(true)
  const [tabelaAtualizando, setTabelaAtualizando] = useState<Record<string, boolean>>({})
  const [prospectsStats, setProspectsStats] = useState<Record<string, {total: number, completos: number, pendentes: number}>>({})
  
  // ❌ REMOVIDO: Seleção de agente não é necessária no upload
  // Os agentes pegam lotes da base comum
  
  // Referência para manter agentes atualizados sem problemas de closure
  const agentsRef = useRef<Record<string, any>>({})
  
  // AUTOREFRESH DESABILITADO - REMOVIDO

  // Sistema de sincronização de agentes
  const { agents: syncedAgents, syncAgents: forceSyncAgents } = useAgentSyncWebhooks({
    autoSync: true,
    syncInterval: 30000, // 30 segundos
    onAgentAdded: (agentId, agentData) => {
      console.log('🆕 Novo agente detectado pelo sistema de sync:', agentData)
      
      // VALIDAÇÃO: Verificar se agente tem dados válidos
      if (!agentData.nome || !agentData.id) {
        console.error('🚨 Agente inválido detectado:', agentData)
        return
      }
      
      // Atualizar dynamicAgentTypes com o novo agente
      setDynamicAgentTypes(prev => ({
        ...prev,
        [agentId]: {
          id: agentId,
          name: agentData.nome,
          description: agentData.descricao || 'Agente de prospecção',
          icon: agentData.icone || '🤖',
          color: agentData.cor || 'bg-blue-500',
          webhook: 'webhook-generic'
        }
      }))
    },
    onSyncError: (error) => {
      console.error('🚨 Erro na sincronização de agentes:', error)
      push({ kind: 'error', message: `Erro na sincronização de agentes: ${error.message}` })
    },
    onAgentRemoved: (agentId) => {
      console.log('🗑️ Agente removido pelo sistema de sync:', agentId)
      // Remover agente do dynamicAgentTypes
      setDynamicAgentTypes(prev => {
        const newTypes = { ...prev }
        delete newTypes[agentId]
        return newTypes
      })
      // Remover dados do agente
      setAgents(prev => {
        const newAgents = { ...prev }
        delete newAgents[agentId]
        return newAgents
      })
    }
  })

  // Manter referência atualizada dos agentes para evitar problemas de closure
  useEffect(() => {
    // Priorizar syncedAgents que sempre tem dados atualizados
    agentsRef.current = syncedAgents || {}
    console.log(`🔄 [REF] Agentes atualizados na referência:`, Object.keys(agentsRef.current))
    console.log(`🔄 [REF] syncedAgents:`, Object.keys(syncedAgents || {}))
    console.log(`🔄 [REF] agents:`, Object.keys(agents || {}))
  }, [syncedAgents, agents])

  // Sincronizar dynamicAgentTypes com syncedAgents (aplicando filtro de permissões)
  useEffect(() => {
    const newAgentTypes: Record<string, any> = {}
    
    Object.entries(syncedAgents).forEach(([agentId, agentData]) => {
      // Aplicar filtro de permissões
      const shouldShowAgent = (() => {
        // Se pode ver todos os agentes, mostrar todos
        if (agentPermissions.canViewAll || agentPermissions.canManage) {
          return true
        }
        
        // Se pode ver apenas seus próprios agentes, filtrar por user_id
        if (agentPermissions.canViewOwn) {
          const userId = parseInt(userData?.id || '0')
          
          return agentData.usuario_id === userId
        }
        
        // NOVA LÓGICA: Se tem permissão de atribuição, verificar atribuições específicas
        if (agentPermissions.canAssignAgents) {
          // Verificar se o agente foi atribuído especificamente para este usuário
          const userId = parseInt(userData?.id || '0')
          return agentData.atribuido_para_usuario || agentData.usuario_id === userId
        }
        
        // Se não tem permissão específica, não mostrar nenhum
        return false
      })()
      
      if (shouldShowAgent) {
        newAgentTypes[agentId] = {
          id: agentId,
          name: agentData.nome,
          description: agentData.descricao || 'Agente de prospecção',
          icon: agentData.icone || '🤖',
          color: agentData.cor || 'bg-blue-500',
          webhook: 'webhook-generic'
        }
      }
    })
    
    console.log(`🔍 Agentes filtrados por permissão: ${Object.keys(newAgentTypes).length} de ${Object.keys(syncedAgents).length}`)
    setDynamicAgentTypes(newAgentTypes)
  }, [syncedAgents, userData]) // Removido agentPermissions das dependências

  console.log('🚀 UploadPage componente carregado')
  console.log('🔍 Estado inicial dynamicAgentTypes:', dynamicAgentTypes)
  console.log('🔍 Estado inicial agents:', agents)
  console.log('🔍 Tamanho dynamicAgentTypes:', Object.keys(dynamicAgentTypes).length)
  console.log('🔍 dynamicAgentTypes vazio?', Object.keys(dynamicAgentTypes).length === 0)

  // Sistema de sincronização automática substitui loadAgentConfigs

  // Função para carregar dados da tabela usando webhook list - VERSÃO ATUALIZADA
  const loadProspects = async (agente?: any, isAutoRefresh = false) => {
    console.log('🔄 loadProspects chamada - VERSÃO ATUALIZADA')
    if (!userData) return
    
    // Se não especificou agente, carregar para todos
    const agentesParaCarregar = agente ? [agente] : agentes
    
    for (const agenteAtual of agentesParaCarregar) {
      // Marcar como atualizando
      setTabelaAtualizando(prev => ({
        ...prev,
        [agenteAtual.id]: true
      }))
      
      try {
        console.log(`📊 ${isAutoRefresh ? 'Auto-atualizando' : 'Carregando'} dados da tabela para ${agenteAtual.nome}...`)
        
        // Usar webhook do banco de dados (sem fallback)
        const webhookId = agenteAtual.webhook_lista_url
        
        if (!webhookId) {
          console.warn(`⚠️ Agente ${agenteAtual.nome} não tem webhook_lista_url configurado`)
          return
        }
        
        console.log(`🔍 Usando webhook: ${webhookId}`)
        console.log(`🔍 Agente ID: ${agenteAtual.id}, Nome: ${agenteAtual.nome}`)
        
        // VALIDAÇÃO DE SEGURANÇA: Verificar se usuário tem empresa_id
        if (!userData.empresa_id) {
          console.error('🚨 FALHA DE SEGURANÇA: Usuário não possui empresa_id. Acesso negado por segurança.')
          return
        }
        
        const response = await callWebhook(webhookId, {
          method: 'GET',
          params: {
            client_id: userData.id,  // Obrigatório para PostgreSQL
            agente_id: agenteAtual.id,  // Obrigatório para PostgreSQL
            workflow_id: agenteAtual.id,
            usuario_id: userData.id,
            empresa_id: userData.empresa_id // OBRIGATÓRIO - sem fallback por segurança
          }
        })
        
        console.log(`📥 Resposta recebida para ${agenteAtual.nome}:`, response)
        
        // Verificar se a resposta está vazia
        if (!response || !response.data) {
          console.log(`⚠️ Resposta vazia para ${agenteAtual.nome}, mantendo dados existentes`)
          // Não resetar prospects nem estatísticas se já existem dados
          if (!prospects[agenteAtual.id] || prospects[agenteAtual.id].length === 0) {
          setProspects(prev => ({
            ...prev,
            [agenteAtual.id]: []
          }))
          }
          return
        }
        
        if (response && response.data) {
          const prospectsData = Array.isArray(response.data) ? response.data : [response.data]
          
          // Filtrar apenas prospectando e concluido
          const filteredProspects = prospectsData.filter((prospect: any) => {
            const status = prospect.status || prospect.estado || 'desconhecido'
            return status === 'prospectando' || status === 'concluido' || status === 'completo'
          })
          
          // Ordenar: prospectando primeiro, depois concluídos
          const sortedProspects = filteredProspects.sort((a, b) => {
            const statusA = a.status || a.estado || 'desconhecido'
            const statusB = b.status || b.estado || 'desconhecido'
            
            if (statusA === 'prospectando' && statusB !== 'prospectando') return -1
            if (statusA !== 'prospectando' && statusB === 'prospectando') return 1
            
            const dateA = new Date(a.data_ultima_interacao || 0)
            const dateB = new Date(b.data_ultima_interacao || 0)
            return dateB.getTime() - dateA.getTime()
          })
          
          setProspects(prev => ({
            ...prev,
            [agenteAtual.id]: sortedProspects
          }))
          
          // Calcular estatísticas baseadas no status real
          const totalCompletos = sortedProspects.filter(p => p.status === 'concluido').length
          const totalPendentes = sortedProspects.filter(p => p.status === 'prospectando' || p.status === 'pendente' || !p.status).length
          
          setProspectsStats(prev => ({
            ...prev,
            [agenteAtual.id]: {
              total: sortedProspects.length,
              completos: totalCompletos,
              pendentes: totalPendentes
            }
          }))
          
          console.log(`✅ ${sortedProspects.length} clientes carregados para ${agenteAtual.nome} (${totalCompletos} completos, ${totalPendentes} pendentes) - VERSÃO ATUALIZADA - ${new Date().toISOString()}`)
        } else {
          console.log(`ℹ️ Resposta vazia para ${agenteAtual.nome}, mantendo dados existentes`)
          // Só resetar se não há dados existentes
          if (!prospects[agenteAtual.id] || prospects[agenteAtual.id].length === 0) {
          setProspects(prev => ({
                ...prev,
            [agenteAtual.id]: []
          }))
          }
        }
      } catch (error) {
        console.error(`❌ Erro ao carregar clientes para ${agenteAtual.nome}:`, error)
        // Só resetar se não há dados existentes
        if (!prospects[agenteAtual.id] || prospects[agenteAtual.id].length === 0) {
        setProspects(prev => ({
              ...prev,
          [agenteAtual.id]: []
        }))
        }
      } finally {
        setTabelaAtualizando(prev => ({
          ...prev,
          [agenteAtual.id]: false
        }))
      }
    }
  }

  // Função para criar novo agente
  const handleCreateAgent = (newAgent: any) => {
    console.log('🎉 Novo agente criado:', newAgent)
    
    // Mostrar toast de sucesso
    push({
        kind: 'success',
      message: `Agente ${newAgent.name} foi criado com sucesso com 4 workflows!`
    })
    
    // Recarregar lista de agentes
    listarAgentes()
  }

  // Função para verificar status de um agente específico
  const verificarStatus = async (agente: any, isAutoRefresh = false) => {
    if (!userData) return
    
    try {
      console.log(`🔍 Verificando status do agente ${agente.nome}...`)
      
      // Usar webhook do banco de dados (sem fallback)
      const webhookId = agente.webhook_status_url
      
      if (!webhookId) {
        console.warn(`⚠️ Agente ${agente.nome} não tem webhook_status_url configurado`)
        return
      }
      
      console.log(`🔍 Usando webhook: ${webhookId}`)
      
      const response = await callWebhook(webhookId, {
        method: 'GET',
        params: {
          workflow_id: agente.id,
          usuario_id: userData.id
        }
      })
      
      console.log(`📥 Resposta do status para ${agente.nome}:`, response)
      
      let newStatus = 'stopped'
      let executionId = null
      
      if (response && response.data) {
        const responseData = Array.isArray(response.data) ? response.data[0] : response.data
        console.log('🔍 Dados do webhook status:', responseData)
        
        // Mapear status corretamente
        const rawStatus = responseData?.status_atual || responseData?.status || 'stopped'
        
        // Converter status do N8N para status do frontend
        if (rawStatus === 'completed' || rawStatus === 'finished' || rawStatus === 'success') {
          newStatus = 'stopped'
        } else if (rawStatus === 'running' || rawStatus === 'active' || rawStatus === 'in_progress') {
          newStatus = 'running'
        } else {
          newStatus = 'stopped'
        }
        
        executionId = responseData?.execution_id_ativo || responseData?.execution_id || responseData?.executionId || null
        console.log('🔍 Status original:', rawStatus, '→ Status mapeado:', newStatus)
        console.log('🔍 Execution ID capturado:', executionId)
      
      // VALIDAÇÃO ADICIONAL: Se o agente foi iniciado recentemente mas o status mostra stopped,
      // verificar se há execution_id válido para determinar o status real
      if (newStatus === 'stopped' && agente.execution_id_ativo && !executionId) {
        console.log('⚠️ Status inconsistente detectado - agente tem execution_id_ativo mas status é stopped')
        // Manter o status como running se há execution_id_ativo
        newStatus = 'running'
        executionId = agente.execution_id_ativo
        console.log('🔧 Corrigindo status para running baseado no execution_id_ativo')
      }
      
      // VALIDAÇÃO CRÍTICA: Se o agente foi parado recentemente (menos de 30 segundos),
      // não sobrescrever o status para running mesmo que o webhook retorne running
      const agora = new Date()
      const ultimaAtualizacao = agente.updated_at ? new Date(agente.updated_at) : null
      const tempoDesdeAtualizacao = ultimaAtualizacao ? (agora.getTime() - ultimaAtualizacao.getTime()) / 1000 : 0
      
      if (agente.status_atual === 'stopped' && newStatus === 'running' && tempoDesdeAtualizacao < 30) {
        console.log(`⚠️ Agente ${agente.nome} foi parado recentemente (${tempoDesdeAtualizacao}s atrás) - mantendo status stopped`)
        newStatus = 'stopped'
        executionId = null
      }
      
      // VALIDAÇÃO CRÍTICA: Se o agente tem execution_id_ativo mas o status retorna stopped,
      // assumir que o webhook de status está desatualizado e manter como running
      if (agente.execution_id_ativo && newStatus === 'stopped' && !executionId) {
        console.log(`⚠️ Agente ${agente.nome} tem execution_id_ativo (${agente.execution_id_ativo}) mas status retorna stopped - assumindo que está rodando`)
        newStatus = 'running'
        executionId = agente.execution_id_ativo
      }
      
      // VALIDAÇÃO ADICIONAL: Se o agente foi iniciado recentemente (menos de 10 segundos),
      // e o status retornado é stopped, assumir que ainda está iniciando
      if (agente.status_atual === 'running' && newStatus === 'stopped' && tempoDesdeAtualizacao < 10) {
        console.log(`⚠️ Agente ${agente.nome} foi iniciado recentemente (${tempoDesdeAtualizacao}s atrás) - assumindo que ainda está iniciando`)
        newStatus = 'running'
        executionId = agente.execution_id_ativo || executionId
      }
      } else {
        // Se data está vazio, verificar se há execution_id_ativo no agente atual
        // Se há execution_id_ativo, assumir que está running
        if (agente.execution_id_ativo) {
          console.log(`⚠️ Resposta vazia mas agente ${agente.nome} tem execution_id_ativo - assumindo running`)
          newStatus = 'running'
          executionId = agente.execution_id_ativo
        }
      }
      
      // VALIDAÇÃO FINAL: Se há execution_id_ativo, sempre assumir que está running
      // independente do que o webhook retornou
      if (agente.execution_id_ativo && newStatus === 'stopped') {
        console.log(`🔧 CORREÇÃO FINAL: Agente ${agente.nome} tem execution_id_ativo - forçando status running`)
        newStatus = 'running'
        executionId = agente.execution_id_ativo
      }
      
      // PROTEÇÃO CRÍTICA: Se é auto-refresh e agente tem execution_id_ativo,
      // NÃO alterar o status para stopped mesmo que webhook retorne stopped
      // (Apenas para auto-refresh, não para verificação manual)
      if (isAutoRefresh && agente.execution_id_ativo && newStatus === 'stopped') {
        console.log(`🛡️ PROTEÇÃO: Auto-refresh detectou agente ${agente.nome} com execution_id_ativo - mantendo running`)
        newStatus = 'running'
        executionId = agente.execution_id_ativo
      }
      
      // LOG: Mostrar diferença entre auto-refresh e verificação manual
      if (isAutoRefresh) {
        console.log(`🔄 AUTO-REFRESH: ${agente.nome} - Status: ${newStatus}, Execution ID: ${executionId}`)
      } else {
        console.log(`🔍 VERIFICAÇÃO MANUAL: ${agente.nome} - Status: ${newStatus}, Execution ID: ${executionId}`)
      }
      
      // Atualizar o estado local dos agentes
      setAgentes(prev => prev.map(a => 
        a.id === agente.id 
          ? { 
              ...a, 
              status_atual: newStatus,
              execution_id_ativo: executionId,
              updated_at: new Date().toISOString()
            }
          : a
      ))
      
      // Notificação removida para evitar popups desnecessários
      console.log(`✅ Status do ${agente.nome} atualizado: ${newStatus}`)
      
    } catch (error: any) {
      console.error('❌ Erro ao verificar status:', error)
      push({ kind: 'error', message: 'Erro ao verificar status: ' + error.message })
    } finally {
      // Só limpar startingAgent se não for auto-refresh
      if (!isAutoRefresh) {
        setStartingAgent(null)
      }
    }
  }

  // Função para verificar status de todos os agentes
  const verificarStatusTodos = async () => {
    if (!userData || agentes.length === 0) return
    
    console.log('🔄 Verificando status de todos os agentes...')
    
    // Verificar status de cada agente
    for (const agente of agentes) {
      try {
        await verificarStatus(agente, true) // true = isAutoRefresh
        // Pequeno delay entre verificações para não sobrecarregar
        await new Promise(resolve => setTimeout(resolve, 500))
      } catch (error) {
        console.error(`❌ Erro ao verificar status do agente ${agente.nome}:`, error)
      }
    }
    
    // ✅ ADICIONAR: Recarregar lista de clientes após verificar status
    console.log('📊 Recarregando lista de clientes...')
    await loadProspects()
    
    console.log('✅ Verificação de status e recarregamento de clientes concluída')
  }

  // Função para forçar sincronização de agentes
  const handleForceSyncAgents = async () => {
    console.log('🔄 Forçando sincronização de agentes...')
    try {
      await forceSyncAgents()
      push({ kind: 'success', message: 'Sincronização de agentes executada com sucesso!' })
    } catch (error) {
      console.error('❌ Erro ao sincronizar agentes:', error)
      push({ kind: 'error', message: 'Erro ao sincronizar agentes' })
    }
  }

  // Função para forçar verificação de status real (ignorando cache)
  const handleForceStatusCheck = async () => {
    console.log('🔄 Forçando verificação de status real...')
    try {
      // Verificar status de todos os agentes SEM proteções (status real do n8n)
      for (const agente of agentes) {
        console.log(`🔍 Verificando status real do ${agente.nome}...`)
        await verificarStatus(agente, false) // false = não é auto-refresh, sem proteções
        // Pequeno delay entre verificações
        await new Promise(resolve => setTimeout(resolve, 500))
      }
      push({ kind: 'success', message: 'Verificação de status real executada!' })
    } catch (error) {
      console.error('❌ Erro ao verificar status:', error)
      push({ kind: 'error', message: 'Erro ao verificar status real' })
    }
  }

  // Função simples para listar agentes
  const listarAgentes = async () => {
    if (!userData) return
    
    // Verificar permissões de acesso
    if (!agentPermissions.canAccess) {
      console.log('❌ Usuário não tem permissão para acessar agentes')
      push({ kind: 'error', message: 'Você não tem permissão para acessar agentes' })
      return
    }
    
    try {
      console.log('🔍 Listando agentes...')
      
      // Carregar atribuições de agentes primeiro
      await loadAgentesAtribuicoes()
      
      // Determinar se deve listar todos os agentes ou apenas os próprios
      const shouldListAll = agentPermissions.canViewAll || agentPermissions.canManage
      
      const response = await callWebhook('webhook/list-agentes', {
              method: 'GET',
        params: {
          usuario_id: userData.id,
          list_all: shouldListAll
        }
      })
      
      console.log('📥 Resposta do webhook:', response)
      
      if (response && response.data) {
        // Verificar se é array ou objeto com array
        let agentesList = []
        if (Array.isArray(response.data) && response.data.length > 0 && response.data[0].success && Array.isArray(response.data[0].data)) {
          // Formato: [{ success: true, data: [...] }]
          agentesList = response.data[0].data
        } else if (response.data.data && Array.isArray(response.data.data)) {
          // Formato: { data: [...] }
          agentesList = response.data.data
        } else if (response.data.success && response.data.data) {
          // Formato: { success: true, data: [...] }
          agentesList = response.data.data
        }
        
        console.log('✅ Agentes encontrados:', agentesList.length)
        
        // Filtrar agentes baseado nas permissões do usuário
        const agentesFiltrados = agentesList.filter((agente: any) => {
          console.log(`🔍 Filtrando agente: ${agente.nome} (usuario_id: ${agente.usuario_id})`)
          console.log(`🔍 Permissões: canViewAll=${agentPermissions.canViewAll}, canManage=${agentPermissions.canManage}, canViewOwn=${agentPermissions.canViewOwn}, canAssignAgents=${agentPermissions.canAssignAgents}`)
          
          // REGRA PRINCIPAL: Se é administrador, sempre mostrar todos os agentes
          if (agentPermissions.canViewAll || agentPermissions.canManage) {
            console.log(`✅ ${agente.nome}: Mostrando (ADMIN - vê todos)`)
            return true
          }
          
          // Para usuários não-admin: verificar se o agente está atribuído para eles
          const userId = parseInt(userData.id)
          
          // Se o agente está atribuído para o usuário atual, mostrar
          if (isAgenteAtribuidoParaUsuario(agente.id, userId)) {
            console.log(`✅ ${agente.nome}: Mostrando (atribuído para o usuário)`)
            return true
          }
          
          // Caso contrário, não mostrar
          console.log(`❌ ${agente.nome}: Ocultando (não atribuído para o usuário)`)
          return false
        })
        
        console.log(`🔍 Agentes filtrados: ${agentesFiltrados.length} de ${agentesList.length}`)
        
        // Preservar estado atual dos agentes (status, execution_id, etc.)
        setAgentes(prevAgentes => {
          console.log('🔄 Estado anterior dos agentes:', prevAgentes)
          console.log('🔄 Novos agentes do banco:', agentesFiltrados)
          
          const agentesAtualizados = agentesFiltrados.map((novoAgente: any) => {
            // Procurar se já existe um agente com o mesmo ID
            const agenteExistente = prevAgentes.find(agente => agente.id === novoAgente.id)
            
            console.log(`🔍 Processando agente: ID=${novoAgente.id}, Nome="${novoAgente.nome}"`)
            
            // Mapear webhooks corretamente - usar APENAS URLs do banco de dados
            const agenteComWebhooks = {
              ...novoAgente,
              webhook_start_url: novoAgente.webhook_start_url,
              webhook_status_url: novoAgente.webhook_status_url,
              webhook_lista_url: novoAgente.webhook_lista_url,
              webhook_stop_url: novoAgente.webhook_stop_url
            }
            
            console.log(`🔍 Webhooks gerados para ${novoAgente.nome}:`, {
              webhook_start_url: agenteComWebhooks.webhook_start_url,
              webhook_stop_url: agenteComWebhooks.webhook_stop_url,
              webhook_status_url: agenteComWebhooks.webhook_status_url,
              webhook_lista_url: agenteComWebhooks.webhook_lista_url
            })
            
            if (agenteExistente) {
              console.log(`🔄 Preservando estado para ${novoAgente.nome}:`, {
                status_atual: agenteExistente.status_atual,
                execution_id_ativo: agenteExistente.execution_id_ativo
              })
              
              // Preservar estado atual se existir - priorizar dados existentes
              return {
                ...agenteComWebhooks, // Dados atualizados do banco com webhooks
                status_atual: agenteExistente.status_atual || novoAgente.status_atual,
                execution_id_ativo: agenteExistente.execution_id_ativo !== undefined ? agenteExistente.execution_id_ativo : (novoAgente.execution_id_ativo || null),
                updated_at: agenteExistente.updated_at || novoAgente.updated_at
              }
            }
            
            // Se é um agente novo, usar dados do banco com webhooks
            return agenteComWebhooks
          })
          
          console.log('🔄 Agentes atualizados preservando estado:', agentesAtualizados.length)
          console.log('🔄 Estado final dos agentes:', agentesAtualizados)
          return agentesAtualizados
        })
        
        // Notificação removida para evitar popups desnecessários
      } else {
        console.log('⚠️ Nenhum agente encontrado')
        setAgentes([])
        push({ kind: 'warning', message: 'Nenhum agente encontrado' })
      }
      
    } catch (error: any) {
      console.error('❌ Erro ao listar agentes:', error)
      push({ kind: 'error', message: 'Erro ao carregar agentes: ' + error.message })
    } finally {
      // Loading removido
    }
  }

  // Função para parar agente
  const pararAgente = async (agente: any) => {
    if (!userData) return
    
    setStoppingAgent(agente.id)
    try {
      console.log(`🛑 Parando agente ${agente.nome}...`)
      
      // Debug detalhado do agente
      console.log('🔍 DEBUG AGENTE COMPLETO:', agente)
      console.log('🔍 execution_id_ativo:', agente.execution_id_ativo)
      console.log('🔍 execution_id:', agente.execution_id)
      console.log('🔍 status_atual:', agente.status_atual)
      
      const executionId = agente.execution_id_ativo || agente.execution_id || null
      console.log('🔍 Execution ID final para envio:', executionId)
      
      // Validar se há execution_id válido
      if (!executionId) {
        console.warn(`⚠️ Agente ${agente.nome} não tem execution_id válido para parar`)
        push({ kind: 'error', message: `Agente ${agente.nome} não está rodando ou não tem execution_id válido` })
        return
      }
      
      const payload = {
        action: 'stop',
        agent_type: agente.id,
        workflow_id: agente.id,
        timestamp: new Date().toISOString(),
        usuario_id: userData.id,
        execution_id: executionId
      }
      
      console.log('📦 Payload enviado:', payload)
      
      // Usar webhook do banco de dados (sem fallback)
      const webhookId = agente.webhook_stop_url
      
      if (!webhookId) {
        console.warn(`⚠️ Agente ${agente.nome} não tem webhook_stop_url configurado`)
        push({ kind: 'error', message: `Agente ${agente.nome} não tem webhook de parada configurado` })
        return
      }
      
      console.log(`🔍 Usando webhook: ${webhookId}`)
      
      const response = await callWebhook(webhookId, {
        method: 'POST',
        data: payload
      })
      
      console.log('📥 Resposta do webhook stop:', response)
      
      // Verificar se a parada foi bem-sucedida
      if (response && response.status === 200) {
        const responseData = Array.isArray(response.data) ? response.data[0] : response.data
        
        // Para webhooks stop, resposta vazia ou com sucesso é considerada válida
        const isSuccess = responseData?.success || 
                         responseData?.message?.includes('sucesso') || 
                         responseData?.message?.includes('parado') ||
                         !responseData || 
                         response.data === '' ||
                         (responseData && Object.keys(responseData).length === 0)
        
        if (isSuccess) {
          // Atualizar o agente na lista com o novo status
          console.log(`🔄 Atualizando estado do agente ${agente.nome} para stopped...`)
          setAgentes(prev => {
            const updated = prev.map(a => 
            a.id === agente.id 
              ? { 
                  ...a, 
                  status_atual: 'stopped',
                  execution_id_ativo: null,
                  updated_at: new Date().toISOString()
                }
              : a
            )
            console.log(`🔄 Estado atualizado do agente ${agente.nome}:`, updated.find(a => a.id === agente.id))
            return updated
          })
          
          console.log(`✅ ${agente.nome} parado com sucesso`)
          push({ kind: 'success', message: `Agente ${agente.nome} parado com sucesso!` })
            } else {
          console.warn(`⚠️ ${agente.nome} - resposta inesperada:`, responseData)
          push({ kind: 'error', message: `Falha ao parar ${agente.nome} - resposta inválida: ${JSON.stringify(responseData)}` })
            }
          } else {
        console.error(`❌ ${agente.nome} - erro de comunicação:`, response)
        push({ kind: 'error', message: `Falha ao parar ${agente.nome} - erro de comunicação (status: ${response?.status})` })
      }
      
    } catch (error: any) {
      console.error('❌ Erro ao parar agente:', error)
      push({ kind: 'error', message: 'Erro ao parar agente: ' + error.message })
    } finally {
      setStoppingAgent(null)
    }
  }

  // Função para iniciar agente
  const iniciarAgente = async (agente: any, isBatchStart = false) => {
    if (!userData) return
    
    // Só definir startingAgent se não for início em lote
    if (!isBatchStart) {
    setStartingAgent(agente.id)
    }
    try {
      console.log(`🚀 Iniciando agente ${agente.nome}...`)
      
      // Buscar dados do usuário para montar payload correto
      const usuarioId = parseInt(userData.id || '0')
      const agenteId = parseInt(agente.id)
      
      // Buscar dados reais do usuário e agente
      let perfisPermitidos = [1, 2] // Padrão
      let perfilId = 1 // Padrão
      
      // VALIDAÇÃO DE SEGURANÇA: Verificar se usuário tem empresa_id
      if (!userData.empresa_id) {
        console.error('🚨 FALHA DE SEGURANÇA: Usuário não possui empresa_id')
        push({ kind: 'error', message: '🚨 FALHA DE SEGURANÇA: Usuário não possui empresa_id. Contate o administrador para configurar sua empresa.' })
        return
      }

      // Usar dados baseados no usuário conhecido (webhook list-user-profiles não existe)
      perfisPermitidos = usuarioId === 6 ? [2, 3] : [1, 2]
      perfilId = perfisPermitidos[0]
      
      const payload = {
        usuario_id: usuarioId,
        action: 'start',
        logged_user: {
          id: usuarioId,
          name: userData.name,
          email: userData.mail,
          empresa_id: userData.empresa_id // OBRIGATÓRIO - sem fallback por segurança
        },
        agente_id: agenteId,
        perfil_id: perfilId,
        perfis_permitidos: perfisPermitidos,
        usuarios_permitidos: [usuarioId],
        empresa_id: userData.empresa_id // OBRIGATÓRIO - sem fallback por segurança
      }
      
      console.log('📦 Payload enviado:', payload)
      
      // Usar webhook do banco de dados (sem fallback)
      const webhookId = agente.webhook_start_url
      
      if (!webhookId) {
        console.warn(`⚠️ Agente ${agente.nome} não tem webhook_start_url configurado`)
        push({ kind: 'error', message: `Agente ${agente.nome} não tem webhook de início configurado` })
        return
      }
      
      console.log(`🔍 Usando webhook: ${webhookId}`)
      
      const response = await callWebhook(webhookId, {
        method: 'POST',
        data: payload
      })
      
      console.log('📥 Resposta do webhook start:', response)
      
      // Tratar resposta como array ou objeto
      const responseData = Array.isArray(response.data) ? response.data[0] : response.data
      
      // Tentar extrair execution_id de vários campos possíveis
      const executionId = responseData?.execution_id || 
                         responseData?.executionId || 
                         responseData?.id || 
                         responseData?.workflow_id ||
                         responseData?.execution?.id ||
                         responseData?.data?.execution_id
      
      console.log('🔍 Dados processados do start:', responseData)
      console.log('🔍 Execution ID extraído:', executionId)
      console.log('🔍 Campos disponíveis:', Object.keys(responseData || {}))
      
      if (response && response.status === 200 && executionId) {
        // Atualizar o agente na lista com o novo status
        setAgentes(prev => prev.map(a => 
          a.id === agente.id 
            ? { 
                ...a, 
                status_atual: 'running',
                execution_id_ativo: executionId,
                updated_at: new Date().toISOString()
              }
            : a
        ))
        
        // Notificação removida para evitar popups desnecessários
        console.log(`✅ ${agente.nome} iniciado - Execution ID: ${executionId || 'N/A'}`)
        
        // Aguardar 3 segundos antes de verificar status para dar tempo do workflow iniciar
        setTimeout(() => {
          console.log(`🔄 Verificando status do ${agente.nome} após início...`)
          verificarStatus(agente, true)
        }, 3000)
      } else {
        push({ kind: 'error', message: 'Falha ao iniciar agente - resposta inválida' })
      }
      
    } catch (error: any) {
      console.error('❌ Erro ao iniciar agente:', error)
      push({ kind: 'error', message: 'Erro ao iniciar agente: ' + error.message })
    } finally {
      // Só limpar startingAgent se não for início em lote
      if (!isBatchStart) {
      setStartingAgent(null)
      }
    }
  }

  // Carregar agentes e status inicial
  useEffect(() => {
    if (userData) {
      listarAgentes()
      setTimeout(() => {
        verificarStatusTodos()
      loadProspects()
      }, 1000)
    }
  }, [userData])

  // ❌ REMOVIDO: Não é necessário carregar agentes para upload
  // Os agentes pegam lotes da base comum

  // Auto-refresh do status a cada 30 segundos (reduzido para evitar conflitos)
  useEffect(() => {
    if (!userData || agentes.length === 0 || !autoRefreshEnabled) {
      setAutoRefreshActive(false)
      return
    }

    console.log('⏰ Iniciando refresh automático a cada 30 segundos')
    setAutoRefreshActive(true)
    
    const interval = setInterval(() => {
      // Só verificar status se não há operações em andamento
      if (!startingAgent && !stoppingAgent && !isStartingAllAgents && !isStoppingAllAgents) {
        console.log('🔄 Auto-refresh: Verificando status...')
      verificarStatusTodos()
      } else {
        console.log('⏭️ Auto-refresh: Pulando verificação (operação em andamento)')
      }
    }, 30000) // Aumentado para 30 segundos

    return () => {
      console.log('⏹️ Parando refresh automático')
      setAutoRefreshActive(false)
      clearInterval(interval)
    }
  }, [userData, agentes.length, startingAgent, stoppingAgent, isStartingAllAgents, isStoppingAllAgents, autoRefreshEnabled])

  // AUTOREFRESH DESABILITADO - APENAS CONTROLE MANUAL
  // useEffect(() => {
  //   console.log('🔧 AUTOREFRESH DESABILITADO - usando apenas controle manual')
  // }, [])

  // Pooling de clientes a cada 20 segundos (reduzido para evitar sobrecarga)
  useEffect(() => {
    if (!userData) return

    console.log('✅ Criando pooling de clientes a cada 20 segundos')
    
    const interval = setInterval(() => {
      console.log('🔄 Pooling de clientes executado!')
      
      // Verificar se há agentes carregados
      if (agentes.length === 0) {
        console.log('⏭️ Pooling: Nenhum agente carregado, pulando...')
        return
      }
      
      // Verificar se há operações em andamento
      if (startingAgent || stoppingAgent || isStartingAllAgents || isStoppingAllAgents) {
        console.log('⏭️ Pooling: Pulando (operação em andamento)')
        return
      }
      
      const hasRunningAgent = agentes.some(agente => agente.status_atual === 'running')
      const hasExistingData = Object.values(prospects).some(p => p.length > 0)
      
      // Só recarregar se:
      // 1. Há agente rodando (dados podem ter mudado)
      // 2. Não há dados existentes (primeira carga)
      // 3. Não há estatísticas calculadas (primeira carga)
      const needsRefresh = hasRunningAgent || !hasExistingData || Object.keys(prospectsStats).length === 0
      
      if (needsRefresh) {
        console.log('📥 Pooling: Recarregando clientes...')
        loadProspects()
      } else {
        console.log('⏭️ Pooling: Pulando recarregamento (dados existentes e nenhum agente rodando)')
      }
    }, 20000) // Aumentado para 20 segundos

    return () => {
      console.log('🛑 Limpando pooling de clientes')
      clearInterval(interval)
    }
  }, [userData, agentes, prospects, prospectsStats, loadProspects])

  // Função para processar arquivo quando selecionado
  async function handleFileSelect(selectedFile: File | null) {
    setFile(selectedFile)
    if (selectedFile) {
      try {
        // Notificação removida para evitar popups desnecessários
        const data = await readExcelFile(selectedFile)
        setExtractedData(data)
        // Notificação removida para evitar popups desnecessários
      } catch (error) {
        push({ kind: 'error', message: 'Erro ao processar arquivo Excel.' })
        setExtractedData([])
      }
    } else {
      setExtractedData([])
      setShowAllData(false)
    }
  }

  // Função para remover arquivo selecionado
  function handleRemoveFile() {
    setFile(null)
    setExtractedData([])
    setShowAllData(false)
    // Reset file input
    const fileInput = document.getElementById('file-upload') as HTMLInputElement
    if (fileInput) fileInput.value = ''
    // Notificação removida para evitar popups desnecessários
  }

  // ❌ REMOVIDO: Funções de seleção de agente não são necessárias
  // Os agentes pegam lotes da base comum de leads

  async function handleUpload(e: React.FormEvent) {
    e.preventDefault()
    if (!file || !userData || extractedData.length === 0) return
    
    // VALIDAÇÃO DE SEGURANÇA: Verificar se usuário tem empresa_id
    if (!userData.empresa_id) {
      push({ kind: 'error', message: '🚨 FALHA DE SEGURANÇA: Usuário não possui empresa_id. Acesso negado por segurança.' })
      return
    }
    
    setUploading(true)
    try {
      // Criar payload simples - sem agente_id (será definido no lote)
      const payload = {
        // Dados do usuário logado
        logged_user: {
          id: userData.id,
          name: userData.name,
          email: userData.mail,
          empresa_id: userData.empresa_id // OBRIGATÓRIO - sem fallback por segurança
        },
        // Dados extraídos do Excel
        data: extractedData,
        // ❌ REMOVIDO: agente_id (será definido quando agente pegar o lote)
        // Metadados do arquivo
        file_info: {
          name: file.name,
          size: file.size,
          type: file.type,
          lastModified: file.lastModified
        },
        empresa_id: userData.empresa_id // OBRIGATÓRIO - sem fallback por segurança
      }

      console.log('📦 Payload de upload (base comum):', payload)

      await callWebhook('webhook-upload', { 
        method: 'POST', 
        data: payload,
        headers: {
          'Content-Type': 'application/json'
        }
      })
      
      // Notificação removida para evitar popups desnecessários
      setFile(null)
      setExtractedData([])
      setShowAllData(false)
      // Reset file input
      const fileInput = document.getElementById('file-upload') as HTMLInputElement
      if (fileInput) fileInput.value = ''
    } catch (e: any) {
      console.error('Erro no upload:', e)
      let errorMessage = 'Falha no upload do arquivo.'
      
      // Tratamento específico baseado na resposta real do n8n
      if (e.response?.status === 200 && e.response?.data) {
        // N8n retorna status 200 mas com dados sobre duplicados
        const responseData = e.response.data
        
        if (responseData.duplicados > 0) {
          const totalProcessados = responseData.total || 0
          const novos = responseData.novos || 0
          const duplicados = responseData.duplicados || 0
          
          if (duplicados === totalProcessados) {
            // Todos os registros são duplicados
            errorMessage = `⚠️ Todos os ${duplicados} registros da planilha já existem no sistema. Nenhum dado novo foi inserido. Verifique se você está enviando a planilha correta.`
          } else {
            // Alguns registros são duplicados
            errorMessage = `⚠️ Processamento concluído com duplicados: ${novos} novos registros inseridos, ${duplicados} registros duplicados ignorados de um total de ${totalProcessados}. Verifique os telefones duplicados nos detalhes.`
          }
          
          // Mostrar como info com aviso, já que tecnicamente funcionou
          push({ kind: 'info', message: errorMessage })
          return
        } else {
          // Sucesso normal
          // Notificação removida para evitar popups desnecessários
          return
        }
      } else if (e.response?.status === 400) {
        const responseData = e.response?.data
        
        if (responseData?.error?.includes('duplicate') || 
            responseData?.message?.includes('duplicate') ||
            responseData?.error?.includes('duplicado') || 
            responseData?.message?.includes('duplicado')) {
          errorMessage = '⚠️ Dados duplicados detectados na planilha. Verifique se há registros repetidos (mesmo telefone ou email) e remova as duplicatas antes de fazer o upload novamente.'
        } else if (responseData?.error?.includes('validation') || 
                   responseData?.message?.includes('validation')) {
          errorMessage = '❌ Erro de validação: Verifique se todos os campos obrigatórios estão preenchidos corretamente na planilha.'
        } else if (responseData?.error || responseData?.message) {
          errorMessage = `❌ Erro do servidor: ${responseData.error || responseData.message}`
        } else {
          errorMessage = '❌ Erro na validação dos dados. Verifique o formato da planilha e tente novamente.'
        }
      } else if (e.response?.status === 422) {
        const responseData = e.response?.data
        if (responseData?.error || responseData?.message) {
          errorMessage = `📋 Dados inválidos: ${responseData.error || responseData.message}`
        } else {
          errorMessage = '📋 Alguns dados da planilha estão em formato inválido. Verifique os campos e tente novamente.'
        }
      } else if (e.response?.status === 413) {
        errorMessage = '📁 Arquivo muito grande. Tente um arquivo menor.'
      } else if (e.response?.status >= 500) {
        errorMessage = '🔧 Erro interno do servidor. Tente novamente em alguns instantes ou contate o suporte.'
      } else if (!e.response) {
        errorMessage = '🌐 Erro de conexão. Verifique sua internet e se o servidor está acessível.'
      }
      
      push({ kind: 'error', message: errorMessage })
    } finally {
      setUploading(false)
    }
  }

  async function handleStartAgent(agente: any) {
    await iniciarAgente(agente)
  }

  async function handleStartAllAgents() {
    if (!userData || agentes.length === 0) return
    
    setIsStartingAllAgents(true)
    
    try {
      console.log(`🚀 Iniciando todos os ${agentes.length} agentes simultaneamente...`)
      
      // Iniciar todos os agentes em paralelo usando a função iniciarAgente existente
      const startPromises = agentes.map(async (agente) => {
        try {
          console.log(`🚀 Iniciando agente ${agente.nome} (ID: ${agente.id})...`)
          
          // Usar a função iniciarAgente existente que já tem toda a lógica correta
          await iniciarAgente(agente, true) // true = isBatchStart
          
          return { success: true, agentName: agente.nome, agentId: agente.id }
        } catch (error) {
          console.error(`❌ Erro ao iniciar agente ${agente.nome}:`, error)
          return { success: false, agentName: agente.nome, agentId: agente.id, error }
        }
      })
      
      // Aguardar todos os agentes iniciarem
      const results = await Promise.all(startPromises)
      
      // Contar sucessos e falhas
      const successful = results.filter(r => r.success)
      const failed = results.filter(r => !r.success)
      
      console.log(`✅ Resultados: ${successful.length} sucessos, ${failed.length} falhas`)
      
      if (successful.length > 0) {
        const successNames = successful.map(r => r.agentName).join(', ')
        push({ 
          kind: 'success', 
          message: `🛑 ${successful.length} agente(s) parado(s) com sucesso: ${successNames}` 
        })
      }
      
      if (failed.length > 0) {
        const failedNames = failed.map(r => r.agentName).join(', ')
        const failedDetails = failed.map(r => `${r.agentName} (${r.error})`).join('; ')
        push({ 
          kind: 'error', 
          message: `❌ ${failed.length} agente(s) falharam ao parar: ${failedDetails}` 
        })
      }
      
      // Recarregar status e clientes após 5 segundos para dar tempo dos workflows iniciarem
      setTimeout(() => {
        console.log('🔄 Recarregando status e clientes após início simultâneo...')
        verificarStatusTodos()
      }, 5000)
      
        } catch (error) {
      console.error('❌ Erro geral ao iniciar agentes:', error)
      push({ kind: 'error', message: 'Falha ao iniciar os agentes.' })
        } finally {
      setIsStartingAllAgents(false)
    }
  }

  async function handleStopAgent(agente: any) {
    // Verificar se o agente está rodando antes de tentar parar
    if (agente.status_atual !== 'running') {
      console.warn(`⚠️ Agente ${agente.nome} não está rodando (status: ${agente.status_atual})`)
      push({ kind: 'warning', message: `Agente ${agente.nome} não está rodando` })
      return
    }
    
    await pararAgente(agente)
  }

  async function handleStopAllAgents() {
    if (!userData || agentes.length === 0) return
    
    setIsStoppingAllAgents(true)
    
    try {
      // Filtrar apenas agentes que estão rodando
      const agentesRodando = agentes.filter(agente => agente.status_atual === 'running')
      
      if (agentesRodando.length === 0) {
        console.log('ℹ️ Nenhum agente está rodando para parar')
        push({ kind: 'info', message: 'Nenhum agente está rodando para parar' })
        return
      }
      
      console.log(`🛑 Parando ${agentesRodando.length} agente(s) rodando simultaneamente...`)
      
      // Parar apenas agentes que estão rodando
      const stopPromises = agentesRodando.map(async (agente) => {
        try {
          console.log(`🛑 Parando agente ${agente.nome} (ID: ${agente.id})...`)
          
          // Usar a função pararAgente existente que já tem toda a lógica correta
          await pararAgente(agente)
          
          return { success: true, agentName: agente.nome, agentId: agente.id }
        } catch (error) {
          console.error(`❌ Erro ao parar agente ${agente.nome}:`, error)
          return { success: false, agentName: agente.nome, agentId: agente.id, error: error.message }
        }
      })
      
      // Aguardar todos os agentes pararem
      const results = await Promise.all(stopPromises)
      
      // Contar sucessos e falhas
      const successful = results.filter(r => r.success).length
      const failed = results.filter(r => !r.success).length
      
      console.log(`✅ Resultados: ${successful} sucessos, ${failed} falhas`)
      
      if (successful > 0) {
        push({ 
          kind: 'success', 
          message: `🛑 ${successful} agente(s) parado(s) com sucesso!` 
        })
      }
      
      if (failed > 0) {
        push({ 
          kind: 'error', 
          message: `❌ ${failed} agente(s) falharam ao parar.` 
        })
      }
      
      // Recarregar status e clientes após 1 segundo
      setTimeout(() => {
        console.log('🔄 Recarregando status e clientes após parada simultânea...')
        verificarStatusTodos()
      }, 1000)
      
    } catch (error) {
      console.error('❌ Erro geral ao parar agentes:', error)
      push({ kind: 'error', message: 'Falha ao parar os agentes.' })
    } finally {
      setIsStoppingAllAgents(false)
    }
  }

  // Verificar se o usuário está logado
  if (!userData) {
    return (
      <div className="card p-6 text-center">
        <AlertCircle className="w-12 h-12 text-yellow-500 mx-auto mb-4" />
        <h2 className="text-lg font-semibold mb-2">Dados do usuário não encontrados</h2>
        <p className="text-zinc-400 mb-4">É necessário fazer login novamente para acessar esta funcionalidade.</p>
        <button 
          onClick={() => useAuthStore.getState().logout()}
          className="btn btn-primary"
        >
          Fazer Login
        </button>
      </div>
    )
  }

  // Determinar quantos registros mostrar
  const recordsToShow = showAllData ? extractedData : extractedData.slice(0, 10)
  const hasMoreRecords = extractedData.length > 10

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-semibold text-foreground mb-2">Upload de Arquivo</h1>
        <p className="text-muted-foreground">Faça upload de planilhas Excel e gerencie o agente de prospecção</p>
      </div>

      {/* Main Content Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Upload Section */}
        <div className="card">
          <div className="card-header flex items-center gap-2">
            <UploadIcon className="w-5 h-5" />
            <span>Upload de Arquivo Excel</span>
          </div>
          <div className="card-content space-y-4">
            <p className="text-sm text-muted-foreground">Faça upload de planilhas .xls ou .xlsx para processamento</p>

            {/* ✅ INFORMAÇÃO: Leads vão para base comum */}
            <div className="mb-4 p-4 bg-blue-50 border border-blue-200 rounded-md">
              <p className="text-blue-800">
                ℹ️ Os leads serão inseridos na base comum. 
                Os agentes pegarão lotes automaticamente quando iniciarem a prospecção.
              </p>
            </div>

            {/* File Upload Area */}
            <div className="border-2 border-dashed border-border rounded-lg hover:border-primary/50 transition-colors relative">
              <input 
                id="file-upload"
                type="file" 
                accept=".xls,.xlsx" 
                onChange={(e) => handleFileSelect(e.target.files?.[0] ?? null)}
                className="absolute inset-0 w-full h-full opacity-0 cursor-pointer z-10"
              />
              <div className="p-8 text-center">
                <div className="w-16 h-16 bg-primary/10 rounded-full flex items-center justify-center mx-auto mb-4">
                  <UploadIcon className="w-8 h-8 text-primary" />
                </div>
                <div className="space-y-2">
                  <p className="font-medium text-foreground">Arraste um arquivo aqui</p>
                  <p className="text-sm text-muted-foreground">ou clique para selecionar</p>
                </div>
                <div className="mt-4">
                  <span className="btn btn-primary inline-block">
                    Selecionar Arquivo
                  </span>
                </div>
                <p className="text-xs text-muted-foreground mt-2">Formatos aceitos: .xls, .xlsx</p>
              </div>
            </div>

            {/* File Info */}
            {file && (
              <div className="space-y-3">
                <div className="bg-muted/30 rounded-lg p-3 flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 bg-primary/20 rounded flex items-center justify-center">
                      <UploadIcon className="w-4 h-4 text-primary" />
                    </div>
                    <div>
                      <p className="text-sm font-medium text-foreground">{file.name}</p>
                      <p className="text-xs text-muted-foreground">{(file.size / 1024 / 1024).toFixed(2)} MB</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-3">
                    <div className="text-xs text-muted-foreground">
                      {extractedData.length} registros
                    </div>
                    <button
                      onClick={handleRemoveFile}
                      className="w-6 h-6 rounded-full bg-destructive/20 hover:bg-destructive/30 flex items-center justify-center text-destructive hover:text-destructive/80 transition-colors"
                      title="Remover arquivo"
                    >
                      <X className="w-3 h-3" />
                    </button>
                  </div>
                </div>

                {/* Upload Button */}
                <form onSubmit={handleUpload}>
                  <button 
                    type="submit" 
                    disabled={uploading || extractedData.length === 0} 
                    className="btn btn-primary w-full"
                  >
                    {uploading ? 'Enviando...' : `Enviar ${extractedData.length} registros`}
                  </button>
                </form>
              </div>
            )}
          </div>
        </div>

        {/* Data Preview Section */}
        <div className="card">
          <div className="card-header flex items-center gap-2">
            <Users className="w-5 h-5" />
            <span>Preview dos dados</span>
          </div>
          <div className="card-content">
            {extractedData.length > 0 ? (
              <div className="space-y-4">
                <p className="text-sm text-muted-foreground">Dados extraídos do arquivo Excel:</p>
                
                {/* Data Preview */}
                <div className="bg-muted/30 rounded-lg p-4 max-h-96 overflow-y-auto">
                  <div className="space-y-3">
                    {recordsToShow.map((row, idx) => (
                      <div key={idx} className="border-b border-border pb-2 last:border-b-0">
                        <div className="grid grid-cols-2 gap-2 text-xs">
                          {Object.entries(row).map(([key, value]) => {
                            if (key === 'ID') return null // Não mostra o ID
                            return (
                              <div key={key}>
                                <span className="text-muted-foreground">{key}:</span>
                                <span className="text-foreground ml-2">{String(value) || '-'}</span>
                              </div>
                            )
                          })}
                        </div>
                      </div>
                    ))}
                    
                    {/* Botão para expandir/contrair */}
                    {hasMoreRecords && (
                      <div className="text-center pt-2">
                        <button
                          onClick={() => setShowAllData(!showAllData)}
                          className="flex items-center gap-2 mx-auto text-primary hover:text-primary/80 text-sm transition-colors"
                        >
                          {showAllData ? (
                            <>
                              <ChevronUp className="w-4 h-4" />
                              Mostrar menos registros
                            </>
                          ) : (
                            <>
                              <ChevronDown className="w-4 h-4" />
                              Ver todos os {extractedData.length} registros
                            </>
                          )}
                        </button>
                      </div>
                    )}
                  </div>
                </div>

                {/* Statistics */}
                <div className="flex justify-center">
                  <div className="bg-muted/30 rounded-lg p-6 text-center">
                    <div className="text-4xl font-bold text-primary">{extractedData.length}</div>
                    <div className="text-sm text-muted-foreground">Total de contatos</div>
                  </div>
                </div>
              </div>
            ) : (
              <div className="text-center py-8 text-muted-foreground">
                <Users className="w-12 h-12 mx-auto mb-2 opacity-50" />
                <p>Nenhum arquivo selecionado</p>
                <p className="text-xs mt-1">Selecione um arquivo Excel para visualizar os dados</p>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Agent Control Section - Reorganized Layout */}
      <div className="card">
        <div className="card-header flex flex-row items-center justify-between w-full">
          <div className="flex items-center gap-2">
            <Zap className="w-5 h-5" />
            <span className="text-lg font-semibold">Agente de Prospecção</span>
          </div>
          <button
            onClick={verificarStatusTodos}
            className="btn btn-outline flex items-center gap-2 h-10 px-4 flex-shrink-0"
            title="Recarregar status manualmente"
          >
            <div className="w-5 h-5">
              🔄
            </div>
            <span className="font-medium">Atualizar</span>
          </button>
        </div>
        <div className="card-content">
          <div className="space-y-6">
            <div className="flex items-center justify-between">
            <p className="text-sm text-muted-foreground">Controle o agente automatizado de prospecção de leads</p>
            </div>
            
            {/* Global Control Buttons */}
            <div className="flex justify-end gap-4">
              {agentPermissions.canCreate && (
              <button
                onClick={() => setShowCreateAgentModal(true)}
                className="btn btn-secondary flex items-center gap-2"
                title="Criar novo agente com workflows automáticos"
              >
                <Plus className="w-4 h-4" />
                Criar Agente
              </button>
              )}
              
              <button
                onClick={handleStopAllAgents}
                disabled={isStoppingAllAgents || Object.values(agentLoading).some(loading => loading)}
                className="btn btn-destructive flex items-center gap-2"
                title="Parar todos os agentes simultaneamente"
              >
                {isStoppingAllAgents ? (
                  <>
                    <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                    Parando...
                  </>
                ) : (
                  <>
                    <div className="w-4 h-4">⏹️</div>
                    Parar Todos
                  </>
                )}
              </button>
              
              <button
                onClick={handleStartAllAgents}
                disabled={isStartingAllAgents || Object.values(agentLoading).some(loading => loading)}
                className="btn btn-primary flex items-center gap-2"
                title="Iniciar todos os agentes simultaneamente"
              >
                {isStartingAllAgents ? (
                  <>
                    <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                    Iniciando...
                  </>
                ) : (
                  <>
                    <Play className="w-4 h-4" />
                    Iniciar Todos
                  </>
                )}
              </button>
            </div>


            {/* Sistema de Sincronização de Agentes - Apenas para administradores */}
            {agentPermissions.canManage && (
              <AgentSyncManager 
                onAgentsChange={(syncedAgents) => {
                  console.log('🔄 Agentes sincronizados:', Object.keys(syncedAgents).length)
                }}
                autoSync={true}
                syncInterval={30000}
              />
            )}

            {/* Individual Agent Sections */}
            {!agentPermissions.canAccess ? (
              <div className="text-center py-12">
                <div className="text-muted-foreground mb-4">
                  <AlertCircle className="w-16 h-16 mx-auto mb-4 opacity-50" />
                  <h3 className="text-lg font-semibold mb-2">Acesso Negado</h3>
                  <p className="text-sm">Você não tem permissão para acessar agentes.</p>
                  <p className="text-xs text-muted-foreground mt-2">
                    Entre em contato com o administrador para solicitar acesso.
                  </p>
                      </div>
                    </div>
            ) : agentes.length === 0 ? (
              <div className="text-center py-12">
                <div className="text-muted-foreground mb-4">
                  <Users className="w-16 h-16 mx-auto mb-4 opacity-50" />
                  <h3 className="text-lg font-semibold mb-2">Nenhum agente encontrado</h3>
                  <p className="text-sm">Não há agentes disponíveis para você no momento.</p>
                  {agentPermissions.canViewAll && (
                    <p className="text-xs text-muted-foreground mt-2">
                      Você tem permissão para ver todos os agentes, mas nenhum foi encontrado.
                    </p>
                  )}
                  <div className="mt-4 p-4 bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800 rounded-lg">
                    <p className="text-sm text-yellow-800 dark:text-yellow-200">
                      <strong>Possíveis causas:</strong>
                    </p>
                    <ul className="text-xs text-yellow-700 dark:text-yellow-300 mt-2 text-left">
                      <li>• Agentes não estão ativos no banco de dados</li>
                      <li>• Webhooks dos agentes não estão configurados</li>
                      <li>• Problema de conectividade com n8n</li>
                      <li>• Usuário não tem permissões adequadas</li>
                    </ul>
                  </div>
                  {agentPermissions.canViewOwn && (
                    <p className="text-xs text-muted-foreground mt-2">
                      Você tem permissão para ver apenas seus próprios agentes.
                    </p>
                  )}
                    </div>
                <button
                  onClick={() => {
                    console.log('🔄 Forçando recarregamento de agentes...')
                    listarAgentes()
                  }}
                  className="px-4 py-2 bg-primary text-primary-foreground rounded-md hover:bg-primary/90 transition-colors"
                >
                  Recarregar Agentes
                </button>
                  </div>
            ) : (
              <div className="space-y-4">
                {agentes.map((agente) => {
              const isRunning = agente.status_atual === 'running'
              const isLoading = startingAgent === agente.id
              const isStopping = stoppingAgent === agente.id
              
              return (
                    <div key={agente.id} className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                      {/* Seção do Agente */}
                      <div className="border border-border rounded-lg p-10 space-y-6 min-h-[280px]">
                    <div className="flex items-center gap-3">
                          <span className="text-2xl">{agente.icone}</span>
                      <div>
                            <h3 className="text-lg font-semibold">{agente.nome}</h3>
                            <p className="text-sm text-muted-foreground">{agente.descricao}</p>
                                </div>
                              </div>

                        <div className="flex gap-2">
                          <button 
                            onClick={() => handleStartAgent(agente)}
                            disabled={isLoading || isStopping || isRunning || !agentPermissions.canExecute}
                            className="btn btn-primary"
                            title={!agentPermissions.canExecute ? 'Você não tem permissão para executar agentes' : ''}
                          >
                            {isLoading ? (
                              <>
                                <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin mr-2"></div>
                                Carregando...
                              </>
                            ) : 'Iniciar'}
                          </button>
                          <button 
                            onClick={() => handleStopAgent(agente)}
                            disabled={isLoading || isStopping || !isRunning || !agentPermissions.canExecute}
                            className="btn btn-destructive"
                            title={!agentPermissions.canExecute ? 'Você não tem permissão para executar agentes' : ''}
                          >
                            {isStopping ? (
                              <>
                                <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin mr-2"></div>
                                Parando...
                              </>
                            ) : 'Parar'}
                          </button>
                        </div>
                        
                        {/* Status */}
                          <div className="flex items-center gap-2">
                          <div className={`w-3 h-3 rounded-full ${
                            isRunning ? 'bg-success' : 'bg-destructive'
                          }`}></div>
                          <span className={`text-sm px-3 py-1 rounded-full font-medium ${
                            isRunning ? 'bg-success/20 text-success' : 'bg-destructive/20 text-destructive'
                          }`}>
                            {isRunning ? 'Executando' : 'Desconectado'}
                          </span>
                          </div>
                        </div>
                      
                      {/* Tabela de Clientes */}
                      <div className="border border-border rounded-lg p-6 min-h-[280px]">
                        <h4 className="text-lg font-semibold mb-4 flex items-center gap-2">
                          📋 Clientes do Agente
                          <span className="text-sm font-normal text-muted-foreground">
                            ({prospects[agente.id]?.length || 0} registros)
                          </span>
                        </h4>
                        
                        <div className="overflow-auto max-h-[400px] border border-border/20 rounded-md">
                                <table className="w-full text-sm">
                                  <thead className="sticky top-0 bg-background z-10">
                                    <tr className="border-b border-border">
                                <th className="text-left py-2 font-medium">Nome</th>
                                <th className="text-left py-2 font-medium">Telefone</th>
                                <th className="text-left py-2 font-medium">Status</th>
                                <th className="text-left py-2 font-medium">Última Interação</th>
                                    </tr>
                                  </thead>
                                  <tbody>
                              {prospects[agente.id]?.length > 0 ? (
                                prospects[agente.id].map((prospect: any, index: number) => (
                                  <tr key={index} className={`border-b border-border/50 hover:bg-muted/50 ${
                                    prospect.status === 'prospectando' ? 'bg-yellow-50/10 dark:bg-yellow-900/5' : ''
                                  }`}>
                                    <td className="py-2 font-medium">
                                          {prospect.nome}
                                      {prospect.status === 'prospectando' && (
                                        <span className="ml-2 text-xs text-yellow-600 dark:text-yellow-400">🔥</span>
                                      )}
                                        </td>
                                    <td className="py-2 text-muted-foreground">{prospect.telefone}</td>
                                    <td className="py-2">
                                          <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                                            prospect.status === 'concluido' 
                                          ? 'bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-400'
                                          : prospect.status === 'prospectando'
                                          ? 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/20 dark:text-yellow-400 animate-pulse'
                                          : 'bg-gray-100 text-gray-800 dark:bg-gray-900/20 dark:text-gray-400'
                                      }`}>
                                        {prospect.status === 'concluido' ? 'Concluído' : 
                                         prospect.status === 'prospectando' ? 'Prospectando' : 
                                         prospect.status}
                                          </span>
                                        </td>
                                    <td className="py-2 text-muted-foreground">
                                      {prospect.data_ultima_interacao 
                                        ? new Date(prospect.data_ultima_interacao).toLocaleString('pt-BR')
                                        : 'N/A'}
                                        </td>
                                      </tr>
                                ))
                              ) : (
                                <tr>
                                  <td colSpan={4} className="py-8 text-center text-muted-foreground">
                                    {tabelaAtualizando[agente.id] ? (
                                      <div className="flex items-center justify-center gap-2">
                                        <div className="w-4 h-4 border-2 border-primary border-t-transparent rounded-full animate-spin"></div>
                                        Carregando clientes...
                                      </div>
                                    ) : (
                                      'Nenhum cliente encontrado'
                                    )}
                                  </td>
                                </tr>
                              )}
                                  </tbody>
                                </table>
                        </div>
                        
                        {/* Mostrar estatísticas de clientes */}
                        <div className="mt-3 text-center">
                          <div className="flex justify-center gap-4 text-sm">
                            <span className="text-muted-foreground">
                              Total: {prospectsStats[agente.id]?.total || 0} clientes
                            </span>
                            <span className="text-green-600 font-medium">
                              Completos: {prospectsStats[agente.id]?.completos || 0}
                            </span>
                            <span className="text-orange-600 font-medium">
                              Pendentes: {prospectsStats[agente.id]?.pendentes || 0}
                            </span>
                          </div>
                        </div>
                        
                  </div>
                </div>
              )
            })}
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Create Agent Modal */}
      <CreateAgentModal
        isOpen={showCreateAgentModal}
        onClose={() => setShowCreateAgentModal(false)}
        onAgentCreated={handleCreateAgent}
        userId={userData?.id}
      />
      
    </div>
  )
}
