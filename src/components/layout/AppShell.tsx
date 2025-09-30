import { Outlet } from 'react-router-dom'
import { Sidebar } from './Sidebar'
import { Header } from './Header'

export function AppShell() {
  console.log('🔍 AppShell: Componente AppShell renderizado!')
  
  return (
    <div className="min-h-screen bg-background">
      <Sidebar />
      <Header />
      <main className="p-4 space-y-4">
        <Outlet />
      </main>
    </div>
  )
}
