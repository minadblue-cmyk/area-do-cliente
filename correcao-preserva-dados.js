// === CÓDIGO CORRIGIDO PARA "Preserva Dados" ===

// CORREÇÃO: Garantir que os dados do lead sejam preservados corretamente
const dadosDoLoop = $('Loop').item || {};

console.log("=== PRESERVANDO DADOS DO LEAD ===");
console.log("Dados recebidos do Loop:", dadosDoLoop);

// Garantir que todos os campos necessários estejam presentes
const dadosCompletos = {
  // Campos básicos do lead
  id: dadosDoLoop.id || dadosDoLoop.json?.id,
  client_id: dadosDoLoop.client_id || dadosDoLoop.json?.client_id,
  nome_cliente: dadosDoLoop.nome_cliente || dadosDoLoop.nome || dadosDoLoop.json?.nome_cliente || dadosDoLoop.json?.nome,
  telefone: dadosDoLoop.telefone || dadosDoLoop.json?.telefone,
  canal: dadosDoLoop.canal || dadosDoLoop.json?.canal,
  status: dadosDoLoop.status || dadosDoLoop.json?.status,
  
  // Campos de personalização
  profissao: dadosDoLoop.profissao || dadosDoLoop.json?.profissao,
  idade: dadosDoLoop.idade || dadosDoLoop.json?.idade,
  estado_civil: dadosDoLoop.estado_civil || dadosDoLoop.json?.estado_civil,
  filhos: dadosDoLoop.filhos || dadosDoLoop.json?.filhos,
  qtd_filhos: dadosDoLoop.qtd_filhos || dadosDoLoop.json?.qtd_filhos,
  
  // Campos de fonte
  fonte_prospec: dadosDoLoop.fonte_prospec || dadosDoLoop.json?.fonte_prospec,
  utm_source: dadosDoLoop.utm_source || dadosDoLoop.json?.utm_source,
  
  // Campos de controle
  posicao_lote: dadosDoLoop.posicao_lote || dadosDoLoop.json?.posicao_lote,
  permitido: dadosDoLoop.permitido || dadosDoLoop.json?.permitido,
  turno: dadosDoLoop.turno || dadosDoLoop.json?.turno,
  
  // Campos de data
  data_criacao: dadosDoLoop.data_criacao || dadosDoLoop.json?.data_criacao,
  data_ultima_interacao: dadosDoLoop.data_ultima_interacao || dadosDoLoop.json?.data_ultima_interacao,
  
  // Campos de reserva
  reservado_por: dadosDoLoop.reservado_por || dadosDoLoop.json?.reservado_por,
  reservado_lote: dadosDoLoop.reservado_lote || dadosDoLoop.json?.reservado_lote,
  reservado_em: dadosDoLoop.reservado_em || dadosDoLoop.json?.reservado_em,
  
  // Dados originais completos
  dados_originais: dadosDoLoop
};

console.log("Dados completos preservados:", dadosCompletos);

return [{
  json: {
    dados_do_lead: dadosCompletos
  }
}];
