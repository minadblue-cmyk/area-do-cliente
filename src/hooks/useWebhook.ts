import { useCallback } from 'react'
import { callWebhook } from '../utils/webhook-client'

interface CallOptions {
  method?: 'GET' | 'POST' | 'PATCH' | 'DELETE'
  data?: any
  params?: Record<string, any>
  headers?: Record<string, string>
  maxBodyBytes?: number
}

export function useWebhook() {
  const callWebhookHook = useCallback(async <T = any>(id: string, options: CallOptions = {}) => {
    return await callWebhook<T>(id, options)
  }, [])

  return {
    callWebhook: callWebhookHook
  }
}
