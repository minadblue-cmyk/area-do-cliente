// CÓDIGO CORRIGIDO PARA O NÓ "PREPARAR PERMISSÕES"

// Obter dados do webhook (dados originais enviados pelo frontend)
const webhookData = $('Webhook Edit Profile').item.json;

console.log('✅ Dados do webhook:', webhookData);

// Extrair as permissões dos dados originais
const permissoes = webhookData.permissoes || [];

console.log('✅ Permissões encontradas:', permissoes);

if (!permissoes || permissoes.length === 0) {
  console.log('⚠️ Nenhuma permissão para inserir');
  return [];
}

// Criar array de objetos para inserção em lote
const permissoesParaInserir = permissoes.map(permissaoId => ({
  json: {
    perfil_id: webhookData.id,
    permissao_id: permissaoId
  }
}));

console.log('✅ Permissões preparadas para inserção:', permissoesParaInserir.length);

return permissoesParaInserir;
