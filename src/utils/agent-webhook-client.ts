import { callWebhook } from './webhook-client'
import { useWebhookStore } from '../store/webhooks'

// Interface para configuração de webhook de agente
interface AgentWebhookConfig {
  agentId: string
  agentName: string
  webhookType: 'start' | 'stop' | 'status' | 'lista' | 'prospects'
  baseUrl?: string
}

// Função para construir URL dinâmica do webhook baseada no agente
function buildAgentWebhookUrl(agentId: string, webhookType: string, agentName?: string, baseUrl?: string): string {
  const defaultBaseUrl = 'https://n8n.code-iq.com.br'
  const url = baseUrl || defaultBaseUrl
  
  // Usar nome do agente em minúsculas para a URL (padrão: start3-zeca)
  const agentNameForUrl = agentName ? agentName.toLowerCase() : agentId
  
  // Mapear tipos de webhook para padrões de URL
  // Padrão baseado no webhook start3-zeca: start3-{nome}
  const webhookPatterns = {
    'start': `/webhook/start3-${agentNameForUrl}`,
    'stop': `/webhook/stop3-${agentNameForUrl}`,
    'status': `/webhook/status3-${agentNameForUrl}`,
    'lista': `/webhook/lista-prospeccao-agente1`, // Usar webhook genérico existente
    'prospects': `/webhook/lista-prospeccao-agente1`, // Usar webhook genérico existente
    'create': `/webhook/create3-${agentNameForUrl}`,
    'update': `/webhook/update3-${agentNameForUrl}`,
    'delete': `/webhook/delete3-${agentNameForUrl}`
  }
  
  const pattern = webhookPatterns[webhookType as keyof typeof webhookPatterns]
  if (!pattern) {
    throw new Error(`Tipo de webhook não suportado: ${webhookType}`)
  }
  
  return `${url}${pattern}`
}

// Função para registrar webhook dinamicamente no store
function registerAgentWebhook(agentId: string, webhookType: string, url: string, agentName: string) {
  const webhookId = `webhook/${webhookType}-${agentId}`
  const webhookName = `Webhook ${webhookType} ${agentName}`
  
  // Registrar no store de webhooks
  const { setUrl } = useWebhookStore.getState()
  setUrl(webhookId, url)
  
  console.log(`✅ Webhook registrado: ${webhookId} -> ${url}`)
  
  return { id: webhookId, name: webhookName, url }
}

// Função principal para chamar webhook de agente dinamicamente
export async function callAgentWebhook(
  webhookType: string, 
  agentId: string, 
  options: any = {},
  agentName?: string
) {
  console.log(`🔧 callAgentWebhook: ${webhookType} para agente ${agentId}`)
  
  // Para webhooks de lista/prospects, usar diretamente o webhook genérico existente
  if (webhookType === 'lista' || webhookType === 'prospects') {
    console.log(`🔄 Usando webhook genérico para ${webhookType}`)
    return await callWebhook('webhook/lista-prospeccao-agente1', options)
  }
  
  try {
    // 1. Tentar webhook específico do agente primeiro
    const specificWebhookId = `webhook/${webhookType}-${agentId}`
    console.log(`🔍 Tentando webhook específico: ${specificWebhookId}`)
    
    // Verificar se já está registrado no store
    const { urls } = useWebhookStore.getState()
    console.log(`🔍 URLs disponíveis no store:`, Object.keys(urls).filter(k => k.includes(agentId)))
    
    if (urls[specificWebhookId]) {
      console.log(`✅ Webhook específico encontrado no store: ${urls[specificWebhookId]}`)
      return await callWebhook(specificWebhookId, options)
    } else {
      console.log(`❌ Webhook específico NÃO encontrado no store: ${specificWebhookId}`)
    }
    
    // 2. Se não estiver registrado, construir URL dinamicamente
    console.log(`🔧 Construindo URL dinâmica para ${agentId}`)
    const dynamicUrl = buildAgentWebhookUrl(agentId, webhookType, agentName)
    
    // 3. Registrar webhook no store
    const webhookConfig = registerAgentWebhook(
      agentId, 
      webhookType, 
      dynamicUrl, 
      agentName || agentId
    )
    
    // 4. Verificar se foi registrado corretamente
    const { urls: urlsAfter } = useWebhookStore.getState()
    if (urlsAfter[specificWebhookId]) {
      console.log(`✅ Webhook registrado com sucesso: ${specificWebhookId} -> ${urlsAfter[specificWebhookId]}`)
    } else {
      console.log(`❌ Falha ao registrar webhook: ${specificWebhookId}`)
    }
    
    // 5. Chamar webhook
    console.log(`🚀 Chamando webhook dinâmico: ${dynamicUrl}`)
    return await callWebhook(specificWebhookId, options)
    
  } catch (error) {
    console.log(`❌ Erro no webhook específico, tentando fallbacks...`)
    console.log(`❌ Erro:`, error)
    
    // 3. Fallback para webhooks genéricos existentes
    const fallbackWebhooks = {
      'start': 'webhook/agente1',
      'stop': 'webhook/parar-agente',
      'status': 'webhook/status-agente1',
      'lista': 'webhook/lista-prospeccao-agente1',
      'prospects': 'webhook/lista-prospeccao-agente1'
    }
    
    const fallbackWebhook = fallbackWebhooks[webhookType as keyof typeof fallbackWebhooks]
    if (fallbackWebhook) {
      console.log(`🔄 Usando fallback: ${fallbackWebhook}`)
      return await callWebhook(fallbackWebhook, options)
    }
    
    console.log(`❌ Nenhum fallback encontrado para ${webhookType}`)
    throw error
  }
}

// Função para registrar todos os webhooks de um agente de uma vez
export function registerAllAgentWebhooks(agentId: string, agentName: string, baseUrl?: string) {
  const webhookTypes = ['start', 'stop', 'status', 'lista', 'prospects']
  const registeredWebhooks = []
  
  console.log(`🔧 [REGISTER] Registrando webhooks para ${agentName} (${agentId})`)
  
  webhookTypes.forEach(webhookType => {
    try {
      const url = buildAgentWebhookUrl(agentId, webhookType, agentName, baseUrl)
      const webhookId = `webhook/${webhookType}-${agentId}`
      const webhookConfig = registerAgentWebhook(agentId, webhookType, url, agentName)
      console.log(`✅ [REGISTER] Webhook registrado: ${webhookId} -> ${url}`)
      registeredWebhooks.push(webhookConfig)
    } catch (error) {
      console.warn(`⚠️ Não foi possível registrar webhook ${webhookType} para ${agentId}:`, error)
    }
  })
  
  console.log(`✅ ${registeredWebhooks.length} webhooks registrados para ${agentName}`)
  return registeredWebhooks
}

// Função para listar webhooks disponíveis para um agente
export function getAgentWebhookList(agentId: string, agentName: string) {
  const webhookTypes = ['start', 'stop', 'status', 'lista', 'prospects']
  
  return webhookTypes.map(webhookType => {
    const webhookId = `webhook/${webhookType}-${agentId}`
    const url = buildAgentWebhookUrl(agentId, webhookType)
    
    return {
      id: webhookId,
      name: `${webhookType.charAt(0).toUpperCase() + webhookType.slice(1)} ${agentName}`,
      url,
      type: webhookType
    }
  })
}

// Função para verificar se um webhook de agente existe
export function checkAgentWebhookExists(agentId: string, webhookType: string): boolean {
  const { urls } = useWebhookStore.getState()
  const webhookId = `webhook/${webhookType}-${agentId}`
  return !!urls[webhookId]
}

// Função para obter URL de webhook de agente sem chamá-lo
export function getAgentWebhookUrl(agentId: string, webhookType: string, baseUrl?: string): string {
  return buildAgentWebhookUrl(agentId, webhookType, baseUrl)
}
