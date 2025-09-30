// Teste final para enviar dados ao webhook e finalizar a montagem

const axios = require('axios');

// URL do webhook (ajuste conforme necessário)
const WEBHOOK_URL = 'https://n8n.code-iq.com.br/webhook/create-agente';

// Dados de teste baseados na estrutura da tabela
const dadosTeste = {
  agent_name: "Agente Vendas Premium",
  agent_type: "vendas-premium",
  agent_id: 8,
  user_id: 5,
  icone: "💼",
  cor: "bg-green-500",
  descricao: "Agente para vendas premium"
};

async function testarWebhook() {
  console.log('🧪 Teste Final - Enviando dados para o webhook\n');
  
  try {
    console.log('📤 Dados sendo enviados:');
    console.log(JSON.stringify(dadosTeste, null, 2));
    console.log('');
    
    console.log('🌐 Enviando para:', WEBHOOK_URL);
    
    const response = await axios.post(WEBHOOK_URL, dadosTeste, {
      headers: {
        'Content-Type': 'application/json'
      },
      timeout: 30000 // 30 segundos
    });
    
    console.log('✅ Resposta recebida:');
    console.log('Status:', response.status);
    console.log('Dados:', JSON.stringify(response.data, null, 2));
    
    // Verificar se a resposta tem a estrutura esperada
    if (response.data && response.data.success) {
      console.log('\n🎯 Estrutura da resposta validada:');
      console.log('- Success:', response.data.success);
      console.log('- Message:', response.data.message);
      console.log('- Agent Name:', response.data.agentName);
      console.log('- Agent Type:', response.data.agentType);
      console.log('- Agent ID:', response.data.agentId);
      console.log('- Total Workflows:', response.data.summary?.totalWorkflows);
      console.log('- Workflows Types:', response.data.summary?.webhookTypes);
      
      if (response.data.workflows && response.data.workflows.length > 0) {
        console.log('\n🏗️ Workflows criados:');
        response.data.workflows.forEach((workflow, index) => {
          console.log(`${index + 1}. ${workflow.name}`);
          console.log(`   Webhook: ${workflow.webhookPath}`);
          console.log(`   Status: ${workflow.status}`);
        });
      }
    }
    
  } catch (error) {
    console.error('❌ Erro no teste:');
    
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Dados:', error.response.data);
    } else if (error.request) {
      console.error('Erro de conexão:', error.message);
    } else {
      console.error('Erro:', error.message);
    }
  }
}

// Executar teste
testarWebhook();

// Exportar dados para uso
module.exports = {
  dadosTeste,
  WEBHOOK_URL
};
