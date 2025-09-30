import https from 'https'

const params = {
  usuario_id: '5',
  workflow_id: 'eBcColwirndBaFZX'
}

// Construir URL com parâmetros
const queryString = new URLSearchParams(params).toString()
const url = `https://n8n.code-iq.com.br/webhook/status-agente1?${queryString}`

console.log('🧪 Testando webhook status-agente1:')
console.log('📡 URL:', url)
console.log('📦 Parâmetros:', params)

const options = {
  hostname: 'n8n.code-iq.com.br',
  port: 443,
  path: `/webhook/status-agente1?${queryString}`,
  method: 'GET',
  headers: {
    'Content-Type': 'application/json'
  }
}

console.log('🚀 Enviando requisição...')

const req = https.request(options, (res) => {
  console.log('📡 Status:', res.statusCode)
  console.log('📋 Headers:', res.headers)
  
  let data = ''
  res.on('data', (chunk) => {
    data += chunk
  })
  
  res.on('end', () => {
    console.log('✅ Resposta completa:')
    console.log('📄 Resposta (texto):', data)
    
    try {
      const jsonResponse = JSON.parse(data)
      console.log('📄 Resposta (JSON):', JSON.stringify(jsonResponse, null, 2))
      
      // Verificar se tem os campos esperados
      if (jsonResponse.status) {
        console.log('✅ Status encontrado:', jsonResponse.status)
        console.log('📊 Dados do agente:')
        console.log('  - Workflow ID:', jsonResponse.workflowId)
        console.log('  - Execution ID:', jsonResponse.executionId)
        console.log('  - Iniciado em:', jsonResponse.iniciadoEm)
        console.log('  - Parado em:', jsonResponse.paradoEm)
        console.log('  - Usuário:', jsonResponse.usuarioNome)
        console.log('  - Email:', jsonResponse.usuarioEmail)
      } else {
        console.log('⚠️ Status não encontrado na resposta')
      }
    } catch (e) {
      console.log('⚠️ Resposta não é JSON válido:', e.message)
    }
  })
})

req.on('error', (e) => {
  console.error('❌ Erro na requisição:', e.message)
})

req.end()
