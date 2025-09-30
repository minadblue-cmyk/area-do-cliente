// CÓDIGO CORRIGIDO PARA O NÓ "PREPARAR PERMISSÕES" - VERSÃO 2

// Tentar diferentes formas de acessar os dados
console.log('🔍 Tentando acessar dados do webhook...');

// Método 1: Acessar diretamente do webhook
try {
  const webhookData = $('Webhook Edit Profile').item.json;
  console.log('✅ Dados do webhook (método 1):', webhookData);
  
  if (webhookData && webhookData.permissoes) {
    const permissoes = webhookData.permissoes;
    console.log('✅ Permissões encontradas (método 1):', permissoes);
    
    if (permissoes.length > 0) {
      const permissoesParaInserir = permissoes.map(permissaoId => ({
        json: {
          perfil_id: webhookData.id,
          permissao_id: permissaoId
        }
      }));
      
      console.log('✅ Permissões preparadas para inserção:', permissoesParaInserir.length);
      return permissoesParaInserir;
    }
  }
} catch (error) {
  console.log('❌ Erro no método 1:', error.message);
}

// Método 2: Acessar via $input
try {
  const inputData = $input.all();
  console.log('✅ Dados de entrada (método 2):', inputData);
  
  if (inputData && inputData.length > 0) {
    const firstItem = inputData[0];
    console.log('✅ Primeiro item:', firstItem);
    
    if (firstItem.json && firstItem.json.permissoes) {
      const permissoes = firstItem.json.permissoes;
      console.log('✅ Permissões encontradas (método 2):', permissoes);
      
      if (permissoes.length > 0) {
        const permissoesParaInserir = permissoes.map(permissaoId => ({
          json: {
            perfil_id: firstItem.json.id,
            permissao_id: permissaoId
          }
        }));
        
        console.log('✅ Permissões preparadas para inserção:', permissoesParaInserir.length);
        return permissoesParaInserir;
      }
    }
  }
} catch (error) {
  console.log('❌ Erro no método 2:', error.message);
}

// Método 3: Acessar via $json
try {
  const jsonData = $json;
  console.log('✅ Dados JSON (método 3):', jsonData);
  
  if (jsonData && jsonData.permissoes) {
    const permissoes = jsonData.permissoes;
    console.log('✅ Permissões encontradas (método 3):', permissoes);
    
    if (permissoes.length > 0) {
      const permissoesParaInserir = permissoes.map(permissaoId => ({
        json: {
          perfil_id: jsonData.id,
          permissao_id: permissaoId
        }
      }));
      
      console.log('✅ Permissões preparadas para inserção:', permissoesParaInserir.length);
      return permissoesParaInserir;
    }
  }
} catch (error) {
  console.log('❌ Erro no método 3:', error.message);
}

// Se chegou até aqui, não encontrou permissões
console.log('⚠️ Nenhuma permissão encontrada em nenhum método');
console.log('🔍 Dados disponíveis:', {
  webhook: $('Webhook Edit Profile')?.item?.json,
  input: $input.all(),
  json: $json
});

// Retornar array vazio para não quebrar o fluxo
return [];
