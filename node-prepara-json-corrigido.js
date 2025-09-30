// Node: Prepara Json - CORRIGIDO para novos campos da query
// Processar agentes do banco

const agentes = $input.all();

console.log('📋 Agentes encontrados:', agentes.length);

// Mapear para o formato esperado pelo frontend
const agentesFormatados = agentes.map(item => {
  const data = item.json;
  
  return {
    // Campos básicos
    id: data.id,
    nome: data.nome,
    descricao: data.descricao,
    icone: data.icone || '🤖',
    cor: data.cor || 'bg-blue-500',
    ativo: data.ativo,
    created_at: data.created_at,
    updated_at: data.updated_at,
    
    // Workflow IDs (para referência)
    workflow_start_id: data.workflow_start_id,
    workflow_status_id: data.workflow_status_id,
    workflow_lista_id: data.workflow_lista_id,
    workflow_stop_id: data.workflow_stop_id,
    
    // Webhook URLs específicos (o que realmente importa)
    webhook_start_url: data.webhook_start_url,
    webhook_status_url: data.webhook_status_url,
    webhook_lista_url: data.webhook_lista_url,
    webhook_stop_url: data.webhook_stop_url,
    
    // Status de execução
    status_atual: data.status_atual,
    execution_id_ativo: data.execution_id_ativo
  };
});

console.log('✅ Agentes formatados:', agentesFormatados.length);

// Log para debug - mostrar estrutura de um agente
if (agentesFormatados.length > 0) {
  console.log('📊 Exemplo de agente formatado:', JSON.stringify(agentesFormatados[0], null, 2));
}

// ✅ CORREÇÃO: Retornar diretamente o objeto, não dentro de 'json'
return {
  success: true,
  message: 'Agentes encontrados',
  data: agentesFormatados,  // ← Array de objetos estruturados
  total: agentesFormatados.length,
  timestamp: new Date().toISOString()
};
