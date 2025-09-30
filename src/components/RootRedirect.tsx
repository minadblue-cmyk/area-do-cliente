import { Navigate } from 'react-router-dom'
import { useEffect } from 'react'

export function RootRedirect() {
  useEffect(() => {
    console.log('🔍 RootRedirect: Usuário acessou a rota raiz (/)')
    console.log('🔍 RootRedirect: Redirecionando para /login')
  }, [])

  return <Navigate to="/login" replace state={{ from: 'root' }} />
}
