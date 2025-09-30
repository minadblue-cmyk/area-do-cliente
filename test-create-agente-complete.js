import https from 'https';

const testCreateAgenteComplete = () => {
  console.log('🧪 Testando webhook create-agente-complete:');
  
  const payload = JSON.stringify({
    action: 'create',
    agent_name: "Agente Teste Complete",
    agent_type: "agente-teste-complete",
    agent_id: "COMPLETE_123",
    user_id: "5",
    icone: "🤖",
    cor: "bg-green-500",
    descricao: "Teste do webhook complete"
  });

  const options = {
    hostname: 'n8n.code-iq.com.br',
    port: 443,
    path: '/webhook/create-agente-complete',
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
        console.log('❌ Resposta vazia');
        return;
      }
      
      try {
        const jsonResponse = JSON.parse(data);
        console.log('📄 Resposta (JSON):', JSON.stringify(jsonResponse, null, 2));
        
        if (jsonResponse.success) {
          console.log('✅ Sucesso! Webhook complete funcionando');
        } else {
          console.log('❌ Falha:', jsonResponse.message);
        }
      } catch (error) {
        console.log('❌ Não é JSON válido');
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

testCreateAgenteComplete();