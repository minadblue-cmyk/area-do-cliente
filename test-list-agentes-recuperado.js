import https from 'https'

console.log('🧪 Testando webhook list-agentes recuperado:')

const options = {
  hostname: 'n8n.code-iq.com.br',
  port: 443,
  path: '/webhook/list-agentes',
  method: 'GET',
  headers: {
    'Content-Type': 'application/json'
  }
}

console.log('📡 URL:', `https://${options.hostname}${options.path}`)

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
      
      if (jsonResponse.success) {
        console.log('✅ Sucesso! Agentes encontrados:', jsonResponse.total)
        if (jsonResponse.data && Array.isArray(jsonResponse.data)) {
          console.log('📊 Lista de agentes:')
          jsonResponse.data.forEach((agente, index) => {
            console.log(`  ${index + 1}. ${agente.nome} (ID: ${agente.id}) - ${agente.ativo ? 'Ativo' : 'Inativo'}`)
          })
        }
      } else {
        console.log('⚠️ Resposta não indica sucesso')
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
