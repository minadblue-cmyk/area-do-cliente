// Debug para verificar se os webhooks estão sendo registrados
// Executar no console do navegador

console.log('🔍 DEBUG: Verificando webhooks registrados')

// Verificar store de webhooks
const webhookStore = window.__ZUSTAND_WEBHOOK_STORE__ || 
  (() => {
    // Tentar acessar o store via React DevTools
    const reactRoot = document.querySelector('#root')._reactInternalFiber || 
                     document.querySelector('#root')._reactInternalInstance
    console.log('React Root encontrado:', !!reactRoot)
    return null
  })()

console.log('Webhook Store:', webhookStore)

// Verificar se há webhooks específicos do agente 59
const agentWebhooks = [
  'webhook/start-59',
  'webhook/stop-59', 
  'webhook/status-59',
  'webhook/lista-59'
]

console.log('🔍 Procurando webhooks do agente 59:')
agentWebhooks.forEach(webhookId => {
  // Tentar encontrar no localStorage ou sessionStorage
  const stored = localStorage.getItem(`webhook-${webhookId}`) || 
                sessionStorage.getItem(`webhook-${webhookId}`)
  console.log(`${webhookId}:`, stored ? 'ENCONTRADO' : 'NÃO ENCONTRADO')
})

// Verificar se o useAgentSyncWebhooks está ativo
console.log('🔍 Verificando se useAgentSyncWebhooks está ativo...')

// Função para testar webhook manualmente
window.testWebhook = async (webhookType = 'start', agentId = '59') => {
  console.log(`🧪 TESTE: Chamando webhook ${webhookType} para agente ${agentId}`)
  
  const payload = {
    action: webhookType,
    agent_type: agentId,
    test: true,
    timestamp: new Date().toISOString()
  }
  
  try {
    const response = await fetch(`https://n8n.code-iq.com.br/webhook/${webhookType}3-zeca`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(payload)
    })
    
    const result = await response.json()
    console.log(`✅ Resposta do webhook:`, result)
    return result
  } catch (error) {
    console.error(`❌ Erro no webhook:`, error)
    return error
  }
}

console.log('🧪 Função de teste criada: testWebhook()')
console.log('📝 Exemplo: testWebhook("start", "59")')
