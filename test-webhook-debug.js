import https from 'https';

const testWebhookDebug = () => {
  console.log('🔍 Testando webhook com debug detalhado:');
  
  const payload = JSON.stringify({
    agent_name: "Agente Debug",
    agent_type: "agente-debug",
    agent_id: "DEBUG_123",
    user_id: "5",
    icone: "🤖",
    cor: "bg-blue-500",
    descricao: "Agente para debug"
  });

  const options = {
    hostname: 'n8n.code-iq.com.br',
    port: 443,
    path: '/webhook/create-agente',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(payload),
      'Origin': 'http://localhost:5173',
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
    }
  };

  console.log('📡 URL:', `https://${options.hostname}${options.path}`);
  console.log('📦 Payload:', payload);
  console.log('📋 Headers:', options.headers);

  const req = https.request(options, (res) => {
    console.log('📡 Status:', res.statusCode);
    console.log('📋 Headers:', res.headers);
    console.log('📋 Status Message:', res.statusMessage);

    let data = '';
    let chunks = 0;
    
    res.on('data', (chunk) => {
      chunks++;
      data += chunk;
      console.log(`📦 Chunk ${chunks}:`, chunk.toString());
    });

    res.on('end', () => {
      console.log('✅ Resposta completa:');
      console.log('📄 Tamanho da resposta:', data.length);
      console.log('📄 Resposta (texto):', data);
      console.log('📄 Resposta (hex):', Buffer.from(data).toString('hex'));
      
      if (data.length === 0) {
        console.log('❌ Resposta vazia - possível problema no workflow n8n');
        return;
      }
      
      try {
        const jsonResponse = JSON.parse(data);
        console.log('📄 Resposta (JSON):', JSON.stringify(jsonResponse, null, 2));
        
        if (jsonResponse.success) {
          console.log('✅ Sucesso! Agente criado:', jsonResponse.agentName);
        } else {
          console.log('❌ Falha na criação:', jsonResponse.message);
        }
      } catch (error) {
        console.log('❌ Erro ao parsear JSON:', error.message);
        console.log('📄 Resposta bruta (primeiros 200 chars):', data.substring(0, 200));
      }
    });
  });

  req.on('error', (error) => {
    console.error('❌ Erro na requisição:', error.message);
  });

  req.on('timeout', () => {
    console.error('❌ Timeout na requisição');
    req.destroy();
  });

  req.setTimeout(30000); // 30 segundos
  req.write(payload);
  req.end();
};

testWebhookDebug();