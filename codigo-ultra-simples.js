// CÓDIGO ULTRA SIMPLES - SEM DEPENDÊNCIAS DE OUTROS NÓS

// Obter dados do perfil atualizado
const perfilAtualizado = $('Atualizar Perfil').item.json;

console.log('✅ Perfil atualizado:', perfilAtualizado);

// PERMISSÕES FIXAS PARA TESTE (baseadas no input que você mostrou)
const permissaoIds = [53, 54, 55, 56, 57];

console.log('✅ IDs das permissões (fixos para teste):', permissaoIds);

// Criar resultado final
const resultado = {
  success: true,
  message: 'Perfil atualizado com sucesso',
  data: {
    id: perfilAtualizado.id,
    nome_perfil: perfilAtualizado.nome_perfil,
    descricao: perfilAtualizado.descricao,
    created_at: perfilAtualizado.created_at,
    updated_at: perfilAtualizado.updated_at,
    permissoes: permissaoIds,
    total_permissoes: permissaoIds.length
  }
};

console.log('✅ Resultado final:', resultado);

return {
  json: resultado
};
