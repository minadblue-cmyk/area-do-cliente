import { useToastStore } from '../../store/toast'
import { cn } from '../../lib/utils'

export function ToastViewport() {
  const { toasts, dismiss } = useToastStore()
  return (
    <div className="fixed bottom-4 right-4 space-y-2 z-50">
      {toasts.map(t => (
        <div key={t.id} className={cn(
          'card px-4 py-3 shadow-lg min-w-64 max-w-sm text-sm',
          t.kind === 'success' && 'border-green-600/40',
          t.kind === 'error' && 'border-red-600/40',
          t.kind === 'info' && 'border-blue-600/40',
          t.kind === 'warning' && 'border-yellow-600/40'
        )}>
          {t.title && <div className="font-medium mb-1">{t.title}</div>}
          <div className="text-zinc-300">{t.message}</div>
          <div className="mt-2 text-right">
            <button className="text-xs text-zinc-400 hover:text-zinc-200" onClick={() => dismiss(t.id)}>Fechar</button>
          </div>
        </div>
      ))}
    </div>
  )
}
