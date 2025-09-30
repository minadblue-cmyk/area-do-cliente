// Teste do webhook list-agentes para validar todos os campos
// Executar com: node teste-webhook-list-agentes.js

import fetch from 'node-fetch';

async function testWebhookListAgentes() {
    console.log('🧪 TESTE: Webhook list-agentes');
    console.log('📍 URL: https://n8n.code-iq.com.br/webhook/list-agentes');
    console.log('⏰ Timestamp:', new Date().toISOString());
    console.log('━'.repeat(60));
    
    try {
        const response = await fetch('https://n8n.code-iq.com.br/webhook/list-agentes');
        
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        
        const data = await response.json();
        
        console.log('✅ STATUS: Sucesso');
        console.log('📊 RESPOSTA COMPLETA:');
        console.log(JSON.stringify(data, null, 2));
        
        console.log('\n🔍 VALIDAÇÃO DOS CAMPOS:');
        console.log('━'.repeat(40));
        
        // Validar estrutura básica
        const requiredFields = ['success', 'message', 'data', 'total', 'timestamp'];
        requiredFields.forEach(field => {
            const exists = data.hasOwnProperty(field);
            console.log(`${exists ? '✅' : '❌'} ${field}: ${exists ? 'OK' : 'FALTANDO'}`);
        });
        
        // Validar dados dos agentes
        if (data.data && Array.isArray(data.data) && data.data.length > 0) {
            const agent = data.data[0];
            console.log('\n🤖 CAMPOS DO AGENTE:');
            console.log('━'.repeat(30));
            
            const agentFields = [
                // Campos básicos
                'id', 'nome', 'descricao', 'icone', 'cor', 'ativo',
                'created_at', 'updated_at',
                
                // Workflow IDs
                'workflow_start_id', 'workflow_status_id', 
                'workflow_lista_id', 'workflow_stop_id',
                
                // Webhook URLs
                'webhook_start_url', 'webhook_status_url',
                'webhook_lista_url', 'webhook_stop_url',
                
                // Status de execução
                'status_atual', 'execution_id_ativo'
            ];
            
            agentFields.forEach(field => {
                const exists = agent.hasOwnProperty(field);
                const value = agent[field];
                const type = typeof value;
                console.log(`${exists ? '✅' : '❌'} ${field}: ${exists ? `${type} = ${JSON.stringify(value)}` : 'FALTANDO'}`);
            });
            
            // Validações específicas
            console.log('\n🎯 VALIDAÇÕES ESPECÍFICAS:');
            console.log('━'.repeat(30));
            
            // Verificar se tem webhooks específicos
            const hasSpecificWebhooks = !!(
                agent.webhook_start_url || 
                agent.webhook_stop_url || 
                agent.webhook_status_url || 
                agent.webhook_lista_url
            );
            console.log(`${hasSpecificWebhooks ? '✅' : '❌'} Webhooks específicos: ${hasSpecificWebhooks ? 'SIM' : 'NÃO'}`);
            
            // Verificar padrão dos webhooks
            const webhookPatterns = [
                { name: 'start', url: agent.webhook_start_url },
                { name: 'stop', url: agent.webhook_stop_url },
                { name: 'status', url: agent.webhook_status_url },
                { name: 'lista', url: agent.webhook_lista_url }
            ];
            
            webhookPatterns.forEach(({ name, url }) => {
                if (url) {
                    const expectedPattern = `webhook/${name}3-${agent.nome.toLowerCase()}`;
                    const matchesPattern = url === expectedPattern;
                    console.log(`${matchesPattern ? '✅' : '❌'} ${name}: ${url} ${matchesPattern ? '✓' : `(esperado: ${expectedPattern})`}`);
                } else {
                    console.log(`⚠️  ${name}: URL não encontrada`);
                }
            });
            
            // Verificar status
            console.log(`✅ Status atual: ${agent.status_atual || 'stopped'}`);
            console.log(`✅ Execution ID: ${agent.execution_id_ativo || 'null'}`);
            
        } else {
            console.log('❌ ERRO: Nenhum agente encontrado nos dados');
        }
        
        console.log('\n🎉 TESTE CONCLUÍDO COM SUCESSO!');
        
    } catch (error) {
        console.error('❌ ERRO NO TESTE:', error.message);
        console.error('📋 Detalhes:', error);
    }
}

// Executar teste
testWebhookListAgentes();
