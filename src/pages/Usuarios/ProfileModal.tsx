import React from 'react'
import { X, Shield } from 'lucide-react'
import { cn } from '../../lib/utils'

interface ProfileItem {
  id: number
  nome_perfil: string
  descricao?: string
  description?: string  // Campo alternativo
}

interface ProfileModalProps {
  isOpen: boolean
  onClose: () => void
  selectedProfiles: number[]
  availableProfiles: ProfileItem[]
  onToggleProfile: (profileId: number) => void
  onSave: () => void
  loading?: boolean
}

export function ProfileModal({ 
  isOpen, 
  onClose, 
  selectedProfiles, 
  availableProfiles, 
  onToggleProfile, 
  onSave,
  loading = false 
}: ProfileModalProps) {
  if (!isOpen) return null

  return (
    <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4 overflow-y-auto">
      <div className="bg-card border border-border rounded-lg w-full max-w-2xl max-h-[90vh] flex flex-col my-8">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b border-border">
          <div className="flex items-center gap-3">
            <Shield className="w-6 h-6 text-primary" />
            <div>
              <h2 className="text-xl font-semibold text-foreground">Selecionar Perfis</h2>
              <p className="text-sm text-muted-foreground">
                Escolha os perfis de acesso para este usuário
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-2 rounded-lg hover:bg-accent transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Content */}
        <div className="p-6 overflow-y-auto flex-1">
          <div className="space-y-4">
            {availableProfiles.length === 0 ? (
              <div className="text-center py-8">
                <p className="text-muted-foreground">Nenhum perfil disponível</p>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                {availableProfiles.map((profile, index) => {
                  console.log('Perfil no modal:', profile)
                  return (
                    <label
                      key={`profile-${profile.id}-${index}`}
                      className={cn(
                        "flex items-start gap-3 p-4 rounded-lg border cursor-pointer transition-colors",
                        selectedProfiles.includes(profile.id)
                          ? "border-primary bg-primary/10"
                          : "border-border hover:bg-accent/50"
                      )}
                    >
                      <input
                        type="checkbox"
                        checked={selectedProfiles.includes(profile.id)}
                        onChange={() => onToggleProfile(profile.id)}
                        className="mt-1 rounded"
                      />
                      <div className="flex-1">
                        <div className="font-medium text-foreground">{profile.nome_perfil}</div>
                        <div className="text-sm text-muted-foreground mt-1">
                          {profile.descricao || profile.description || 'Sem descrição'}
                        </div>
                      </div>
                    </label>
                  )
                })}
              </div>
            )}
          </div>
        </div>

        {/* Footer */}
        <div className="flex items-center justify-between p-6 border-t border-border flex-shrink-0">
          <div className="text-sm text-muted-foreground">
            {selectedProfiles.length} perfil{selectedProfiles.length !== 1 ? 's' : ''} selecionado{selectedProfiles.length !== 1 ? 's' : ''}
          </div>
          <div className="flex gap-3">
            <button
              onClick={onClose}
              className="btn-secondary px-4 py-2 min-w-[100px]"
            >
              Cancelar
            </button>
            <button
              onClick={onSave}
              disabled={loading}
              className="btn-primary flex items-center gap-2 px-4 py-2 min-w-[120px]"
            >
              <Shield className="w-4 h-4" />
              {loading ? 'Salvando...' : 'Salvar Perfis'}
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
