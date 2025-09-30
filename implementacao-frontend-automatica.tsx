// Exemplo de implementação no frontend para configuração automática
// src/pages/Upload/index.tsx

import React, { useState, useEffect } from 'react'
import { useAgentSyncWebhooks } from '../hooks/useAgentSyncWebhooks'
import { callAgentWebhook } from '../utils/agent-webhook-client'

export default function UploadPage() {
  // Sistema de sincronização automática de agentes
  const { 
    agents, 
    getAgentWebhooks, 
    hasSpecificWebhooks,
    getAgentStatus,
    getAgentExecutionId,
    syncAgents 
  } = useAgentSyncWebhooks({
    autoSync: true,
    syncInterval: 30000, // 30 segundos
    onAgentAdded: (agentId, agentData) => {
      console.log(`🆕 Novo agente detectado: ${agentData.nome} (${agentId})`)
      console.log(`🔗 Webhooks específicos: ${hasSpecificWebhooks(agentId) ? 'SIM' : 'NÃO'}`)
    },
    onAgentRemoved: (agentId) => {
      console.log(`🗑️ Agente removido: ${agentId}`)
    }
  })

  // Estados para cada agente
  const [agentProspects, setAgentProspects] = useState<Record<string, any[]>>({})
  const [agentLoading, setAgentLoading] = useState<Record<string, boolean>>({})

  // Carregar prospects de um agente específico
  const loadProspects = async (agentId: string) => {
    try {
      setAgentLoading(prev => ({ ...prev, [agentId]: true }))
      
      const prospects = await callAgentWebhook(agentId, 'lista', {
        action: 'get_prospects',
        agente_id: agentId
      })
      
      setAgentProspects(prev => ({ ...prev, [agentId]: prospects }))
      console.log(`📋 Prospects carregados para agente ${agentId}:`, prospects.length)
      
    } catch (error) {
      console.error(`❌ Erro ao carregar prospects do agente ${agentId}:`, error)
    } finally {
      setAgentLoading(prev => ({ ...prev, [agentId]: false }))
    }
  }

  // Iniciar agente
  const handleStartAgent = async (agentId: string) => {
    try {
      console.log(`▶️ Iniciando agente ${agentId}...`)
      
      const result = await callAgentWebhook(agentId, 'start', {
        action: 'start',
        agente_id: agentId,
        usuario_id: userData?.id
      })
      
      if (result.success) {
        console.log(`✅ Agente ${agentId} iniciado com sucesso`)
        // Força sincronização para atualizar status
        syncAgents()
      }
      
    } catch (error) {
      console.error(`❌ Erro ao iniciar agente ${agentId}:`, error)
    }
  }

  // Parar agente
  const handleStopAgent = async (agentId: string) => {
    try {
      console.log(`⏹️ Parando agente ${agentId}...`)
      
      const result = await callAgentWebhook(agentId, 'stop', {
        action: 'stop',
        agente_id: agentId,
        execution_id: getAgentExecutionId(agentId)
      })
      
      if (result.success) {
        console.log(`✅ Agente ${agentId} parado com sucesso`)
        // Força sincronização para atualizar status
        syncAgents()
      }
      
    } catch (error) {
      console.error(`❌ Erro ao parar agente ${agentId}:`, error)
    }
  }

  // Verificar status do agente
  const handleCheckStatus = async (agentId: string) => {
    try {
      console.log(`🔄 Verificando status do agente ${agentId}...`)
      
      const status = await callAgentWebhook(agentId, 'status', {
        action: 'get_status',
        agente_id: agentId
      })
      
      console.log(`📊 Status do agente ${agentId}:`, status)
      // Força sincronização para atualizar interface
      syncAgents()
      
    } catch (error) {
      console.error(`❌ Erro ao verificar status do agente ${agentId}:`, error)
    }
  }

  // Sincronização automática de prospects para agentes ativos
  useEffect(() => {
    const interval = setInterval(() => {
      Object.entries(agents).forEach(([agentId, agent]) => {
        // Se agente está rodando, atualiza prospects
        if (agent.status_atual === 'running') {
          loadProspects(agentId)
        }
      })
    }, 10000) // A cada 10 segundos

    return () => clearInterval(interval)
  }, [agents])

  // Carregar prospects iniciais
  useEffect(() => {
    Object.keys(agents).forEach(agentId => {
      loadProspects(agentId)
    })
  }, [agents])

  // Função para obter ícone de status
  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'running': return '🟢'
      case 'stopped': return '🔴'
      case 'error': return '🟡'
      default: return '⚪'
    }
  }

  // Função para obter cor do botão
  const getButtonColor = (action: string, agentId: string) => {
    const status = getAgentStatus(agentId)
    
    if (action === 'start') {
      return status === 'running' ? 'bg-gray-400' : 'bg-green-500 hover:bg-green-600'
    } else if (action === 'stop') {
      return status === 'stopped' ? 'bg-gray-400' : 'bg-red-500 hover:bg-red-600'
    }
    return 'bg-blue-500 hover:bg-blue-600'
  }

  return (
    <div className="upload-page">
      <div className="header">
        <h1>🤖 Gerenciamento de Agentes</h1>
        <button 
          onClick={syncAgents}
          className="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600"
        >
          🔄 Sincronizar Agentes
        </button>
      </div>

      {/* Lista de Agentes - Configurada Automaticamente */}
      <div className="agents-grid">
        {Object.entries(agents).map(([agentId, agent]) => (
          <div key={agentId} className="agent-card">
            {/* Cabeçalho do Agente */}
            <div className="agent-header">
              <h3 className="agent-title">
                {agent.icone} {agent.nome}
              </h3>
              <div className="agent-status">
                {getStatusIcon(agent.status_atual)} 
                Status: {agent.status_atual || 'stopped'}
              </div>
              {agent.execution_id_ativo && (
                <div className="execution-id">
                  ID: {agent.execution_id_ativo}
                </div>
              )}
            </div>

            {/* Informações do Agente */}
            <div className="agent-info">
              <p className="agent-description">{agent.descricao || 'Agente de prospecção'}</p>
              <div className="webhook-info">
                {hasSpecificWebhooks(agentId) ? (
                  <span className="text-green-600">✅ Webhooks específicos</span>
                ) : (
                  <span className="text-yellow-600">⚠️ Webhooks padrão</span>
                )}
              </div>
            </div>

            {/* Controles do Agente */}
            <div className="agent-controls">
              <button
                onClick={() => handleStartAgent(agentId)}
                disabled={getAgentStatus(agentId) === 'running'}
                className={`${getButtonColor('start', agentId)} text-white px-4 py-2 rounded mr-2 disabled:cursor-not-allowed`}
              >
                ▶️ Iniciar
              </button>
              
              <button
                onClick={() => handleStopAgent(agentId)}
                disabled={getAgentStatus(agentId) === 'stopped'}
                className={`${getButtonColor('stop', agentId)} text-white px-4 py-2 rounded mr-2 disabled:cursor-not-allowed`}
              >
                ⏹️ Parar
              </button>
              
              <button
                onClick={() => handleCheckStatus(agentId)}
                className="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded"
              >
                🔄 Status
              </button>
            </div>

            {/* Lista de Prospects */}
            <div className="prospects-section">
              <h4>📋 Prospects ({agentProspects[agentId]?.length || 0})</h4>
              
              {agentLoading[agentId] ? (
                <div className="loading">Carregando prospects...</div>
              ) : (
                <div className="prospects-list">
                  {agentProspects[agentId]?.slice(0, 5).map((prospect, index) => (
                    <div key={index} className="prospect-item">
                      <span className="prospect-name">{prospect.nome}</span>
                      <span className="prospect-phone">{prospect.telefone}</span>
                    </div>
                  ))}
                  
                  {agentProspects[agentId]?.length > 5 && (
                    <div className="more-prospects">
                      +{agentProspects[agentId].length - 5} prospects adicionais
                    </div>
                  )}
                </div>
              )}
            </div>

            {/* Debug Info (apenas em desenvolvimento) */}
            {process.env.NODE_ENV === 'development' && (
              <div className="debug-info">
                <details>
                  <summary>🔧 Debug Info</summary>
                  <pre>{JSON.stringify({
                    agentId,
                    webhooks: getAgentWebhooks(agentId),
                    status: getAgentStatus(agentId),
                    executionId: getAgentExecutionId(agentId)
                  }, null, 2)}</pre>
                </details>
              </div>
            )}
          </div>
        ))}
      </div>

      {/* Mensagem quando não há agentes */}
      {Object.keys(agents).length === 0 && (
        <div className="no-agents">
          <h3>🤖 Nenhum agente encontrado</h3>
          <p>Clique em "Sincronizar Agentes" para carregar os agentes disponíveis.</p>
        </div>
      )}
    </div>
  )
}

// Estilos CSS (exemplo)
const styles = `
.upload-page {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

.agents-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  gap: 20px;
}

.agent-card {
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  padding: 20px;
  background: white;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.agent-header {
  margin-bottom: 15px;
}

.agent-title {
  font-size: 1.2em;
  font-weight: bold;
  margin: 0 0 5px 0;
}

.agent-status {
  font-size: 0.9em;
  color: #666;
}

.agent-controls {
  display: flex;
  gap: 10px;
  margin: 15px 0;
}

.prospects-section {
  margin-top: 15px;
  border-top: 1px solid #e0e0e0;
  padding-top: 15px;
}

.prospects-list {
  max-height: 200px;
  overflow-y: auto;
}

.prospect-item {
  display: flex;
  justify-content: space-between;
  padding: 5px 0;
  border-bottom: 1px solid #f0f0f0;
}

.debug-info {
  margin-top: 15px;
  font-size: 0.8em;
  color: #666;
}

.no-agents {
  text-align: center;
  padding: 40px;
  color: #666;
}
`
