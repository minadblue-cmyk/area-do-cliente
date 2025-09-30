import https from 'https';

const testCounterIncrement = () => {
  const payloads = [
    {
      action: 'create',
      agent_name: 'Agente Teste 1',
      agent_type: 'teste1',
      agent_id: 'TESTE1_123456789',
      user_id: '5',
      icone: '🤖',
      cor: 'bg-blue-500'
    },
    {
      action: 'create',
      agent_name: 'Agente Teste 2',
      agent_type: 'teste2',
      agent_id: 'TESTE2_123456789',
      user_id: '5',
      icone: '🚀',
      cor: 'bg-green-500'
    },
    {
      action: 'create',
      agent_name: 'Agente Teste 3',
      agent_type: 'teste3',
      agent_id: 'TESTE3_123456789',
      user_id: '5',
      icone: '⚡',
      cor: 'bg-red-500'
    }
  ];

  let currentIndex = 0;

  const sendRequest = (payload) => {
    const options = {
      hostname: 'n8n.code-iq.com.br',
      port: 443,
      path: '/webhook/create-agente',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'Test-Counter-Script'
      }
    };

    console.log(`\n🔢 Testando Agente ${currentIndex + 1}:`);
    console.log(`📦 Payload:`, JSON.stringify(payload, null, 2));

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        try {
          const jsonData = JSON.parse(data);
          console.log(`✅ Resposta Agente ${currentIndex + 1}:`);
          console.log(`   - Success: ${jsonData.success}`);
          console.log(`   - Agent Counter: ${jsonData.agentCounter}`);
          console.log(`   - Agent Name: ${jsonData.agentName}`);
          console.log(`   - Workflows: ${jsonData.workflows?.length || 0} criados`);
          
          if (jsonData.workflows) {
            jsonData.workflows.forEach((wf, idx) => {
              console.log(`     ${idx + 1}. ${wf.name} (${wf.webhook})`);
            });
          }

          // Próximo agente
          currentIndex++;
          if (currentIndex < payloads.length) {
            setTimeout(() => sendRequest(payloads[currentIndex]), 2000);
          } else {
            console.log('\n🎯 Teste de incremento concluído!');
            console.log('📊 Verifique se os contadores estão incrementando corretamente: 1, 2, 3...');
          }
        } catch (error) {
          console.log(`❌ Erro ao parsear JSON Agente ${currentIndex + 1}:`, error.message);
          console.log('📄 Resposta raw:', data);
        }
      });
    });

    req.on('error', (error) => {
      console.error(`❌ Erro na requisição Agente ${currentIndex + 1}:`, error.message);
    });

    req.write(JSON.stringify(payload));
    req.end();
  };

  console.log('🚀 Iniciando teste de incremento de contador...');
  console.log('📋 Serão criados 3 agentes para verificar se o contador incrementa: 1, 2, 3');
  
  sendRequest(payloads[currentIndex]);
};

testCounterIncrement();
