import { Routes, Route } from 'react-router-dom'
import { Suspense, lazy } from 'react'
import { ProtectedRoute } from './utils/protected-route'
import { PermissionRoute } from './components/PermissionRoute'
import { FirstAllowedPage } from './components/FirstAllowedPage'
import { RootRedirect } from './components/RootRedirect'
import { AppShell } from './components/layout/AppShell'
// import { PERMISSIONS } from './constants/permissions.constants'

const Login = lazy(() => import('./pages/Login'))
const Dashboard = lazy(() => import('./pages/Dashboard'))
const Upload = lazy(() => import('./pages/Upload'))
const Saudacoes = lazy(() => import('./pages/Saudacoes'))
const Usuarios = lazy(() => import('./pages/Usuarios'))
const Empresas = lazy(() => import('./pages/Empresas'))
const Permissions = lazy(() => import('./pages/Permissions'))
const Webhooks = lazy(() => import('./pages/Webhooks'))
const AgentesConfig = lazy(() => import('./pages/AgentesConfig'))
const TesteAgente = lazy(() => import('./pages/TesteAgente'))
const NotFound = lazy(() => import('./pages/NotFound'))

export function AppRoutes() {
  return (
    <Suspense fallback={<div className="p-6">Carregando...</div>}>
      <Routes>
        <Route path="/" element={<RootRedirect />} />
        <Route path="/login" element={<Login />} />
        <Route element={<ProtectedRoute />}> 
          <Route element={<AppShell />}>
            <Route path="/dashboard" element={
              <PermissionRoute permission="visualizar_dashboard" fallbackPath="/upload">
                <Dashboard />
              </PermissionRoute>
            } />
            <Route path="/first-allowed" element={<FirstAllowedPage />} />
            <Route path="/upload" element={
              <PermissionRoute permission="visualizar_pgina_de_upload">
                <Upload />
              </PermissionRoute>
            } />
            <Route path="/saudacoes" element={
              <PermissionRoute permission="visualizar_saudaes">
                <Saudacoes />
              </PermissionRoute>
            } />
            <Route path="/usuarios" element={
              <PermissionRoute permission="visualizar_usurios">
                <Usuarios />
              </PermissionRoute>
            } />
            <Route path="/empresas" element={
              <PermissionRoute permission="visualizar_empresas">
                <Empresas />
              </PermissionRoute>
            } />
            <Route path="/permissions" element={
              <PermissionRoute permission="visualizar_perfis">
                <Permissions />
              </PermissionRoute>
            } />
            <Route path="/webhooks" element={
              <PermissionRoute permission="configurar_webhooks">
                <Webhooks />
              </PermissionRoute>
            } />
            <Route path="/agentes-config" element={
              <PermissionRoute permission="configurar_parmetros_do_agente">
                <AgentesConfig />
              </PermissionRoute>
            } />
            <Route path="/teste-agente" element={
              <PermissionRoute permission="visualizar_status_do_agente">
                <TesteAgente />
              </PermissionRoute>
            } />
          </Route>
        </Route>
        <Route path="*" element={<NotFound />} />
      </Routes>
    </Suspense>
  )
}
