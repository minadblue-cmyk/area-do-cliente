import https from 'https';

const testN8nAPIDirect = async () => {
  console.log('🧪 Teste direto da API do n8n...\n');

  // Teste 1: Listar workflows existentes
  console.log('📋 Teste 1: Listar workflows existentes');
  const listWorkflows = () => {
    return new Promise((resolve, reject) => {
      const options = {
        hostname: 'n8n.code-iq.com.br',
        port: 443,
        path: '/api/v1/workflows',
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_KEY_HERE' // Substitua pela sua API key
        }
      };

      const req = https.request(options, (res) => {
        let data = '';
        res.on('data', (chunk) => data += chunk);
        res.on('end', () => {
          console.log(`Status: ${res.statusCode}`);
          if (data) {
            try {
              const parsed = JSON.parse(data);
              console.log(`Workflows encontrados: ${parsed.data?.length || 0}`);
              resolve(parsed);
            } catch (e) {
              console.log('Resposta não é JSON:', data);
              resolve(null);
            }
          } else {
            console.log('Resposta vazia');
            resolve(null);
          }
        });
      });

      req.on('error', reject);
      req.end();
    });
  };

  // Teste 2: Criar um workflow simples
  console.log('\n📋 Teste 2: Criar workflow simples');
  const createWorkflow = () => {
    return new Promise((resolve, reject) => {
      const workflowData = {
        name: 'Teste API - ' + new Date().toISOString(),
        nodes: [
          {
            id: 'test-node',
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
        tags: ['teste', 'api']
      };

      const postData = JSON.stringify(workflowData);

      const options = {
        hostname: 'n8n.code-iq.com.br',
        port: 443,
        path: '/api/v1/workflows',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(postData),
          'Authorization': 'Bearer YOUR_API_KEY_HERE' // Substitua pela sua API key
        }
      };

      const req = https.request(options, (res) => {
        let data = '';
        res.on('data', (chunk) => data += chunk);
        res.on('end', () => {
          console.log(`Status: ${res.statusCode}`);
          console.log('Headers:', res.headers);
          if (data) {
            try {
              const parsed = JSON.parse(data);
              console.log('Workflow criado:', parsed);
              resolve(parsed);
            } catch (e) {
              console.log('Resposta não é JSON:', data);
              resolve(null);
            }
          } else {
            console.log('Resposta vazia');
            resolve(null);
          }
        });
      });

      req.on('error', reject);
      req.write(postData);
      req.end();
    });
  };

  try {
    console.log('⚠️ IMPORTANTE: Substitua YOUR_API_KEY_HERE pela sua API key real do n8n');
    console.log('📝 Para obter a API key: n8n > Settings > API Keys > Create API Key\n');
    
    // await listWorkflows();
    // await createWorkflow();
    
    console.log('🔧 Para testar, descomente as linhas acima e adicione sua API key');
    
  } catch (error) {
    console.error('❌ Erro:', error);
  }
};

testN8nAPIDirect().catch(console.error);

