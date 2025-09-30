const express = require('express');
const Redis = require('redis');
const cors = require('cors');

const app = express();
const port = 3001;

// Middleware
app.use(cors());
app.use(express.json());

// Configuração do Redis
const redisClient = Redis.createClient({
  host: 'localhost', // ou seu host Redis
  port: 6379,
  // password: 'sua_senha_redis', // descomente se usar senha
});

redisClient.on('error', (err) => {
  console.error('Redis Client Error:', err);
});

redisClient.on('connect', () => {
  console.log('✅ Conectado ao Redis');
});

// Conectar ao Redis
redisClient.connect().catch(console.error);

// Função para gerar próximo contador de forma atômica
async function getNextCounter(agentType, webhookType) {
  const key = `agent_counter:${agentType}:${webhookType}`;
  
  try {
    // Incrementar contador de forma atômica
    const counter = await redisClient.incr(key);
    
    // Definir expiração para 30 dias (opcional)
    await redisClient.expire(key, 30 * 24 * 60 * 60);
    
    return counter;
  } catch (error) {
    console.error('Erro ao incrementar contador:', error);
    // Fallback: usar timestamp como contador
    return Date.now();
  }
}

// Endpoint para obter próximo contador
app.post('/api/counter/next', async (req, res) => {
  try {
    const { agentType, webhookType } = req.body;
    
    if (!agentType || !webhookType) {
      return res.status(400).json({
        error: 'agentType e webhookType são obrigatórios'
      });
    }
    
    const counter = await getNextCounter(agentType, webhookType);
    
    res.json({
      success: true,
      counter: counter,
      agentType: agentType,
      webhookType: webhookType,
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    console.error('Erro no endpoint /api/counter/next:', error);
    res.status(500).json({
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// Endpoint para obter contador atual (sem incrementar)
app.get('/api/counter/current/:agentType/:webhookType', async (req, res) => {
  try {
    const { agentType, webhookType } = req.params;
    const key = `agent_counter:${agentType}:${webhookType}`;
    
    const counter = await redisClient.get(key) || '0';
    
    res.json({
      success: true,
      counter: parseInt(counter),
      agentType: agentType,
      webhookType: webhookType
    });
    
  } catch (error) {
    console.error('Erro no endpoint /api/counter/current:', error);
    res.status(500).json({
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// Endpoint para resetar contador
app.post('/api/counter/reset', async (req, res) => {
  try {
    const { agentType, webhookType } = req.body;
    
    if (!agentType || !webhookType) {
      return res.status(400).json({
        error: 'agentType e webhookType são obrigatórios'
      });
    }
    
    const key = `agent_counter:${agentType}:${webhookType}`;
    await redisClient.del(key);
    
    res.json({
      success: true,
      message: `Contador resetado para ${agentType}:${webhookType}`,
      agentType: agentType,
      webhookType: webhookType
    });
    
  } catch (error) {
    console.error('Erro no endpoint /api/counter/reset:', error);
    res.status(500).json({
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// Endpoint para listar todos os contadores
app.get('/api/counter/list', async (req, res) => {
  try {
    const keys = await redisClient.keys('agent_counter:*');
    const counters = {};
    
    for (const key of keys) {
      const value = await redisClient.get(key);
      const [, agentType, webhookType] = key.split(':');
      
      if (!counters[agentType]) {
        counters[agentType] = {};
      }
      
      counters[agentType][webhookType] = parseInt(value);
    }
    
    res.json({
      success: true,
      counters: counters,
      totalKeys: keys.length
    });
    
  } catch (error) {
    console.error('Erro no endpoint /api/counter/list:', error);
    res.status(500).json({
      error: 'Erro interno do servidor',
      details: error.message
    });
  }
});

// Health check
app.get('/health', async (req, res) => {
  try {
    await redisClient.ping();
    res.json({
      status: 'healthy',
      redis: 'connected',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      status: 'unhealthy',
      redis: 'disconnected',
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Iniciar servidor
app.listen(port, () => {
  console.log(`🚀 Servidor Redis Counter rodando na porta ${port}`);
  console.log(`📊 Endpoints disponíveis:`);
  console.log(`   POST /api/counter/next - Obter próximo contador`);
  console.log(`   GET  /api/counter/current/:agentType/:webhookType - Contador atual`);
  console.log(`   POST /api/counter/reset - Resetar contador`);
  console.log(`   GET  /api/counter/list - Listar todos os contadores`);
  console.log(`   GET  /health - Health check`);
});

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('\n🛑 Encerrando servidor...');
  await redisClient.quit();
  process.exit(0);
});

module.exports = app;
