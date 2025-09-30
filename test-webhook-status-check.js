import https from 'https';

const testWebhookStatusCheck = () => {
  console.log('🔍 Verificando status dos webhooks:');
  
  const testEndpoints = [
    { name: 'List Agentes', path: '/webhook/list-agentes', method: 'GET' },
    { name: 'Status Agente', path: '/webhook/status-agente1', method: 'GET' },
    { name: 'Create Agente', path: '/webhook/create-agente', method: 'POST' }
  ];
  
  testEndpoints.forEach((endpoint, index) => {
    setTimeout(() => {
      console.log(`\n🧪 Testando ${endpoint.name}:`);
      
      const options = {
        hostname: 'n8n.code-iq.com.br',
        port: 443,
        path: endpoint.path,
        method: endpoint.method,
        headers: {
          'Content-Type': 'application/json',
          'Origin': 'http://localhost:5173'
        }
      };

      if (endpoint.method === 'POST') {
        const payload = JSON.stringify({
          agent_name: "Teste Status",
          agent_type: "teste-status",
          agent_id: "STATUS_TEST_123",
          user_id: "5",
          icone: "🤖",
          cor: "bg-blue-500",
          descricao: "Teste de status do webhook"
        });
        
        options.headers['Content-Length'] = Buffer.byteLength(payload);
        
        const req = https.request(options, (res) => {
          console.log(`📡 Status: ${res.statusCode}`);
          
          let data = '';
          res.on('data', (chunk) => {
            data += chunk;
          });

          res.on('end', () => {
            console.log(`📄 Resposta (${data.length} bytes):`, data.substring(0, 200) + (data.length > 200 ? '...' : ''));
            
            if (data.length === 0) {
              console.log('❌ Resposta vazia - workflow pode não estar ativo');
            } else if (res.statusCode === 200) {
              console.log('✅ Webhook funcionando');
            } else {
              console.log('⚠️ Webhook com problema');
            }
          });
        });

        req.on('error', (error) => {
          console.error('❌ Erro:', error.message);
        });

        req.write(payload);
        req.end();
      } else {
        const req = https.request(options, (res) => {
          console.log(`📡 Status: ${res.statusCode}`);
          
          let data = '';
          res.on('data', (chunk) => {
            data += chunk;
          });

          res.on('end', () => {
            console.log(`📄 Resposta (${data.length} bytes):`, data.substring(0, 200) + (data.length > 200 ? '...' : ''));
            
            if (res.statusCode === 200) {
              console.log('✅ Webhook funcionando');
            } else {
              console.log('⚠️ Webhook com problema');
            }
          });
        });

        req.on('error', (error) => {
          console.error('❌ Erro:', error.message);
        });

        req.end();
      }
    }, index * 2000);
  });
};

testWebhookStatusCheck();
