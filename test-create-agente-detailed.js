import axios from 'axios';

async function testCreateAgente() {
  console.log('🧪 Teste Detalhado do Webhook create-agente\n');
  
  const testData = {
    agent_name: "Agente Teste Fix",
    agent_type: "agente-teste-fix",
    agent_id: "TESTE_FIX_123",
    user_id: "1",
    icone: "🤖",
    cor: "bg-blue-500",
    descricao: "Agente para teste de correção"
  };

  try {
    console.log('📤 Enviando dados:', JSON.stringify(testData, null, 2));
    console.log('📡 URL: https://n8n.code-iq.com.br/webhook/create-agente\n');

    const response = await axios.post(
      'https://n8n.code-iq.com.br/webhook/create-agente',
      testData,
      {
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        timeout: 30000 // 30 segundos
      }
    );

    console.log('✅ Status:', response.status);
    console.log('📋 Headers:', response.headers);
    console.log('📄 Resposta completa:');
    console.log('Tipo:', typeof response.data);
    console.log('Tamanho:', response.data ? response.data.length || JSON.stringify(response.data).length : 0);
    console.log('Conteúdo:', JSON.stringify(response.data, null, 2));

    if (response.data && typeof response.data === 'object') {
      console.log('\n🎯 Análise da resposta:');
      console.log('- success:', response.data.success);
      console.log('- message:', response.data.message);
      console.log('- agentId:', response.data.agentId);
      console.log('- agentName:', response.data.agentName);
      console.log('- workflowId:', response.data.workflowId);
      console.log('- webhookUrl:', response.data.webhookUrl);
    }

  } catch (error) {
    console.log('❌ Erro na requisição:');
    if (error.response) {
      console.log('Status:', error.response.status);
      console.log('Headers:', error.response.headers);
      console.log('Data:', error.response.data);
    } else if (error.request) {
      console.log('Erro de rede:', error.message);
    } else {
      console.log('Erro:', error.message);
    }
  }
}

testCreateAgente();
