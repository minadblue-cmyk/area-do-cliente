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
  
  // Workflow IDs (para referência)
  workflow_start_id?: string
  workflow_status_id?: string
  workflow_lista_id?: string
  workflow_stop_id?: string
  
  // Webhook URLs específicos (o que importa)
  webhook_start_url?: string
  webhook_status_url?: string
  webhook_lista_url?: string
  webhook_stop_url?: string
  
  // Status básico de execução (da tabela agente_execucoes)
  status_atual?: string
  execution_id_ativo?: string
}

export function useAgentSyncWebhooks(config: AgentSyncConfig = { autoSync: true, syncInterval: 30000 }) {
  const [agents, setAgents] = useState<Record<string, AgentData>>({})
  const [lastSync, setLastSync] = useState<Date | null>(null)
  const [isSyncing, setIsSyncing] = useState(false)
  const [syncCount, setSyncCount] = useState(0)
  const [lastSyncTime, setLastSyncTime] = useState<number>(0)
  
  const { addWebhook } = useWebhookStore()

  // Função para carregar agentes do webhook
  const loadAgents = useCallback(async (): Promise<AgentData[]> => {
    try {
      console.log('🔄 [WEBHOOKS] Carregando agentes...')
      
      // Verificar cache local primeiro
      const cacheKey = 'agents-webhooks-cache'
      const cachedData = localStorage.getItem(cacheKey)
      const cacheTimestamp = localStorage.getItem(`${cacheKey}-timestamp`)
      
      // Se tem cache válido (menos de 15 segundos), usar cache
      if (cachedData && cacheTimestamp) {
        const cacheAge = Date.now() - parseInt(cacheTimestamp)
        if (cacheAge < 15000) { // 15 segundos
          console.log('📦 [WEBHOOKS] Usando cache local')
          return JSON.parse(cachedData)
        }
      }
      
      const response = await callWebhook('webhook/list-agentes', { method: 'GET' })
      
      if (!response) {
        console.log('❌ [WEBHOOKS] Resposta vazia')
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
      
      // VALIDAÇÃO CRÍTICA: Verificar se agentes têm dados válidos
      console.log('🔍 [WEBHOOKS] Agentes brutos recebidos:', agentsArray)
      
      const filteredAgents = agentsArray.filter(agent => {
        const isValid = agent?.id && agent?.nome && agent?.ativo === true
        
        if (!isValid) {
          console.warn('⚠️ [WEBHOOKS] Agente inválido ignorado:', {
            id: agent?.id,
            nome: agent?.nome,
            ativo: agent?.ativo,
            webhook_start_url: agent?.webhook_start_url,
            webhook_stop_url: agent?.webhook_stop_url,
            webhook_status_url: agent?.webhook_status_url,
            webhook_lista_url: agent?.webhook_lista_url
          })
        }
        
        return isValid
      })
      
      console.log('✅ [WEBHOOKS] Agentes válidos encontrados:', filteredAgents.length)
      
      // VALIDAÇÃO ADICIONAL: Verificar se agentes têm webhooks
      const agentsWithWebhooks = filteredAgents.filter(agent => {
        const hasWebhooks = agent.webhook_start_url && agent.webhook_stop_url && 
                           agent.webhook_status_url && agent.webhook_lista_url
        
        if (!hasWebhooks) {
          console.warn('⚠️ [WEBHOOKS] Agente sem webhooks completos:', {
            id: agent.id,
            nome: agent.nome,
            webhook_start_url: agent.webhook_start_url,
            webhook_stop_url: agent.webhook_stop_url,
            webhook_status_url: agent.webhook_status_url,
            webhook_lista_url: agent.webhook_lista_url
          })
        }
        
        return hasWebhooks
      })
      
      console.log('✅ [WEBHOOKS] Agentes com webhooks completos:', agentsWithWebhooks.length)
      
      // Salvar no cache
      localStorage.setItem(cacheKey, JSON.stringify(agentsWithWebhooks))
      localStorage.setItem(`${cacheKey}-timestamp`, Date.now().toString())
      
      console.log(`✅ [WEBHOOKS] ${agentsWithWebhooks.length} agentes carregados e salvos no cache`)
      return agentsWithWebhooks
      
    } catch (error) {
      console.error('❌ [WEBHOOKS] Erro ao carregar agentes:', error)
      config.onSyncError?.(error as Error)
      return []
    }
  }, [config])

  // Função para registrar webhooks específicos do agente
  const registerSpecificWebhooks = useCallback((agent: AgentData) => {
    const agentId = agent.id.toString()
    const agentName = agent.nome
    
    console.log(`🔧 [WEBHOOKS] Registrando webhooks para ${agentName} (${agentId})`)
    
    // Registrar webhooks específicos se disponíveis
    const webhookMappings = [
      { type: 'start', url: agent.webhook_start_url, workflowId: agent.workflow_start_id },
      { type: 'stop', url: agent.webhook_stop_url, workflowId: agent.workflow_stop_id },
      { type: 'status', url: agent.webhook_status_url, workflowId: agent.workflow_status_id },
      { type: 'lista', url: agent.webhook_lista_url, workflowId: agent.workflow_lista_id }
    ]
    
    let hasSpecificWebhooks = false
    
    webhookMappings.forEach(({ type, url, workflowId }) => {
      if (url) {
        const webhookId = `webhook/${type}-${agentId}`
        const fullUrl = url.startsWith('http') ? url : `https://n8n.code-iq.com.br/${url}`
        addWebhook(webhookId, fullUrl)
        console.log(`✅ [WEBHOOKS] Webhook específico registrado: ${webhookId} -> ${fullUrl}`)
        hasSpecificWebhooks = true
      } else {
        console.log(`⚠️ [WEBHOOKS] URL não disponível para ${type} do agente ${agentName} (${agentId})`)
      }
    })
    
    // Fallback: registrar webhooks padrão se não houver específicos
    if (!hasSpecificWebhooks) {
      console.log(`🔄 [WEBHOOKS] Nenhum webhook específico encontrado, usando padrão para ${agentName}`)
      registerAllAgentWebhooks(agentId, agentName)
    } else {
      console.log(`✅ [WEBHOOKS] Webhooks específicos registrados para ${agentName}`)
    }
    
    return hasSpecificWebhooks
  }, [addWebhook])

  // Função para sincronizar agentes
  const syncAgents = useCallback(async () => {
    const now = Date.now()
    
    // Evitar sincronizações muito frequentes (mínimo 10 segundos entre sincronizações)
    if (isSyncing || (now - lastSyncTime < 10000)) {
      console.log('⏸️ [WEBHOOKS] Sincronização ignorada - muito frequente ou já em andamento')
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
            console.log(`🆕 [WEBHOOKS] Novo agente detectado: ${agent.nome} (${agentId})`)
            
            // Notificar callback
            config.onAgentAdded?.(agentId, agent)
          }
          return currentAgents
        })
        
        // Registrar webhooks fora do setState para evitar erro React
        const currentAgents = useAgentSyncWebhooks.getState?.()?.agents || {}
        if (!currentAgents[agentId]) {
          const hasSpecific = registerSpecificWebhooks(agent)
          console.log(`✅ [WEBHOOKS] Agente ${agent.nome} configurado com ${hasSpecific ? 'webhooks específicos' : 'webhooks padrão'}`)
        }
      })
      
      // Verificar agentes removidos
      setAgents(currentAgents => {
        Object.keys(currentAgents).forEach(agentId => {
          if (!newAgentsMap[agentId]) {
            console.log(`🗑️ [WEBHOOKS] Agente removido: ${agentId}`)
            config.onAgentRemoved?.(agentId)
          }
        })
        return currentAgents
      })
      
      setAgents(newAgentsMap)
      setLastSync(new Date())
      setSyncCount(prev => prev + 1)
      
      console.log(`✅ [WEBHOOKS] Sincronização completa - ${newAgents.length} agentes ativos`)
      
    } catch (error) {
      console.error('❌ [WEBHOOKS] Erro na sincronização:', error)
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
    console.log('🔄 [WEBHOOKS] Forçando sincronização manual...')
    syncAgents()
  }, [syncAgents])

  // Funções para controlar auto-sync (compatibilidade com componente antigo)
  const stopAutoSync = useCallback(() => {
    console.log('⏸️ [WEBHOOKS] Auto-sync pausado')
    // Para o hook novo, auto-sync é controlado pelo config.autoSync
    // Esta função é apenas para compatibilidade
  }, [])

  const startAutoSync = useCallback(() => {
    console.log('▶️ [WEBHOOKS] Auto-sync iniciado')
    // Para o hook novo, auto-sync é controlado pelo config.autoSync
    // Esta função é apenas para compatibilidade
  }, [])

  return {
    agents,
    lastSync,
    isSyncing,
    syncCount,
    syncAgents: forceSync,
    stopAutoSync,
    startAutoSync,
    // Helpers básicos
    getAgentById: (agentId: string) => agents[agentId],
    getActiveAgents: () => Object.values(agents).filter(agent => agent.ativo),
    getAgentCount: () => Object.keys(agents).length,
    // Helpers para webhooks
    getAgentWebhooks: (agentId: string) => {
      const agent = agents[agentId]
      if (!agent) return {}
      
      return {
        start: agent.webhook_start_url,
        stop: agent.webhook_stop_url,
        status: agent.webhook_status_url,
        lista: agent.webhook_lista_url
      }
    },
    // Helper para verificar se tem webhooks específicos
    hasSpecificWebhooks: (agentId: string) => {
      const agent = agents[agentId]
      return !!(agent?.webhook_start_url || agent?.webhook_stop_url || agent?.webhook_status_url || agent?.webhook_lista_url)
    },
    // Status básico
    getAgentStatus: (agentId: string) => agents[agentId]?.status_atual || 'stopped',
    getAgentExecutionId: (agentId: string) => agents[agentId]?.execution_id_ativo
  }
}
