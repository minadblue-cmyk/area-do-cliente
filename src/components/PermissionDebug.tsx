import { useUserPermissions } from '../hooks/useUserPermissions'
import { useAuthStore } from '../store/auth'

export function PermissionDebug() {
  const { userData } = useAuthStore()
  const { 
    permissions, 
    userProfile, 
    userPermissions, 
    loading, 
    error,
    hasPermission,
    isAdmin 
  } = useUserPermissions()

  if (loading) {
    return (
      <div className="p-4 bg-yellow-100 border border-yellow-300 rounded-lg">
        <h3 className="font-semibold text-yellow-800">🔍 Carregando permissões...</h3>
      </div>
    )
  }

  if (error) {
    return (
      <div className="p-4 bg-red-100 border border-red-300 rounded-lg">
        <h3 className="font-semibold text-red-800">❌ Erro ao carregar permissões</h3>
        <p className="text-red-600">{error}</p>
      </div>
    )
  }

  return (
    <div className="p-4 bg-blue-100 border border-blue-300 rounded-lg space-y-4">
      <h3 className="font-semibold text-blue-800">🔍 Debug de Permissões</h3>
      
      <div>
        <h4 className="font-medium text-blue-700">Usuário Logado:</h4>
        <p className="text-sm text-blue-600">
          ID: {userData?.id} | Nome: {userData?.name} | Perfil: {userData?.perfil} | Perfil ID: {userData?.perfil_id}
        </p>
      </div>

      <div>
        <h4 className="font-medium text-blue-700">Perfil Encontrado:</h4>
        {userProfile ? (
          <div className="text-sm text-blue-600">
            <p>ID: {userProfile.id} | Nome: {userProfile.nome_perfil}</p>
            <p>Descrição: {userProfile.descricao}</p>
            <p>Permissões (IDs): {userProfile.permissoes.filter(id => id !== null).join(', ')}</p>
          </div>
        ) : (
          <p className="text-sm text-red-600">❌ Perfil não encontrado</p>
        )}
      </div>

      <div>
        <h4 className="font-medium text-blue-700">Permissões do Usuário ({userPermissions.length}):</h4>
        <div className="text-sm text-blue-600 max-h-32 overflow-y-auto">
          {userPermissions.map((permission, index) => (
            <div key={index} className="flex items-center gap-2">
              <span className="w-2 h-2 bg-green-500 rounded-full"></span>
              {permission}
            </div>
          ))}
        </div>
      </div>

      <div>
        <h4 className="font-medium text-blue-700">Teste de Permissões Específicas:</h4>
        <div className="text-sm text-blue-600 space-y-1">
          <div className="flex items-center gap-2">
            <span className={`w-2 h-2 rounded-full ${hasPermission('visualizar_dashboard') ? 'bg-green-500' : 'bg-red-500'}`}></span>
            visualizar_dashboard: {hasPermission('visualizar_dashboard') ? '✅' : '❌'}
          </div>
          <div className="flex items-center gap-2">
            <span className={`w-2 h-2 rounded-full ${hasPermission('visualizar_página_de_upload') ? 'bg-green-500' : 'bg-red-500'}`}></span>
            visualizar_página_de_upload: {hasPermission('visualizar_página_de_upload') ? '✅' : '❌'}
          </div>
          <div className="flex items-center gap-2">
            <span className={`w-2 h-2 rounded-full ${hasPermission('visualizar_usuários') ? 'bg-green-500' : 'bg-red-500'}`}></span>
            visualizar_usuários: {hasPermission('visualizar_usuários') ? '✅' : '❌'}
          </div>
          <div className="flex items-center gap-2">
            <span className={`w-2 h-2 rounded-full ${hasPermission('criar_usuários') ? 'bg-green-500' : 'bg-red-500'}`}></span>
            criar_usuários: {hasPermission('criar_usuários') ? '✅' : '❌'}
          </div>
          <div className="flex items-center gap-2">
            <span className={`w-2 h-2 rounded-full ${isAdmin() ? 'bg-green-500' : 'bg-red-500'}`}></span>
            isAdmin: {isAdmin() ? '✅' : '❌'}
          </div>
        </div>
      </div>
    </div>
  )
}

