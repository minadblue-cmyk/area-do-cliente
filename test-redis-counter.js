const axios = require('axios');

const BASE_URL = 'http://localhost:3001';

async function testRedisCounter() {
  console.log('🧪 Testando Redis Counter Server...\n');
  
  try {
    // 1. Health Check
    console.log('1️⃣ Testando Health Check...');
    const healthResponse = await axios.get(`${BASE_URL}/health`);
    console.log('✅ Health Check:', healthResponse.data);
    console.log('');
    
    // 2. Testar incremento de contadores
    console.log('2️⃣ Testando incremento de contadores...');
    
    const testCases = [
      { agentType: 'agente-teste-1', webhookType: 'start' },
      { agentType: 'agente-teste-1', webhookType: 'status' },
      { agentType: 'agente-teste-1', webhookType: 'lista' },
      { agentType: 'agente-teste-1', webhookType: 'stop' },
      { agentType: 'agente-teste-2', webhookType: 'start' },
      { agentType: 'agente-teste-2', webhookType: 'status' }
    ];
    
    for (const testCase of testCases) {
      const response = await axios.post(`${BASE_URL}/api/counter/next`, testCase);
      console.log(`✅ ${testCase.agentType}:${testCase.webhookType} -> Contador: ${response.data.counter}`);
    }
    
    console.log('');
    
    // 3. Listar todos os contadores
    console.log('3️⃣ Listando todos os contadores...');
    const listResponse = await axios.get(`${BASE_URL}/api/counter/list`);
    console.log('📊 Contadores atuais:', JSON.stringify(listResponse.data.counters, null, 2));
    console.log('');
    
    // 4. Testar contador atual (sem incrementar)
    console.log('4️⃣ Testando contador atual...');
    const currentResponse = await axios.get(`${BASE_URL}/api/counter/current/agente-teste-1/start`);
    console.log('📊 Contador atual para agente-teste-1:start:', currentResponse.data.counter);
    console.log('');
    
    // 5. Testar múltiplos incrementos simultâneos
    console.log('5️⃣ Testando incrementos simultâneos...');
    const promises = [];
    for (let i = 0; i < 5; i++) {
      promises.push(axios.post(`${BASE_URL}/api/counter/next`, {
        agentType: 'agente-concorrencia',
        webhookType: 'start'
      }));
    }
    
    const results = await Promise.all(promises);
    console.log('🚀 Incrementos simultâneos:');
    results.forEach((result, index) => {
      console.log(`   ${index + 1}: Contador ${result.data.counter}`);
    });
    console.log('');
    
    // 6. Testar reset
    console.log('6️⃣ Testando reset de contador...');
    const resetResponse = await axios.post(`${BASE_URL}/api/counter/reset`, {
      agentType: 'agente-teste-1',
      webhookType: 'start'
    });
    console.log('🔄 Reset:', resetResponse.data.message);
    
    // Verificar se foi resetado
    const afterResetResponse = await axios.get(`${BASE_URL}/api/counter/current/agente-teste-1/start`);
    console.log('📊 Contador após reset:', afterResetResponse.data.counter);
    console.log('');
    
    console.log('🎉 Todos os testes passaram!');
    
  } catch (error) {
    console.error('❌ Erro nos testes:', error.message);
    if (error.response) {
      console.error('📄 Resposta do servidor:', error.response.data);
    }
  }
}

// Executar testes
testRedisCounter();
