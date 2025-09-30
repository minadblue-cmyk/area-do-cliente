import https from 'https';

const testWorkflowStructure = async () => {
  console.log('🧪 Testando estrutura do workflow...\n');

  // Teste 1: Verificar se o webhook está funcionando
  console.log('📋 Teste 1: Verificar webhook');
  const testWebhook = () => {
    return new Promise((resolve, reject) => {
      const postData = JSON.stringify({
        action: 'create',
        agent_name: 'Teste Estrutura',
        agent_type: 'testeEstrutura',
        agent_id: 'TESTE_ESTRUTURA_123',
        user_id: '1'
      });

      const options = {
        hostname: 'n8n.code-iq.com.br',
        port: 443,
        path: '/webhook/create-agente',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(postData)
        }
      };

      const req = https.request(options, (res) => {
        let data = '';
        res.on('data', (chunk) => data += chunk);
        res.on('end', () => {
          console.log(`Status: ${res.statusCode}`);
          if (data) {
            try {
              const parsed = JSON.parse(data);
              console.log('Resposta:', JSON.stringify(parsed, null, 2));
              resolve(parsed);
            } catch (e) {
              console.log('Resposta não é JSON:', data);
              resolve(null);
            }
          } else {
            console.log('Resposta vazia');
            resolve(null);
          }
        });
      });

      req.on('error', reject);
      req.write(postData);
      req.end();
    });
  };

  try {
    await testWebhook();
  } catch (error) {
    console.error('❌ Erro:', error);
  }
};

testWorkflowStructure().catch(console.error);

