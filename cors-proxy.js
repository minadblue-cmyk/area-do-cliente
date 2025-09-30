const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');

const app = express();
const PORT = 3001;

// Habilitar CORS para todas as origens
app.use(cors());

// Proxy para o webhook do n8n
app.use('/webhook', createProxyMiddleware({
  target: 'https://n8n.code-iq.com.br',
  changeOrigin: true,
  pathRewrite: {
    '^/webhook': '/webhook'
  },
  onError: (err, req, res) => {
    console.error('Erro no proxy:', err);
    res.status(500).json({ error: 'Erro no proxy' });
  }
}));

app.listen(PORT, () => {
  console.log(`🚀 Proxy CORS rodando em http://localhost:${PORT}`);
  console.log(`📡 Redirecionando /webhook/* para https://n8n.code-iq.com.br/webhook/*`);
});
