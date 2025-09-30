import https from 'https';

const testWebhookDetailedDebug = () => {
  console.log('🔍 Teste detalhado do webhook /webhook/create-agente:');
  
  const payload = JSON.stringify({
    agent_name: "Agente Teste Debug",
    agent_type: "agente-teste-debug",
    agent_id: "DEBUG_123",
    user_id: "5",
    icone: "🤖",
    cor: "bg-red-500",
    descricao: "Teste detalhado para debug"
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
      console.log(`📦 Chunk ${chunks} (${chunk.length} bytes):`, chunk.toString().substring(0, 100) + (chunk.length > 100 ? '...' : ''));
    });

    res.on('end', () => {
      console.log('✅ Resposta completa:');
      console.log('📄 Tamanho total:', data.length, 'bytes');
      console.log('📄 Número de chunks:', chunks);
      
      if (data.length === 0) {
        console.log('❌ Resposta vazia - possível problema no workflow');
        console.log('🔍 Verificações necessárias:');
        console.log('  1. Workflow está ativo?');
        console.log('  2. Webhook está configurado corretamente?');
        console.log('  3. Há erros na execução do workflow?');
        return;
      }
      
      // Verificar se é JSON válido
      try {
        const jsonResponse = JSON.parse(data);
        console.log('📄 Resposta (JSON válido):');
        console.log(JSON.stringify(jsonResponse, null, 2));
        
        // Verificar estrutura da resposta
        if (jsonResponse.success && jsonResponse.agentId && jsonResponse.agentName) {
          console.log('✅ SUCESSO! Webhook funcionando corretamente');
          console.log('🎯 Agente criado:', jsonResponse.agentName);
          console.log('🆔 ID do Agente:', jsonResponse.agentId);
          console.log('🔗 Workflow ID:', jsonResponse.workflowId);
          console.log('🌐 Webhook URL:', jsonResponse.webhookUrl);
        } else if (jsonResponse.nodes && jsonResponse.connections) {
          console.log('❌ AINDA COM PROBLEMA - retorna definição do workflow');
          console.log('⚠️  O workflow não foi atualizado com as correções');
        } else {
          console.log('⚠️  Resposta inesperada:', jsonResponse);
        }
      } catch (error) {
        console.log('❌ Não é JSON válido');
        console.log('📄 Resposta (primeiros 200 chars):', data.substring(0, 200));
        console.log('📄 Resposta (hex):', Buffer.from(data).toString('hex').substring(0, 100));
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

  req.setTimeout(30000);
  req.write(payload);
  req.end();
};

testWebhookDetailedDebug();
