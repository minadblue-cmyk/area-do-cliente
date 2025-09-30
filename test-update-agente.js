import axios from 'axios';

// URL do webhook
const webhookUrl = 'https://n8n.code-iq.com.br/webhook/update-agente';

// Dados de teste para atualizar o agente
const testData = {
  id: 7, // ID do agente existente
  nome: "Elleven Agente1 Atualizado",
  workflow_id: "eBcColwirndBaFZX",
  webhook_url: "webhook/agente1",
  descricao: "Agente para prospecção de leads atualizado via teste",
  icone: "🚀",
  cor: "bg-blue-500",
  ativo: true,
  logged_user: {
    id: 1,
    name: "Administrator Code-IQ",
    email: "admin@code-iq.com"
  }
};

async function testUpdateAgente() {
  try {
    console.log('🚀 Testando webhook update-agente...');
    console.log('📤 Dados enviados:', JSON.stringify(testData, null, 2));
    
    const response = await axios.post(webhookUrl, testData, {
      headers: {
        'Content-Type': 'application/json'
      },
      timeout: 30000
    });
    
    console.log('✅ Resposta recebida:');
    console.log('📊 Status:', response.status);
    console.log('📋 Headers:', response.headers);
    console.log('📦 Dados:', JSON.stringify(response.data, null, 2));
    
  } catch (error) {
    console.error('❌ Erro no teste:');
    
    if (error.response) {
      console.error('📊 Status:', error.response.status);
      console.error('📋 Headers:', error.response.headers);
      console.error('📦 Dados:', JSON.stringify(error.response.data, null, 2));
    } else if (error.request) {
      console.error('🌐 Erro de rede:', error.message);
    } else {
      console.error('⚠️ Erro:', error.message);
    }
  }
}

// Executar teste
testUpdateAgente();
