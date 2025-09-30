import https from 'https';

const testWebhook = (path, method = 'GET') => {
  console.log(`🧪 Testando webhook ${method} ${path}:`);
  
  const options = {
    hostname: 'n8n.code-iq.com.br',
    port: 443,
    path: `/webhook/${path}`,
    method: method,
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
      console.log('📄 Resposta (texto):', data.substring(0, 200) + (data.length > 200 ? '...' : ''));
      
      if (res.statusCode === 200) {
        console.log('✅ Webhook funcionando!');
      } else if (res.statusCode === 404) {
        console.log('❌ Webhook não encontrado (404)');
      } else if (res.statusCode === 500) {
        console.log('❌ Erro interno do servidor (500)');
      } else {
        console.log(`⚠️ Status inesperado: ${res.statusCode}`);
      }
    });
  });

  req.on('error', (error) => {
    console.error('❌ Erro na requisição:', error.message);
  });

  if (method === 'POST') {
    const payload = JSON.stringify({ test: 'data' });
    req.write(payload);
  }
  
  req.end();
};

// Testar webhooks
console.log('🔍 Testando webhooks disponíveis:\n');

testWebhook('create-agente', 'POST');
setTimeout(() => {
  testWebhook('delete-agente', 'POST');
}, 1000);
setTimeout(() => {
  testWebhook('list-agentes', 'GET');
}, 2000);