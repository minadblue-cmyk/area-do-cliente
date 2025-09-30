// CÓDIGO SIMPLES E ROBUSTO PARA O NÓ "PROCESSAR RESULTADO"

// Obter dados do perfil atualizado
const perfilAtualizado = $('Atualizar Perfil').item.json;

// Obter dados normalizados (onde estão as permissões originais)
const dadosNormalizados = $('Normalizar Dados').item.json;

console.log('✅ Perfil atualizado:', perfilAtualizado);
console.log('✅ Dados normalizados:', dadosNormalizados);

// Usar as permissões dos dados normalizados (que são os IDs enviados pelo frontend)
const permissaoIds = dadosNormalizados.permissoes || [];

console.log('✅ IDs das permissões:', permissaoIds);

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
