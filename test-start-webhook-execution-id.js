// Teste para verificar se o webhook de start está retornando execution_id
import axios from 'axios';

async function testStartWebhook() {
  try {
    console.log('🚀 Testando webhook de start para verificar execution_id...');
    
    // URL do webhook de start (baseado nos dados fornecidos)
    const webhookUrl = 'https://n8n.code-iq.com.br/webhook/start7-joao';
    
    // Payload para iniciar agente
    const payload = {
      action: 'start',
      agent_type: 65,
      workflow_id: 65,
      timestamp: new Date().toISOString(),
      usuario_id: '5',
      logged_user: {
        id: '5',
        name: 'Usuário Teste',
        email: 'teste@exemplo.com'
      }
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
    
    // Verificar se o start foi bem-sucedido e se retornou execution_id
    if (response.data) {
      const data = Array.isArray(response.data) ? response.data[0] : response.data;
      console.log('\n🔍 ANÁLISE DA RESPOSTA:');
      console.log('Sucesso:', data?.success || 'N/A');
      console.log('Mensagem:', data?.message || 'N/A');
      console.log('Status:', data?.status || 'N/A');
      console.log('Execution ID:', data?.execution_id || 'N/A');
      console.log('ExecutionId:', data?.executionId || 'N/A');
      console.log('ID:', data?.id || 'N/A');
      
      // Verificar se há execution_id em qualquer campo
      const executionId = data?.execution_id || data?.executionId || data?.id;
      if (executionId) {
        console.log('\n✅ EXECUTION_ID ENCONTRADO:', executionId);
        console.log('✅ Agente deve ser iniciado com sucesso!');
      } else {
        console.log('\n❌ EXECUTION_ID NÃO ENCONTRADO');
        console.log('❌ Agente pode não ser iniciado corretamente');
      }
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
testStartWebhook();
