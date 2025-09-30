import axios from 'axios'
import { useAuthStore } from '../store/auth'

export const api = axios.create({
  timeout: 120000, // Aumentar timeout para agentes (2 minutos)
  headers: {
    'Content-Type': 'application/json',
  },
  withCredentials: false,
  // Configurações para melhor suporte a CORS
  validateStatus: function (status) {
    return status < 500 // Resolve apenas se status < 500
  }
})

api.interceptors.request.use((config) => {
  const token = useAuthStore.getState().token
  if (token) {
    config.headers = config.headers ?? {}
    config.headers.Authorization = `Bearer ${token}`
  }
  
  // Para FormData, remover Content-Type para que o browser defina automaticamente
  if (config.data instanceof FormData) {
    delete config.headers['Content-Type']
  }
  
  return config
})

api.interceptors.response.use(
  (res) => {
    // Verificar se a resposta indica erro de CORS ou servidor
    if (res.status >= 400) {
      const error = new Error(`HTTP Error ${res.status}: ${res.statusText}`)
      error.response = res
      throw error
    }
    return res
  },
  (err) => {
    // Melhor tratamento de erros de rede/CORS
    if (!err.response) {
      // Erro de rede (incluindo CORS)
      const message = err.code === 'ERR_NETWORK' 
        ? 'Erro de conexão. Verifique se o servidor está acessível e configurado para CORS.' 
        : err.message
      
      const networkError = new Error(message)
      networkError.code = err.code
      networkError.originalError = err
      throw networkError
    }
    
    return Promise.reject(err)
  }
)
