// Teste para verificar se o webhook de stop está recebendo o execution_id corretamente
import axios from 'axios';

async function testStopWebhook() {
  try {
    console.log('🛑 Testando webhook de stop com execution_id...');
    
    // URL do webhook de stop (baseado nos dados fornecidos)
    const webhookUrl = 'https://n8n.code-iq.com.br/webhook/stop7-joao';
    
    // Payload com execution_id (baseado nos dados fornecidos)
    const payload = {
      action: 'stop',
      agent_type: 65,
      workflow_id: 65,
      timestamp: new Date().toISOString(),
      usuario_id: '5',
      execution_id: '66359' // Execution ID do agente João
    };
    
    console.log('📡 Fazendo requisição POST para:', webhookUrl);
    console.log('📦 Payload enviado:', JSON.stringify(payload, null, 2));
    
    const response = await axios.post(webhookUrl, payload, {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer sess-5-1758561139891'
      },
      timeout: 10000
    });
    
    console.log('✅ Status da resposta:', response.status);
    console.log('📥 Dados recebidos:', JSON.stringify(response.data, null, 2));
    
    // Verificar se a parada foi bem-sucedida
    if (response.data) {
      const data = Array.isArray(response.data) ? response.data[0] : response.data;
      console.log('\n🔍 ANÁLISE DA RESPOSTA:');
      console.log('Sucesso:', data?.success || 'N/A');
      console.log('Mensagem:', data?.message || 'N/A');
      console.log('Status:', data?.status || 'N/A');
      console.log('Execution ID processado:', data?.execution_id || 'N/A');
    }
    
  } catch (error) {
    console.error('❌ Erro no teste:', error.message);
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Dados:', error.response.data);
    }
  }
}

// Executar teste
testStopWebhook();
