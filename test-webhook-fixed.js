import https from 'https';

const testWebhookFixed = () => {
  console.log('🔍 Testando webhook create-agente-fixed...\n');

  const payload = JSON.stringify({
    action: 'create',
    agent_name: 'Agente Teste Fixed',
    agent_type: 'agenteTesteFixed',
    agent_id: 'TESTE_FIXED_123456789',
    user_id: '1'
  });

  const options = {
    hostname: 'n8n.code-iq.com.br',
    port: 443,
    path: '/webhook/create-agente-fixed',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(payload)
    }
  };

  console.log('📤 Payload enviado:', JSON.parse(payload));
  console.log('🔗 URL: https://n8n.code-iq.com.br/webhook/create-agente-fixed\n');

  const req = https.request(options, (res) => {
    console.log(`📊 Status: ${res.statusCode} ${res.statusMessage}`);
    console.log('📋 Headers de resposta:', res.headers);

    let data = '';
    res.on('data', (chunk) => {
      data += chunk;
      console.log('📥 Chunk recebido:', chunk.toString());
    });

    res.on('end', () => {
      console.log('\n✅ Resposta completa recebida');
      console.log(`📏 Tamanho total: ${data.length}`);
      console.log('📄 Conteúdo:', data);

      try {
        const jsonResponse = JSON.parse(data);
        console.log('\n📋 JSON parseado:', JSON.stringify(jsonResponse, null, 2));
        
        if (jsonResponse.success) {
          console.log('\n🎉 SUCESSO! Webhook funcionando!');
          console.log(`📊 Workflows criados: ${jsonResponse.statistics?.successful || 0}/${jsonResponse.statistics?.total || 0}`);
        } else {
          console.log('\n❌ Falha no webhook');
        }
      } catch (error) {
        console.log('\n⚠️ Erro ao parsear JSON:', error.message);
      }
    });
  });

  req.on('error', (error) => {
    console.error('❌ Erro na requisição:', error.message);
  });

  req.write(payload);
  req.end();
};

testWebhookFixed();

