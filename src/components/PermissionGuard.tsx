import React from 'react'
import { usePermissions } from '../hooks/usePermissions'

interface PermissionGuardProps {
  children: React.ReactNode
  permission?: string
  permissions?: string[]
  requireAll?: boolean // true = AND, false = OR
  fallback?: React.ReactNode
  redirectTo?: string
}

/**
 * Componente para proteger conteúdo baseado em permissões
 */
export function PermissionGuard({
  children,
  permission,
  permissions = [],
  requireAll = false,
  fallback = null,
  redirectTo
}: PermissionGuardProps) {
  const { can, canAll, canAny } = usePermissions()

  // Verificar permissão única
  if (permission) {
    if (!can(permission)) {
      return <>{fallback}</>
    }
  }

  // Verificar múltiplas permissões
  if (permissions.length > 0) {
    const hasPermission = requireAll 
      ? canAll(permissions)
      : canAny(permissions)
    
    if (!hasPermission) {
      return <>{fallback}</>
    }
  }

  // Se chegou até aqui, tem permissão
  return <>{children}</>
}

/**
 * Componente para proteger botões baseado em permissões
 */
interface PermissionButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  permission?: string
  permissions?: string[]
  requireAll?: boolean
  children: React.ReactNode
}

export function PermissionButton({
  permission,
  permissions = [],
  requireAll = false,
  children,
  ...props
}: PermissionButtonProps) {
  const { can, canAll, canAny } = usePermissions()

  // Verificar permissão única
  if (permission && !can(permission)) {
    return null
  }

  // Verificar múltiplas permissões
  if (permissions.length > 0) {
    const hasPermission = requireAll 
      ? canAll(permissions)
      : canAny(permissions)
    
    if (!hasPermission) {
      return null
    }
  }

  return <button {...props}>{children}</button>
}

/**
 * Componente para proteger links baseado em permissões
 */
interface PermissionLinkProps extends React.AnchorHTMLAttributes<HTMLAnchorElement> {
  permission?: string
  permissions?: string[]
  requireAll?: boolean
  children: React.ReactNode
}

export function PermissionLink({
  permission,
  permissions = [],
  requireAll = false,
  children,
  ...props
}: PermissionLinkProps) {
  const { can, canAll, canAny } = usePermissions()

  // Verificar permissão única
  if (permission && !can(permission)) {
    return null
  }

  // Verificar múltiplas permissões
  if (permissions.length > 0) {
    const hasPermission = requireAll 
      ? canAll(permissions)
      : canAny(permissions)
    
    if (!hasPermission) {
      return null
    }
  }

  return <a {...props}>{children}</a>
}
