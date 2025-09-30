import { api } from './api'
import { useWebhookStore } from '../store/webhooks'

interface CallOptions {
  method?: 'GET' | 'POST' | 'PATCH' | 'DELETE'
  data?: any
  params?: Record<string, any>
  headers?: Record<string, string>
  maxBodyBytes?: number
}

const RATE_LIMIT_WINDOW_MS = 60_000
const RATE_LIMIT_MAX = 60
const requestTimestamps: Record<string, number[]> = {}

function checkRateLimit(id: string) {
  const now = Date.now()
  const arr = (requestTimestamps[id] = (requestTimestamps[id] ?? []).filter(ts => now - ts < RATE_LIMIT_WINDOW_MS))
  if (arr.length >= RATE_LIMIT_MAX) {
    throw new Error('Muitas requisições. Tente novamente em instantes.')
  }
  arr.push(now)
}

export async function callWebhook<T = any>(id: string, options: CallOptions = {}) {
  console.log('🚀 callWebhook chamada com ID:', id)
  console.log('📦 Dados sendo enviados:', options.data)
  const { urls } = useWebhookStore.getState()
  console.log('🔍 Webhook store URLs:', urls)
  console.log('🔍 Procurando webhook:', id)
  
  let url = urls[id]
  
  // Se não encontrou no store, verificar se é uma URL completa ou webhook dinâmico
  if (!url) {
    // Se começa com 'webhook/', construir URL completa
    if (id.startsWith('webhook/')) {
      // Todos os webhooks dinâmicos vão para CODE-IQ (que está funcionando)
      url = `https://n8n.code-iq.com.br/${id}`
      console.log('🔧 Construindo URL dinâmica (CODE-IQ):', url)
    } else if (id.startsWith('http')) {
      // Se já é uma URL completa, usar diretamente
      url = id
      console.log('🔧 Usando URL completa:', url)
    } else {
      console.error('❌ Webhook não encontrado:', id)
      console.error('❌ URLs disponíveis:', Object.keys(urls))
      throw new Error(`Webhook não configurado: ${id}`)
    }
  }

  // Verificar tamanho do payload apenas para dados não-FormData
  if (options.data && !(options.data instanceof FormData)) {
    const size = new Blob([JSON.stringify(options.data)]).size
    const limit = options.maxBodyBytes ?? 2 * 1024 * 1024
    if (size > limit) throw new Error('Payload excede o limite permitido.')
  }

  checkRateLimit(id)

  try {
    const method = options.method ?? 'GET'
    
    // Preparar headers
    const headers = { ...options.headers }
    
    // Para FormData, não definir Content-Type - o browser define automaticamente com boundary
    if (options.data instanceof FormData) {
      delete headers['Content-Type']
    } else if (options.data && !headers['Content-Type']) {
      headers['Content-Type'] = 'application/json'
    }
    
    // TESTE DIRETO: Webhook stop agora está ativo
    if (id === 'webhook/parar-agente') {
      console.log('🔄 Testando webhook stop diretamente (CORS deve estar resolvido)')
      // Remover proxy temporariamente para testar se CORS foi resolvido
    }
    
    const res = await api.request<T>({ 
      url, 
      method, 
      data: options.data, 
      params: options.params, 
      headers 
    })
    
    return res
  } catch (error: any) {
    // Melhor tratamento de erros CORS
    if (error.code === 'ERR_NETWORK' || error.message?.includes('CORS')) {
      throw new Error('CORS: O servidor não está configurado para aceitar requisições do frontend.')
    }
    
    // Re-throw com contexto adicional
    const enhancedError = new Error(error.message || 'Erro na requisição')
    enhancedError.response = error.response
    enhancedError.status = error.response?.status
    throw enhancedError
  }
}

// Função para chamar webhook via proxy (solução temporária para CORS)
async function callWebhookViaProxy(url: string, method: string, data: any, params: any, headers: any) {
  try {
    // Usar um serviço de proxy CORS público (temporário)
    const proxyUrl = `https://cors-anywhere.herokuapp.com/${url}`
    
    const response = await fetch(proxyUrl, {
      method,
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        ...headers
      },
      body: data ? JSON.stringify(data) : undefined
    })
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)
    }
    
    const result = await response.json()
    return { data: result, status: response.status }
  } catch (error) {
    console.error('❌ Erro no proxy CORS:', error)
    throw new Error('Falha ao chamar webhook via proxy. Tente novamente.')
  }
}
