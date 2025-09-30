import https from 'https';

const testSimpleWorkflowCreation = async () => {
  console.log('🧪 Teste de criação simples de workflow...\n');

  const workflowData = {
    name: 'Teste Simples - ' + new Date().toISOString(),
    nodes: [
      {
        id: 'manual-trigger',
        name: 'Manual Trigger',
        type: 'n8n-nodes-base.manualTrigger',
        typeVersion: 1,
        position: [100, 100],
        parameters: {}
      }
    ],
    connections: {},
    active: false,
    settings: {},
    tags: ['teste']
  };

  const postData = JSON.stringify(workflowData);

  const options = {
    hostname: 'n8n.code-iq.com.br',
    port: 443,
    path: '/api/v1/workflows',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(postData)
    }
  };

  console.log('📤 Enviando dados:', JSON.stringify(workflowData, null, 2));
  console.log('🔗 URL:', `https://${options.hostname}${options.path}`);

  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      console.log(`\n📊 Status: ${res.statusCode} ${res.statusMessage}`);
      console.log('📋 Headers:', res.headers);

      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
        console.log('📥 Chunk recebido:', chunk.toString());
      });

      res.on('end', () => {
        console.log('\n✅ Resposta completa recebida');
        console.log('📏 Tamanho total:', data.length);
        console.log('📄 Conteúdo:', data || '(vazio)');
        
        if (data) {
          try {
            const parsed = JSON.parse(data);
            console.log('📋 JSON parseado:', JSON.stringify(parsed, null, 2));
            
            if (parsed.id) {
              console.log('✅ Workflow criado com sucesso! ID:', parsed.id);
            } else {
              console.log('⚠️ Workflow não retornou ID');
            }
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

testSimpleWorkflowCreation().catch(console.error);

