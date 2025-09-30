import React, { useState, useEffect } from 'react'
import { callWebhook } from '../../utils/webhook-client'
import { useToastStore } from '../../store/toast'
import { X, Plus, Save, Trash2, Shield } from 'lucide-react'
import { cn } from '../../lib/utils'
import { useScrollLock } from '../../hooks/useScrollLock'

interface ProfileItem {
  id: number
  nome_perfil: string
  descricao?: string
  permissoes?: PermissionItem[]
}

interface PermissionItem {
  id: number
  nome: string
  descricao: string
}

interface UserProfilesProps {
  userId: string
  userName: string
  currentProfiles: ProfileItem[]
  onClose: () => void
  onUpdate: () => void
}

export function UserProfiles({ userId, userName, currentProfiles, onClose, onUpdate }: UserProfilesProps) {
  const [availableProfiles, setAvailableProfiles] = useState<ProfileItem[]>([])
  const [selectedProfiles, setSelectedProfiles] = useState<number[]>([])
  const [loading, setLoading] = useState(false)
  const [searchTerm, setSearchTerm] = useState('')
  const push = useToastStore((s) => s.push)

  // Congelar scroll da página de fundo quando modal estiver aberto
  useScrollLock(true)

  // Categorias de permissões (mesma estrutura da página de Permissions)
  const permissionCategories = [
    {
      name: 'Dashboard',
      description: 'Acesso ao painel principal e visualizações',
      permissions: [
        { id: 1, nome: 'dashboard.view', descricao: 'Visualizar dashboard' },
        { id: 2, nome: 'dashboard.export', descricao: 'Exportar dados do dashboard' },
        { id: 3, nome: 'dashboard.analytics', descricao: 'Acessar análises avançadas' }
      ]
    },
    {
      name: 'Usuários',
      description: 'Gerenciamento de usuários e perfis',
      permissions: [
        { id: 4, nome: 'users.view', descricao: 'Visualizar usuários' },
        { id: 5, nome: 'users.create', descricao: 'Criar usuários' },
        { id: 6, nome: 'users.edit', descricao: 'Editar usuários' },
        { id: 7, nome: 'users.delete', descricao: 'Deletar usuários' }
      ]
    },
    {
      name: 'Agentes',
      description: 'Controle de agentes de prospecção',
      permissions: [
        { id: 8, nome: 'agents.view', descricao: 'Visualizar agentes' },
        { id: 9, nome: 'agents.create', descricao: 'Criar agentes' },
        { id: 10, nome: 'agents.edit', descricao: 'Editar agentes' },
        { id: 11, nome: 'agents.control', descricao: 'Controlar execução de agentes' }
      ]
    },
    {
      name: 'Uploads',
      description: 'Gerenciamento de arquivos e leads',
      permissions: [
        { id: 12, nome: 'uploads.view', descricao: 'Visualizar uploads' },
        { id: 13, nome: 'uploads.create', descricao: 'Fazer uploads' },
        { id: 14, nome: 'uploads.delete', descricao: 'Deletar uploads' }
      ]
    },
    {
      name: 'Relatórios',
      description: 'Geração e visualização de relatórios',
      permissions: [
        { id: 15, nome: 'reports.view', descricao: 'Visualizar relatórios' },
        { id: 16, nome: 'reports.export', descricao: 'Exportar relatórios' },
        { id: 17, nome: 'reports.create', descricao: 'Criar relatórios' }
      ]
    }
  ]

  // Carregar perfis disponíveis
  useEffect(() => {
    loadProfiles()
  }, [])

  // Inicializar perfis selecionados
  useEffect(() => {
    if (currentProfiles.length > 0) {
      setSelectedProfiles(currentProfiles.map(profile => Number(profile.id)))
    }
  }, [currentProfiles])

  async function loadProfiles() {
    try {
      setLoading(true)
      const { data } = await callWebhook<any>('webhook/list-profile', { 
        method: 'GET'
      })
      
      if (data && Array.isArray(data)) {
        setAvailableProfiles(data)
      }
    } catch (error) {
      console.error('Erro ao carregar perfis:', error)
      push({ kind: 'error', message: 'Erro ao carregar perfis' })
    } finally {
      setLoading(false)
    }
  }

  function toggleProfile(profileId: number) {
    setSelectedProfiles(prev => {
      if (prev.includes(profileId)) {
        return prev.filter(id => id !== profileId)
      } else {
        return [...prev, profileId]
      }
    })
  }

  function selectAllProfiles() {
    const allProfileIds = availableProfiles.map(p => Number(p.id))
    setSelectedProfiles(allProfileIds)
  }

  function clearAllProfiles() {
    setSelectedProfiles([])
  }

  async function saveUserProfiles() {
    try {
      setLoading(true)
      
      const payload = {
        usuario_id: userId,
        perfis: selectedProfiles
      }

      await callWebhook('webhook/assign-user-profiles', {
        method: 'POST',
        body: payload
      })

      push({ kind: 'success', message: 'Perfis salvos com sucesso!' })
      onUpdate()
      onClose()
    } catch (error) {
      console.error('Erro ao salvar perfis:', error)
      push({ kind: 'error', message: 'Erro ao salvar perfis' })
    } finally {
      setLoading(false)
    }
  }

  // Filtrar perfis baseado na busca
  const filteredProfiles = availableProfiles.filter(profile =>
    profile.nome_perfil.toLowerCase().includes(searchTerm.toLowerCase()) ||
    (profile.descricao && profile.descricao.toLowerCase().includes(searchTerm.toLowerCase()))
  )

  // Calcular permissões consolidadas
  const consolidatedPermissions = selectedProfiles.reduce((acc, profileId) => {
    const profile = availableProfiles.find(p => Number(p.id) === profileId)
    if (profile && profile.permissoes) {
      profile.permissoes.forEach(permission => {
        if (!acc.find(p => p.id === permission.id)) {
          acc.push(permission)
        }
      })
    }
    return acc
  }, [] as PermissionItem[])

  return (
    <div 
      className="fixed inset-0 bg-black/80 backdrop-blur-sm z-50 flex items-center justify-center p-2 sm:p-4"
      onWheel={(e) => e.stopPropagation()}
      onClick={(e) => {
        if (e.target === e.currentTarget) {
          onClose()
        }
      }}
    >
      <div 
        className="bg-card border border-border rounded-lg w-full h-full max-w-7xl max-h-[95vh] flex flex-col"
        onWheel={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b border-border">
          <div className="flex items-center gap-3">
            <Shield className="w-6 h-6 text-primary" />
            <div>
              <h2 className="text-2xl font-semibold text-foreground">Perfis do Usuário</h2>
              <p className="text-sm text-muted-foreground">{userName}</p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="text-muted-foreground hover:text-foreground p-2 rounded-lg hover:bg-muted transition-colors"
          >
            <X className="w-6 h-6" />
          </button>
        </div>

        <div className="flex-1 overflow-hidden p-4 sm:p-6">
          <form className="h-full flex flex-col space-y-4">
            {/* Barra de Busca */}
            <div>
              <input
                type="text"
                placeholder="Buscar perfis por nome ou descrição..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full px-4 py-2 border border-border rounded-lg bg-background text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-primary"
              />
              {searchTerm && (
                <div className="mt-2 text-sm text-muted-foreground">
                  {filteredProfiles.length} de {availableProfiles.length} perfis encontrados
                </div>
              )}
            </div>

            {/* Controles */}
            <div className="flex items-center justify-between">
              <h3 className="text-lg font-medium text-foreground">Perfis Disponíveis</h3>
              <div className="flex gap-2">
                <button
                  type="button"
                  onClick={() => selectAllProfiles()}
                  className="text-sm px-3 py-1 bg-blue-600 text-white rounded hover:bg-blue-700 transition-colors"
                >
                  Selecionar Todos
                </button>
                <button
                  type="button"
                  onClick={() => clearAllProfiles()}
                  className="text-sm px-3 py-1 bg-gray-600 text-white rounded hover:bg-gray-700 transition-colors"
                >
                  Limpar Todos
                </button>
              </div>
            </div>

            {/* Lista de Perfis com Scroll */}
            <div className="flex-1 min-h-0">
              <div className="h-full overflow-y-auto space-y-3">
                {loading ? (
                  <div className="text-center py-4 text-muted-foreground">
                    Carregando perfis...
                  </div>
                ) : filteredProfiles.length === 0 ? (
                  <div className="text-center py-4 text-muted-foreground">
                    {searchTerm ? 'Nenhum perfil encontrado para a busca' : 'Nenhum perfil disponível'}
                  </div>
                ) : (
                  <div className="space-y-3">
                    {filteredProfiles.map(profile => {
                      const profileIdNumber = Number(profile.id)
                      const isSelected = selectedProfiles.includes(profileIdNumber)
                      
                      return (
                        <label
                          key={profile.id}
                          className={cn(
                            "flex items-start gap-3 p-4 rounded-lg border cursor-pointer transition-colors",
                            isSelected
                              ? "border-primary bg-primary/10 border-2"
                              : "border-border hover:bg-accent/50 hover:border-primary/50"
                          )}
                        >
                          <input
                            type="checkbox"
                            checked={isSelected}
                            onChange={() => toggleProfile(profileIdNumber)}
                            className="mt-1 w-4 h-4 text-primary bg-background border-border rounded focus:ring-primary focus:ring-2"
                          />
                          <div className="flex-1 min-w-0">
                            <div className="font-semibold text-foreground mb-1">
                              {profile.nome_perfil}
                            </div>
                            <div className="text-sm text-muted-foreground mb-2">
                              {profile.descricao || 'Sem descrição'}
                            </div>
                            {profile.permissoes && (
                              <div className="text-xs text-primary">
                                {profile.permissoes.length} permissões
                              </div>
                            )}
                          </div>
                        </label>
                      )
                    })}
                  </div>
                )}
              </div>
            </div>
          </form>
        </div>

        {/* Footer */}
        <div className="flex flex-col sm:flex-row items-center justify-between p-4 sm:p-6 border-t border-border gap-3">
          <div className="text-sm text-muted-foreground">
            {selectedProfiles.length} perfil(is) selecionado(s)
          </div>
          <div className="flex items-center gap-2 sm:gap-3 w-full sm:w-auto">
            <button
              onClick={onClose}
              className="flex-1 sm:flex-none px-4 sm:px-6 py-2 sm:py-3 bg-gray-600 text-white rounded-lg hover:bg-gray-500 transition-colors flex items-center justify-center gap-2 text-sm"
            >
              <X className="w-4 h-4" />
              <span className="hidden sm:inline">Cancelar</span>
              <span className="sm:hidden">Cancelar</span>
            </button>
            <button
              onClick={saveUserProfiles}
              disabled={loading}
              className="flex-1 sm:flex-none px-4 sm:px-6 py-2 sm:py-3 bg-primary text-primary-foreground rounded-lg hover:bg-primary/90 transition-colors flex items-center justify-center gap-2 disabled:opacity-50 text-sm"
            >
              <Save className="w-4 h-4" />
              <span className="hidden sm:inline">{loading ? 'Salvando...' : 'Salvar Perfis'}</span>
              <span className="sm:hidden">{loading ? 'Salvando...' : 'Salvar'}</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}