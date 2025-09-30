import https from 'https'

console.log('🧪 Testando webhook list-agentes final:')

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
            console.log(`     Workflow ID: ${agente.workflow_id}`)
            console.log(`     Webhook URL: ${agente.webhook_url}`)
            console.log(`     Ícone: ${agente.icone} | Cor: ${agente.cor}`)
            console.log(`     Criado em: ${agente.created_at}`)
            console.log('')
          })
        }
      } else {
        console.log('⚠️ Resposta não indica sucesso')
        console.log('📋 Estrutura da resposta:', Object.keys(jsonResponse))
      }
    } catch (e) {
      console.log('⚠️ Resposta não é JSON válido:', e.message)
      console.log('📄 Primeiros 200 caracteres:', data.substring(0, 200))
    }
  })
})

req.on('error', (e) => {
  console.error('❌ Erro na requisição:', e.message)
})

req.end()
