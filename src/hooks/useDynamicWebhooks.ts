import { useState, useEffect, useCallback } from 'react'
import { useWebhookStore } from '../store/webhooks'
import { 
  callAgentWebhook, 
  registerAllAgentWebhooks, 
  getAgentWebhookList, 
  checkAgentWebhookExists,
  getAgentWebhookUrl 
} from '../utils/agent-webhook-client'

interface UseDynamicWebhooksOptions {
  agentId: string
  agentName: string
  autoRegister?: boolean
}

interface WebhookStatus {
  id: string
  type: string
  name: string
  url: string
  exists: boolean
  registered: boolean
  lastTest?: {
    success: boolean
    timestamp: number
    error?: any
  }
}

export function useDynamicWebhooks({ 
  agentId, 
  agentName, 
  autoRegister = true 
}: UseDynamicWebhooksOptions) {
  const [webhooks, setWebhooks] = useState<WebhookStatus[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const { urls, setUrl } = useWebhookStore()

  // Carregar webhooks disponíveis para o agente
  const loadWebhooks = useCallback(() => {
    try {
      const agentWebhooks = getAgentWebhookList(agentId, agentName)
      
      const webhookStatuses: WebhookStatus[] = agentWebhooks.map(webhook => ({
        id: webhook.id,
        type: webhook.type,
        name: webhook.name,
        url: webhook.url,
        exists: checkAgentWebhookExists(agentId, webhook.type),
        registered: !!urls[webhook.id]
      }))
      
      setWebhooks(webhookStatuses)
      setError(null)
    } catch (err) {
      setError(`Erro ao carregar webhooks: ${err}`)
    }
  }, [agentId, agentName, urls])

  // Registrar todos os webhooks do agente
  const registerAllWebhooks = useCallback(async () => {
    if (!agentId || !agentName) return

    setLoading(true)
    setError(null)

    try {
      console.log(`🔧 Registrando webhooks para agente: ${agentName} (${agentId})`)
      const registeredWebhooks = registerAllAgentWebhooks(agentId, agentName)
      
      // Atualizar estado local
      loadWebhooks()
      
      console.log(`✅ ${registeredWebhooks.length} webhooks registrados para ${agentName}`)
      return registeredWebhooks
    } catch (err) {
      const errorMsg = `Erro ao registrar webhooks: ${err}`
      setError(errorMsg)
      console.error(errorMsg)
      throw err
    } finally {
      setLoading(false)
    }
  }, [agentId, agentName, loadWebhooks])

  // Testar um webhook específico
  const testWebhook = useCallback(async (webhookType: string) => {
    if (!agentId) return { success: false, error: 'Agent ID não fornecido' }

    setLoading(true)
    setError(null)

    try {
      console.log(`🧪 Testando webhook ${webhookType} para agente ${agentId}`)
      
      const response = await callAgentWebhook(webhookType, agentId, {
        method: 'GET',
        params: { test: true }
      }, agentName)
      
      // Atualizar status do webhook
      setWebhooks(prev => prev.map(webhook => 
        webhook.type === webhookType 
          ? {
              ...webhook,
              lastTest: {
                success: true,
                timestamp: Date.now()
              }
            }
          : webhook
      ))
      
      console.log(`✅ Webhook ${webhookType} funcionando:`, response)
      return { success: true, response }
    } catch (err) {
      const errorMsg = `Erro ao testar webhook ${webhookType}: ${err}`
      setError(errorMsg)
      console.error(errorMsg)
      
      // Atualizar status do webhook com erro
      setWebhooks(prev => prev.map(webhook => 
        webhook.type === webhookType 
          ? {
              ...webhook,
              lastTest: {
                success: false,
                timestamp: Date.now(),
                error: err
              }
            }
          : webhook
      ))
      
      return { success: false, error: err }
    } finally {
      setLoading(false)
    }
  }, [agentId, agentName])

  // Chamar webhook com dados específicos
  const callWebhook = useCallback(async (
    webhookType: string, 
    options: any = {}
  ) => {
    if (!agentId) throw new Error('Agent ID não fornecido')

    try {
      return await callAgentWebhook(webhookType, agentId, options, agentName)
    } catch (err) {
      console.error(`Erro ao chamar webhook ${webhookType}:`, err)
      throw err
    }
  }, [agentId, agentName])

  // Obter URL de um webhook
  const getWebhookUrl = useCallback((webhookType: string) => {
    return getAgentWebhookUrl(agentId, webhookType)
  }, [agentId])

  // Verificar se um webhook está registrado
  const isWebhookRegistered = useCallback((webhookType: string) => {
    const webhookId = `webhook/${webhookType}-${agentId}`
    return !!urls[webhookId]
  }, [agentId, urls])

  // Auto-registrar webhooks se habilitado
  useEffect(() => {
    if (autoRegister && agentId && agentName) {
      loadWebhooks()
    }
  }, [autoRegister, agentId, agentName, loadWebhooks])

  return {
    webhooks,
    loading,
    error,
    loadWebhooks,
    registerAllWebhooks,
    testWebhook,
    callWebhook,
    getWebhookUrl,
    isWebhookRegistered
  }
}
