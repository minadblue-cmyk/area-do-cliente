import https from 'https';

const testSimpleWorkflow = async () => {
  console.log('🧪 Testando workflow simples...\n');

  const testWebhook = () => {
    return new Promise((resolve, reject) => {
      const postData = JSON.stringify({
        agent_name: 'Teste Simples',
        agent_type: 'testeSimples',
        agent_id: 'TESTE_SIMPLES_123',
        user_id: '1'
      });

      const options = {
        hostname: 'n8n.code-iq.com.br',
        port: 443,
        path: '/webhook/create-agente-simple',
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
    console.log('⚠️ IMPORTANTE: Este teste requer que o workflow simples seja importado no n8n primeiro!');
    console.log('📁 Arquivo: agente-clone-workflow-simple.json');
    console.log('🔗 Webhook: /webhook/create-agente-simple\n');
    
    await testWebhook();
  } catch (error) {
    console.error('❌ Erro:', error);
  }
};

testSimpleWorkflow().catch(console.error);

