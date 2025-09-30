import { Navigate, useLocation } from 'react-router-dom'
import { useUserPermissions } from '../hooks/useUserPermissions'

interface PermissionRouteProps {
  children: React.ReactNode
  permission: string
  fallbackPath?: string
}

export function PermissionRoute({ 
  children, 
  permission, 
  fallbackPath = '/dashboard' 
}: PermissionRouteProps) {
  const location = useLocation()
  const { hasPermission, loading } = useUserPermissions()

  console.log(`🔍 PermissionRoute: Verificando permissão ${permission}`)
  console.log(`🔍 PermissionRoute: Loading: ${loading}`)
  console.log(`🔍 PermissionRoute: Tem acesso: ${hasPermission(permission)}`)
  console.log(`🔍 PermissionRoute: Fallback path: ${fallbackPath}`)

  // Se ainda está carregando, mostrar loading
  if (loading) {
    console.log(`⏳ PermissionRoute: Ainda carregando permissões...`)
    return <div className="p-6">Carregando permissões...</div>
  }

  if (!hasPermission(permission)) {
    console.log(`🚫 Acesso negado para permissão: ${permission} - redirecionando para ${fallbackPath}`)
    return <Navigate to={fallbackPath} replace state={{ from: location }} />
  }

  console.log(`✅ Acesso permitido para permissão: ${permission}`)
  return <>{children}</>
}

