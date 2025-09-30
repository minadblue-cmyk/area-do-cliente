import https from 'https';

const testWebhook = async () => {
  console.log('🔍 Teste detalhado do webhook de clonagem...\n');

  const payload = {
    action: 'create',
    agent_name: 'Agente Teste Debug',
    agent_type: 'agenteTesteDebug',
    agent_id: 'TESTE_DEBUG_123456789',
    user_id: '1'
  };

  const postData = JSON.stringify(payload);

  const options = {
    hostname: 'n8n.code-iq.com.br',
    port: 443,
    path: '/webhook/create-agente',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(postData),
      'User-Agent': 'Node.js Test Script'
    }
  };

  console.log('📤 Payload enviado:', JSON.stringify(payload, null, 2));
  console.log('🔗 URL:', `https://${options.hostname}${options.path}`);
  console.log('📋 Headers:', options.headers);
  console.log('');

  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      console.log(`📊 Status: ${res.statusCode} ${res.statusMessage}`);
      console.log('📋 Headers de resposta:', res.headers);
      console.log('');

      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
        console.log('📥 Chunk recebido:', chunk.toString());
      });

      res.on('end', () => {
        console.log('✅ Resposta completa recebida');
        console.log('📏 Tamanho total:', data.length);
        console.log('📄 Conteúdo:', data || '(vazio)');
        
        if (data) {
          try {
            const parsed = JSON.parse(data);
            console.log('📋 JSON parseado:', JSON.stringify(parsed, null, 2));
          } catch (e) {
            console.log('⚠️ Não é JSON válido:', e.message);
          }
        }
        
        resolve({
          status: res.statusCode,
          headers: res.headers,
          data: data
        });
      });
    });

    req.on('error', (error) => {
      console.error('❌ Erro na requisição:', error);
      reject(error);
    });

    req.write(postData);
    req.end();
  });
};

testWebhook().catch(console.error);
