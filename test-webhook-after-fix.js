import https from 'https';

const testWebhookAfterFix = () => {
  console.log('🧪 Testando webhook /webhook/create-agente após correção:');
  
  const payload = JSON.stringify({
    agent_name: "Agente Teste Fix",
    agent_type: "agente-teste-fix",
    agent_id: "TESTE_FIX_123",
    user_id: "5",
    icone: "🤖",
    cor: "bg-purple-500",
    descricao: "Teste após correção do webhook"
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
        console.log('❌ Resposta vazia');
        return;
      }
      
      // Verificar se é JSON válido
      try {
        const jsonResponse = JSON.parse(data);
        console.log('📄 Resposta (JSON válido):');
        console.log(JSON.stringify(jsonResponse, null, 2));
        
        // Verificar se tem a estrutura esperada
        if (jsonResponse.success && jsonResponse.agentId && jsonResponse.agentName) {
          console.log('✅ SUCESSO! Webhook corrigido - retorna JSON limpo');
          console.log('🎯 Agente criado:', jsonResponse.agentName);
          console.log('🆔 ID do Agente:', jsonResponse.agentId);
          console.log('🔗 Workflow ID:', jsonResponse.workflowId);
        } else if (jsonResponse.nodes && jsonResponse.connections) {
          console.log('❌ AINDA COM PROBLEMA - retorna definição do workflow');
          console.log('⚠️  O nó "Fix Response Payload" não foi implementado corretamente');
        } else {
          console.log('⚠️  Resposta inesperada:', jsonResponse);
        }
      } catch (error) {
        console.log('❌ Não é JSON válido');
        console.log('📄 Resposta (primeiros 200 chars):', data.substring(0, 200));
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

testWebhookAfterFix();
