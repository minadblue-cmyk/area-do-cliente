import express from 'express';
import { createProxyMiddleware } from 'http-proxy-middleware';
import cors from 'cors';

const app = express();

// Habilitar CORS para todas as origens
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Proxy para n8n
app.use('/n8n', createProxyMiddleware({
  target: 'https://n8n.code-iq.com.br',
  changeOrigin: true,
  pathRewrite: {
    '^/n8n': ''
  },
  onError: (err, req, res) => {
    console.log('Proxy error:', err.message);
    res.status(500).json({ error: 'Proxy error: ' + err.message });
  },
  onProxyReq: (proxyReq, req, res) => {
    console.log('Proxying request:', req.method, req.url);
  },
  onProxyRes: (proxyRes, req, res) => {
    console.log('Proxy response:', proxyRes.statusCode, req.url);
  }
}));

const PORT = 3001;
app.listen(PORT, () => {
  console.log(`🚀 Proxy server running on http://localhost:${PORT}`);
  console.log(`📡 Proxying /n8n/* to https://n8n.code-iq.com.br/*`);
});
