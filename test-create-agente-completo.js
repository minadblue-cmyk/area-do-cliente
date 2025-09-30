import https from 'https';

const testCreateAgente = () => {
  console.log('🧪 Testando webhook create-agente completo:');
  
  const payload = JSON.stringify({
    agent_name: "Agente SDR - Teste",
    agent_type: "agente-teste",
    agent_id: "TESTE123",
    user_id: "5",
    icone: "🤖",
    cor: "bg-green-500",
    descricao: "Agente de teste para validação"
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
          console.log('✅ Sucesso! Agente criado:', jsonResponse.agentName);
          console.log('📊 Workflows criados:', jsonResponse.workflowsCreated);
        } else {
          console.log('❌ Falha na criação:', jsonResponse.message);
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

testCreateAgente();
