// Teste detalhado do webhook de clonagem
import fetch from 'node-fetch'

const testDetailed = async () => {
  console.log('🧪 Teste detalhado do webhook de clonagem...')
  
  // Teste com diferentes estruturas de payload
  const testCases = [
    {
      name: 'Payload completo original',
      data: {
        action: 'create',
        agent_name: 'Agente Teste Completo',
        agent_type: 'agenteTesteCompleto',
        agent_id: 'COMPLETO123456789',
        user_id: 'user123'
      }
    },
    {
      name: 'Payload sem action',
      data: {
        agent_name: 'Agente Teste Sem Action',
        agent_type: 'agenteTesteSemAction',
        agent_id: 'SEMACTION123456789',
        user_id: 'user123'
      }
    },
    {
      name: 'Payload apenas com nome',
      data: {
        agent_name: 'Agente Teste Nome'
      }
    },
    {
      name: 'Payload vazio',
      data: {}
    }
  ]

  for (const testCase of testCases) {
    console.log(`\n📋 ${testCase.name}`)
    console.log('Dados:', JSON.stringify(testCase.data, null, 2))
    
    try {
      const response = await fetch('https://n8n.code-iq.com.br/webhook/create-agente', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(testCase.data)
      })
      
      console.log('Status:', response.status)
      console.log('Headers:', Object.fromEntries(response.headers.entries()))
      
      const text = await response.text()
      console.log('Resposta:', text || '(vazia)')
      
      if (text) {
        try {
          const json = JSON.parse(text)
          console.log('JSON:', JSON.stringify(json, null, 2))
        } catch (e) {
          console.log('Não é JSON válido')
        }
      }
      
    } catch (error) {
      console.log('Erro:', error.message)
    }
    
    console.log('─'.repeat(50))
  }
}

testDetailed()
