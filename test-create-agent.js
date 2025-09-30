// Teste para criar novo agente via webhook
const https = require('https')

const testCreateAgent = async () => {
  const agentData = {
    action: 'create',
    agent_name: 'Agente Teste',
    agent_type: 'agenteTeste',
    agent_id: 'TEST123456789',
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

  console.log('🚀 Testando criação de agente...')
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
          console.log('✅ Agente criado com sucesso!')
          console.log('🔧 Workflows criados:', Object.keys(response.workflows || {}))
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
testCreateAgent().catch(console.error)
