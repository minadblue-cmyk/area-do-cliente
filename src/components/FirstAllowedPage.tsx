import { Navigate } from 'react-router-dom'
import { usePermissions } from '../hooks/usePermissions'
import { PERMISSIONS } from '../constants/permissions.constants'

const PAGE_PERMISSIONS = [
  { path: '/dashboard', permission: PERMISSIONS.NAV_DASHBOARD }, // Priorizar Dashboard
  { path: '/upload', permission: PERMISSIONS.UPLOAD_VIEW },
  { path: '/saudacoes', permission: PERMISSIONS.SAUDACAO_VIEW },
  { path: '/usuarios', permission: PERMISSIONS.USUARIO_VIEW },
  { path: '/empresas', permission: PERMISSIONS.EMPRESA_VIEW },
  { path: '/permissions', permission: PERMISSIONS.PERFIL_VIEW },
  { path: '/webhooks', permission: PERMISSIONS.CONFIG_VIEW },
]

export function FirstAllowedPage() {
  const { can } = usePermissions()

  console.log('🔍 FirstAllowedPage: Componente executado!')
  console.log('🔍 FirstAllowedPage: Verificando permissões...')

  // Verificar cada permissão individualmente
  PAGE_PERMISSIONS.forEach(({ path, permission }) => {
    const hasAccess = can(permission)
    console.log(`🔍 FirstAllowedPage: ${path} (${permission}) - tem acesso: ${hasAccess}`)
  })

  // Encontrar a primeira página que o usuário tem acesso
  const firstAllowedPage = PAGE_PERMISSIONS.find(({ permission }) => can(permission))

  if (firstAllowedPage) {
    console.log(`🔄 Redirecionando para primeira página permitida: ${firstAllowedPage.path}`)
    return <Navigate to={firstAllowedPage.path} replace />
  }

  // Se não tem acesso a nenhuma página, redirecionar para uma página de erro ou login
  console.log('🚫 Usuário não tem acesso a nenhuma página')
  return <Navigate to="/login" replace />
}
