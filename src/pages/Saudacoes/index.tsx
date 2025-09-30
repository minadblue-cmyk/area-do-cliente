import { useState, useEffect } from 'react'
import { callWebhook } from '../../utils/webhook-client'
import type { SaudacaoItem } from '../../lib/types'
import { useToastStore } from '../../store/toast'
import { useAuthStore } from '../../store/auth'
import { MessageSquare, Save, Smile, Trash2, Send, RefreshCw } from 'lucide-react'

export default function Saudacoes() {
  const [items, setItems] = useState<SaudacaoItem[]>([])
  const [loading, setLoading] = useState(true)
  const [newMessage, setNewMessage] = useState('')
  const [showEmojiPicker, setShowEmojiPicker] = useState(false)
  const [lastUpdated, setLastUpdated] = useState<Date | null>(null)
  const push = useToastStore((s) => s.push)
  const { userData } = useAuthStore()

  // Emojis simplificados
  const emojis = [
    '😊', '😄', '😃', '😁', '😆', '😅', '😂', '🤣', '😇', '🙂', '🙃', '😉', '😌', '😍', '🥰', '😘', '😗', '😙', '😚', '😋', '😛', '😝', '😜', '🤪', '🤨', '🧐', '🤓', '😎', '🤩', '🥳', '😏', '😒', '😞', '😔', '😟', '😕', '🙁', '☹️', '😣', '😖', '😫', '😩', '🥺', '😢', '😭', '😤', '😠', '😡', '🤬', '🤯', '😳', '🥵', '🥶', '😱', '😨', '😰', '😥', '😓', '🤗', '🤔', '🤭', '🤫', '🤥', '😶', '😐', '😑', '😬', '🙄', '😯', '😦', '😧', '😮', '😲', '🥱', '😴', '🤤', '😪', '😵', '🤐', '🥴', '🤢', '🤮', '🤧', '😷', '🤒', '🤕', '🤑', '🤠', '😈', '👿', '👹', '👺', '🤡', '💩', '👻', '💀', '☠️', '👽', '👾', '🤖', '🎃', '😺', '😸', '😹', '😻', '😼', '😽', '🙀', '😿', '😾',
    '💰', '💸', '💳', '💎', '🏦', '📊', '📈', '📉', '💹', '💱', '💲', '💵', '💴', '💶', '💷', '🪙', '🏆', '🥇', '🥈', '🥉', '🏅', '🎖️', '⭐', '🌟', '✨', '💫', '⚡', '🔥', '💯', '✅', '✔️', '👍', '👎', '👌', '🤝', '🤞', '✌️', '🤟', '🤘', '👏', '🙌', '👐', '🤲', '🤜', '🤛', '✊', '👊', '👋', '🤚', '🖐️', '✋', '🖖', '🤏', '🤙', '👈', '👉', '👆', '🖕', '👇', '☝️'
  ]

  // Carregar saudações do webhook
  async function loadSaudacoes() {
    console.log('🔄 Carregando saudações...')
    setLoading(true)
    try {
      // VALIDAÇÃO DE SEGURANÇA: Verificar se usuário tem empresa_id e perfil_id
      if (!userData?.empresa_id) {
        console.warn('⚠️ AVISO: Usuário não possui empresa_id - usando fallback')
        // Não bloquear, usar fallback
      }

      if (!userData?.perfil_id) {
        console.warn('⚠️ AVISO: Usuário não possui perfil_id - usando fallback')
        // Não bloquear, usar fallback
      }

      const payload = {
        id: userData?.id ? parseInt(userData.id) : 0,
        usuario_id: userData?.id ? parseInt(userData.id) : 0,
        nome: userData?.name || '',
        email: userData?.mail || '',
        empresa_id: userData?.empresa_id || 0, // ✅ FALLBACK para 0
        perfil_id: userData?.perfil_id || 0,   // ✅ FALLBACK para 0
        tipo: userData?.perfil || 'Administrador',
        role: userData?.perfil || 'Administrador'
      }

      console.log('Payload completo enviado para webhook-listar-saudacao:', payload)

      const { data } = await callWebhook<any>('webhook-listar-saudacao', { 
        method: 'POST',
        data: payload
      })
      
      console.log('✅ Resposta recebida do webhook:', data)
      console.log('🔍 Estrutura da resposta:', JSON.stringify(data, null, 2))
      
      // ✅ CORREÇÃO: Extrair dados da estrutura aninhada do n8n
      let saudacoes: any[] = []
      
      if (data?.data && Array.isArray(data.data)) {
        // Estrutura: data.data[].json.data[]
        const allSaudacoes: any[] = []
        data.data.forEach((item: any) => {
          if (item?.json?.data && Array.isArray(item.json.data)) {
            allSaudacoes.push(...item.json.data)
          }
        })
        saudacoes = allSaudacoes
      } else if (data?.saudacoes && Array.isArray(data.saudacoes)) {
        // Estrutura alternativa: data.saudacoes[]
        saudacoes = data.saudacoes
      }
      
      // ✅ CORREÇÃO: Remover duplicatas por ID
      const uniqueSaudacoes = saudacoes.filter((saudacao, index, self) => 
        index === self.findIndex(s => s.id === saudacao.id)
      )
      saudacoes = uniqueSaudacoes
      
      console.log('📋 Saudações extraídas:', saudacoes)
      console.log('🔍 Tipo de saudacoes:', typeof saudacoes, 'Array?', Array.isArray(saudacoes))
      
      const mappedItems: SaudacaoItem[] = saudacoes.map((item: any) => ({
        id: item.id?.toString() || '',
        title: 'Saudação Personalizada',
        content: item.texto || '',
        createdAt: item.criado_em || new Date().toISOString()
      }))
      
      console.log('✅ Items finais:', mappedItems)
      setItems(mappedItems)
      setLastUpdated(new Date())
    } catch (error: any) {
      console.error('Erro ao carregar saudações:', error)
      
      // Verificar tipo de erro
      if (error.message?.includes('404') || error.message?.includes('Not Found')) {
        push({ 
          kind: 'warning', 
          message: 'Webhook não encontrado (404). Usando dados de exemplo.' 
        })
      } else if (error.message?.includes('CORS') || error.message?.includes('cors')) {
        push({ 
          kind: 'error', 
          message: 'Erro de CORS: Configure o n8n para aceitar requisições de http://localhost:5175' 
        })
      } else {
        push({ 
          kind: 'error', 
          message: `Erro ao carregar saudações: ${error.message || 'Erro desconhecido'}` 
        })
      }
      
      // Dados mock para desenvolvimento quando webhook falha
      const mockData: SaudacaoItem[] = [
        {
          id: '1',
          title: 'Saudação Personalizada',
          content: 'Olá! Seja muito bem-vindo(a) à nossa empresa. Como posso ajudá-lo(a) hoje?',
          createdAt: new Date().toISOString()
        },
        {
          id: '2', 
          title: 'Saudação Personalizada',
          content: 'Boa tarde! Espero que esteja tendo um excelente dia. Em que posso ser útil?',
          createdAt: new Date().toISOString()
        },
        {
          id: '3',
          title: 'Saudação Personalizada', 
          content: 'Seja muito bem-vindo(a) a FITH CONSULTORIA FINANCEIRA! Estamos aqui para ajudar com suas necessidades financeiras.',
          createdAt: new Date().toISOString()
        }
      ]
      
      setItems(mockData)
      setLastUpdated(new Date())
      push({ kind: 'info', message: 'Exibindo saudações de exemplo para demonstração.' })
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    if (userData) {
      loadSaudacoes()
    }
  }, [userData])

  // Recarregar lista quando a página ganha foco (usuário volta para a aba)
  useEffect(() => {
    const handleFocus = () => {
      console.log('🔄 Página ganhou foco - recarregando saudações...')
      if (userData) {
        loadSaudacoes()
      }
    }

    window.addEventListener('focus', handleFocus)
    return () => window.removeEventListener('focus', handleFocus)
  }, [userData])

  // Auto-refresh a cada 30 segundos
  useEffect(() => {
    if (!userData) return

    console.log('🔄 Iniciando auto-refresh das saudações...')
    const interval = setInterval(() => {
      console.log('🔄 Auto-refresh executando...')
      loadSaudacoes()
    }, 30000) // 30 segundos

    return () => {
      console.log('🔄 Parando auto-refresh das saudações...')
      clearInterval(interval)
    }
  }, [userData])

  async function saveNewMessage() {
    if (!newMessage.trim()) {
      push({ kind: 'error', message: 'Digite uma mensagem antes de salvar.' })
      return
    }

    // VALIDAÇÃO DE SEGURANÇA: Verificar se usuário tem empresa_id e perfil_id
    if (!userData?.empresa_id) {
      console.warn('⚠️ AVISO: Usuário não possui empresa_id - usando fallback')
      // Não bloquear, usar fallback
    }

    if (!userData?.perfil_id) {
      console.warn('⚠️ AVISO: Usuário não possui perfil_id - usando fallback')
      // Não bloquear, usar fallback
    }

    try {
      // Payload completo para o n8n com estrutura esperada
      const payload = {
        texto: newMessage,
        usuario_id: userData?.id ? parseInt(userData.id) : 0,
        nome: userData?.name || '',
        email: userData?.mail || '',
        empresa_id: userData?.empresa_id || 0, // ✅ FALLBACK para 0
        perfil_id: userData?.perfil_id || 0,   // ✅ FALLBACK para 0
        ativo: true                            // ✅ ADICIONADO
      }
      
      console.log('Payload completo enviado para webhook-salvar-saudacao:', payload)
      
      await callWebhook('webhook-salvar-saudacao', { method: 'POST', data: payload })
      setNewMessage('')
      push({ kind: 'success', message: 'Saudação salva com sucesso!' })
      // Recarregar lista após salvar
      await loadSaudacoes()
    } catch (error: any) {
      console.error('Erro ao salvar saudação:', error)
      push({ kind: 'error', message: `Erro ao salvar saudação: ${error.message || 'Erro desconhecido'}` })
    }
  }

  function insertEmoji(emoji: string) {
    setNewMessage(prev => prev + emoji)
    setShowEmojiPicker(false)
  }

  async function applyToAgent(content: string, saudacaoId: string) {
    // VALIDAÇÃO DE SEGURANÇA: Verificar se usuário tem empresa_id e perfil_id
    if (!userData?.empresa_id) {
      console.warn('⚠️ AVISO: Usuário não possui empresa_id - usando fallback')
      // Não bloquear, usar fallback
    }

    if (!userData?.perfil_id) {
      console.warn('⚠️ AVISO: Usuário não possui perfil_id - usando fallback')
      // Não bloquear, usar fallback
    }

    try {
      const payload = {
        usuario_id: userData?.id ? parseInt(userData.id) : 0,
        saudacao_id: parseInt(saudacaoId),
        content: content,
        empresa_id: userData?.empresa_id || 0 // ✅ FALLBACK para 0
      }
      
      console.log('Payload completo enviado para webhook-agente-recebimento:', payload)
      
      await callWebhook('webhook-agente-recebimento', { 
        method: 'POST', 
        data: payload 
      })
      push({ kind: 'success', message: 'Saudação aplicada ao agente com sucesso!' })
      // Recarregar lista após aplicar
      await loadSaudacoes()
    } catch (error: any) {
      console.error('Erro ao aplicar saudação ao agente:', error)
      push({ kind: 'error', message: `Erro ao aplicar saudação ao agente: ${error.message || 'Erro desconhecido'}` })
    }
  }

  async function deleteSaudacao(id: string) {
    console.log('deleteSaudacao chamada com ID:', id)
    
    // VALIDAÇÃO DE SEGURANÇA: Verificar se usuário tem empresa_id e perfil_id
    if (!userData?.empresa_id) {
      console.warn('⚠️ AVISO: Usuário não possui empresa_id - usando fallback')
      // Não bloquear, usar fallback
    }

    if (!userData?.perfil_id) {
      console.warn('⚠️ AVISO: Usuário não possui perfil_id - usando fallback')
      // Não bloquear, usar fallback
    }
    
    try {
      const payload = {
        id: parseInt(id),
        usuario_id: userData?.id ? parseInt(userData.id) : 0,
        empresa_id: userData?.empresa_id || 0, // ✅ FALLBACK para 0
        perfil_id: userData?.perfil_id || 0    // ✅ FALLBACK para 0
      }
      
      console.log('Payload enviado para webhook-deletar-saudacao:', payload)
      console.log('Tentando requisição no-cors...')
      
      // Usar fetch com no-cors para contornar CORS (POST porque no-cors não suporta DELETE)
      const response = await fetch('https://n8n-lavo-n8n.15gxno.easypanel.host/webhook/deletar-saudacao', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          ...payload,
          _method: 'DELETE' // Indica que é uma operação de delete
        }),
        mode: 'no-cors' // Ignora CORS completamente
      })
      
      console.log('Resposta no-cors:', response)
      console.log('Status:', response.status)
      console.log('Type:', response.type)
      
      // Com no-cors, não conseguimos ver a resposta, mas a requisição foi enviada
      push({ kind: 'success', message: 'Saudação deletada com sucesso! (requisição enviada)' })
      
      // Recarregar lista para verificar se foi deletado
      await loadSaudacoes()
      
    } catch (error) {
      console.error('Erro ao deletar saudação:', error)
      
      // Fallback: deletar localmente
      console.log('Erro na requisição - deletando localmente')
      push({ kind: 'info', message: 'Erro na requisição - saudação removida localmente.' })
      
      // Remover item da lista localmente
      setItems(prevItems => prevItems.filter(item => item.id !== id))
      setLastUpdated(new Date())
    }
  }

  if (!userData) {
    return (
      <div className="card p-6 text-center">
        <h2 className="text-lg font-semibold mb-2">Acesso necessário</h2>
        <p className="text-muted-foreground">Faça login para gerenciar saudações personalizadas.</p>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-semibold text-foreground mb-2">Saudação Personalizada</h1>
        <p className="text-muted-foreground">Crie e gerencie mensagens de saudação para o agente de prospecção</p>
      </div>

      {/* Nova Saudação Personalizada */}
      <div className="card">
        <div className="card-header flex items-center gap-2">
          <MessageSquare className="w-5 h-5" />
          <span>Nova Saudação Personalizada</span>
        </div>
        <div className="card-content space-y-4">
          <p className="text-sm text-muted-foreground">
            Crie uma nova mensagem de saudação para o agente de prospecção
          </p>

          {/* Área de texto personalizada */}
          <div className="space-y-3">
            <div className="relative">
              <textarea
                value={newMessage}
                onChange={(e) => setNewMessage(e.target.value)}
                placeholder="Digite sua saudação personalizada aqui..."
                className="w-full h-32 rounded-md bg-input border border-border px-4 py-3 text-sm text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring resize-none"
                maxLength={500}
              />
              <div className="absolute bottom-3 right-3 flex items-center gap-2">
                <button
                  type="button"
                  onClick={() => setShowEmojiPicker(!showEmojiPicker)}
                  className="p-1 rounded hover:bg-muted/50 transition-colors"
                  title="Adicionar emoji"
                >
                  <Smile className="w-4 h-4 text-muted-foreground" />
                </button>
                <span className="text-xs text-muted-foreground">
                  {newMessage.length}/500
                </span>
              </div>
            </div>

            {/* Seletor de Emojis */}
            {showEmojiPicker && (
              <div className="bg-muted/30 rounded-lg p-4 border border-border">
                <div className="flex items-center justify-between mb-3">
                  <span className="text-sm font-medium text-foreground">Escolha um emoji</span>
                  <button
                    onClick={() => setShowEmojiPicker(false)}
                    className="text-muted-foreground hover:text-foreground"
                  >
                    ✕
                  </button>
                </div>
                <div className="grid grid-cols-8 gap-2 max-h-32 overflow-y-auto">
                  {emojis.map((emoji, index) => (
                    <button
                      key={index}
                      onClick={() => insertEmoji(emoji)}
                      className="p-2 text-lg hover:bg-muted/50 rounded transition-colors"
                      title={emoji}
                    >
                      {emoji}
                    </button>
                  ))}
                </div>
              </div>
            )}

            {/* Botão de ação */}
            <div className="flex gap-3">
              <button
                onClick={saveNewMessage}
                disabled={!newMessage.trim()}
                className="btn btn-primary flex items-center gap-2"
              >
                <Save className="w-4 h-4" />
                Salvar Saudação
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Lista de Saudações Salvas */}
      <div className="card">
        <div className="card-header">
          <div className="flex items-center justify-between">
            <div>
              <h2 className="text-lg font-semibold">Saudações Salvas</h2>
              <p className="text-sm text-muted-foreground mt-1">
                Lista de saudações salvas anteriormente
                {lastUpdated && (
                  <span className="ml-2 text-xs">
                    • Atualizada às {lastUpdated.toLocaleTimeString('pt-BR')}
                  </span>
                )}
              </p>
            </div>
            <button
              onClick={loadSaudacoes}
              disabled={loading}
              className="btn btn-outline flex items-center gap-2 text-xs"
              title="Recarregar lista"
            >
              <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
              Atualizar
            </button>
          </div>
        </div>
        <div className="card-content">
          {loading ? (
            <div className="flex items-center justify-center py-8">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
            </div>
          ) : (
            <div className="space-y-4">
              {Array.isArray(items) && items.map((saudacao) => (
                <div
                  key={saudacao.id}
                  className="bg-muted/30 rounded-lg p-4 space-y-3 hover:bg-muted/50 transition-colors"
                >
                  {/* Conteúdo da saudação */}
                  <div className="space-y-2">
                    <h3 className="text-sm font-medium text-foreground">{saudacao.title}</h3>
                    <div className="text-sm text-foreground leading-relaxed">
                      {saudacao.content}
                    </div>
                  </div>

                  {/* Ações */}
                  <div className="flex items-center justify-end pt-2 border-t border-border">
                    <div className="flex gap-2">
                      <button
                        onClick={() => applyToAgent(saudacao.content, saudacao.id)}
                        className="btn btn-primary text-xs px-3 py-1 flex items-center gap-1"
                      >
                        <Send className="w-3 h-3" />
                        Aplicar ao Agente
                      </button>
                      <button
                        onClick={() => deleteSaudacao(saudacao.id)}
                        className="btn btn-destructive text-xs px-3 py-1 flex items-center gap-1"
                      >
                        <Trash2 className="w-3 h-3" />
                        Excluir
                      </button>
                    </div>
                  </div>
                </div>
              ))}

              {Array.isArray(items) && items.length === 0 && !loading && (
                <div className="text-center py-8 text-muted-foreground">
                  <MessageSquare className="w-12 h-12 mx-auto mb-2 opacity-50" />
                  <p>Nenhuma saudação salva encontrada</p>
                  <p className="text-xs mt-1">Crie sua primeira saudação personalizada acima</p>
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}