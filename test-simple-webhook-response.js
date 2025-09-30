import https from 'https';

const testSimpleWebhookResponse = () => {
  console.log('🧪 Testando webhook com resposta simples:');
  
  const payload = JSON.stringify({
    test: true,
    message: "Teste de conectividade"
  });

  const options = {
    hostname: 'n8n.code-iq.com.br',
    port: 443,
    path: '/webhook/create-agente',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(payload),
      'Origin': 'http://localhost:5173'
    }
  };

  console.log('📡 URL:', `https://${options.hostname}${options.path}`);
  console.log('📦 Payload:', payload);

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
      
      if (data.length === 0) {
        console.log('❌ Resposta vazia - workflow não está funcionando');
        console.log('🔧 Solução: Importe o workflow corrigido no n8n');
      } else {
        console.log('📄 Resposta:', data);
      }
    });
  });

  req.on('error', (error) => {
    console.error('❌ Erro:', error.message);
  });

  req.setTimeout(30000);
  req.write(payload);
  req.end();
};

testSimpleWebhookResponse();
