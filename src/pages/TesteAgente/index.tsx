import { useState, useEffect } from 'react'
import { useAuthStore } from '../../store/auth'
import { callWebhook } from '../../utils/webhook-client'
import { useToastStore } from '../../store/toast'
import { useAgentPermissions } from '../../hooks/useAgentPermissions'

export default function TesteAgente() {
  const { userData } = useAuthStore()
  const push = useToastStore((s) => s.push)
  const agentPermissions = useAgentPermissions()
  const [agentes, setAgentes] = useState<any[]>([])
  const [loading, setLoading] = useState(false)
  const [startingAgent, setStartingAgent] = useState<string | null>(null)
  const [autoRefreshActive, setAutoRefreshActive] = useState(false)
  const [tabelaDados, setTabelaDados] = useState<Record<string, any[]>>({})
  const [tabelaAtualizando, setTabelaAtualizando] = useState<Record<string, boolean>>({})

  // Função simples para listar agentes
  const listarAgentes = async () => {
    if (!userData) return
    
    // Verificar permissões de acesso
    if (!agentPermissions.canAccess) {
      console.log('❌ Usuário não tem permissão para acessar agentes')
      push({ kind: 'error', message: 'Você não tem permissão para acessar agentes' })
      return
    }
    
    setLoading(true)
    try {
      console.log('🔍 Listando agentes...')
      
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
        if (Array.isArray(response.data)) {
          agentesList = response.data
        } else if (response.data.data && Array.isArray(response.data.data)) {
          agentesList = response.data.data
        } else if (response.data.success && response.data.data) {
          agentesList = response.data.data
        }
        
        console.log('✅ Agentes encontrados:', agentesList.length)
        
        // Preservar estado atual dos agentes (status, execution_id, etc.)
        setAgentes(prevAgentes => {
          console.log('🔄 Estado anterior dos agentes:', prevAgentes)
          console.log('🔄 Novos agentes do banco:', agentesList)
          
          const agentesAtualizados = agentesList.map((novoAgente: any) => {
            // Procurar se já existe um agente com o mesmo ID
            const agenteExistente = prevAgentes.find(agente => agente.id === novoAgente.id)
            
            if (agenteExistente) {
              console.log(`🔄 Preservando estado para ${novoAgente.nome}:`, {
                status_atual: agenteExistente.status_atual,
                execution_id_ativo: agenteExistente.execution_id_ativo
              })
              
              // Preservar estado atual se existir - priorizar dados existentes
              return {
                ...novoAgente, // Dados atualizados do banco
                status_atual: agenteExistente.status_atual || novoAgente.status_atual,
                execution_id_ativo: agenteExistente.execution_id_ativo !== undefined ? agenteExistente.execution_id_ativo : (novoAgente.execution_id_ativo || null),
                updated_at: agenteExistente.updated_at || novoAgente.updated_at
              }
            }
            
            // Se é um agente novo, usar dados do banco
            return novoAgente
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
      setLoading(false)
    }
  }

  // Função para parar agente
  const pararAgente = async (agente: any) => {
    if (!userData) return
    
    setStartingAgent(agente.id)
    try {
      console.log(`🛑 Parando agente ${agente.nome}...`)
      
      // Debug detalhado do agente
      console.log('🔍 DEBUG AGENTE COMPLETO:', agente)
      console.log('🔍 execution_id_ativo:', agente.execution_id_ativo)
      console.log('🔍 execution_id:', agente.execution_id)
      console.log('🔍 status_atual:', agente.status_atual)
      
      const executionId = agente.execution_id_ativo || agente.execution_id || null
      console.log('🔍 Execution ID final para envio:', executionId)
      
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
        
        if (responseData?.success || responseData?.message?.includes('sucesso')) {
          // Atualizar o agente na lista com o novo status
          setAgentes(prev => prev.map(a => 
            a.id === agente.id 
              ? { 
                  ...a, 
                  status_atual: 'stopped',
                  execution_id_ativo: null,
                  updated_at: new Date().toISOString()
                }
              : a
          ))
          
          // Notificação removida para evitar popups desnecessários
          console.log(`✅ ${agente.nome} parado - Execution ID: ${agente.execution_id_ativo}`)
        } else {
          push({ kind: 'error', message: 'Falha ao parar agente - resposta inválida' })
          console.error('❌ Resposta inválida do webhook stop:', responseData)
        }
      } else {
        push({ kind: 'error', message: 'Falha ao parar agente - erro de comunicação' })
        console.error('❌ Erro de comunicação com webhook stop:', response)
      }
      
    } catch (error: any) {
      console.error('❌ Erro ao parar agente:', error)
      push({ kind: 'error', message: 'Erro ao parar agente: ' + error.message })
    } finally {
      setStartingAgent(null)
    }
  }

  // Função para verificar status do agente
  const verificarStatus = async (agente: any, isAutoRefresh = false) => {
    if (!userData) return
    
    // Só definir startingAgent se não for auto-refresh
    if (!isAutoRefresh) {
      setStartingAgent(agente.id)
    }
    try {
      console.log(`🔍 Verificando status do agente ${agente.nome}...`)
      
      // Usar webhook do banco de dados (sem fallback)
      const webhookId = agente.webhook_status_url
      
      if (!webhookId) {
        console.warn(`⚠️ Agente ${agente.nome} não tem webhook_status_url configurado`)
        return
      }
      console.log(`🔍 Usando webhook: ${webhookId}`)
      
      // Webhook de status precisa dos parâmetros corretos
      const response = await callWebhook(webhookId, {
        method: 'GET',
        params: {
          workflow_id: agente.id,
          usuario_id: userData.id
        }
      })
      
      console.log('📥 Resposta do webhook status:', response)
      
      if (response && response.status === 200) {
        // Se data está vazio, assumir que o agente está parado
        let newStatus = 'stopped'
        let executionId = null
        
        if (response.data && response.data !== '') {
          // Se há dados, processar normalmente
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
        } else {
          // Se data está vazio, verificar se há execution_id_ativo no agente atual
          // Se há execution_id_ativo, assumir que está running
          if (agente.execution_id_ativo) {
            newStatus = 'running'
            executionId = agente.execution_id_ativo
          }
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
        
        // Só mostrar toast se não for auto-refresh
        // Notificação removida para evitar popups desnecessários
        console.log(`✅ Status do ${agente.nome} atualizado: ${newStatus}`)
      }
      
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
    
    console.log('✅ Verificação de status concluída')
  }

  // Função para carregar dados da tabela usando webhook list
  const carregarDadosTabela = async (agente: any, isAutoRefresh = false) => {
    if (!userData) return
    
    // Marcar como atualizando
    setTabelaAtualizando(prev => ({
      ...prev,
      [agente.id]: true
    }))
    
    try {
      console.log(`📊 ${isAutoRefresh ? 'Auto-atualizando' : 'Carregando'} dados da tabela para ${agente.nome}...`)
      
      // Usar webhook do banco de dados (sem fallback)
      const webhookId = agente.webhook_lista_url
      
      if (!webhookId) {
        console.warn(`⚠️ Agente ${agente.nome} não tem webhook_lista_url configurado`)
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
      
      console.log('📥 Resposta do webhook lista:', response)
      
      if (response && response.status === 200 && response.data) {
        // Processar dados da resposta
        let dadosLista = []
        if (Array.isArray(response.data)) {
          dadosLista = response.data
        } else if (response.data.data && Array.isArray(response.data.data)) {
          dadosLista = response.data.data
        } else if (response.data.success && response.data.data) {
          dadosLista = response.data.data
        }
        
        // Atualizar dados da tabela para este agente
        setTabelaDados(prev => ({
          ...prev,
          [agente.id]: dadosLista
        }))
        
        console.log(`✅ ${dadosLista.length} itens carregados para ${agente.nome}`)
      } else {
        console.log(`⚠️ Nenhum dado encontrado para ${agente.nome}`)
        setTabelaDados(prev => ({
          ...prev,
          [agente.id]: []
        }))
      }
      
    } catch (error: any) {
      console.error(`❌ Erro ao carregar dados da tabela para ${agente.nome}:`, error)
      setTabelaDados(prev => ({
        ...prev,
        [agente.id]: []
      }))
    } finally {
      // Marcar como não atualizando
      setTabelaAtualizando(prev => ({
        ...prev,
        [agente.id]: false
      }))
    }
  }

  // Função para iniciar agente
  const iniciarAgente = async (agente: any) => {
    if (!userData) return
    
    setStartingAgent(agente.id)
    try {
      console.log(`🚀 Iniciando agente ${agente.nome}...`)
      
      const payload = {
        action: 'start',
        agent_type: agente.id,
        workflow_id: agente.id,
        timestamp: new Date().toISOString(),
        usuario_id: userData.id,
        logged_user: {
          id: userData.id,
          name: userData.name,
          email: userData.mail
        }
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
      const executionId = responseData?.execution_id || responseData?.executionId || responseData?.id
      
      console.log('🔍 Dados processados do start:', responseData)
      console.log('🔍 Execution ID extraído:', executionId)
      
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
      } else {
        push({ kind: 'error', message: 'Falha ao iniciar agente - resposta inválida' })
        console.error('❌ Resposta inválida do webhook start:', response)
      }
      
    } catch (error: any) {
      console.error('❌ Erro ao iniciar agente:', error)
      push({ kind: 'error', message: 'Erro ao iniciar agente: ' + error.message })
    } finally {
      setStartingAgent(null)
    }
  }

  // Carregar agentes ao inicializar
  useEffect(() => {
    if (userData) {
      listarAgentes()
    }
  }, [userData])

  // Carregar dados da tabela automaticamente quando agentes são carregados
  useEffect(() => {
    if (userData && agentes.length > 0) {
      console.log('📊 Carregando dados da tabela automaticamente para todos os agentes...')
      
      // Carregar dados da tabela para todos os agentes após um pequeno delay
      const timer = setTimeout(() => {
        agentes.forEach(agente => {
          console.log(`🔄 Carregando dados da tabela para ${agente.nome}`)
          carregarDadosTabela(agente, true) // true = isAutoRefresh
        })
      }, 1000) // 1 segundo de delay para garantir que os agentes foram carregados

      return () => clearTimeout(timer)
    }
  }, [userData, agentes.length]) // Dependências: userData e quantidade de agentes

  // Refresh automático do status a cada 15 segundos
  useEffect(() => {
    if (!userData || agentes.length === 0) {
      setAutoRefreshActive(false)
      return
    }

    console.log('⏰ Iniciando refresh automático a cada 15 segundos')
    setAutoRefreshActive(true)
    
    const interval = setInterval(() => {
      verificarStatusTodos()
    }, 15000) // 15 segundos

    // Cleanup do interval quando o componente for desmontado
    return () => {
      console.log('⏹️ Parando refresh automático')
      setAutoRefreshActive(false)
      clearInterval(interval)
    }
  }, [userData, agentes.length]) // Dependências: userData e quantidade de agentes

  // Auto-refresh da tabela de dados a cada 5 segundos
  useEffect(() => {
    if (!userData || agentes.length === 0) {
      return
    }

    console.log('📊 Iniciando auto-refresh da tabela a cada 5 segundos')
    
    const interval = setInterval(() => {
      // Atualizar dados da tabela para todos os agentes que têm dados carregados
      agentes.forEach(agente => {
        if (tabelaDados[agente.id] !== undefined) {
          console.log(`🔄 Auto-atualizando dados da tabela para ${agente.nome}`)
          carregarDadosTabela(agente, true) // true = isAutoRefresh
        }
      })
    }, 5000) // 5 segundos

    // Cleanup do interval quando o componente for desmontado
    return () => {
      console.log('⏹️ Parando auto-refresh da tabela')
      clearInterval(interval)
    }
  }, [userData, agentes.length, tabelaDados]) // Dependências: userData, agentes e dados da tabela

  return (
    <div className="container mx-auto p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">Teste de Agente</h1>
          <p className="text-muted-foreground">Teste isolado das funcionalidades de agente</p>
          {autoRefreshActive && (
            <div className="flex items-center gap-2 mt-2">
              <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
              <span className="text-sm text-green-600 font-medium">Auto-refresh ativo (15s)</span>
            </div>
          )}
        </div>
        
        <div className="flex items-center gap-2">
          <button
            onClick={listarAgentes}
            disabled={loading}
            className="btn btn-primary flex items-center gap-2"
          >
            <div className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`}>
              🔄
            </div>
            {loading ? 'Carregando...' : 'Listar Agentes'}
          </button>
          
          <button
            onClick={() => {
              agentes.forEach(agente => carregarDadosTabela(agente))
            }}
            disabled={loading || agentes.length === 0}
            className="btn btn-secondary flex items-center gap-2"
          >
            <span>📊</span>
            Carregar Dados
          </button>
        </div>
      </div>

      {/* Status */}
      <div className="card">
        <div className="card-header">
          <h2 className="text-lg font-semibold">Status do Teste</h2>
        </div>
        <div className="card-content">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="text-center p-4 bg-muted rounded-lg">
              <div className="text-2xl font-bold text-primary">{agentes.length}</div>
              <div className="text-sm text-muted-foreground">Agentes Encontrados</div>
            </div>
            <div className="text-center p-4 bg-muted rounded-lg">
              <div className="text-2xl font-bold text-green-600">
                {agentes.filter(a => a.ativo).length}
              </div>
              <div className="text-sm text-muted-foreground">Agentes Ativos</div>
            </div>
            <div className="text-center p-4 bg-muted rounded-lg">
              <div className="text-2xl font-bold text-blue-600">
                {loading ? '...' : 'OK'}
              </div>
              <div className="text-sm text-muted-foreground">Status</div>
            </div>
          </div>
        </div>
      </div>

      {/* Lista de Agentes */}
      <div className="card">
        <div className="card-header">
          <h2 className="text-lg font-semibold">Lista de Agentes</h2>
        </div>
        <div className="card-content">
          {loading ? (
            <div className="flex items-center justify-center py-8">
              <div className="w-8 h-8 border-4 border-primary border-t-transparent rounded-full animate-spin"></div>
              <span className="ml-2">Carregando agentes...</span>
            </div>
          ) : agentes.length > 0 ? (
            <div className="space-y-4">
              {agentes.map((agente, index) => (
                <div key={agente.id || index} className="border border-border rounded-lg p-4">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <div className="text-2xl">{agente.icone || '🤖'}</div>
                      <div>
                        <h3 className="font-semibold">{agente.nome}</h3>
                        <p className="text-sm text-muted-foreground">{agente.descricao}</p>
                      </div>
                    </div>
                    <div className="flex items-center gap-3">
                      {/* Status do Banco */}
                      <div className="flex items-center gap-2">
                        <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                          agente.ativo 
                            ? 'bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-400'
                            : 'bg-red-100 text-red-800 dark:bg-red-900/20 dark:text-red-400'
                        }`}>
                          {agente.ativo ? 'Ativo' : 'Inativo'}
                        </span>
                        <div className={`w-3 h-3 rounded-full ${
                          agente.ativo ? 'bg-green-500' : 'bg-red-500'
                        }`}></div>
                      </div>
                      
                      {/* Botões de Controle */}
                      <div className="flex items-center gap-2">
                        {/* Botão Iniciar/Parar */}
                        {agente.status_atual === 'running' ? (
                          <button
                            onClick={() => pararAgente(agente)}
                            disabled={startingAgent === agente.id}
                            className={`px-3 py-1 rounded-full text-xs font-medium transition-colors ${
                              startingAgent === agente.id
                                ? 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/20 dark:text-yellow-400 cursor-not-allowed'
                                : 'bg-red-100 text-red-800 dark:bg-red-900/20 dark:text-red-400 hover:bg-red-200 dark:hover:bg-red-900/30'
                            }`}
                            title={startingAgent === agente.id ? 'Parando agente...' : 'Parar agente'}
                          >
                            {startingAgent === agente.id ? (
                              <span className="flex items-center gap-1">
                                <div className="w-3 h-3 border-2 border-current border-t-transparent rounded-full animate-spin"></div>
                                Parando...
                              </span>
                            ) : (
                              'Parar'
                            )}
                          </button>
                        ) : (
                          <button
                            onClick={() => iniciarAgente(agente)}
                            disabled={startingAgent === agente.id}
                            className={`px-3 py-1 rounded-full text-xs font-medium transition-colors ${
                              startingAgent === agente.id
                                ? 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/20 dark:text-yellow-400 cursor-not-allowed'
                                : 'bg-blue-100 text-blue-800 dark:bg-blue-900/20 dark:text-blue-400 hover:bg-blue-200 dark:hover:bg-blue-900/30'
                            }`}
                            title={startingAgent === agente.id ? 'Iniciando agente...' : 'Iniciar agente'}
                          >
                            {startingAgent === agente.id ? (
                              <span className="flex items-center gap-1">
                                <div className="w-3 h-3 border-2 border-current border-t-transparent rounded-full animate-spin"></div>
                                Iniciando...
                              </span>
                            ) : (
                              'Iniciar'
                            )}
                          </button>
                        )}
                        
                        {/* Botão Verificar Status */}
                        <button
                          onClick={() => verificarStatus(agente)}
                          disabled={startingAgent === agente.id}
                          className="px-3 py-1 rounded-full text-xs font-medium bg-gray-100 text-gray-800 dark:bg-gray-900/20 dark:text-gray-400 hover:bg-gray-200 dark:hover:bg-gray-900/30 transition-colors"
                          title="Verificar status atual"
                        >
                          🔍
                        </button>
                        
                        {/* Botão Carregar Dados da Tabela */}
                        <button
                          onClick={() => carregarDadosTabela(agente)}
                          disabled={tabelaAtualizando[agente.id]}
                          className={`px-2 py-1 rounded-full text-xs font-medium transition-colors ${
                            tabelaAtualizando[agente.id]
                              ? 'bg-gray-100 text-gray-500 dark:bg-gray-900/20 dark:text-gray-600 cursor-not-allowed'
                              : 'bg-purple-100 text-purple-800 dark:bg-purple-900/20 dark:text-purple-400 hover:bg-purple-200 dark:hover:bg-purple-900/30'
                          }`}
                          title={tabelaAtualizando[agente.id] ? 'Atualizando dados...' : 'Carregar dados da tabela'}
                        >
                          {tabelaAtualizando[agente.id] ? '⏳' : '📊'}
                        </button>
                        
                        {/* Botão Debug (temporário) */}
                        <button
                          onClick={() => {
                            console.log('🔍 DEBUG BOTÃO CLICADO - Agente completo:', agente)
                            console.log('🔍 execution_id_ativo:', agente.execution_id_ativo)
                            console.log('🔍 execution_id:', agente.execution_id)
                            console.log('🔍 status_atual:', agente.status_atual)
                          }}
                          className="px-2 py-1 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800 dark:bg-yellow-900/20 dark:text-yellow-400 hover:bg-yellow-200 dark:hover:bg-yellow-900/30 transition-colors"
                          title="Debug - verificar dados do agente"
                        >
                          🐛
                        </button>
                      </div>
                    </div>
                  </div>
                  
                  {/* Detalhes do Agente */}
                  <div className="mt-3 grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
                    <div>
                      <span className="text-muted-foreground">ID:</span>
                      <span className="ml-1 font-mono">{agente.id}</span>
                    </div>
                    <div>
                      <span className="text-muted-foreground">Status Real:</span>
                      <span className={`ml-1 px-2 py-1 rounded-full text-xs font-medium ${
                        agente.status_atual === 'running' 
                          ? 'bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-400'
                          : agente.status_atual === 'stopped'
                          ? 'bg-red-100 text-red-800 dark:bg-red-900/20 dark:text-red-400'
                          : 'bg-gray-100 text-gray-800 dark:bg-gray-900/20 dark:text-gray-400'
                      }`}>
                        {agente.status_atual === 'running' ? 'Executando' : 
                         agente.status_atual === 'stopped' ? 'Parado' : 
                         agente.status_atual || 'Desconhecido'}
                      </span>
                    </div>
                    <div>
                      <span className="text-muted-foreground">Criado:</span>
                      <span className="ml-1">
                        {agente.created_at 
                          ? new Date(agente.created_at).toLocaleDateString('pt-BR')
                          : 'N/A'
                        }
                      </span>
                    </div>
                    <div>
                      <span className="text-muted-foreground">Atualizado:</span>
                      <span className="ml-1">
                        {agente.updated_at 
                          ? new Date(agente.updated_at).toLocaleDateString('pt-BR')
                          : 'N/A'
                        }
                      </span>
                    </div>
                  </div>
                  
                  {/* Execution ID se disponível */}
                  {agente.execution_id_ativo && (
                    <div className="mt-3 pt-3 border-t border-border">
                      <h4 className="text-sm font-medium text-muted-foreground mb-2">Execução Ativa:</h4>
                      <div className="text-xs font-mono bg-green-50 dark:bg-green-900/20 p-2 rounded">
                        ID: {agente.execution_id_ativo}
                      </div>
                    </div>
                  )}
                  
                  
                  {/* Tabela de Dados */}
                  {tabelaDados[agente.id] && tabelaDados[agente.id].length > 0 && (
                    <div className="mt-4 pt-4 border-t border-border">
                      <div className="flex items-center justify-between mb-3">
                        <div>
                          <h4 className="text-sm font-medium text-muted-foreground flex items-center gap-2">
                            Dados da Tabela ({tabelaDados[agente.id].filter(item => {
                              const status = item.status || item.estado || 'desconhecido'
                              return status === 'prospectando' || status === 'concluido' || status === 'completo'
                            }).length} itens filtrados de {tabelaDados[agente.id].length} total)
                            {tabelaAtualizando[agente.id] && (
                              <span className="flex items-center gap-1 text-xs text-blue-600 dark:text-blue-400">
                                <div className="w-3 h-3 border-2 border-current border-t-transparent rounded-full animate-spin"></div>
                                Auto-atualizando...
                              </span>
                            )}
                          </h4>
                          <div className="flex items-center gap-4 mt-1 text-xs text-muted-foreground">
                            <span className="flex items-center gap-1">
                              <span className="w-2 h-2 bg-yellow-500 rounded-full"></span>
                              Prospectando: {tabelaDados[agente.id].filter(item => (item.status || item.estado) === 'prospectando').length}
                            </span>
                            <span className="flex items-center gap-1">
                              <span className="w-2 h-2 bg-green-500 rounded-full"></span>
                              Completo: {tabelaDados[agente.id].filter(item => ['concluido', 'completo'].includes(item.status || item.estado)).length}
                            </span>
                          </div>
                        </div>
                        <button
                          onClick={() => carregarDadosTabela(agente)}
                          disabled={tabelaAtualizando[agente.id]}
                          className={`px-3 py-1 text-xs rounded transition-colors ${
                            tabelaAtualizando[agente.id]
                              ? 'bg-gray-100 text-gray-500 dark:bg-gray-900/20 dark:text-gray-600 cursor-not-allowed'
                              : 'bg-blue-100 text-blue-800 dark:bg-blue-900/20 dark:text-blue-400 hover:bg-blue-200 dark:hover:bg-blue-900/30'
                          }`}
                        >
                          {tabelaAtualizando[agente.id] ? (
                            <span className="flex items-center gap-1">
                              <div className="w-3 h-3 border-2 border-current border-t-transparent rounded-full animate-spin"></div>
                              Atualizando...
                            </span>
                          ) : (
                            '🔄 Atualizar'
                          )}
                        </button>
                      </div>
                      
                      <div className="overflow-x-auto">
                        <div className="max-h-80 overflow-y-auto border border-border rounded-lg">
                          <table className="w-full text-sm">
                            <thead className="bg-muted sticky top-0 z-10">
                              <tr>
                                <th className="px-4 py-3 text-left font-semibold border-b border-border">Nome</th>
                                <th className="px-4 py-3 text-left font-semibold border-b border-border">Telefone</th>
                                <th className="px-4 py-3 text-center font-semibold border-b border-border">Status</th>
                              </tr>
                            </thead>
                            <tbody>
                              {tabelaDados[agente.id]
                                .filter(item => {
                                  // Filtrar apenas prospectando e concluido
                                  const status = item.status || item.estado || 'desconhecido'
                                  return status === 'prospectando' || status === 'concluido' || status === 'completo'
                                })
                                .sort((a, b) => {
                                  // Ordenar: prospectando primeiro, depois outros status
                                  const statusA = a.status || a.estado || 'desconhecido'
                                  const statusB = b.status || b.estado || 'desconhecido'
                                  
                                  if (statusA === 'prospectando' && statusB !== 'prospectando') return -1
                                  if (statusA !== 'prospectando' && statusB === 'prospectando') return 1
                                  return 0
                                })
                                .slice(0, 10)
                                .map((item, index) => {
                                const nome = item.nome_cliente || item.nome || item.name || 'N/A'
                                const telefone = item.telefone || item.phone || 'N/A'
                                const status = item.status || item.estado || 'desconhecido'
                                
                                return (
                                  <tr key={index} className="border-b border-border hover:bg-muted/50 transition-colors">
                                    <td className="px-4 py-3 border-r border-border">
                                      <div className="font-medium text-foreground truncate max-w-48" title={nome}>
                                        {nome}
                                      </div>
                                    </td>
                                    <td className="px-4 py-3 border-r border-border">
                                      <div className="font-mono text-sm text-muted-foreground" title={telefone}>
                                        {telefone}
                                      </div>
                                    </td>
                                    <td className="px-4 py-3 text-center">
                                      <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium ${
                                        status === 'prospectando' 
                                          ? 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/20 dark:text-yellow-400'
                                          : status === 'concluido' || status === 'completo'
                                          ? 'bg-green-100 text-green-800 dark:bg-green-900/20 dark:text-green-400'
                                          : 'bg-gray-100 text-gray-800 dark:bg-gray-900/20 dark:text-gray-400'
                                      }`}>
                                        {status === 'prospectando' && '🔄'}
                                        {status === 'concluido' && '✅'}
                                        {status === 'completo' && '✅'}
                                        {!['prospectando', 'concluido', 'completo'].includes(status) && '❓'}
                                        <span className="ml-1 capitalize">
                                          {status === 'concluido' ? 'Completo' : status}
                                        </span>
                                      </span>
                                    </td>
                                  </tr>
                                )
                              })}
                          </tbody>
                        </table>
                        </div>
                        
                        {(() => {
                          const itensFiltrados = tabelaDados[agente.id].filter(item => {
                            const status = item.status || item.estado || 'desconhecido'
                            return status === 'prospectando' || status === 'concluido' || status === 'completo'
                          })
                          return itensFiltrados.length > 10 && (
                            <div className="text-xs text-muted-foreground mt-3 text-center bg-muted/50 py-2 rounded-b-lg">
                              Mostrando 10 de {itensFiltrados.length} itens filtrados
                            </div>
                          )
                        })()}
                      </div>
                    </div>
                  )}
                  
                  {/* Placeholder para carregar dados */}
                  {(!tabelaDados[agente.id] || tabelaDados[agente.id].length === 0) && (
                    <div className="mt-4 pt-4 border-t border-border">
                      <div className="text-center py-4 text-muted-foreground">
                        <div className="text-2xl mb-2">📊</div>
                        <p className="text-sm">Nenhum dado carregado</p>
                        <p className="text-xs">Clique no botão 📊 para carregar dados da tabela</p>
                      </div>
                    </div>
                  )}
                </div>
              ))}
            </div>
          ) : (
            <div className="text-center py-8 text-muted-foreground">
              <div className="text-4xl mb-2">🤖</div>
              <p>Nenhum agente encontrado</p>
              <p className="text-sm">Clique em "Listar Agentes" para carregar</p>
            </div>
          )}
        </div>
      </div>

    </div>
  )
}
