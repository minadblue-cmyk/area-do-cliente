import { useState, useEffect, useCallback } from 'react'
import { useWebhookStore } from '../store/webhooks'
import { callWebhook } from '../utils/webhook-client'
import { registerAllAgentWebhooks } from '../utils/agent-webhook-client'

interface AgentSyncConfig {
  autoSync: boolean
  syncInterval: number // em milissegundos
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
  webhook_url?: string
  created_at?: string
  updated_at?: string
}

export function useAgentSync(config: AgentSyncConfig = { autoSync: true, syncInterval: 10000 }) {
  const [agents, setAgents] = useState<Record<string, AgentData>>({})
  const [lastSync, setLastSync] = useState<Date | null>(null)
  const [isSyncing, setIsSyncing] = useState(false)
  const [syncCount, setSyncCount] = useState(0)
  const [lastSyncTime, setLastSyncTime] = useState<number>(0)
  
  const { addWebhook } = useWebhookStore()

  // Função para carregar agentes do webhook
  const loadAgents = useCallback(async (): Promise<AgentData[]> => {
    try {
      console.log('🔄 [SYNC] Carregando agentes...')
      
      // Verificar cache local primeiro
      const cacheKey = 'agents-cache'
      const cachedData = localStorage.getItem(cacheKey)
      const cacheTimestamp = localStorage.getItem(`${cacheKey}-timestamp`)
      
      // Se tem cache válido (menos de 10 segundos), usar cache
      if (cachedData && cacheTimestamp) {
        const cacheAge = Date.now() - parseInt(cacheTimestamp)
        if (cacheAge < 10000) { // 10 segundos
          console.log('📦 [SYNC] Usando cache local')
          return JSON.parse(cachedData)
        }
      }
      
      const response = await callWebhook('webhook/list-agentes', { method: 'GET' })
      
      if (!response) {
        console.log('❌ [SYNC] Resposta vazia')
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
      
      console.log(`✅ [SYNC] ${filteredAgents.length} agentes carregados e salvos no cache`)
      return filteredAgents
      
    } catch (error) {
      console.error('❌ [SYNC] Erro ao carregar agentes:', error)
      config.onSyncError?.(error as Error)
      return []
    }
  }, [config])

  // Função para sincronizar agentes
  const syncAgents = useCallback(async () => {
    const now = Date.now()
    
    // Evitar sincronizações muito frequentes (mínimo 5 segundos entre sincronizações)
    if (isSyncing || (now - lastSyncTime < 5000)) {
      console.log('⏸️ [SYNC] Sincronização ignorada - muito frequente ou já em andamento')
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
        
        // Verificar se é um agente novo (usar agents do estado atual)
        setAgents(currentAgents => {
          if (!currentAgents[agentId]) {
            console.log(`🆕 [SYNC] Novo agente detectado: ${agent.nome} (${agentId})`)
            
            // Registrar webhooks dinamicamente
            registerAllAgentWebhooks(agentId, agent.nome)
            
            // Adicionar webhook personalizado se existir
            if (agent.webhook_url) {
              addWebhook(`webhook/custom-${agentId}`, agent.webhook_url)
            }
            
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
            console.log(`🗑️ [SYNC] Agente removido: ${agentId}`)
            config.onAgentRemoved?.(agentId)
          }
        })
        return currentAgents
      })
      
      setAgents(newAgentsMap)
      setLastSync(new Date())
      setSyncCount(prev => prev + 1)
      
      console.log(`✅ [SYNC] Sincronização completa - ${newAgents.length} agentes ativos`)
      
    } catch (error) {
      console.error('❌ [SYNC] Erro na sincronização:', error)
      config.onSyncError?.(error as Error)
    } finally {
      setIsSyncing(false)
    }
  }, [isSyncing, lastSyncTime, loadAgents, addWebhook, config])

  // Sincronização automática
  useEffect(() => {
    if (!config.autoSync) return
    
    // Sincronização inicial
    syncAgents()
    
    // Sincronização periódica
    const interval = setInterval(syncAgents, config.syncInterval)
    
    return () => clearInterval(interval)
  }, [config.autoSync, config.syncInterval]) // Removido syncAgents das dependências

  // Função para forçar sincronização manual
  const forceSync = useCallback(() => {
    console.log('🔄 [SYNC] Forçando sincronização manual...')
    syncAgents()
  }, [syncAgents])

  // Função para parar sincronização automática
  const stopAutoSync = useCallback(() => {
    console.log('⏹️ [SYNC] Parando sincronização automática...')
    // O useEffect vai limpar o interval automaticamente
  }, [])

  // Função para reiniciar sincronização automática
  const startAutoSync = useCallback(() => {
    console.log('▶️ [SYNC] Iniciando sincronização automática...')
    syncAgents()
  }, [syncAgents])

  return {
    agents,
    lastSync,
    isSyncing,
    syncCount,
    syncAgents: forceSync,
    stopAutoSync,
    startAutoSync,
    // Helpers para compatibilidade
    getAgentById: (agentId: string) => agents[agentId],
    getActiveAgents: () => Object.values(agents).filter(agent => agent.ativo),
    getAgentCount: () => Object.keys(agents).length
  }
}
