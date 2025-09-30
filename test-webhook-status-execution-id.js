// Teste para verificar se o webhook de status retorna execution_id
import axios from 'axios';

async function testWebhookStatus() {
  try {
    console.log('🔍 Testando webhook de status para verificar execution_id...');
    
    // URL do webhook de status (substitua pelo seu agente)
    const webhookUrl = 'https://n8n.code-iq.com.br/webhook/status-59';
    
    // Parâmetros necessários
    const params = {
      workflow_id: '59', // ID do agente
      usuario_id: '5'    // ID do usuário
    };
    
    console.log('📡 Fazendo requisição GET para:', webhookUrl);
    console.log('📦 Parâmetros:', params);
    
    const response = await axios.get(webhookUrl, {
      params: params,
      timeout: 10000
    });
    
    console.log('✅ Status da resposta:', response.status);
    console.log('📥 Dados recebidos:', JSON.stringify(response.data, null, 2));
    
    // Verificar se execution_id está presente
    const data = response.data;
    console.log('\n🔍 ANÁLISE DOS DADOS:');
    console.log('Tipo de dados:', typeof data);
    console.log('É array?', Array.isArray(data));
    
    if (data) {
      const responseData = Array.isArray(data) ? data[0] : data;
      console.log('\n📊 CAMPOS DISPONÍVEIS:');
      console.log('execution_id:', responseData?.execution_id);
      console.log('executionId:', responseData?.executionId);
      console.log('execution_id_ativo:', responseData?.execution_id_ativo);
      console.log('status:', responseData?.status);
      console.log('status_atual:', responseData?.status_atual);
      console.log('workflow_id:', responseData?.workflow_id);
      console.log('usuario_id:', responseData?.usuario_id);
      
      // Verificar se há execution_id em qualquer campo
      const executionId = responseData?.execution_id || 
                         responseData?.executionId || 
                         responseData?.execution_id_ativo;
      
      if (executionId) {
        console.log('\n✅ EXECUTION_ID ENCONTRADO:', executionId);
      } else {
        console.log('\n❌ EXECUTION_ID NÃO ENCONTRADO');
        console.log('Todos os campos disponíveis:', Object.keys(responseData || {}));
      }
    } else {
      console.log('\n❌ DADOS VAZIOS OU NULL');
    }
    
  } catch (error) {
    console.error('❌ Erro no teste:', error.message);
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Dados:', error.response.data);
    }
  }
}

// Executar teste
testWebhookStatus();
