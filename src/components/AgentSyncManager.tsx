import { useEffect, useState } from 'react'
import { useAgentSyncWebhooks } from '../hooks/useAgentSyncWebhooks'
import { RefreshCw, Play, Pause, AlertCircle, CheckCircle, Users } from 'lucide-react'

interface AgentSyncManagerProps {
  onAgentsChange?: (agents: Record<string, any>) => void
  autoSync?: boolean
  syncInterval?: number
}

export function AgentSyncManager({ 
  onAgentsChange, 
  autoSync = true, 
  syncInterval = 10000 
}: AgentSyncManagerProps) {
  // useToastStore removido para evitar popups desnecessários
  const [showDetails, setShowDetails] = useState(false)
  
  const {
    agents,
    lastSync,
    isSyncing,
    syncCount,
    syncAgents,
    stopAutoSync,
    startAutoSync,
    getAgentCount
  } = useAgentSyncWebhooks({
    autoSync,
    syncInterval,
    onAgentAdded: (agentId, agentData) => {
      // Notificação removida para evitar popups desnecessários
      console.log('🆕 Novo agente adicionado:', agentData)
    },
    onAgentRemoved: (agentId) => {
      // Notificação removida para evitar popups desnecessários
      console.log('🗑️ Agente removido:', agentId)
    },
    onSyncError: (error) => {
      // Notificação removida para evitar popups desnecessários
      console.error('❌ Erro na sincronização:', error)
    }
  })

  // Notificar mudanças nos agentes
  useEffect(() => {
    onAgentsChange?.(agents)
  }, [agents, onAgentsChange])

  const formatLastSync = () => {
    if (!lastSync) return 'Nunca'
    const now = new Date()
    const diff = now.getTime() - lastSync.getTime()
    
    if (diff < 60000) return 'Agora mesmo'
    if (diff < 3600000) return `${Math.floor(diff / 60000)}min atrás`
    return lastSync.toLocaleTimeString()
  }

  return (
    <div className="bg-gray-800 rounded-lg p-4 border border-gray-700">
      <div className="flex items-center justify-between mb-3">
        <div className="flex items-center gap-2">
          <Users className="w-5 h-5 text-blue-400" />
          <h3 className="text-lg font-semibold">Sincronização de Agentes</h3>
          {isSyncing && <RefreshCw className="w-4 h-4 animate-spin text-blue-400" />}
        </div>
        
        <div className="flex items-center gap-2">
          <button
            onClick={autoSync ? stopAutoSync : startAutoSync}
            className={`px-3 py-1 rounded-md text-sm font-medium transition-colors ${
              autoSync 
                ? 'bg-red-600 hover:bg-red-700 text-white' 
                : 'bg-green-600 hover:bg-green-700 text-white'
            }`}
          >
            {autoSync ? (
              <>
                <Pause className="w-4 h-4 inline mr-1" />
                Pausar
              </>
            ) : (
              <>
                <Play className="w-4 h-4 inline mr-1" />
                Iniciar
              </>
            )}
          </button>
          
          <button
            onClick={syncAgents}
            disabled={isSyncing}
            className="px-3 py-1 bg-blue-600 hover:bg-blue-700 disabled:opacity-50 text-white rounded-md text-sm font-medium transition-colors"
          >
            <RefreshCw className={`w-4 h-4 inline mr-1 ${isSyncing ? 'animate-spin' : ''}`} />
            Sincronizar
          </button>
          
          <button
            onClick={() => setShowDetails(!showDetails)}
            className="px-2 py-1 text-gray-400 hover:text-white transition-colors"
          >
            {showDetails ? '▲' : '▼'}
          </button>
        </div>
      </div>

      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-3">
        <div className="bg-gray-700 rounded p-3">
          <div className="text-2xl font-bold text-blue-400">{getAgentCount()}</div>
          <div className="text-sm text-gray-300">Agentes Ativos</div>
        </div>
        
        <div className="bg-gray-700 rounded p-3">
          <div className="text-2xl font-bold text-green-400">{syncCount}</div>
          <div className="text-sm text-gray-300">Sincronizações</div>
        </div>
        
        <div className="bg-gray-700 rounded p-3">
          <div className="text-sm font-medium text-yellow-400">{formatLastSync()}</div>
          <div className="text-sm text-gray-300">Última Sync</div>
        </div>
        
        <div className="bg-gray-700 rounded p-3">
          <div className="flex items-center gap-1">
            {autoSync ? (
              <CheckCircle className="w-4 h-4 text-green-400" />
            ) : (
              <AlertCircle className="w-4 h-4 text-red-400" />
            )}
            <span className="text-sm text-gray-300">
              {autoSync ? 'Automática' : 'Manual'}
            </span>
          </div>
        </div>
      </div>

      {showDetails && (
        <div className="border-t border-gray-700 pt-3">
          <h4 className="text-sm font-medium text-gray-300 mb-2">Detalhes dos Agentes:</h4>
          <div className="space-y-2 max-h-40 overflow-y-auto">
            {Object.entries(agents).map(([agentId, agent]) => (
              <div key={agentId} className="flex items-center justify-between bg-gray-700 rounded p-2">
                <div className="flex items-center gap-2">
                  <span className="text-lg">{agent.icone || '🤖'}</span>
                  <div>
                    <div className="font-medium">{agent.nome}</div>
                    <div className="text-xs text-gray-400">ID: {agentId}</div>
                  </div>
                </div>
                <div className={`px-2 py-1 rounded text-xs font-medium ${
                  agent.ativo ? 'bg-green-600 text-white' : 'bg-red-600 text-white'
                }`}>
                  {agent.ativo ? 'Ativo' : 'Inativo'}
                </div>
              </div>
            ))}
            {getAgentCount() === 0 && (
              <div className="text-center text-gray-400 py-4">
                Nenhum agente encontrado
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  )
}
