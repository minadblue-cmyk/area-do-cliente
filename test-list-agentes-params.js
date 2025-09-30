// Script de teste para webhook list-agentes com parâmetros
import https from 'https';

const testParams = [
  { name: 'Sem parâmetros', path: '/webhook/list-agentes' },
  { name: 'Com ativo=true', path: '/webhook/list-agentes?ativo=true' },
  { name: 'Com ativo=false', path: '/webhook/list-agentes?ativo=false' },
  { name: 'Com usuario_id=5', path: '/webhook/list-agentes?usuario_id=5' },
  { name: 'Com ambos parâmetros', path: '/webhook/list-agentes?ativo=true&usuario_id=5' }
];

async function testWebhook(testCase) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'n8n.code-iq.com.br',
      port: 443,
      path: testCase.path,
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    };

    console.log(`\n🧪 ${testCase.name}:`);
    console.log(`URL: https://${options.hostname}${options.path}`);

    const req = https.request(options, (res) => {
      console.log(`📡 Status: ${res.statusCode}`);
      
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        try {
          const jsonData = JSON.parse(data);
          console.log('📥 Resposta:', JSON.stringify(jsonData, null, 2));
          resolve({ testCase, status: res.statusCode, data: jsonData });
        } catch (e) {
          console.log('📄 Resposta (texto):', data);
          resolve({ testCase, status: res.statusCode, data: data });
        }
      });
    });

    req.on('error', (e) => {
      console.error('❌ Erro:', e.message);
      reject(e);
    });

    req.end();
  });
}

async function runTests() {
  console.log('🚀 Iniciando testes do webhook list-agentes...\n');
  
  for (const testCase of testParams) {
    try {
      await testWebhook(testCase);
      // Aguardar 1 segundo entre testes
      await new Promise(resolve => setTimeout(resolve, 1000));
    } catch (error) {
      console.error(`❌ Erro no teste ${testCase.name}:`, error.message);
    }
  }
  
  console.log('\n✅ Testes concluídos!');
}

runTests();
