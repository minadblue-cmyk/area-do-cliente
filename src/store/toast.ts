import { create } from 'zustand'

export type ToastKind = 'success' | 'error' | 'info' | 'warning'

export interface ToastItem {
  id: string
  title?: string
  message: string
  kind: ToastKind
  durationMs?: number
}

interface ToastState {
  toasts: ToastItem[]
  push: (t: Omit<ToastItem, 'id'>) => string
  dismiss: (id: string) => void
  clear: () => void
}

export const useToastStore = create<ToastState>((set, get) => ({
  toasts: [],
  push(t) {
    const id = crypto.randomUUID()
    const item: ToastItem = { id, durationMs: 4000, ...t }
    set({ toasts: [...get().toasts, item] })
    if (item.durationMs && item.durationMs > 0) {
      setTimeout(() => {
        get().dismiss(id)
      }, item.durationMs)
    }
    return id
  },
  dismiss(id) {
    set({ toasts: get().toasts.filter(t => t.id !== id) })
  },
  clear() {
    set({ toasts: [] })
  }
}))
