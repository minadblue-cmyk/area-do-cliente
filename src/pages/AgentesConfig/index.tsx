import { useState, useEffect } from 'react'
import { useToastStore } from '../../store/toast'
import { useAuthStore } from '../../store/auth'
import { useWebhookStore } from '../../store/webhooks'
import { callWebhook } from '../../utils/webhook-client'
import { Bot, Plus, Edit, Trash2, Play, Square, Settings, Save, X, Users, UserCheck, UserX } from 'lucide-react'

interface AgenteConfig {
  id?: number
  nome: string
  workflow_id: string
  webhook_url: string
  descricao: string
  icone: string
  cor: string
  ativo: boolean
  usuario_id?: number
}

interface Usuario {
  id: number
  nome: string
  email: string
  perfil_id: number
}

interface AtribuicaoAgente {
  id: number
  agente_id: number
  usuario_id: number
  atribuido_por: number
  atribuido_em: string
  agente_nome: string
  usuario_nome: string
}

export default function AgentesConfig() {
  const { addWebhook } = useWebhookStore()
  const [agentes, setAgentes] = useState<AgenteConfig[]>([])
  const [usuarios, setUsuarios] = useState<Usuario[]>([])
  const [atribuicoes, setAtribuicoes] = useState<AtribuicaoAgente[]>([])
  const [loading, setLoading] = useState(false)
  const [showForm, setShowForm] = useState(false)
  const [showIconPicker, setShowIconPicker] = useState(false)
  const [showAtribuicaoModal, setShowAtribuicaoModal] = useState(false)
  const [editingAgent, setEditingAgent] = useState<AgenteConfig | null>(null)
  const [agenteParaAtribuir, setAgenteParaAtribuir] = useState<AgenteConfig | null>(null)
  const [formData, setFormData] = useState<AgenteConfig>({
    nome: '',
    workflow_id: '',
    webhook_url: '',
    descricao: '',
    icone: '🤖',
    cor: 'bg-blue-500',
    ativo: true
  })
  
  const push = useToastStore((s) => s.push)
  const { userData } = useAuthStore()

  // Carregar agentes
  async function loadAgentes() {
    setLoading(true)
    try {
      console.log('🔄 REFRESH: Carregando agentes via webhook...')
      
      const response = await callWebhook('webhook/list-agentes', { 
        method: 'GET' 
      })
      
      console.log('🔄 REFRESH: Resposta completa do webhook:', response)
      console.log('🔄 REFRESH: Tipo da resposta:', typeof response)
      console.log('🔄 REFRESH: response.data:', response.data)
      
      // Verificar se a resposta tem o formato esperado
      if (response.data && Array.isArray(response.data) && response.data.length > 0 && response.data[0].success && Array.isArray(response.data[0].data) && response.data[0].data.length > 0) {
        console.log('🔍 Dados encontrados:', response.data)
        
        // O webhook retorna [{ success: true, data: [...], total: X }]
        console.log('🔍 Processando agentes do formato correto:', response.data[0].data)
        
        const agentesData = response.data[0].data.map((agente: any) => ({
          id: agente.id,
          nome: agente.nome,
          workflow_id: agente.workflow_start_id || agente.workflow_id,
          webhook_url: agente.webhook_start_url || agente.webhook_url,
          descricao: agente.descricao,
          icone: agente.icone,
          cor: agente.cor,
          ativo: agente.ativo,
          usuario_id: agente.usuario_id,
          status_atual: agente.status_atual,
          execution_id_ativo: agente.execution_id_ativo
        }))
        
        console.log('🔍 Agentes processados:', agentesData)
        setAgentes(agentesData)
        
        // Mostrar mensagem de sucesso
        push({ 
          kind: 'success', 
          message: `${agentesData.length} agentes carregados com sucesso!` 
        })
      } else if (response.data && response.data !== '' && response.data.success && Array.isArray(response.data.data)) {
        // Fallback: se response.data for { success: true, data: [...] }
        console.log('🔍 Formato objeto com data array detectado:', response.data.data)
        
        const agentesData = response.data.data.map((item: any) => {
          console.log('🔍 Processando agente (formato data array):', item)
          return {
            id: item.id,
            nome: item.nome,
            workflow_id: item.workflow_id,
            webhook_url: item.webhook_url,
            descricao: item.descricao,
            icone: item.icone,
            cor: item.cor,
            ativo: item.ativo
          }
        })
        
        console.log('🔍 Agentes processados (formato data array):', agentesData)
        setAgentes(agentesData)
        
        // Mostrar mensagem de sucesso
        push({ 
          kind: 'success', 
          message: `${agentesData.length} agentes carregados com sucesso!` 
        })
      } else {
        console.log('🔍 Resposta vazia ou formato não reconhecido, lista vazia')
        
        // Se o webhook retornar vazio ou formato não reconhecido, usar lista vazia
        setAgentes([])
        
        // Mostrar mensagem informativa apenas se não for uma resposta vazia esperada
        if (response.data && response.data !== '') {
          console.log('⚠️ Formato de resposta não reconhecido:', response.data)
          push({ kind: 'warning', message: 'Formato de resposta não reconhecido do webhook' })
        } else {
          console.log('ℹ️ Nenhum agente encontrado')
          push({ kind: 'info', message: 'Nenhum agente encontrado' })
        }
      }
    } catch (error: any) {
      console.error('Erro ao carregar agentes:', error)
      push({ kind: 'error', message: 'Erro ao carregar configurações de agentes' })
      setAgentes([])
    } finally {
      setLoading(false)
    }
  }

  // Carregar usuários
  async function loadUsuarios() {
    try {
      const response = await callWebhook('webhook/list-users', { 
        method: 'GET' 
      })
      
      if (response.data && Array.isArray(response.data)) {
        setUsuarios(response.data)
      }
    } catch (error) {
      console.error('Erro ao carregar usuários:', error)
    }
  }

       // Carregar atribuições de agentes
       async function loadAtribuicoes() {
         try {
           // Carregar todas as atribuições (sem filtro de usuário)
           const response = await callWebhook('webhook/list-agente-atribuicoes', { 
             method: 'GET'
           })
      
           if (response.data) {
             // O webhook agora retorna array direto ou objeto com data
             let atribuicoesData = []
             
             if (Array.isArray(response.data)) {
               // Formato novo: array direto - extrair data de cada item
               atribuicoesData = response.data.map(item => item.data || item)
             } else if (response.data.data) {
               // Formato antigo: objeto com propriedade data
               atribuicoesData = Array.isArray(response.data.data) 
                 ? response.data.data 
                 : [response.data.data]
             }
             
             setAtribuicoes(atribuicoesData)
             console.log('📋 Atribuições carregadas:', atribuicoesData)
           } else {
             console.log('⚠️ Nenhuma atribuição encontrada ou formato inválido')
             setAtribuicoes([])
           }
    } catch (error) {
      console.error('Erro ao carregar atribuições:', error)
      setAtribuicoes([])
    }
  }

       // Atribuir agente para usuário
       async function atribuirAgente(agenteId: number, usuarioId: number) {
         try {
           const response = await callWebhook('webhook/atribuir-agente-usuario', {
             method: 'POST',
             data: {
               agente_id: agenteId,
               usuario_id: usuarioId,
               atribuido_por: userData?.id
             }
           })

           if (response.data && response.data.success) {
             push({ kind: 'success', message: 'Agente atribuído com sucesso!' })
             
             // Aguardar um pouco e recarregar atribuições
             setTimeout(async () => {
               await loadAtribuicoes()
               console.log('🔄 Atribuições recarregadas após atribuição')
             }, 500)
           } else {
             throw new Error('Falha na atribuição')
           }
         } catch (error) {
           console.error('Erro ao atribuir agente:', error)
           push({ kind: 'error', message: 'Erro ao atribuir agente' })
         }
       }

  // Remover atribuição de agente
  async function removerAtribuicao(agenteId: number, usuarioId: number) {
    try {
      const response = await callWebhook('webhook/remover-atribuicao-agente', {
        method: 'POST',
        data: {
          agente_id: agenteId,
          usuario_id: usuarioId
        }
      })

      if (response.data && response.data.success) {
        push({ kind: 'success', message: 'Atribuição removida com sucesso!' })
        
        // Aguardar um pouco e recarregar atribuições
        setTimeout(async () => {
          await loadAtribuicoes()
          console.log('🔄 Atribuições recarregadas após remoção')
        }, 500)
      } else {
        throw new Error('Falha na remoção')
      }
    } catch (error) {
      console.error('Erro ao remover atribuição:', error)
      push({ kind: 'error', message: 'Erro ao remover atribuição' })
    }
  }

  // Verificar se agente está atribuído para usuário
  function isAgenteAtribuidoParaUsuario(agenteId: number, usuarioId: number): boolean {
    console.log(`🔍 Verificando atribuição: agente ${agenteId} para usuário ${usuarioId}`)
    console.log(`📋 Atribuições disponíveis:`, atribuicoes)
    console.log(`📊 Tipo de atribuicoes:`, typeof atribuicoes, Array.isArray(atribuicoes))
    console.log(`📊 Tamanho do array:`, atribuicoes?.length)
    
    if (!Array.isArray(atribuicoes)) {
      console.log('⚠️ Atribuições não é um array, retornando false')
      return false
    }
    
    if (atribuicoes.length === 0) {
      console.log('⚠️ Array de atribuições está vazio, retornando false')
      return false
    }
    
    const isAtribuido = atribuicoes.some(
      attr => {
        console.log(`🔍 Comparando: agente ${attr.agente_id} (${typeof attr.agente_id}) === ${agenteId} (${typeof agenteId}) && usuario ${attr.usuario_id} (${typeof attr.usuario_id}) === ${usuarioId} (${typeof usuarioId})`)
        const agenteMatch = attr.agente_id == agenteId // Usar == para conversão de tipo
        const usuarioMatch = attr.usuario_id == usuarioId // Usar == para conversão de tipo
        console.log(`🔍 Resultado: agenteMatch=${agenteMatch}, usuarioMatch=${usuarioMatch}`)
        return agenteMatch && usuarioMatch
      }
    )
    
    console.log(`✅ Está atribuído:`, isAtribuido)
    
    return isAtribuido
  }

  // Abrir modal de atribuição
  function abrirModalAtribuicao(agente: AgenteConfig) {
    console.log('🔍 Abrindo modal de atribuição para agente:', agente)
    setAgenteParaAtribuir(agente)
    setShowAtribuicaoModal(true)
    // Recarregar atribuições para garantir dados atualizados
    loadAtribuicoes()
  }

  // Fechar modal de atribuição
  function fecharModalAtribuicao() {
    setShowAtribuicaoModal(false)
    setAgenteParaAtribuir(null)
  }

  // Função de teste para atribuições
  async function testarAtribuicoes() {
    console.log('🧪 Iniciando teste de atribuições...')
    
    try {
      // 1. Verificar atribuições atuais
      console.log('📋 1. Verificando atribuições atuais...')
      await loadAtribuicoes()
      
      // 2. Aguardar o estado ser atualizado usando um loop de verificação
      console.log('📋 2. Aguardando estado ser atualizado...')
      let tentativas = 0
      let isAtribuido = false
      
      while (tentativas < 10) {
        await new Promise(resolve => setTimeout(resolve, 200))
        isAtribuido = isAgenteAtribuidoParaUsuario(65, 6)
        console.log(`📋 Tentativa ${tentativas + 1}: isAtribuido = ${isAtribuido}`)
        
        if (isAtribuido) break
        tentativas++
      }
      
      console.log('✅ Usuário 6 atribuído ao agente 65:', isAtribuido)
      
      if (isAtribuido) {
        push({ 
          kind: 'success', 
          message: 'Teste de atribuição: SUCESSO! Atribuição já existe e foi encontrada.' 
        })
      } else {
        // 3. Criar uma atribuição de teste
        console.log('📋 3. Criando atribuição de teste...')
        await atribuirAgente(65, 6) // Agente João para usuário Teste de Dashboard
        
        // 4. Aguardar um pouco
        await new Promise(resolve => setTimeout(resolve, 1000))
        
        // 5. Recarregar atribuições
        console.log('📋 4. Recarregando atribuições...')
        await loadAtribuicoes()
        
        // 6. Aguardar o estado ser atualizado novamente
        console.log('📋 5. Aguardando estado ser atualizado após criação...')
        tentativas = 0
        let isAtribuidoApos = false
        
        while (tentativas < 10) {
          await new Promise(resolve => setTimeout(resolve, 200))
          isAtribuidoApos = isAgenteAtribuidoParaUsuario(65, 6)
          console.log(`📋 Tentativa ${tentativas + 1} (após criação): isAtribuido = ${isAtribuidoApos}`)
          
          if (isAtribuidoApos) break
          tentativas++
        }
        
        console.log('✅ Usuário 6 atribuído ao agente 65 (após criação):', isAtribuidoApos)
        
        push({ 
          kind: isAtribuidoApos ? 'success' : 'warning', 
          message: isAtribuidoApos 
            ? 'Teste de atribuição: SUCESSO! Usuário foi atribuído.' 
            : 'Teste de atribuição: FALHOU! Usuário não foi atribuído.' 
        })
      }
      
    } catch (error) {
      console.error('❌ Erro no teste:', error)
      push({ kind: 'error', message: 'Erro no teste de atribuições' })
    }
  }

  // Gerar ID único para o agente
  const generateAgentId = () => {
    const timestamp = Date.now().toString(36)
    const random = Math.random().toString(36).substr(2, 5)
    return `${timestamp}${random}`.toUpperCase()
  }

  // Gerar tipo do agente baseado no nome
  const generateAgentType = (name: string) => {
    return name
      .toLowerCase()
      .replace(/\s+/g, '')
      .replace(/[^a-z0-9]/g, '')
      .substring(0, 20)
  }

  // Salvar agente (criar ou editar)
  async function saveAgent() {
    if (!formData.nome) {
      push({ kind: 'error', message: 'Nome do agente é obrigatório' })
      return
    }

    // Prevenir duplo clique
    if (loading) {
      console.log('⚠️ Requisição já em andamento, ignorando duplo clique')
      return
    }

    setLoading(true)

    try {
      if (editingAgent) {
        // Editar agente existente
        await callWebhook('webhook/update-agente', {
          method: 'POST',
          data: {
            id: editingAgent.id,
            ...formData,
            logged_user: {
              id: userData?.id,
              name: userData?.name,
              email: userData?.mail
            }
          }
        })
        push({ kind: 'success', message: 'Agente atualizado com sucesso!' })
      } else {
        // Criar novo agente com clonagem automática
        const agentId = generateAgentId()
        const agentType = generateAgentType(formData.nome)
        
        console.log('🚀 Criando agente com clonagem automática:', {
          agent_name: formData.nome,
          agent_type: agentType,
          agent_id: agentId,
          user_id: userData?.id
        })

        // Chamar webhook de clonagem automática
        const response = await callWebhook('webhook/create-agente', {
          method: 'POST',
          data: {
            action: 'create',
            agent_name: formData.nome,
            agent_type: agentType,
            agent_id: agentId,
            user_id: userData?.id,
            // Campos adicionais do formulário
            descricao: formData.descricao || '',
            icone: formData.icone || '🤖',
            cor: formData.cor || 'bg-blue-500',
            ativo: formData.ativo !== undefined ? formData.ativo : true,
            workflow_id: formData.workflow_id || '',
            webhook_url: formData.webhook_url || ''
          }
        })

        console.log('✅ Resposta da clonagem:', response)

        // Verificar se a resposta indica sucesso
        if (response.data && response.data.success && response.data.agentId) {
          // Agente criado com sucesso no n8n (nova estrutura)
          push({ 
            kind: 'success', 
            message: `Agente ${response.data.agentName || formData.nome} criado com sucesso! ID: ${response.data.agentId}` 
          })
          // Recarregar lista de agentes com delay
          console.log('🔄 REFRESH: Chamando loadAgentes() após criação bem-sucedida (nova estrutura)')
          setTimeout(() => {
            console.log('🔄 REFRESH: Executando loadAgentes() após delay de 2s')
            loadAgentes()
          }, 2000)
          // Refresh adicional após 5 segundos para garantir
          setTimeout(() => {
            console.log('🔄 REFRESH: Executando loadAgentes() após delay de 5s (backup)')
            loadAgentes()
          }, 5000)
        } else if (response.data && response.data.message === 'Workflow was started') {
          // Workflow iniciado com sucesso no n8n (estrutura antiga)
          push({ 
            kind: 'success', 
            message: `Agente ${formData.nome} criado com sucesso! Workflow foi iniciado automaticamente.` 
          })
          // Recarregar lista de agentes com delay
          console.log('🔄 REFRESH: Chamando loadAgentes() após criação bem-sucedida (workflow started)')
          setTimeout(() => {
            console.log('🔄 REFRESH: Executando loadAgentes() após delay de 2s')
            loadAgentes()
          }, 2000)
          // Refresh adicional após 5 segundos para garantir
          setTimeout(() => {
            console.log('🔄 REFRESH: Executando loadAgentes() após delay de 5s (backup)')
            loadAgentes()
          }, 5000)
        } else if (response.data && (response.data.id || response.data.name)) {
          // Workflow criado com sucesso (estrutura com dados completos)
          push({ 
            kind: 'success', 
            message: `Agente ${formData.nome} criado com sucesso! Workflow "${response.data.name}" foi criado automaticamente.` 
          })
          // Recarregar lista de agentes com delay
          console.log('🔄 REFRESH: Chamando loadAgentes() após criação bem-sucedida (dados completos)')
          setTimeout(() => {
            console.log('🔄 REFRESH: Executando loadAgentes() após delay de 2s')
            loadAgentes()
          }, 2000)
          // Refresh adicional após 5 segundos para garantir
          setTimeout(() => {
            console.log('🔄 REFRESH: Executando loadAgentes() após delay de 5s (backup)')
            loadAgentes()
          }, 5000)
        } else if (response.data?.success) {
          // Estrutura antiga com success flag
          const workflows = response.data.workflows
          if (workflows) {
            Object.values(workflows).forEach((workflow: any) => {
              if (workflow.webhook) {
                const webhookUrl = `https://n8n.code-iq.com.br/webhook/${workflow.webhook}`
                addWebhook(`webhook/${workflow.webhook}`, webhookUrl)
              }
            })
          }
          
          push({ 
            kind: 'success', 
            message: `Agente ${formData.nome} criado com sucesso! 4 workflows foram criados automaticamente.` 
          })
          // Recarregar lista de agentes com delay
          console.log('🔄 REFRESH: Chamando loadAgentes() após criação bem-sucedida (success flag)')
          setTimeout(() => {
            console.log('🔄 REFRESH: Executando loadAgentes() após delay de 2s')
            loadAgentes()
          }, 2000)
          // Refresh adicional após 5 segundos para garantir
          setTimeout(() => {
            console.log('🔄 REFRESH: Executando loadAgentes() após delay de 5s (backup)')
            loadAgentes()
          }, 5000)
        } else if (response.status === 200 && response.data) {
          // Resposta de sucesso com status 200 (mesmo que data seja vazio)
          push({ 
            kind: 'success', 
            message: `Agente ${formData.nome} criado com sucesso! Workflow foi processado.` 
          })
          // Recarregar lista de agentes com delay para dar tempo do n8n processar
          console.log('🔄 REFRESH: Chamando loadAgentes() após criação bem-sucedida')
          setTimeout(() => {
            console.log('🔄 REFRESH: Executando loadAgentes() após delay de 2s')
            loadAgentes()
          }, 2000)
          // Refresh adicional após 5 segundos para garantir
          setTimeout(() => {
            console.log('🔄 REFRESH: Executando loadAgentes() após delay de 5s (backup)')
            loadAgentes()
          }, 5000)
        } else {
          throw new Error('Falha na criação automática do agente')
        }
      }
      
      setShowForm(false)
      setEditingAgent(null)
      resetForm()
      
      // Refresh final para garantir que a lista seja atualizada
      console.log('🔄 REFRESH: Executando refresh final após criação')
      setTimeout(() => {
        loadAgentes()
      }, 3000)
      
    } catch (error: any) {
      console.error('Erro ao salvar agente:', error)
      push({ kind: 'error', message: 'Erro ao criar agente automaticamente' })
    } finally {
      setLoading(false)
    }
  }

  // Excluir agente
  async function deleteAgent(id: number, agentName: string) {
    if (!confirm('Tem certeza que deseja excluir este agente?')) return

    try {
      await callWebhook('webhook/delete-agente', {
        method: 'POST',
        data: {
          id,
          agent_name: agentName, // ← ADICIONAR NOME DO AGENTE
          logged_user: {
            id: userData?.id,
            name: userData?.name,
            email: userData?.mail
          }
        }
      })
      push({ kind: 'success', message: 'Agente excluído com sucesso!' })
      loadAgentes()
    } catch (error: any) {
      console.error('Erro ao excluir agente:', error)
      push({ kind: 'error', message: 'Erro ao excluir agente' })
    }
  }

  // Testar webhook (apenas conectividade)
  async function testWebhook(agente: AgenteConfig) {
    try {
      console.log('🔍 Testando conectividade do webhook:', agente.webhook_url)
      
      // Tentar fazer uma requisição simples para verificar se o webhook está ativo
      const webhookUrl = `https://n8n.code-iq.com.br/${agente.webhook_url}`
      
      // Usar fetch com mode 'no-cors' para contornar CORS
      const response = await fetch(webhookUrl, {
        method: 'POST',
        mode: 'no-cors',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          test: true,
          ping: "connectivity_test"
        })
      })
      
      // Com mode 'no-cors', não conseguimos ver a resposta, mas se não deu erro, o webhook está ativo
      console.log('🔍 Requisição enviada para:', webhookUrl)
      push({ kind: 'success', message: `✅ Webhook ${agente.nome} está ativo!` })
      
    } catch (error: any) {
      console.error('Erro ao testar webhook:', error)
      
      // Se deu erro, provavelmente o webhook não está ativo
      if (error.message.includes('Failed to fetch') || error.message.includes('ERR_FAILED')) {
        push({ kind: 'error', message: `❌ Webhook ${agente.nome} não está ativo` })
      } else {
        push({ kind: 'error', message: `❌ Webhook ${agente.nome} com erro de conectividade` })
      }
    }
  }

  // Resetar formulário
  function resetForm() {
    setFormData({
      nome: '',
      workflow_id: '',
      webhook_url: '',
      descricao: '',
      icone: '🤖',
      cor: 'bg-blue-500',
      ativo: true
    })
  }

  // Editar agente
  function editAgent(agente: AgenteConfig) {
    console.log('🔍 Editando agente:', agente)
    setEditingAgent(agente)
    setFormData(agente)
    setShowForm(true)
  }

  // Cancelar edição
  function cancelEdit() {
    setShowForm(false)
    setShowIconPicker(false)
    setEditingAgent(null)
    resetForm()
  }

  // Carregar dados na inicialização
  useEffect(() => {
    loadAgentes()
    loadUsuarios()
    loadAtribuicoes()
  }, [])

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-semibold text-foreground mb-2">
            Configuração de Agentes
          </h1>
          <p className="text-muted-foreground">
            Gerencie os agentes automatizados do sistema
          </p>
        </div>
        <div className="flex gap-2">
          <button
            onClick={() => setShowForm(true)}
            className="btn btn-primary flex items-center gap-2"
          >
            <Plus className="w-4 h-4" />
            Criar Agente Automaticamente
          </button>
          <button
            onClick={testarAtribuicoes}
            className="btn btn-outline flex items-center gap-2"
          >
            🧪 Testar Atribuições
          </button>
        </div>
      </div>

      {/* Lista de Agentes */}
           <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 2xl:grid-cols-5 gap-6 auto-rows-max">
        {loading ? (
          <div className="col-span-full text-center py-8">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto"></div>
            <p className="mt-2 text-muted-foreground">Carregando agentes...</p>
          </div>
        ) : agentes.length === 0 ? (
          <div className="col-span-full text-center py-8">
            <Bot className="w-12 h-12 text-muted-foreground mx-auto mb-4" />
            <p className="text-muted-foreground">Nenhum agente configurado</p>
            <p className="text-sm text-muted-foreground mt-1">
              Clique em "Criar Agente Automaticamente" para começar
            </p>
          </div>
        ) : (
          agentes.map((agente) => (
            <div key={agente.id} className="card min-h-[450px] flex flex-col hover:shadow-lg transition-shadow duration-200 overflow-hidden">
                   <div className="card-header pb-4">
                     <div className="flex items-start justify-between gap-3">
                       <div className="flex items-center gap-3 flex-1 min-w-0">
                         <span className="text-3xl flex-shrink-0">{agente.icone}</span>
                         <div className="flex-1 min-w-0">
                           <h3 className="font-semibold text-lg truncate">{agente.nome}</h3>
                           <p className="text-sm text-muted-foreground truncate">
                             {agente.descricao || 'Agente automatizado'}
                           </p>
                           {/* Indicador de atribuições */}
                           {(() => {
                             const agentesAtribuidos = atribuicoes.filter(attr => attr.agente_id === agente.id)
                             if (agentesAtribuidos.length > 0) {
                               return (
                                 <div className="flex items-center gap-1 mt-2">
                                   <div className="w-2 h-2 bg-green-500 rounded-full flex-shrink-0"></div>
                                   <span className="text-xs text-green-600 font-medium truncate">
                                     {agentesAtribuidos.length} usuário{agentesAtribuidos.length > 1 ? 's' : ''} atribuído{agentesAtribuidos.length > 1 ? 's' : ''}
                                   </span>
                                 </div>
                               )
                             }
                             return null
                           })()}
                         </div>
                       </div>
                       <div className="flex flex-col gap-2 flex-shrink-0">
                         <div className={`px-3 py-1 rounded-full text-xs font-medium whitespace-nowrap ${
                           agente.ativo 
                             ? 'bg-green-100 text-green-700 dark:bg-green-900/20 dark:text-green-400' 
                             : 'bg-red-100 text-red-700 dark:bg-red-900/20 dark:text-red-400'
                         }`}>
                           {agente.ativo ? 'Ativo' : 'Inativo'}
                         </div>
                         {/* Indicador visual de atribuições */}
                         {(() => {
                           const agentesAtribuidos = atribuicoes.filter(attr => attr.agente_id === agente.id)
                           if (agentesAtribuidos.length > 0) {
                             return (
                               <div className="px-3 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-700 dark:bg-blue-900/20 dark:text-blue-400 whitespace-nowrap">
                                 {agentesAtribuidos.length} atribuído{agentesAtribuidos.length > 1 ? 's' : ''}
                               </div>
                             )
                           }
                           return (
                             <div className="px-3 py-1 rounded-full text-xs font-medium bg-gray-100 text-gray-500 dark:bg-gray-800 dark:text-gray-400 whitespace-nowrap">
                               Sem atribuições
                             </div>
                           )
                         })()}
                       </div>
                     </div>
                   </div>
              
                   <div className="card-content space-y-4 flex-1">
                     <div className="grid grid-cols-2 gap-3">
                       <div className="space-y-2 min-w-0">
                         <div className="text-xs font-medium text-muted-foreground">Workflow ID</div>
                         <div className="text-sm font-mono bg-muted px-2 py-1 rounded truncate">
                           {agente.workflow_id || 'Não definido'}
                         </div>
                       </div>
                       <div className="space-y-2 min-w-0">
                         <div className="text-xs font-medium text-muted-foreground">Cor</div>
                         <div className="flex items-center gap-2 min-w-0">
                           <span className={`w-4 h-4 rounded flex-shrink-0 ${agente.cor || 'bg-gray-500'}`}></span>
                           <span className="text-sm truncate">
                             {(() => {
                               const corCode = agente.cor?.replace('bg-', '').replace('-500', '').replace('-600', '') || 'gray'
                               const coresMap: { [key: string]: string } = {
                                 'red': 'Vermelho',
                                 'pink': 'Rosa',
                                 'orange': 'Laranja',
                                 'yellow': 'Amarelo',
                                 'lime': 'Lima',
                                 'green': 'Verde',
                                 'emerald': 'Esmeralda',
                                 'teal': 'Verde Azulado',
                                 'cyan': 'Ciano',
                                 'blue': 'Azul',
                                 'indigo': 'Índigo',
                                 'purple': 'Roxo',
                                 'violet': 'Violeta',
                                 'fuchsia': 'Fuchsia',
                                 'slate': 'Cinza',
                                 'gray': 'Cinza',
                                 'zinc': 'Zinco',
                                 'neutral': 'Neutro',
                                 'stone': 'Pedra',
                                 'amber': 'Âmbar'
                               }
                               return coresMap[corCode] || corCode
                             })()}
                           </span>
                         </div>
                       </div>
                     </div>
                     
                     <div className="space-y-2 min-w-0">
                       <div className="text-xs font-medium text-muted-foreground">Webhook URL</div>
                       <div className="text-xs font-mono bg-muted px-2 py-1 rounded truncate">
                         {agente.webhook_url || 'Não definido'}
                       </div>
                     </div>
                       
                     {/* SEÇÃO: Atribuições */}
                     <div className="border-t pt-4">
                       <div className="flex items-center gap-2 mb-3">
                         <div className="w-2 h-2 bg-blue-500 rounded-full flex-shrink-0"></div>
                         <div className="text-sm font-semibold text-foreground truncate">
                           👥 Atribuído para:
                         </div>
                       </div>
                       {(() => {
                         const agentesAtribuidos = atribuicoes.filter(attr => attr.agente_id === agente.id)
                         
                         if (agentesAtribuidos.length === 0) {
                           return (
                             <div className="text-sm text-muted-foreground italic bg-muted/50 px-3 py-2 rounded-lg">
                               Nenhum usuário atribuído
                             </div>
                           )
                         }
                         
                         return (
                           <div className="space-y-2 max-h-32 overflow-y-auto">
                             {agentesAtribuidos.map((atribuicao, index) => (
                               <div key={index} className="flex items-center gap-3 p-2 bg-muted/30 rounded-lg min-w-0">
                                 <div className="w-2 h-2 bg-green-500 rounded-full flex-shrink-0"></div>
                                 <div className="flex-1 min-w-0">
                                   <div className="font-medium text-sm text-foreground truncate">
                                     {atribuicao.usuario_nome || `Usuário ${atribuicao.usuario_id}`}
                                   </div>
                                   <div className="text-xs text-muted-foreground truncate">
                                     {atribuicao.usuario_id || 'Sem ID'}
                                   </div>
                                 </div>
                               </div>
                             ))}
                           </div>
                         )
                       })()}
                     </div>
                     
                     {/* BOTÕES DE AÇÃO */}
                     <div className="grid grid-cols-2 gap-2 pt-4 mt-auto border-t">
                       <button
                         onClick={() => testWebhook(agente)}
                         className="btn btn-sm btn-outline flex items-center justify-center gap-2 hover:bg-blue-50 hover:border-blue-300 min-w-0"
                         title="Testar Webhook"
                       >
                         <Play className="w-4 h-4 flex-shrink-0" />
                         <span className="truncate">Testar</span>
                       </button>
                       <button
                         onClick={() => editAgent(agente)}
                         className="btn btn-sm btn-outline flex items-center justify-center gap-2 hover:bg-yellow-50 hover:border-yellow-300 min-w-0"
                         title="Editar Agente"
                       >
                         <Edit className="w-4 h-4 flex-shrink-0" />
                         <span className="truncate">Editar</span>
                       </button>
                       <button
                         onClick={() => abrirModalAtribuicao(agente)}
                         className="btn btn-sm btn-primary flex items-center justify-center gap-2 hover:bg-blue-600 min-w-0"
                         title="Atribuir Agente"
                       >
                         <Users className="w-4 h-4 flex-shrink-0" />
                         <span className="truncate">Atribuir</span>
                       </button>
                       <button
                         onClick={() => deleteAgent(agente.id!, agente.nome)}
                         className="btn btn-sm btn-destructive flex items-center justify-center gap-2 hover:bg-red-600 min-w-0"
                         title="Excluir Agente"
                       >
                         <Trash2 className="w-4 h-4 flex-shrink-0" />
                         <span className="truncate">Excluir</span>
                       </button>
                     </div>
              </div>
            </div>
          ))
        )}
      </div>

      {/* Formulário de Criação/Edição */}
      {showForm && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
          <div className="bg-background border rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-xl font-semibold">
                {editingAgent ? 'Editar Agente' : 'Criar Agente Automaticamente'}
              </h2>
              <button
                onClick={cancelEdit}
                className="text-muted-foreground hover:text-foreground"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={(e) => { e.preventDefault(); saveAgent(); }} className="space-y-4">
              {/* Informação sobre criação automática */}
              {!editingAgent && (
                <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
                  <div className="flex items-start gap-3">
                    <div className="text-blue-600 text-xl">🚀</div>
                    <div>
                      <h3 className="font-medium text-blue-900 mb-1">Criação Automática de Agente</h3>
                      <p className="text-sm text-blue-700">
                        Ao criar um novo agente, o sistema irá automaticamente:
                      </p>
                      <ul className="text-sm text-blue-700 mt-2 space-y-1">
                        <li>• Gerar um ID único para o agente</li>
                        <li>• Criar 4 workflows essenciais (Start, Stop, Status, Lista)</li>
                        <li>• Configurar webhooks específicos</li>
                        <li>• Organizar na estrutura "Elleve Consorcios"</li>
                      </ul>
                    </div>
                  </div>
                </div>
              )}

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-2">
                    Nome do Agente *
                  </label>
                  <input
                    type="text"
                    value={formData.nome || ''}
                    onChange={(e) => setFormData({ ...formData, nome: e.target.value })}
                    className="input w-full"
                    placeholder="ex: Agente João"
                    required
                  />
                  {!editingAgent && (
                    <p className="text-xs text-muted-foreground mt-1">
                      O sistema gerará automaticamente o Workflow ID e Webhook URL
                    </p>
                  )}
                </div>

                {editingAgent && (
                  <>
                    <div>
                      <label className="block text-sm font-medium mb-2">
                        Workflow ID *
                      </label>
                      <input
                        type="text"
                        value={formData.workflow_id || ''}
                        onChange={(e) => setFormData({ ...formData, workflow_id: e.target.value })}
                        className="input w-full"
                        placeholder="ex: eBcColwirndBaFZX"
                        required
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium mb-2">
                        Webhook URL *
                      </label>
                      <input
                        type="text"
                        value={formData.webhook_url || ''}
                        onChange={(e) => setFormData({ ...formData, webhook_url: e.target.value })}
                        className="input w-full"
                        placeholder="ex: webhook/agente1"
                        required
                      />
                    </div>
                  </>
                )}

                <div>
                  <label className="block text-sm font-medium mb-2">
                    Ícone
                  </label>
                  <div className="flex gap-2">
                    <input
                      type="text"
                      value={formData.icone || ''}
                      onChange={(e) => setFormData({ ...formData, icone: e.target.value })}
                      className="input flex-1"
                      placeholder="ex: 🤖"
                    />
                    <button
                      type="button"
                      onClick={() => setShowIconPicker(!showIconPicker)}
                      className="btn btn-outline px-3"
                      title="Escolher ícone"
                    >
                      🎨
                    </button>
                  </div>
                  
                  {/* Seletor de Ícones */}
                  {showIconPicker && (
                    <div className="mt-3 p-4 border rounded-lg bg-muted/50">
                      <h4 className="text-sm font-medium mb-3">Escolha um ícone:</h4>
                      <div className="grid grid-cols-8 gap-2">
                        {/* Robôs e IA */}
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🤖' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Robô">🤖</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '👾' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Alien">👾</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🦾' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Braço Robótico">🦾</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🦿' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Perna Robótica">🦿</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🧠' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Cérebro IA">🧠</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '⚡' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Energia">⚡</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🔮' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Cristal">🔮</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🎯' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Alvo">🎯</button>
                        
                        {/* Comunicação */}
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '💬' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Chat">💬</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '📞' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Telefone">📞</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '📧' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Email">📧</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '📱' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Celular">📱</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🌐' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Web">🌐</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🔗' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Link">🔗</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '📊' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Analytics">📊</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '📈' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Gráfico">📈</button>
                        
                        {/* Ações */}
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🚀' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Foguete">🚀</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '⚙️' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Engrenagem">⚙️</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🔧' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Ferramenta">🔧</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🛠️' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Ferramentas">🛠️</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🔍' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Busca">🔍</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '💡' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Ideia">💡</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🎪' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Show">🎪</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🎭' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Teatro">🎭</button>
                        
                        {/* Status */}
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🔥' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Fogo">🔥</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '❄️' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Gelo">❄️</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '⭐' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Estrela">⭐</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🌟' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Estrela Brilhante">🌟</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '💎' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Diamante">💎</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🏆' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Troféu">🏆</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🎖️' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Medalha">🎖️</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '✅' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Sucesso">✅</button>
                        
                        {/* Adicionais */}
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🎨' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Arte">🎨</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🎵' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Música">🎵</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🎮' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Game">🎮</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🎲' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Dado">🎲</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🎪' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Show">🎪</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🎭' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Teatro">🎭</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🎧' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Fone">🎧</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🎬' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Filme">🎬</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🎤' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Microfone">🎤</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🎸' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Guitarra">🎸</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🎹' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Piano">🎹</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🥳' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Festa">🥳</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🤩' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Impressionado">🤩</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '😎' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Cool">😎</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🚀' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Foguete">🚀</button>
                        <button type="button" onClick={() => { setFormData({ ...formData, icone: '🌌' }); setShowIconPicker(false) }} className="p-2 text-2xl hover:bg-background rounded border" title="Galáxia">🌌</button>
                      </div>
                    </div>
                  )}
                </div>

                <div>
                  <label className="block text-sm font-medium mb-2">
                    Cor CSS
                  </label>
                  <select
                    value={formData.cor}
                    onChange={(e) => setFormData({ ...formData, cor: e.target.value })}
                    className="input w-full"
                  >
                    <option value="bg-red-500">🔴 Vermelho</option>
                    <option value="bg-red-600">🔴 Vermelho Escuro</option>
                    <option value="bg-pink-500">🌸 Rosa</option>
                    <option value="bg-pink-600">🌸 Rosa Escuro</option>
                    <option value="bg-orange-500">🟠 Laranja</option>
                    <option value="bg-orange-600">🟠 Laranja Escuro</option>
                    <option value="bg-yellow-500">🟡 Amarelo</option>
                    <option value="bg-yellow-600">🟡 Amarelo Escuro</option>
                    <option value="bg-lime-500">🟢 Lima</option>
                    <option value="bg-lime-600">🟢 Lima Escuro</option>
                    <option value="bg-green-500">🟢 Verde</option>
                    <option value="bg-green-600">🟢 Verde Escuro</option>
                    <option value="bg-emerald-500">💚 Esmeralda</option>
                    <option value="bg-emerald-600">💚 Esmeralda Escuro</option>
                    <option value="bg-teal-500">🟦 Verde Azulado</option>
                    <option value="bg-teal-600">🟦 Verde Azulado Escuro</option>
                    <option value="bg-cyan-500">🔵 Ciano</option>
                    <option value="bg-cyan-600">🔵 Ciano Escuro</option>
                    <option value="bg-blue-500">🔵 Azul</option>
                    <option value="bg-blue-600">🔵 Azul Escuro</option>
                    <option value="bg-indigo-500">🟣 Índigo</option>
                    <option value="bg-indigo-600">🟣 Índigo Escuro</option>
                    <option value="bg-purple-500">🟣 Roxo</option>
                    <option value="bg-purple-600">🟣 Roxo Escuro</option>
                    <option value="bg-violet-500">💜 Violeta</option>
                    <option value="bg-violet-600">💜 Violeta Escuro</option>
                    <option value="bg-fuchsia-500">🟣 Fuchsia</option>
                    <option value="bg-fuchsia-600">🟣 Fuchsia Escuro</option>
                    <option value="bg-slate-500">⚫ Cinza</option>
                    <option value="bg-slate-600">⚫ Cinza Escuro</option>
                    <option value="bg-gray-500">⚫ Cinza Médio</option>
                    <option value="bg-gray-600">⚫ Cinza Médio Escuro</option>
                    <option value="bg-zinc-500">⚫ Zinco</option>
                    <option value="bg-zinc-600">⚫ Zinco Escuro</option>
                    <option value="bg-neutral-500">⚫ Neutro</option>
                    <option value="bg-neutral-600">⚫ Neutro Escuro</option>
                    <option value="bg-stone-500">🟤 Pedra</option>
                    <option value="bg-stone-600">🟤 Pedra Escuro</option>
                    <option value="bg-amber-500">🟡 Âmbar</option>
                    <option value="bg-amber-600">🟡 Âmbar Escuro</option>
                  </select>
                </div>

                <div className="md:col-span-2">
                  <label className="block text-sm font-medium mb-2">
                    Descrição
                  </label>
                  <textarea
                    value={formData.descricao || ''}
                    onChange={(e) => setFormData({ ...formData, descricao: e.target.value })}
                    className="input w-full"
                    rows={3}
                    placeholder="Descrição do agente..."
                  />
                </div>

                <div className="md:col-span-2">
                  <label className="flex items-center gap-2">
                    <input
                      type="checkbox"
                      checked={formData.ativo}
                      onChange={(e) => setFormData({ ...formData, ativo: e.target.checked })}
                      className="rounded"
                    />
                    <span className="text-sm font-medium">Agente ativo</span>
                  </label>
                </div>
              </div>

              <div className="flex justify-end gap-3 pt-4">
                <button
                  type="button"
                  onClick={cancelEdit}
                  className="btn btn-outline"
                >
                  Cancelar
                </button>
                <button
                  type="submit"
                  disabled={loading}
                  className="btn btn-primary flex items-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <Save className="w-4 h-4" />
                  {loading ? 'Processando...' : (editingAgent ? 'Atualizar' : 'Criar Automaticamente')} Agente
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal de Atribuição de Agentes */}
      {showAtribuicaoModal && agenteParaAtribuir && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
          <div className="bg-background border rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-xl font-semibold">
                Atribuir Agente: {agenteParaAtribuir.nome}
              </h2>
              <button
                onClick={fecharModalAtribuicao}
                className="text-muted-foreground hover:text-foreground"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="space-y-4">
              <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                <div className="flex items-start gap-3">
                  <div className="text-blue-600 text-xl">👥</div>
                  <div>
                    <h3 className="font-medium text-blue-900 mb-1">Atribuição de Agentes</h3>
                    <p className="text-sm text-blue-700">
                      Selecione os usuários que terão acesso a este agente. 
                      Apenas usuários com permissão de execução de agentes poderão utilizá-lo.
                    </p>
                  </div>
                </div>
              </div>

              <div className="space-y-3">
                <h3 className="font-medium text-gray-900">Usuários Disponíveis</h3>
                {usuarios.length === 0 ? (
                  <div className="text-center py-8 text-gray-500">
                    <Users className="w-12 h-12 mx-auto mb-2 text-gray-400" />
                    <p>Nenhum usuário encontrado</p>
                  </div>
                ) : (
                  <div className="grid grid-cols-1 gap-2 max-h-60 overflow-y-auto">
                    {usuarios.map((usuario) => {
                      const isAtribuido = isAgenteAtribuidoParaUsuario(agenteParaAtribuir.id!, usuario.id)
                      return (
                        <div
                          key={usuario.id}
                          className={`flex items-center justify-between p-3 border rounded-lg transition-colors ${
                            isAtribuido 
                              ? 'bg-green-100 border-green-300 shadow-sm' 
                              : 'bg-white border-gray-200 hover:bg-gray-50'
                          }`}
                        >
                          <div className="flex items-center gap-3">
                            <div className={`w-8 h-8 rounded-full flex items-center justify-center ${
                              isAtribuido ? 'bg-green-200 text-green-700' : 'bg-gray-200 text-gray-700'
                            }`}>
                              {isAtribuido ? <UserCheck className="w-4 h-4" /> : <Users className="w-4 h-4" />}
                            </div>
                            <div>
                              <p className={`font-medium ${isAtribuido ? 'text-green-800' : 'text-gray-900'}`}>
                                {usuario.nome}
                              </p>
                              <p className={`text-sm ${isAtribuido ? 'text-green-600' : 'text-gray-600'}`}>
                                {usuario.email}
                              </p>
                            </div>
                          </div>
                          <div className="flex gap-2">
                            {isAtribuido ? (
                              <button
                                onClick={() => removerAtribuicao(agenteParaAtribuir.id!, usuario.id)}
                                className="btn btn-sm btn-destructive flex items-center gap-1"
                                title="Remover Atribuição"
                              >
                                <UserX className="w-3 h-3" />
                                Remover
                              </button>
                            ) : (
                              <button
                                onClick={() => atribuirAgente(agenteParaAtribuir.id!, usuario.id)}
                                className="btn btn-sm btn-primary flex items-center gap-1"
                                title="Atribuir Agente"
                              >
                                <UserCheck className="w-3 h-3" />
                                Atribuir
                              </button>
                            )}
                          </div>
                        </div>
                      )
                    })}
                  </div>
                )}
              </div>

              <div className="flex justify-end pt-4 border-t">
                <button
                  onClick={fecharModalAtribuicao}
                  className="btn btn-outline"
                >
                  Fechar
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
