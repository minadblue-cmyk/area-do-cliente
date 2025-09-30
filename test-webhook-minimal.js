// Teste mínimo do webhook
import fetch from 'node-fetch'

const testMinimal = async () => {
  console.log('🧪 Teste mínimo do webhook...')
  
  // Teste 1: Payload mínimo
  console.log('\n📋 Teste 1: Payload mínimo')
  try {
    const response = await fetch('https://n8n.code-iq.com.br/webhook/create-agente', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ test: true })
    })
    
    console.log('Status:', response.status)
    const text = await response.text()
    console.log('Resposta:', text || '(vazia)')
  } catch (error) {
    console.log('Erro:', error.message)
  }

  // Teste 2: GET request
  console.log('\n📋 Teste 2: GET request')
  try {
    const response = await fetch('https://n8n.code-iq.com.br/webhook/create-agente', {
      method: 'GET'
    })
    
    console.log('Status:', response.status)
    const text = await response.text()
    console.log('Resposta:', text || '(vazia)')
  } catch (error) {
    console.log('Erro:', error.message)
  }

  // Teste 3: Verificar se o webhook existe
  console.log('\n📋 Teste 3: Verificar webhook')
  try {
    const response = await fetch('https://n8n.code-iq.com.br/webhook/create-agente', {
      method: 'OPTIONS'
    })
    
    console.log('Status:', response.status)
    console.log('Headers:', Object.fromEntries(response.headers.entries()))
  } catch (error) {
    console.log('Erro:', error.message)
  }
}

testMinimal()
