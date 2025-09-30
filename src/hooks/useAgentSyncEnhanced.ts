import { useState, useEffect, useCallback } from 'react'
import { useWebhookStore } from '../store/webhooks'
import { callWebhook } from '../utils/webhook-client'
import { registerAllAgentWebhooks } from '../utils/agent-webhook-client'

interface AgentSyncConfig {
  autoSync: boolean
  syncInterval: number
  onAgentAdded?: (agentId: string, agentData: any) => void
  onAgentRemoved?: (agentId: string) => void
  onSyncError?: (error: Error) => void
}

interface AgentData {
  id: string
  nome: string
  descricao?: string
  icone?: string
  cor?: string
  ativo: boolean
  created_at?: string
  updated_at?: string
  
  // Workflow IDs
  workflow_start_id?: string
  workflow_status_id?: string
  workflow_lista_id?: string
  workflow_stop_id?: string
  
  // Webhook URLs específicos
  webhook_start_url?: string
  webhook_status_url?: string
  webhook_lista_url?: string
  webhook_stop_url?: string
  
  // Informações de leads (tabela LEAD)
  leads_pendentes?: number
  leads_reservados_total?: number
  leads_contatados?: number
  ultimo_lote?: string
  ultima_reserva?: string
  leads_no_ultimo_lote?: number
  leads_disponiveis?: number
  leads_prospeccao_disponiveis?: number
  
  // Status de execução
  status_atual?: string
  execution_id_ativo?: string
  ultima_execucao?: string
  
  // Performance
  taxa_conversao?: number
  leads_processados_hoje?: number
}

export function useAgentSyncEnhanced(config: AgentSyncConfig = { autoSync: true, syncInterval: 10000 }) {
  const [agents, setAgents] = useState<Record<string, AgentData>>({})
  const [lastSync, setLastSync] = useState<Date | null>(null)
  const [isSyncing, setIsSyncing] = useState(false)
  const [syncCount, setSyncCount] = useState(0)
  const [lastSyncTime, setLastSyncTime] = useState<number>(0)
  
  const { addWebhook } = useWebhookStore()

  // Função para carregar agentes do webhook
  const loadAgents = useCallback(async (): Promise<AgentData[]> => {
    try {
      console.log('🔄 [ENHANCED] Carregando agentes...')
      
      // Verificar cache local primeiro
      const cacheKey = 'agents-enhanced-cache'
      const cachedData = localStorage.getItem(cacheKey)
      const cacheTimestamp = localStorage.getItem(`${cacheKey}-timestamp`)
      
      // Se tem cache válido (menos de 10 segundos), usar cache
      if (cachedData && cacheTimestamp) {
        const cacheAge = Date.now() - parseInt(cacheTimestamp)
        if (cacheAge < 10000) { // 10 segundos
          console.log('📦 [ENHANCED] Usando cache local')
          return JSON.parse(cachedData)
        }
      }
      
      const response = await callWebhook('webhook/list-agentes', { method: 'GET' })
      
      if (!response) {
        console.log('❌ [ENHANCED] Resposta vazia')
        return []
      }
      
      // Processar resposta (mesma lógica do loadAgentConfigs)
      let agentsArray: AgentData[] = []
      
      if (Array.isArray(response)) {
        const firstItem = response[0]
        if (firstItem && firstItem.data && Array.isArray(firstItem.data)) {
          agentsArray = firstItem.data
        }
      } else if (response.data && Array.isArray(response.data)) {
        agentsArray = response.data
      } else if (response.data && typeof response.data === 'object') {
        if (Array.isArray(response.data.agents)) {
          agentsArray = response.data.agents
        } else if (Array.isArray(response.data.data)) {
          agentsArray = response.data.data
        } else {
          agentsArray = [response.data]
        }
      }
      
      const filteredAgents = agentsArray.filter(agent => agent?.id && agent?.nome && agent?.ativo === true)
      
      // Salvar no cache
      localStorage.setItem(cacheKey, JSON.stringify(filteredAgents))
      localStorage.setItem(`${cacheKey}-timestamp`, Date.now().toString())
      
      console.log(`✅ [ENHANCED] ${filteredAgents.length} agentes carregados e salvos no cache`)
      return filteredAgents
      
    } catch (error) {
      console.error('❌ [ENHANCED] Erro ao carregar agentes:', error)
      config.onSyncError?.(error as Error)
      return []
    }
  }, [config])

  // Função para registrar webhooks específicos do agente
  const registerSpecificWebhooks = useCallback((agent: AgentData) => {
    const agentId = agent.id.toString()
    
    // Registrar webhooks específicos se disponíveis
    const webhookMappings = [
      { type: 'start', url: agent.webhook_start_url, workflowId: agent.workflow_start_id },
      { type: 'stop', url: agent.webhook_stop_url, workflowId: agent.workflow_stop_id },
      { type: 'status', url: agent.webhook_status_url, workflowId: agent.workflow_status_id },
      { type: 'lista', url: agent.webhook_lista_url, workflowId: agent.workflow_lista_id }
    ]
    
    webhookMappings.forEach(({ type, url, workflowId }) => {
      if (url) {
        const webhookId = `webhook/${type}-${agentId}`
        const fullUrl = url.startsWith('http') ? url : `https://n8n.code-iq.com.br/${url}`
        addWebhook(webhookId, fullUrl)
        console.log(`✅ [ENHANCED] Webhook específico registrado: ${webhookId} -> ${fullUrl}`)
      }
    })
    
    // Fallback: registrar webhooks padrão se não houver específicos
    if (!agent.webhook_start_url) {
      registerAllAgentWebhooks(agentId, agent.nome)
      console.log(`🔄 [ENHANCED] Webhooks padrão registrados para ${agent.nome}`)
    }
  }, [addWebhook])

  // Função para sincronizar agentes
  const syncAgents = useCallback(async () => {
    const now = Date.now()
    
    // Evitar sincronizações muito frequentes (mínimo 5 segundos entre sincronizações)
    if (isSyncing || (now - lastSyncTime < 5000)) {
      console.log('⏸️ [ENHANCED] Sincronização ignorada - muito frequente ou já em andamento')
      return
    }
    
    setIsSyncing(true)
    setLastSyncTime(now)
    try {
      const newAgents = await loadAgents()
      const newAgentsMap: Record<string, AgentData> = {}
      
      // Processar novos agentes
      newAgents.forEach(agent => {
        const agentId = agent.id.toString()
        newAgentsMap[agentId] = agent
        
        // Verificar se é um agente novo
        setAgents(currentAgents => {
          if (!currentAgents[agentId]) {
            console.log(`🆕 [ENHANCED] Novo agente detectado: ${agent.nome} (${agentId})`)
            
            // Registrar webhooks específicos ou padrão
            registerSpecificWebhooks(agent)
            
            // Notificar callback
            config.onAgentAdded?.(agentId, agent)
          }
          return currentAgents
        })
      })
      
      // Verificar agentes removidos
      setAgents(currentAgents => {
        Object.keys(currentAgents).forEach(agentId => {
          if (!newAgentsMap[agentId]) {
            console.log(`🗑️ [ENHANCED] Agente removido: ${agentId}`)
            config.onAgentRemoved?.(agentId)
          }
        })
        return currentAgents
      })
      
      setAgents(newAgentsMap)
      setLastSync(new Date())
      setSyncCount(prev => prev + 1)
      
      console.log(`✅ [ENHANCED] Sincronização completa - ${newAgents.length} agentes ativos`)
      
    } catch (error) {
      console.error('❌ [ENHANCED] Erro na sincronização:', error)
      config.onSyncError?.(error as Error)
    } finally {
      setIsSyncing(false)
    }
  }, [isSyncing, lastSyncTime, loadAgents, registerSpecificWebhooks, config])

  // Sincronização automática
  useEffect(() => {
    if (!config.autoSync) return
    
    // Sincronização inicial
    syncAgents()
    
    // Sincronização periódica
    const interval = setInterval(syncAgents, config.syncInterval)
    
    return () => clearInterval(interval)
  }, [config.autoSync, config.syncInterval])

  // Função para forçar sincronização manual
  const forceSync = useCallback(() => {
    console.log('🔄 [ENHANCED] Forçando sincronização manual...')
    syncAgents()
  }, [syncAgents])

  return {
    agents,
    lastSync,
    isSyncing,
    syncCount,
    syncAgents: forceSync,
    // Helpers para compatibilidade
    getAgentById: (agentId: string) => agents[agentId],
    getActiveAgents: () => Object.values(agents).filter(agent => agent.ativo),
    getAgentCount: () => Object.keys(agents).length,
    // Helpers específicos
    getAgentStatus: (agentId: string) => agents[agentId]?.status_atual || 'stopped',
    getAgentExecutionId: (agentId: string) => agents[agentId]?.execution_id_ativo,
    getAgentLeads: (agentId: string) => ({
      pendentes: agents[agentId]?.leads_pendentes || 0,
      total: agents[agentId]?.leads_reservados_total || 0,
      contatados: agents[agentId]?.leads_contatados || 0,
      disponiveis: agents[agentId]?.leads_disponiveis || 0,
      ultimoLote: agents[agentId]?.ultimo_lote,
      taxaConversao: agents[agentId]?.taxa_conversao || 0
    }),
    // Helper para verificar se agente tem leads disponíveis
    hasLeadsAvailable: (agentId: string) => (agents[agentId]?.leads_pendentes || 0) > 0,
    // Helper para verificar performance
    getAgentPerformance: (agentId: string) => ({
      taxaConversao: agents[agentId]?.taxa_conversao || 0,
      processadosHoje: agents[agentId]?.leads_processados_hoje || 0,
      ultimaReserva: agents[agentId]?.ultima_reserva,
      ultimaExecucao: agents[agentId]?.ultima_execucao
    })
  }
}
