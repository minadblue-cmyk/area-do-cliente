import https from 'https';

const testWebhookStatus = () => {
  console.log('🧪 Testando webhook de status para comparar:');
  
  const options = {
    hostname: 'n8n.code-iq.com.br',
    port: 443,
    path: '/webhook/status-agente1',
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
      'Origin': 'http://localhost:5173'
    }
  };

  console.log('📡 URL:', `https://${options.hostname}${options.path}`);

  const req = https.request(options, (res) => {
    console.log('📡 Status:', res.statusCode);
    console.log('📋 Headers:', res.headers);

    let data = '';
    res.on('data', (chunk) => {
      data += chunk;
    });

    res.on('end', () => {
      console.log('✅ Resposta completa:');
      console.log('📄 Tamanho:', data.length, 'bytes');
      console.log('📄 Resposta:', data);
      
      try {
        const jsonResponse = JSON.parse(data);
        console.log('📄 JSON válido:', JSON.stringify(jsonResponse, null, 2));
      } catch (error) {
        console.log('❌ Não é JSON válido');
      }
    });
  });

  req.on('error', (error) => {
    console.error('❌ Erro:', error.message);
  });

  req.setTimeout(10000);
  req.end();
};

testWebhookStatus();
