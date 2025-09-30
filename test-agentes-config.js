// Teste para verificar a integração da página de configuração de agentes
import https from 'https'

const testAgentesConfig = async () => {
  console.log('🧪 Testando integração da página de configuração de agentes...')
  
  // Simular dados que seriam enviados pela interface
  const agentData = {
    action: 'create',
    agent_name: 'Agente Teste Config',
    agent_type: 'agenteTesteConfig',
    agent_id: 'CONFIG123456789',
    user_id: 'user123'
  }

  const postData = JSON.stringify(agentData)

  const options = {
    hostname: 'n8n.code-iq.com.br',
    port: 443,
    path: '/webhook/create-agente',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(postData)
    }
  }

  console.log('📋 Dados enviados:', agentData)

  const req = https.request(options, (res) => {
    console.log(`📊 Status: ${res.statusCode}`)
    console.log(`📋 Headers:`, res.headers)

    let data = ''
    res.on('data', (chunk) => {
      data += chunk
    })

    res.on('end', () => {
      console.log('📥 Resposta recebida:')
      try {
        const response = JSON.parse(data)
        console.log(JSON.stringify(response, null, 2))
        
        if (response.success) {
          console.log('✅ Agente criado com sucesso via página de configuração!')
          console.log('🔧 Workflows criados:', Object.keys(response.workflows || {}))
          console.log('📁 Organização:', response.organization)
          
          // Verificar se os webhooks foram criados corretamente
          const workflows = response.workflows || {}
          const expectedWebhooks = ['start', 'stop', 'status', 'lista']
          
          expectedWebhooks.forEach(webhookType => {
            if (workflows[webhookType]) {
              console.log(`✅ Webhook ${webhookType}: ${workflows[webhookType].webhook}`)
            } else {
              console.log(`❌ Webhook ${webhookType} não encontrado`)
            }
          })
        } else {
          console.log('❌ Falha na criação do agente')
        }
      } catch (error) {
        console.log('📄 Resposta (texto):', data)
      }
    })
  })

  req.on('error', (error) => {
    console.error('❌ Erro na requisição:', error)
  })

  req.write(postData)
  req.end()
}

// Executar teste
testAgentesConfig().catch(console.error)
