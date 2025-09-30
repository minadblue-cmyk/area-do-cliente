// Debug para analisar a resposta do webhook list-agentes
// Cole este código no console do navegador para debugar

async function debugListAgentes() {
  try {
    console.log('🔍 Debugando webhook list-agentes...')
    
    const response = await fetch('https://n8n.code-iq.com.br/webhook/list-agentes', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    })
    
    const data = await response.json()
    console.log('📥 Resposta completa:', data)
    console.log('📊 Tipo da resposta:', typeof data)
    console.log('📊 É array?', Array.isArray(data))
    
    if (Array.isArray(data) && data.length > 0) {
      console.log('📊 Primeiro item:', data[0])
      console.log('📊 Chaves do primeiro item:', Object.keys(data[0]))
      
      const firstItem = data[0]
      console.log('📊 Campo data:', firstItem.data)
      console.log('📊 Campo data\\t:', firstItem['data\t'])
      console.log('📊 Campo data (espaço):', firstItem['data '])
      
      // Verificar se tem campo data
      const dataField = firstItem.data || firstItem['data\t'] || firstItem['data ']
      console.log('📊 Campo dataField encontrado:', dataField)
      console.log('📊 Tipo do dataField:', typeof dataField)
      console.log('📊 É array?', Array.isArray(dataField))
      
      if (dataField && Array.isArray(dataField)) {
        console.log('📊 Quantidade de itens no dataField:', dataField.length)
        console.log('📊 Primeiro item do dataField:', dataField[0])
        
        if (dataField[0] && dataField[0].json) {
          console.log('📊 JSON do primeiro item:', dataField[0].json)
          console.log('📊 Chaves do JSON:', Object.keys(dataField[0].json))
        }
      }
    }
    
    return data
  } catch (error) {
    console.error('❌ Erro ao debugar:', error)
  }
}

// Executar debug
debugListAgentes()
