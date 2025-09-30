import https from 'https';

const testSimpleWebhook = () => {
  console.log('🔍 Testando webhook simples para verificar conectividade:');
  
  // Testar um webhook que sabemos que funciona
  const testEndpoints = [
    '/webhook/list-agentes',
    '/webhook/status-agente1',
    '/webhook/lista-prospeccao-agente1'
  ];
  
  testEndpoints.forEach((endpoint, index) => {
    setTimeout(() => {
      console.log(`\n🧪 Testando endpoint ${index + 1}: ${endpoint}`);
      
      const options = {
        hostname: 'n8n.code-iq.com.br',
        port: 443,
        path: endpoint,
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'Origin': 'http://localhost:5173',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }
      };

      const req = https.request(options, (res) => {
        console.log(`📡 Status: ${res.statusCode}`);
        
        let data = '';
        res.on('data', (chunk) => {
          data += chunk;
        });

        res.on('end', () => {
          console.log(`📄 Resposta (${data.length} bytes):`, data.substring(0, 200) + (data.length > 200 ? '...' : ''));
          
          if (res.statusCode === 200) {
            console.log('✅ Endpoint funcionando');
          } else {
            console.log('❌ Endpoint com problema');
          }
        });
      });

      req.on('error', (error) => {
        console.error('❌ Erro:', error.message);
      });

      req.setTimeout(10000);
      req.end();
    }, index * 2000); // Delay entre testes
  });
};

testSimpleWebhook();
