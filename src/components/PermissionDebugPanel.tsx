import { useSimplePermissions } from '../hooks/useSimplePermissions'
import { useUserPermissions } from '../hooks/useUserPermissions'
import { useAuthStore } from '../store/auth'

export function PermissionDebugPanel() {
  const { userData } = useAuthStore()
  const simplePermissions = useSimplePermissions()
  const realPermissions = useUserPermissions()

  const testPermissions = [
    'visualizar_dashboard',
    'visualizar_página_de_upload',
    'visualizar_usuários',
    'criar_usuários',
    'visualizar_empresas',
    'visualizar_perfis',
    'configurar_webhooks',
    'configurar_parâmetros_do_agente'
  ]

  return (
    <div className="fixed top-4 right-4 w-80 bg-gray-900 border border-gray-700 rounded-lg p-4 text-xs text-white z-50 max-h-96 overflow-y-auto">
      <h3 className="font-bold text-sm mb-2 text-yellow-400">🔍 Debug de Permissões</h3>
      
      <div className="mb-2">
        <div className="text-gray-300">Usuário: {userData?.name}</div>
        <div className="text-gray-300">Perfil: {userData?.perfil} (ID: {userData?.perfil_id})</div>
      </div>

      <div className="mb-2">
        <div className="text-gray-300">Simple Loading: {simplePermissions.loading ? 'Sim' : 'Não'}</div>
        <div className="text-gray-300">Real Loading: {realPermissions.loading ? 'Sim' : 'Não'}</div>
      </div>

      <div className="space-y-1">
        <div className="text-gray-300 font-semibold">Teste de Permissões:</div>
        {testPermissions.map(permission => {
          const simpleHas = simplePermissions.hasPermission(permission)
          const realHas = realPermissions.hasPermission(permission)
          const isDifferent = simpleHas !== realHas
          
          return (
            <div key={permission} className={`flex items-center gap-2 ${isDifferent ? 'bg-red-900' : ''}`}>
              <span className={`w-2 h-2 rounded-full ${simpleHas ? 'bg-green-500' : 'bg-red-500'}`}></span>
              <span className="text-gray-300 flex-1">{permission}</span>
              <span className="text-xs">
                S:{simpleHas ? '✓' : '✗'} R:{realHas ? '✓' : '✗'}
              </span>
            </div>
          )
        })}
      </div>

      {realPermissions.userPermissions.length > 0 && (
        <div className="mt-2">
          <div className="text-gray-300 font-semibold">Permissões Reais ({realPermissions.userPermissions.length}):</div>
          <div className="text-xs text-gray-400 max-h-20 overflow-y-auto">
            {realPermissions.userPermissions.map((perm, idx) => (
              <div key={idx}>• {perm}</div>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}
