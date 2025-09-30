// === CÓDIGO CORRIGIDO PARA "Filtro de Mensagens Permitidas" ===

const NOME_FONTE = 'Verificador de Limite de Mensagens';
const MAX = 20;

// 1) Pega TODOS os leads diretamente do nó-fonte
const leads = $(NOME_FONTE).all().map(it => it.json || it);

// 2) Pega o contador atual
const usadoPreferencial = Number($('Normaliza Contador').item?.json?.contadorAtual ?? NaN);
const usadoFallback = Number($input.first()?.json?.contadorAtual ?? 0);
const usados = Number.isFinite(usadoPreferencial) ? usadoPreferencial : usadoFallback;

// 3) Calcula quantos ainda podem sair
const restantes = Math.max(0, MAX - (usados || 0));

console.log(`=== FILTRO DEBUG ===`);
console.log(`Total leads: ${leads.length}, Usados: ${usados}, Restantes: ${restantes}`);

// 4) RETORNA TODOS OS LEADS COM FLAGS - não filtra aqui!
// O IF fará a separação depois
return leads.map((lead, idx) => {
  // CORREÇÃO: Garantir que todos os campos necessários estejam presentes
  const leadCompleto = {
    // Campos básicos
    id: lead.id,
    client_id: lead.client_id || lead.clientId || 0,
    nome_cliente: lead.nome_cliente || lead.nome || lead.name,
    telefone: lead.telefone,
    canal: lead.canal,
    status: lead.status,
    
    // Campos de personalização
    profissao: lead.profissao,
    idade: lead.idade,
    estado_civil: lead.estado_civil,
    filhos: lead.filhos,
    qtd_filhos: lead.qtd_filhos,
    
    // Campos de fonte
    fonte_prospec: lead.fonte_prospec,
    utm_source: lead.utm_source,
    
    // Campos de data
    data_criacao: lead.data_criacao,
    data_ultima_interacao: lead.data_ultima_interacao,
    
    // Campos de reserva
    reservado_por: lead.reservado_por,
    reservado_lote: lead.reservado_lote,
    reservado_em: lead.reservado_em,
    
    // Campos de controle do filtro
    restantes,
    permitido: idx < restantes, // true para os primeiros X leads
    posicao_lote: idx,
    motivo: idx >= restantes ? "Limite de mensagens atingido para este turno" : null,
    contador_atual: usados,
    
    // Campos do verificador de limite
    turno: lead.turno,
    chaveRedis: lead.chaveRedis,
    ttlSegundos: lead.ttlSegundos,
    
    // Dados originais
    ...lead
  };

  console.log(`Lead ${idx}: ${leadCompleto.nome_cliente} - Permitido: ${leadCompleto.permitido}`);
  
  return {
    json: leadCompleto
  };
});
