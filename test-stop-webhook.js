// 🧪 TESTE DO WEBHOOK STOP
// Execute com: node test-stop-webhook.js

import https from 'https';

// Configurações do teste
const webhookUrl = 'https://n8n.code-iq.com.br/webhook/stop-agente1';
const testPayload = {
  action: 'stop',
  agent_type: 'eBcColwirndBaFZX',
  workflow_id: 'eBcColwirndBaFZX',
  execution_id: 'TESTE_' + Date.now(),
  timestamp: new Date().toISOString(),
  usuario_id: '5',
  logged_user: {
    id: '5',
    name: 'Teste User',
    email: 'teste@exemplo.com'
  }
};

console.log('🧪 TESTE DO WEBHOOK STOP');
console.log('========================');
console.log('');
console.log('📊 URL:', webhookUrl);
console.log('📊 Payload:', JSON.stringify(testPayload, null, 2));
console.log('');

// Função para fazer requisição HTTPS
function testWebhook() {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify(testPayload);
    
    const options = {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData),
        'User-Agent': 'Teste-Webhook-Stop/1.0'
      }
    };

    console.log('🚀 Enviando requisição...');
    
    const req = https.request(webhookUrl, options, (res) => {
      console.log('📥 Status:', res.statusCode);
      console.log('📥 Headers:', res.headers);
      
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        console.log('📥 Response Body:', data);
        
        try {
          const responseData = JSON.parse(data);
          console.log('📥 Parsed Response:', JSON.stringify(responseData, null, 2));
          
          if (responseData.success) {
            console.log('✅ SUCESSO: Webhook funcionando!');
            console.log('✅ Message:', responseData.message);
            console.log('✅ Execution ID:', responseData.execution_id);
          } else {
            console.log('❌ ERRO: Webhook retornou erro');
            console.log('❌ Message:', responseData.message);
          }
        } catch (e) {
          console.log('⚠️ AVISO: Resposta não é JSON válido');
          console.log('⚠️ Raw Response:', data);
        }
        
        resolve({
          status: res.statusCode,
          headers: res.headers,
          body: data
        });
      });
    });

    req.on('error', (error) => {
      console.log('❌ ERRO DE CONEXÃO:', error.message);
      reject(error);
    });

    req.write(postData);
    req.end();
  });
}

// Executar teste
testWebhook()
  .then((result) => {
    console.log('');
    console.log('🎯 RESULTADO DO TESTE:');
    console.log('======================');
    console.log('Status:', result.status);
    console.log('Sucesso:', result.status === 200);
    console.log('');
    
    if (result.status === 200) {
      console.log('✅ WEBHOOK STOP FUNCIONANDO!');
      console.log('✅ Pronto para uso em produção');
    } else {
      console.log('❌ WEBHOOK STOP COM PROBLEMAS');
      console.log('❌ Verificar configuração no n8n');
    }
  })
  .catch((error) => {
    console.log('');
    console.log('❌ ERRO NO TESTE:');
    console.log('=================');
    console.log('Erro:', error.message);
    console.log('');
    console.log('🔧 POSSÍVEIS CAUSAS:');
    console.log('• Webhook não está ativo');
    console.log('• URL incorreta');
    console.log('• Problema de rede');
    console.log('• Workflow não configurado');
  });
