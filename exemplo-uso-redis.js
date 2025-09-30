// Exemplo de como usar o Redis Counter Server
const axios = require('axios');

const REDIS_SERVER_URL = 'http://localhost:3001';

async function exemploCriacaoAgente() {
  console.log('🤖 Exemplo de criação de agente com Redis Counter\n');
  
  try {
    // 1. Simular criação de um agente
    const agentData = {
      agent_name: 'Agente Vendas Premium',
      agent_type: 'vendas-premium',
      agent_id: 'VENDA_PREMIUM_001',
      user_id: '5',
      icone: '💼',
      cor: 'bg-green-500'
    };
    
    console.log('📝 Dados do agente:', agentData);
    console.log('');
    
    // 2. Obter contadores únicos para cada tipo de workflow
    const workflowTypes = ['start', 'status', 'lista', 'stop'];
    const counters = {};
    
    console.log('🔢 Obtendo contadores únicos do Redis...');
    for (const type of workflowTypes) {
      const response = await axios.post(`${REDIS_SERVER_URL}/api/counter/next`, {
        agentType: agentData.agent_type,
        webhookType: type
      });
      
      counters[type] = response.data.counter;
      console.log(`   ${type}: contador ${counters[type]}`);
    }
    console.log('');
    
    // 3. Simular criação dos workflows com nomes únicos
    console.log('🏗️ Simulando criação dos workflows...');
    const workflows = [];
    
    for (const type of workflowTypes) {
      const workflowName = `Agente SDR - ${type.charAt(0).toUpperCase() + type.slice(1)} - ${agentData.agent_name}-${counters[type]}`;
      const webhookPath = `${type}-${agentData.agent_type}-${counters[type]}`;
      
      workflows.push({
        name: workflowName,
        webhookPath: webhookPath,
        type: type,
        counter: counters[type]
      });
      
      console.log(`   ✅ ${workflowName}`);
      console.log(`      Webhook: /webhook/${webhookPath}`);
    }
    console.log('');
    
    // 4. Mostrar resultado final
    console.log('🎯 Resultado final:');
    console.log(JSON.stringify({
      agent: agentData,
      workflows: workflows,
      timestamp: new Date().toISOString()
    }, null, 2));
    
    // 5. Listar todos os contadores
    console.log('\n📊 Estado atual dos contadores:');
    const listResponse = await axios.get(`${REDIS_SERVER_URL}/api/counter/list`);
    console.log(JSON.stringify(listResponse.data.counters, null, 2));
    
  } catch (error) {
    console.error('❌ Erro:', error.message);
    if (error.response) {
      console.error('📄 Resposta:', error.response.data);
    }
  }
}

// Função para testar concorrência
async function testarConcorrencia() {
  console.log('\n🚀 Testando criação simultânea de agentes...\n');
  
  const agentes = [
    { agent_type: 'vendas-rapido', webhookType: 'start' },
    { agent_type: 'suporte-tecnico', webhookType: 'start' },
    { agent_type: 'vendas-rapido', webhookType: 'start' }, // Mesmo tipo, deve ter contador diferente
    { agent_type: 'marketing-digital', webhookType: 'start' }
  ];
  
  const promises = agentes.map(async (agente, index) => {
    const response = await axios.post(`${REDIS_SERVER_URL}/api/counter/next`, agente);
    return {
      index: index + 1,
      agent_type: agente.agent_type,
      counter: response.data.counter,
      timestamp: response.data.timestamp
    };
  });
  
  const results = await Promise.all(promises);
  
  console.log('📊 Resultados da criação simultânea:');
  results.forEach(result => {
    console.log(`   ${result.index}. ${result.agent_type} -> contador ${result.counter}`);
  });
}

// Executar exemplos
async function main() {
  await exemploCriacaoAgente();
  await testarConcorrencia();
}

main().catch(console.error);
