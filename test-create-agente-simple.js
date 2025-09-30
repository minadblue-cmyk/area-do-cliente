import https from 'https';

const testCreateAgenteSimple = () => {
  console.log('🧪 Testando webhook /webhook/create-agente:');
  
  const payload = JSON.stringify({
    agent_name: "Agente Teste Webhook",
    agent_type: "agente-teste-webhook",
    agent_id: "TESTE_WEBHOOK_123",
    user_id: "5",
    icone: "🤖",
    cor: "bg-blue-500",
    descricao: "Teste do webhook create-agente"
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
    let chunks = 0;
    
    res.on('data', (chunk) => {
      chunks++;
      data += chunk;
      console.log(`📦 Chunk ${chunks} (${chunk.length} bytes)`);
    });

    res.on('end', () => {
      console.log('✅ Resposta completa:');
      console.log('📄 Tamanho total:', data.length, 'bytes');
      
      if (data.length === 0) {
        console.log('❌ Resposta vazia');
        return;
      }
      
      // Verificar se é JSON válido
      try {
        const jsonResponse = JSON.parse(data);
        console.log('📄 Resposta (JSON válido):');
        console.log(JSON.stringify(jsonResponse, null, 2));
        
        if (jsonResponse.success) {
          console.log('✅ Sucesso! Agente criado');
        } else {
          console.log('❌ Falha na criação:', jsonResponse.message);
        }
      } catch (error) {
        console.log('❌ Não é JSON válido');
        console.log('📄 Resposta (primeiros 500 chars):', data.substring(0, 500));
        
        // Verificar se contém informações de workflow
        if (data.includes('"nodes"') && data.includes('"connections"')) {
          console.log('⚠️  Resposta contém definição de workflow n8n');
        }
      }
    });
  });

  req.on('error', (error) => {
    console.error('❌ Erro na requisição:', error.message);
  });

  req.setTimeout(30000);
  req.write(payload);
  req.end();
};

testCreateAgenteSimple();
