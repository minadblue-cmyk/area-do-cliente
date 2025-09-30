import axios from 'axios';

async function testN8nWorkflowStatus() {
  console.log('🔍 Verificando status do workflow no n8n\n');
  
  try {
    // Verificar se o workflow create-agente existe e está ativo
    const response = await axios.get(
      'https://n8n.code-iq.com.br/api/v1/workflows',
      {
        headers: {
          'Authorization': 'Bearer YOUR_API_KEY', // Substitua pela chave real
          'Content-Type': 'application/json'
        }
      }
    );

    console.log('📊 Workflows encontrados:', response.data.data.length);
    
    const createAgenteWorkflow = response.data.data.find(w => 
      w.name && w.name.toLowerCase().includes('create-agente')
    );
    
    if (createAgenteWorkflow) {
      console.log('✅ Workflow create-agente encontrado:');
      console.log('- ID:', createAgenteWorkflow.id);
      console.log('- Nome:', createAgenteWorkflow.name);
      console.log('- Ativo:', createAgenteWorkflow.active);
      console.log('- Webhooks:', createAgenteWorkflow.webhookUrl);
    } else {
      console.log('❌ Workflow create-agente não encontrado');
    }

  } catch (error) {
    console.log('❌ Erro ao verificar workflows:', error.message);
    console.log('💡 Dica: Verifique se a API key está correta');
  }
}

testN8nWorkflowStatus();
