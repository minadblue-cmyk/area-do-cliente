import { create } from 'zustand'
import { DEFAULT_WEBHOOKS } from '../constants/webhooks.constants'
import { z } from 'zod'

const STORAGE_KEY = 'flowhub:webhooks'

const cfgSchema = z.record(z.string(), z.string().url())

interface WebhookState {
  urls: Record<string, string>
  setUrl: (id: string, url: string) => void
  setAll: (entries: Record<string, string>) => void
  addWebhook: (id: string, url: string) => void
  reset: () => void
  forceReload: () => void
}

function loadInitial(): Record<string, string> {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (!raw) {
      console.log('🔄 Carregando webhooks padrão:', Object.keys(DEFAULT_WEBHOOKS))
      return { ...DEFAULT_WEBHOOKS }
    }
    const parsed = JSON.parse(raw)
    const validated = cfgSchema.parse(parsed)
    console.log('🔄 Carregando webhooks do localStorage:', Object.keys(validated))
    return validated
  } catch (error) {
    console.log('🔄 Erro ao carregar webhooks, usando padrão:', Object.keys(DEFAULT_WEBHOOKS))
    console.log('❌ Erro detalhado:', error)
    return { ...DEFAULT_WEBHOOKS }
  }
}

export const useWebhookStore = create<WebhookState>((set, get) => {
  const initialUrls = loadInitial()
  console.log('🔍 Store inicializado com URLs:', Object.keys(initialUrls))
  
  return {
    urls: initialUrls,
    setUrl(id, url) {
      const { urls } = get()
      const next = { ...urls, [id]: url }
      try {
        cfgSchema.parse(next)
        localStorage.setItem(STORAGE_KEY, JSON.stringify(next))
        set({ urls: next })
      } catch {}
    },
    setAll(entries) {
      try {
        cfgSchema.parse(entries)
        localStorage.setItem(STORAGE_KEY, JSON.stringify(entries))
        set({ urls: entries })
      } catch {}
    },
    addWebhook(id, url) {
      const { urls } = get()
      const next = { ...urls, [id]: url }
      try {
        cfgSchema.parse(next)
        localStorage.setItem(STORAGE_KEY, JSON.stringify(next))
        set({ urls: next })
      } catch {}
    },
    reset() {
      const defaults = { ...DEFAULT_WEBHOOKS }
      localStorage.setItem(STORAGE_KEY, JSON.stringify(defaults))
      set({ urls: defaults })
    },
    forceReload() {
      console.log('🔄 Forçando reload do store de webhooks')
      const defaults = { ...DEFAULT_WEBHOOKS }
      localStorage.setItem(STORAGE_KEY, JSON.stringify(defaults))
      set({ urls: defaults })
    }
  }
})
