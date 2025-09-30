// CÓDIGO CORRIGIDO PARA O NÓ "PROCESSAR RESULTADO"

// Processar resultado da edição
const perfilAtualizado = $('Atualizar Perfil').item.json;
const permissoesInseridas = $input.all();

console.log('✅ Perfil atualizado:', perfilAtualizado);
console.log('✅ Permissões inseridas:', permissoesInseridas.length);

// Buscar os IDs das permissões que foram inseridas
let permissaoIds = [];

if (permissoesInseridas && permissoesInseridas.length > 0) {
  permissaoIds = permissoesInseridas.map(p => {
    if (p.json && p.json.permissao_id) {
      return p.json.permissao_id;
    }
    return null;
  }).filter(id => id !== null);
} else {
  // Se não há permissões inseridas, buscar do nó "Normalizar Dados"
  const dadosNormalizados = $('Normalizar Dados').item.json;
  if (dadosNormalizados && dadosNormalizados.permissoes) {
    permissaoIds = dadosNormalizados.permissoes;
  }
}

console.log('✅ IDs das permissões:', permissaoIds);

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
