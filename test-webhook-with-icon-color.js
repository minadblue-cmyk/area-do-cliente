import https from 'https';

const testPayload = {
  action: 'create',
  agent_name: 'Teste Icone Cor',
  agent_type: 'testeIconeCor',
  agent_id: 'TEST_ICONE_COR_123',
  user_id: '5',
  icone: '🚀',
  cor: 'bg-green-500'
};

const postData = JSON.stringify(testPayload);

const options = {
  hostname: 'n8n.code-iq.com.br',
  port: 443,
  path: '/webhook/create-agente-complete',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(postData)
  }
};

console.log('🚀 Testando webhook com icone e cor:');
console.log('📦 Payload:', testPayload);

const req = https.request(options, (res) => {
  console.log(`📡 Status: ${res.statusCode}`);
  console.log(`📋 Headers:`, res.headers);
  
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    console.log('✅ Resposta completa:');
    try {
      const response = JSON.parse(data);
      console.log(JSON.stringify(response, null, 2));
    } catch (e) {
      console.log('📄 Resposta (texto):', data);
    }
  });
});

req.on('error', (e) => {
  console.error('❌ Erro na requisição:', e.message);
});

req.write(postData);
req.end();
