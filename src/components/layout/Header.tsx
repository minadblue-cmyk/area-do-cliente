import { useAuthStore } from '../../store/auth'

export function Header() {
  const userName = useAuthStore((s) => s.userName)
  return (
    <header className="h-14 border-b border-border flex items-center justify-between px-4 bg-background">
      <div /> {/* Espaço para o botão do menu */}
      <div className="text-sm text-muted-foreground text-center">
        {userName ? `Olá, ${userName}` : 'Área do Cliente'}
      </div>
    </header>
  )
}
