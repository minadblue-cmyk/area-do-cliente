import { useState, useEffect } from 'react'
import { useWebhookStore } from '../store/webhooks'
import { callAgentWebhook, getAgentWebhookList, checkAgentWebhookExists } from '../utils/agent-webhook-client'

interface DynamicWebhookManagerProps {
  agentId: string
  agentName: string
  onWebhookRegistered?: (webhookId: string, url: string) => void
}

export function DynamicWebhookManager({ 
  agentId, 
  agentName, 
  onWebhookRegistered 
}: DynamicWebhookManagerProps) {
  const [webhooks, setWebhooks] = useState<any[]>([])
  const [loading, setLoading] = useState(false)
  const { urls } = useWebhookStore()

  // Carregar lista de webhooks disponíveis para o agente
  useEffect(() => {
    const agentWebhooks = getAgentWebhookList(agentId, agentName)
    setWebhooks(agentWebhooks)
  }, [agentId, agentName])

  // Função para testar um webhook
  const testWebhook = async (webhookType: string) => {
    setLoading(true)
    try {
      console.log(`🧪 Testando webhook ${webhookType} para agente ${agentId}`)
      
      const response = await callAgentWebhook(webhookType, agentId, {
        method: 'GET',
        params: { test: true }
      }, agentName)
      
      console.log(`✅ Webhook ${webhookType} funcionando:`, response)
      
      // Notificar que o webhook foi registrado
      if (onWebhookRegistered) {
        const webhookId = `webhook/${webhookType}-${agentId}`
        const webhookUrl = urls[webhookId] || `https://n8n.code-iq.com.br/webhook/${webhookType}-${agentId}`
        onWebhookRegistered(webhookId, webhookUrl)
      }
      
      return { success: true, response }
    } catch (error) {
      console.error(`❌ Erro ao testar webhook ${webhookType}:`, error)
      return { success: false, error }
    } finally {
      setLoading(false)
    }
  }

  // Função para registrar todos os webhooks do agente
  const registerAllWebhooks = async () => {
    setLoading(true)
    const results = []
    
    for (const webhook of webhooks) {
      try {
        const result = await testWebhook(webhook.type)
        results.push({ ...webhook, ...result })
      } catch (error) {
        results.push({ ...webhook, success: false, error })
      }
    }
    
    setLoading(false)
    return results
  }

  return (
    <div className="p-4 bg-gray-50 rounded-lg">
      <h3 className="text-lg font-semibold mb-4">
        Webhooks Dinâmicos - {agentName}
      </h3>
      
      <div className="space-y-2">
        {webhooks.map((webhook) => {
          const exists = checkAgentWebhookExists(agentId, webhook.type)
          const isRegistered = !!urls[webhook.id]
          
          return (
            <div 
              key={webhook.id}
              className={`p-3 rounded border ${
                isRegistered 
                  ? 'bg-green-50 border-green-200' 
                  : 'bg-yellow-50 border-yellow-200'
              }`}
            >
              <div className="flex items-center justify-between">
                <div>
                  <h4 className="font-medium">{webhook.name}</h4>
                  <p className="text-sm text-gray-600">{webhook.url}</p>
                  <p className="text-xs text-gray-500">
                    Status: {isRegistered ? 'Registrado' : 'Não registrado'}
                  </p>
                </div>
                
                <button
                  onClick={() => testWebhook(webhook.type)}
                  disabled={loading}
                  className={`px-3 py-1 rounded text-sm ${
                    isRegistered
                      ? 'bg-green-100 text-green-700 hover:bg-green-200'
                      : 'bg-blue-100 text-blue-700 hover:bg-blue-200'
                  }`}
                >
                  {loading ? 'Testando...' : 'Testar'}
                </button>
              </div>
            </div>
          )
        })}
      </div>
      
      <div className="mt-4 flex gap-2">
        <button
          onClick={registerAllWebhooks}
          disabled={loading}
          className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 disabled:opacity-50"
        >
          {loading ? 'Registrando...' : 'Registrar Todos'}
        </button>
        
        <button
          onClick={() => window.location.reload()}
          className="px-4 py-2 bg-gray-500 text-white rounded hover:bg-gray-600"
        >
          Atualizar
        </button>
      </div>
    </div>
  )
}
