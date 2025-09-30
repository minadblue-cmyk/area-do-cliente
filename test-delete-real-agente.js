import https from 'https';

const testPayload = {
  agent_id: '7',  // ID real do agente
  agent_name: 'Elleven Agente 1 (Maria)'  // Nome real do agente
};

const postData = JSON.stringify(testPayload);

const options = {
  hostname: 'n8n.code-iq.com.br',
  port: 443,
  path: '/webhook/delete-agente',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(postData)
  }
};

console.log('🗑️ Testando deleção de agente REAL:');
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
