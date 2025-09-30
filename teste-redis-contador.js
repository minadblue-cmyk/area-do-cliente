// Teste prático para simular comportamento do Redis Counter

// Simular Redis em memória
const redisSimulado = {
  contadores: {},
  
  // Simular operação INCREMENT do Redis
  increment: function(key, value = 1) {
    if (!this.contadores[key]) {
      this.contadores[key] = 0;
    }
    this.contadores[key] += value;
    return this.contadores[key];
  },
  
  // Simular operação GET do Redis
  get: function(key) {
    return this.contadores[key] || 0;
  },
  
  // Listar todos os contadores
  listar: function() {
    return this.contadores;
  }
};

// Função para testar criação de agente
function testarCriacaoAgente(agentType) {
  console.log(`\n🤖 Testando criação de agente: ${agentType}`);
  
  // Simular incremento do contador global
  const contadorGlobal = redisSimulado.increment('agente_counter_global');
  
  console.log(`📊 Contador global: ${contadorGlobal}`);
  
  // Simular criação dos 4 workflows com contadores únicos
  const workflows = [
    { tipo: 'start', templateId: 'eBcColwirndBaFZX' },
    { tipo: 'status', templateId: 'ZWeNlGbLyv0HkXvq' },
    { tipo: 'lista', templateId: 'piyABVIDxK9OoLYB' },
    { tipo: 'stop', templateId: 'wBDZdXsfY8GYYUYg' }
  ];
  
  const resultados = workflows.map(workflow => {
    const contador = redisSimulado.increment(`${agentType}:${workflow.tipo}`);
    
    return {
      tipo: workflow.tipo,
      contador: contador,
      nome: `Agente SDR - ${workflow.tipo.charAt(0).toUpperCase() + workflow.tipo.slice(1)}-${contador}`,
      webhookPath: `${workflow.tipo}${contador}-${agentType}`,
      templateId: workflow.templateId
    };
  });
  
  console.log("🏗️ Workflows criados:");
  resultados.forEach(resultado => {
    console.log(`   ${resultado.tipo}: ${resultado.nome} (webhook: ${resultado.webhookPath})`);
  });
  
  return {
    agentType: agentType,
    contadorGlobal: contadorGlobal,
    workflows: resultados
  };
}

// Executar testes
console.log("🧪 Teste Prático - Redis Counter Simulado\n");

// Teste 1: Primeiro agente
const resultado1 = testarCriacaoAgente('vendas-premium');

// Teste 2: Segundo agente
const resultado2 = testarCriacaoAgente('suporte-tecnico');

// Teste 3: Terceiro agente
const resultado3 = testarCriacaoAgente('marketing-digital');

console.log("\n📊 Estado final dos contadores Redis:");
console.log(JSON.stringify(redisSimulado.listar(), null, 2));

console.log("\n✅ Teste concluído! Dados prontos para usar no N8N.");

// Exportar para uso no N8N
module.exports = {
  redisSimulado,
  testarCriacaoAgente,
  dadosExemplo: {
    payload: {
      agent_name: "Agente Teste",
      agent_type: "agente-teste",
      agent_id: "TESTE_001",
      user_id: "1",
      icone: "🤖",
      cor: "bg-blue-500"
    },
    contadorEsperado: 1,
    workflowsEsperados: [
      { tipo: "start", contador: 1, nome: "Agente SDR - Start-1" },
      { tipo: "status", contador: 1, nome: "Agente SDR - Status-1" },
      { tipo: "lista", contador: 1, nome: "Agente SDR - Lista-1" },
      { tipo: "stop", contador: 1, nome: "Agente SDR - Stop-1" }
    ]
  }
};
