import { NavLink } from 'react-router-dom'
import { cn } from '../../lib/utils'
import { LayoutDashboard, Upload, MessageSquare, Users, Building2, Webhook, Shield, LogOut, Menu, X, Bot, TestTube } from 'lucide-react'
import { useAuthStore } from '../../store/auth'
import { useUserPermissions } from '../../hooks/useUserPermissions'
import { Logo } from '../ui/Logo'
import { useState, useEffect } from 'react'

const links = [
  { to: '/dashboard', label: 'Dashboard', icon: LayoutDashboard, permission: 'visualizar_dashboard' },
  { to: '/upload', label: 'Upload de Arquivo', icon: Upload, permission: 'visualizar_pgina_de_upload' },
  { to: '/teste-agente', label: 'Teste de Agente', icon: TestTube, permission: 'visualizar_status_do_agente' },
  { to: '/saudacoes', label: 'Saudação Personalizada', icon: MessageSquare, permission: 'visualizar_saudaes' },
  { to: '/usuarios', label: 'Usuários', icon: Users, permission: 'visualizar_usurios' },
  { to: '/empresas', label: 'Empresas', icon: Building2, permission: 'visualizar_empresas' },
  { to: '/permissions', label: 'Gerenciamento de Perfis', icon: Shield, permission: 'visualizar_perfis' },
  { to: '/webhooks', label: 'Configurar Webhooks', icon: Webhook, permission: 'configurar_webhooks' },
  { to: '/agentes-config', label: 'Configurar Agentes', icon: Bot, permission: 'configurar_parmetros_do_agente' },
]

export function Sidebar() {
  const logout = useAuthStore((s) => s.logout)
  const { hasPermission, loading } = useUserPermissions()
  const [isOpen, setIsOpen] = useState(false)
  
  console.log('🔍 Sidebar: Componente renderizado!')
  
  // Verificar se o Dashboard está sendo filtrado
  const dashboardLink = links.find(link => link.to === '/dashboard')
  if (dashboardLink) {
    const hasDashboardAccess = hasPermission(dashboardLink.permission)
    console.log(`🔍 Sidebar: Dashboard - permissão: ${dashboardLink.permission} - tem acesso: ${hasDashboardAccess}`)
  }
  
  // Fechar sidebar ao clicar em um link (mobile e desktop)
  const handleLinkClick = () => {
    setIsOpen(false)
  }
  
  // Fechar sidebar ao pressionar ESC
  useEffect(() => {
    const handleEscape = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        setIsOpen(false)
      }
    }
    
    document.addEventListener('keydown', handleEscape)
    return () => document.removeEventListener('keydown', handleEscape)
  }, [])
  
  return (
    <>
      {/* Botão de toggle para mobile e desktop */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="fixed top-4 left-4 z-50 p-2 rounded-lg bg-card border border-border shadow-lg hover:bg-accent"
      >
        {isOpen ? <X size={20} /> : <Menu size={20} />}
      </button>
      
      {/* Overlay para mobile e desktop */}
      {isOpen && (
        <div 
          className="fixed inset-0 bg-black/50 z-40"
          onClick={() => setIsOpen(false)}
        />
      )}
      
      {/* Sidebar */}
      <aside 
        onClick={() => setIsOpen(false)}
        className={cn(
          "fixed inset-y-0 left-0 w-60 bg-card border-r border-border backdrop-blur-sm z-50 transition-transform duration-300 ease-in-out",
          isOpen ? "translate-x-0" : "-translate-x-full" // Flutuante em todos os tamanhos
        )}
      >
        <div className="h-14 flex items-center gap-3 px-4 border-b border-border">
          <Logo size={28} />
          <div className="flex flex-col">
            <span className="font-semibold text-sm text-foreground">Code-IQ</span>
            <span className="text-xs text-muted-foreground">Área do Cliente</span>
          </div>
        </div>
        
        <nav className="p-3 space-y-1">
          {loading ? (
            <div className="p-4 text-center text-muted-foreground">
              Carregando permissões...
            </div>
          ) : (
            links
              .filter(({ permission, label }) => {
                const hasAccess = hasPermission(permission)
                console.log(`🔍 Sidebar: ${label} - permissão: ${permission} - tem acesso: ${hasAccess}`)
                return hasAccess
              })
              .map(({ to, label, icon: Icon }) => (
              <NavLink 
                key={to} 
                to={to}
                onClick={(e) => {
                  e.stopPropagation() // Evitar que o clique no link feche o menu
                  handleLinkClick()
                }}
                className={({ isActive }) => cn(
                  'sidebar-item',
                  isActive && 'active'
                )}
              >
                <Icon size={18} />
                <span>{label}</span>
              </NavLink>
              ))
            )
          }
        </nav>
        
        <div className="absolute bottom-4 left-3 right-3">
          <button 
            onClick={(e) => {
              e.stopPropagation() // Evitar que o clique no botão feche o menu
              logout()
              setIsOpen(false)
            }}
            className="sidebar-item w-full hover:bg-destructive/20 hover:text-destructive-foreground"
          >
            <LogOut size={18} />
            <span>Sair</span>
          </button>
        </div>
      </aside>
    </>
  )
}
