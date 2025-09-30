// CÓDIGO CORRIGIDO PARA O NÓ "PREPARAR PERMISSÕES" - VERSÃO 3

// Acessar dados do webhook diretamente
const webhookData = $('Webhook Edit Profile').item.json;

console.log('✅ Dados do webhook:', webhookData);

// Extrair as permissões
const permissoes = webhookData.permissoes || [];

console.log('✅ Permissões encontradas:', permissoes);
console.log('✅ Tipo das permissões:', typeof permissoes);
console.log('✅ É array?', Array.isArray(permissoes));

if (!permissoes || permissoes.length === 0) {
  console.log('⚠️ Nenhuma permissão para inserir');
  return [];
}

// Criar UM item para cada permissão (não um array de objetos)
const resultados = [];

for (let i = 0; i < permissoes.length; i++) {
  const permissaoId = permissoes[i];
  
  console.log(`✅ Criando item ${i + 1}: perfil_id=${webhookData.id}, permissao_id=${permissaoId}`);
  
  resultados.push({
    json: {
      perfil_id: webhookData.id,
      permissao_id: permissaoId
    }
  });
}

console.log('✅ Total de itens criados:', resultados.length);
console.log('✅ Primeiro item:', resultados[0]);

return resultados;
