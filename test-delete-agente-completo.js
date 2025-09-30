import https from 'https';

const testDeleteAgente = () => {
  console.log('🧪 Testando webhook delete-agente completo:');
  
  const payload = JSON.stringify({
    id: "AGENTE_2",
    agent_name: "Agente SDR - 2",
    logged_user: {
      id: "5",
      name: "Sistema",
      email: "sistema@teste.com"
    }
  });

  const options = {
    hostname: 'n8n.code-iq.com.br',
    port: 443,
    path: '/webhook/delete-agente',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(payload),
      'Origin': 'http://localhost:5173',
      'Access-Control-Request-Method': 'POST',
      'Access-Control-Request-Headers': 'Content-Type'
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
      console.log('📄 Resposta (texto):', data);
      
      try {
        const jsonResponse = JSON.parse(data);
        console.log('📄 Resposta (JSON):', JSON.stringify(jsonResponse, null, 2));
        
        if (jsonResponse.success) {
          console.log('✅ Sucesso! Agente deletado:', jsonResponse.agentName);
        } else {
          console.log('❌ Falha na deleção:', jsonResponse.message);
        }
      } catch (error) {
        console.log('❌ Erro ao parsear JSON:', error.message);
      }
    });
  });

  req.on('error', (error) => {
    console.error('❌ Erro na requisição:', error.message);
  });

  req.write(payload);
  req.end();
};

testDeleteAgente();
