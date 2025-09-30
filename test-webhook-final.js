// Teste final do webhook com diferentes abordagens
import fetch from 'node-fetch'

const testFinal = async () => {
  console.log('🎯 Teste final do webhook de clonagem...')
  
  // Teste 1: Payload mínimo
  console.log('\n📋 Teste 1: Payload mínimo')
  try {
    const response = await fetch('https://n8n.code-iq.com.br/webhook/create-agente', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ test: true })
    })
    
    console.log('Status:', response.status)
    const text = await response.text()
    console.log('Resposta:', text || '(vazia)')
    
    if (text) {
      try {
        const json = JSON.parse(text)
        console.log('JSON:', JSON.stringify(json, null, 2))
      } catch (e) {
        console.log('Não é JSON:', text)
      }
    }
  } catch (error) {
    console.log('Erro:', error.message)
  }

  // Teste 2: Payload completo
  console.log('\n📋 Teste 2: Payload completo')
  try {
    const data = {
      action: 'create',
      agent_name: 'Agente Teste Final',
      agent_type: 'agenteTesteFinal',
      agent_id: 'FINAL123456789',
      user_id: 'user123'
    }

    const response = await fetch('https://n8n.code-iq.com.br/webhook/create-agente', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: JSON.stringify(data)
    })
    
    console.log('Status:', response.status)
    console.log('Status Text:', response.statusText)
    console.log('Headers:', Object.fromEntries(response.headers.entries()))
    
    const text = await response.text()
    console.log('Resposta (texto):', text || '(vazia)')
    console.log('Tamanho:', text ? text.length : 0)
    
    if (text) {
      try {
        const json = JSON.parse(text)
        console.log('✅ SUCESSO! Resposta JSON:')
        console.log(JSON.stringify(json, null, 2))
        
        if (json.success) {
          console.log('🎉 AGENTE CRIADO COM SUCESSO!')
          console.log('🔧 Workflows:', Object.keys(json.workflows || {}))
          console.log('📁 Organização:', json.organization)
        } else {
          console.log('❌ Falha:', json.message)
        }
      } catch (e) {
        console.log('⚠️ Resposta não é JSON:', e.message)
        console.log('📄 Conteúdo bruto:', text)
      }
    } else {
      console.log('⚠️ Resposta completamente vazia')
    }
  } catch (error) {
    console.log('❌ Erro:', error.message)
  }

  // Teste 3: Verificar se webhook está ativo
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

testFinal()
