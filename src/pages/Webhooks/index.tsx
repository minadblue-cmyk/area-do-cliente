import { useState, useMemo, useEffect } from 'react'
import { WEBHOOKS } from '../../constants/webhooks.constants'
import { useWebhookStore } from '../../store/webhooks'
import { useToastStore } from '../../store/toast'
import { Search, Filter, Save, RefreshCw, ExternalLink, Copy, Check } from 'lucide-react'
import { callWebhook } from '../../utils/webhook-client'

function isValidUrl(url: string): boolean {
  try { new URL(url); return true } catch { return false }
}

// Categorias dos webhooks
const WEBHOOK_CATEGORIES = {
  'Agentes': ['webhook/agente1', 'webhook/parar-agente', 'webhook/status-agente', 'webhook/agente-fria', 'webhook/agente-followup', 'webhook/agente-suporte', 'webhook-test/agente-teste', 'webhook/agente-teste', 'webhook-agente2', 'agente2'],
  'Usuários': ['webhook/list-users', 'webhook/list-company'],
  'Perfis': ['webhook/list-profile', 'webhook/list-permission', 'webhook/create-profile', 'webhook/edit-profile', 'webhook/assign-user-profiles', 'webhook/delete-profile'],
  'Upload': ['webhook-upload', 'webhook-controle-agente'],
  'Saudações': ['webhook-deletar-saudacao', 'webhook-agente-recebimento']
}

// Função para obter categorias dinâmicas incluindo webhooks de agentes
function getDynamicCategories(dynamicWebhooks: Record<string, string>) {
  const agentWebhookIds = Object.keys(dynamicWebhooks)
  
  // Adicionar webhooks que contêm "agente" no nome automaticamente
  const allWebhooks = [...WEBHOOKS, ...Object.entries(dynamicWebhooks).map(([id, url]) => ({
    id,
    name: `Webhook ${id.split('/').pop()}`,
    url
  }))]
  
  const autoAgentWebhooks = allWebhooks
    .filter(webhook => 
      webhook.id.toLowerCase().includes('agente') || 
      webhook.name.toLowerCase().includes('agente')
    )
    .map(webhook => webhook.id)
  
  return {
    ...WEBHOOK_CATEGORIES,
    'Agentes': [...WEBHOOK_CATEGORIES['Agentes'], ...agentWebhookIds, ...autoAgentWebhooks]
  }
}

export default function Webhooks() {
  const { urls, setAll, addWebhook } = useWebhookStore()
  const push = useToastStore((s) => s.push)
  const [values, setValues] = useState<Record<string, string>>({ ...urls })
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedCategory, setSelectedCategory] = useState<string>('Todos')
  const [copiedId, setCopiedId] = useState<string | null>(null)
  const [dynamicWebhooks, setDynamicWebhooks] = useState<Record<string, string>>({})

  // Carregar webhooks dinâmicos dos agentes
  useEffect(() => {
    async function loadAgentWebhooks() {
      try {
        const response = await callWebhook('webhook/list-agentes', { method: 'GET' })
        
        if (response.data && Array.isArray(response.data) && response.data.length > 0) {
          const firstItem = response.data[0]
          const dataField = firstItem.data || firstItem['data\t'] || firstItem['data ']
          
          if (dataField && Array.isArray(dataField)) {
            const agentWebhooks: Record<string, string> = {}
            
            dataField.forEach((item: any) => {
              const agent = item.json
              if (agent.webhook_url) {
                const webhookId = agent.webhook_url
                const webhookUrl = `https://n8n.code-iq.com.br/${agent.webhook_url}`
                agentWebhooks[webhookId] = webhookUrl
                
                // Adicionar ao store se não existir
                if (!urls[webhookId]) {
                  addWebhook(webhookId, webhookUrl)
                }
              }
            })
            
            setDynamicWebhooks(agentWebhooks)
          }
        }
      } catch (error) {
        console.error('Erro ao carregar webhooks dos agentes:', error)
      }
    }
    
    loadAgentWebhooks()
  }, [urls, addWebhook])

  // Filtrar webhooks baseado na busca e categoria
  const filteredWebhooks = useMemo(() => {
    let filtered = WEBHOOKS

    // Adicionar webhooks dinâmicos dos agentes
    const dynamicWebhookList = Object.entries(dynamicWebhooks).map(([id, url]) => ({
      id,
      name: `Webhook ${id.split('/').pop()}`,
      url
    }))
    
    filtered = [...filtered, ...dynamicWebhookList]

    // Filtrar por categoria
    if (selectedCategory !== 'Todos') {
      const dynamicCategories = getDynamicCategories(dynamicWebhooks)
      const categoryIds = dynamicCategories[selectedCategory as keyof typeof dynamicCategories]
      filtered = filtered.filter(webhook => categoryIds.includes(webhook.id))
    }

    // Filtrar por termo de busca
    if (searchTerm && searchTerm.trim() !== '') {
      const searchLower = searchTerm.toLowerCase().trim()
      filtered = filtered.filter(webhook => 
        webhook.name.toLowerCase().includes(searchLower) ||
        webhook.id.toLowerCase().includes(searchLower)
      )
    }

    return filtered
  }, [searchTerm, selectedCategory, dynamicWebhooks])

  function onChange(id: string, url: string) {
    setValues(v => ({ ...v, [id]: url }))
  }

  function onSave() {
    const allValid = Object.values(values).every(isValidUrl)
    if (!allValid) {
      push({ kind: 'error', message: 'Há URLs inválidas. Verifique e tente novamente.' })
      return
    }
    try {
      setAll(values)
      push({ kind: 'success', message: 'Webhooks salvos com sucesso!' })
    } catch {
      push({ kind: 'error', message: 'Falha ao salvar webhooks.' })
    }
  }

  function copyToClipboard(text: string, id: string) {
    navigator.clipboard.writeText(text)
    setCopiedId(id)
    setTimeout(() => setCopiedId(null), 2000)
    push({ kind: 'info', message: 'URL copiada para a área de transferência!' })
  }

  function getCategoryForWebhook(webhookId: string): string {
    for (const [category, ids] of Object.entries(WEBHOOK_CATEGORIES)) {
      if (ids.includes(webhookId)) {
        return category
      }
    }
    return 'Outros'
  }

  return (
    <div className="space-y-6">
      {/* Header com estatísticas */}
      <div className="card">
        <div className="card-header flex items-center justify-between">
          <div>
            <h1 className="text-xl font-semibold">Configurar Webhooks</h1>
            <p className="text-sm text-muted-foreground mt-1">
              Gerencie as URLs dos webhooks do sistema
            </p>
          </div>
          <div className="flex items-center gap-2">
            <span className="text-sm text-muted-foreground">
              {filteredWebhooks.length} de {WEBHOOKS.length} webhooks
            </span>
            {searchTerm && (
              <span className="text-xs bg-primary/10 text-primary px-2 py-1 rounded">
                Buscando: "{searchTerm}"
              </span>
            )}
          </div>
        </div>
      </div>

      {/* Filtros e Busca */}
      <div className="card">
        <div className="card-content">
          <div className="flex flex-col md:flex-row gap-4">
            {/* Campo de Busca */}
            <div className="flex-1">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground w-4 h-4" />
                <input
                  type="text"
                  placeholder="Buscar webhook por nome ou ID..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="input pl-10 w-full"
                  autoComplete="off"
                />
                {searchTerm && (
                  <button
                    onClick={() => setSearchTerm('')}
                    className="absolute right-3 top-1/2 transform -translate-y-1/2 text-muted-foreground hover:text-foreground transition-colors"
                    title="Limpar busca"
                  >
                    ×
                  </button>
                )}
              </div>
            </div>

            {/* Filtro por Categoria */}
            <div className="md:w-48">
              <div className="relative">
                <Filter className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground w-4 h-4" />
                <select
                  value={selectedCategory}
                  onChange={(e) => setSelectedCategory(e.target.value)}
                  className="input pl-10 w-full"
                >
                  <option value="Todos">Todas as Categorias</option>
                  {Object.keys(WEBHOOK_CATEGORIES).map(category => (
                    <option key={category} value={category}>{category}</option>
                  ))}
                </select>
              </div>
            </div>

            {/* Botão Salvar */}
            <button 
              onClick={onSave}
              className="btn btn-primary flex items-center gap-2 px-6"
            >
              <Save className="w-4 h-4" />
              Salvar Alterações
            </button>

          </div>
        </div>
      </div>

      {/* Lista de Webhooks */}
      <div className="space-y-4">
        {filteredWebhooks.length === 0 ? (
          <div className="card">
            <div className="card-content text-center py-12">
              <div className="text-muted-foreground">
                <Search className="w-12 h-12 mx-auto mb-4 opacity-50" />
                <p className="text-lg font-medium mb-2">Nenhum webhook encontrado</p>
                <p className="text-sm">
                  Tente ajustar os filtros ou termo de busca
                </p>
              </div>
            </div>
          </div>
        ) : (
          filteredWebhooks.map(webhook => {
            const category = getCategoryForWebhook(webhook.id)
            const hasUrl = values[webhook.id] && values[webhook.id].trim() !== ''
            const isValid = hasUrl ? isValidUrl(values[webhook.id]) : true

            return (
              <div key={webhook.id} className="card">
                <div className="card-content">
                  <div className="flex items-start gap-4">
                    {/* Informações do Webhook */}
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-2">
                        <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-primary/10 text-primary">
                          {category}
                        </span>
                        {hasUrl && (
                          <span className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium ${
                            isValid ? 'bg-success/10 text-success' : 'bg-destructive/10 text-destructive'
                          }`}>
                            {isValid ? 'URL Válida' : 'URL Inválida'}
                          </span>
                        )}
                      </div>
                      
                      <h3 className="font-medium text-foreground mb-1">
                        {webhook.name}
                      </h3>
                      
                      <p className="text-sm text-muted-foreground font-mono mb-3">
                        {webhook.id}
                      </p>

                      {/* Campo de URL */}
                      <div className="relative">
                        <input
                          type="url"
                          placeholder="https://exemplo.com/webhook/endpoint"
                          value={values[webhook.id] ?? ''}
                          onChange={(e) => onChange(webhook.id, e.target.value)}
                          className={`input w-full pr-20 ${
                            hasUrl && !isValid ? 'border-destructive focus:border-destructive' : ''
                          }`}
                        />
                        
                        {/* Botões de Ação */}
                        <div className="absolute right-2 top-1/2 transform -translate-y-1/2 flex items-center gap-1">
                          {hasUrl && (
                            <>
                              <button
                                onClick={() => copyToClipboard(values[webhook.id], webhook.id)}
                                className="p-1 hover:bg-accent rounded transition-colors"
                                title="Copiar URL"
                              >
                                {copiedId === webhook.id ? (
                                  <Check className="w-4 h-4 text-success" />
                                ) : (
                                  <Copy className="w-4 h-4 text-muted-foreground" />
                                )}
                              </button>
                              
                              <button
                                onClick={() => window.open(values[webhook.id], '_blank')}
                                className="p-1 hover:bg-accent rounded transition-colors"
                                title="Abrir URL"
                              >
                                <ExternalLink className="w-4 h-4 text-muted-foreground" />
                              </button>
                            </>
                          )}
                        </div>
                      </div>

                      {/* Mensagem de erro */}
                      {hasUrl && !isValid && (
                        <p className="text-xs text-destructive mt-2">
                          URL inválida. Verifique o formato.
                        </p>
                      )}
                    </div>
                  </div>
                </div>
              </div>
            )
          })
        )}
      </div>

      {/* Resumo e Ações */}
      {filteredWebhooks.length > 0 && (
        <div className="card">
          <div className="card-content">
            <div className="flex items-center justify-between">
              <div className="text-sm text-muted-foreground">
                Mostrando {filteredWebhooks.length} webhook{filteredWebhooks.length !== 1 ? 's' : ''}
                {searchTerm && ` para "${searchTerm}"`}
                {selectedCategory !== 'Todos' && ` na categoria "${selectedCategory}"`}
              </div>
              
              <div className="flex items-center gap-2">
                <button 
                  onClick={() => {
                    setSearchTerm('')
                    setSelectedCategory('Todos')
                  }}
                  className="btn btn-outline flex items-center gap-2"
                >
                  <RefreshCw className="w-4 h-4" />
                  Limpar Filtros
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
