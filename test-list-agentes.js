import https from 'https';

const options = {
  hostname: 'n8n.code-iq.com.br',
  port: 443,
  path: '/webhook/list-agentes',
  method: 'GET',
  headers: {
    'Content-Type': 'application/json'
  }
};

console.log('📋 Listando agentes existentes...');

const req = https.request(options, (res) => {
  console.log(`📡 Status: ${res.statusCode}`);
  
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    console.log('✅ Agentes encontrados:');
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

req.end();