import https from 'https'

const payload = {
  id: 26,
  agent_name: "Agente Teste Frontend",
  logged_user: {
    id: 5,
    name: "Administrator Code-IQ",
    email: "admin@code-iq.com.br"
  }
}

console.log('🧪 Testando payload do FRONTEND:')
console.log('📦 Payload:', JSON.stringify(payload, null, 2))

const postData = JSON.stringify(payload)

const options = {
  hostname: 'n8n.code-iq.com.br',
  port: 443,
  path: '/webhook/delete-agente-complete',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(postData)
  }
}

console.log('📡 Enviando para:', `https://${options.hostname}${options.path}`)

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
    } catch (e) {
      console.log('⚠️ Resposta não é JSON válido')
    }
  })
})

req.on('error', (e) => {
  console.error('❌ Erro na requisição:', e.message)
})

req.write(postData)
req.end()
