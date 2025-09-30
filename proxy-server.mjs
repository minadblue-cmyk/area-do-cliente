import express from 'express'
import { createProxyMiddleware } from 'http-proxy-middleware'
import cors from 'cors'

const app = express()
const PORT = 8080

// Configurar CORS para permitir todas as origens
app.use(cors({
  origin: ['http://localhost:5173', 'http://localhost:5174', 'http://localhost:5175', 'http://localhost:3000'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}))

// Proxy para o n8n
app.use('/webhook', createProxyMiddleware({
  target: 'https://n8n.code-iq.com.br',
  changeOrigin: true,
  secure: true,
  logLevel: 'debug',
  pathRewrite: {
    '^/webhook': '/webhook' // Manter /webhook no path
  },
  onProxyReq: (proxyReq, req, res) => {
    console.log(`🔄 Proxying ${req.method} ${req.url} -> https://n8n.code-iq.com.br${req.url}`)
    console.log(`📤 Headers:`, proxyReq.getHeaders())
  },
  onProxyRes: (proxyRes, req, res) => {
    console.log(`✅ Response ${proxyRes.statusCode} for ${req.url}`)
  },
  onError: (err, req, res) => {
    console.error(`❌ Proxy error for ${req.url}:`, err.message)
    console.error(`❌ Full error:`, err)
  }
}))

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'Proxy server running' })
})

app.listen(PORT, () => {
  console.log(`🚀 Proxy server running on http://localhost:${PORT}`)
  console.log(`📡 Proxying requests to: https://n8n.code-iq.com.br`)
  console.log(`🔗 Frontend should use: http://localhost:${PORT}/webhook/...`)
})
