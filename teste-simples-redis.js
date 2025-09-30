// Teste simples para gerar dados de exemplo para o fluxo N8N

const dadosExemplo = {
  // Dados que o frontend enviaria para o webhook
  payloadFrontend: {
    agent_name: "Agente Vendas Premium",
    agent_type: "vendas-premium",
    agent_id: "VENDA_PREMIUM_001",
    user_id: "5",
    icone: "💼",
    cor: "bg-green-500",
    descricao: "Agente para vendas premium"
  },

  // Dados após normalização
  dadosNormalizados: {
    agentName: "Agente Vendas Premium",
    agentType: "vendas-premium", 
    agentId: "VENDA_PREMIUM_001",
    userId: "5",
    icone: "💼",
    cor: "bg-green-500"
  },

  // Simulação de contadores Redis
  contadoresRedis: {
    global: 1,
    start: 1,
    status: 2,
    lista: 3,
    stop: 4
  },

  // Resultado esperado dos workflows
  workflowsCriados: [
    {
      id: "workflow-start-001",
      name: "Agente SDR - Start-1",
      webhookType: "start",
      counter: 1,
      webhookPath: "start1-vendas-premium"
    },
    {
      id: "workflow-status-002", 
      name: "Agente SDR - Status-2",
      webhookType: "status",
      counter: 2,
      webhookPath: "status2-vendas-premium"
    },
    {
      id: "workflow-lista-003",
      name: "Agente SDR - Lista-3", 
      webhookType: "lista",
      counter: 3,
      webhookPath: "lista3-vendas-premium"
    },
    {
      id: "workflow-stop-004",
      name: "Agente SDR - Stop-4",
      webhookType: "stop", 
      counter: 4,
      webhookPath: "stop4-vendas-premium"
    }
  ],

  // Resposta final do webhook
  respostaFinal: {
    success: true,
    message: "4 workflows criados com sucesso",
    agentName: "Agente Vendas Premium",
    agentType: "vendas-premium",
    agentId: "VENDA_PREMIUM_001",
    workflows: [
      {
        id: "workflow-start-001",
        name: "Agente SDR - Start-1",
        webhookType: "start",
        counter: 1,
        webhookPath: "start1-vendas-premium",
        status: "ativo"
      },
      {
        id: "workflow-status-002",
        name: "Agente SDR - Status-2", 
        webhookType: "status",
        counter: 2,
        webhookPath: "status2-vendas-premium",
        status: "ativo"
      },
      {
        id: "workflow-lista-003",
        name: "Agente SDR - Lista-3",
        webhookType: "lista",
        counter: 3,
        webhookPath: "lista3-vendas-premium", 
        status: "ativo"
      },
      {
        id: "workflow-stop-004",
        name: "Agente SDR - Stop-4",
        webhookType: "stop",
        counter: 4,
        webhookPath: "stop4-vendas-premium",
        status: "ativo"
      }
    ],
    summary: {
      totalWorkflows: 4,
      activeWorkflows: 4,
      webhookTypes: ["start", "status", "lista", "stop"]
    },
    timestamp: "2024-01-15T10:30:00.000Z",
    executionId: "execution-123"
  }
};

// Função para simular teste do Redis
function simularTesteRedis() {
  console.log("🧪 Teste Simples - Dados para o Fluxo N8N\n");
  
  console.log("📥 1. Payload do Frontend:");
  console.log(JSON.stringify(dadosExemplo.payloadFrontend, null, 2));
  console.log("");
  
  console.log("🔄 2. Dados Após Normalização:");
  console.log(JSON.stringify(dadosExemplo.dadosNormalizados, null, 2));
  console.log("");
  
  console.log("🔢 3. Contadores Redis:");
  console.log(JSON.stringify(dadosExemplo.contadoresRedis, null, 2));
  console.log("");
  
  console.log("🏗️ 4. Workflows Criados:");
  console.log(JSON.stringify(dadosExemplo.workflowsCriados, null, 2));
  console.log("");
  
  console.log("✅ 5. Resposta Final do Webhook:");
  console.log(JSON.stringify(dadosExemplo.respostaFinal, null, 2));
  console.log("");
  
  console.log("🎯 Dados prontos para usar no fluxo N8N!");
}

// Executar teste
simularTesteRedis();

// Exportar dados para uso
module.exports = dadosExemplo;
