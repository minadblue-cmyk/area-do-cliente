import React from 'react'
import { Shield, X } from 'lucide-react'
import { cn } from '../../lib/utils'

interface ProfileItem {
  id: number
  nome_perfil: string
  descricao?: string
  description?: string  // Campo alternativo
}

interface ProfileSelectorProps {
  selectedProfiles: number[]
  availableProfiles: ProfileItem[]
  onToggleProfile: (profileId: number) => void
  onOpenSelector: () => void
  disabled?: boolean
}

export function ProfileSelector({ 
  selectedProfiles, 
  availableProfiles, 
  onToggleProfile, 
  onOpenSelector,
  disabled = false 
}: ProfileSelectorProps) {
  return (
    <div className="space-y-2">
      <label className="text-sm font-medium text-foreground">
        Perfis de Acesso
      </label>
      <div className="space-y-2">
        {/* Campo de visualização dos perfis selecionados */}
        <div 
          className={cn(
            "input cursor-pointer hover:bg-accent/50 transition-colors",
            disabled && "opacity-50 cursor-not-allowed"
          )}
          onClick={disabled ? undefined : onOpenSelector}
        >
          {selectedProfiles.length > 0 ? (
            <div className="flex flex-wrap gap-1">
              {selectedProfiles.map((profileId, index) => {
                const profile = availableProfiles.find(p => p.id === profileId)
                return profile ? (
                  <span 
                    key={`selected-profile-${profileId}-${index}`}
                    className="inline-flex items-center gap-1 px-2 py-1 bg-primary/20 text-primary text-xs rounded-full"
                  >
                    {profile.nome_perfil}
                    <button
                      type="button"
                      onClick={(e) => {
                        e.stopPropagation()
                        onToggleProfile(profileId)
                      }}
                      className="ml-1 hover:text-destructive"
                      disabled={disabled}
                    >
                      ×
                    </button>
                  </span>
                ) : null
              })}
            </div>
          ) : (
            <span className="text-muted-foreground">
              {disabled ? 'Carregando perfis...' : 'Clique para selecionar perfis'}
            </span>
          )}
        </div>
        
        {/* Botão para gerenciar perfis */}
        <button
          type="button"
          onClick={onOpenSelector}
          disabled={disabled}
          className="btn-secondary w-full flex items-center justify-center gap-2"
        >
          <Shield className="w-4 h-4" />
          Gerenciar Perfis ({selectedProfiles.length})
        </button>
      </div>
    </div>
  )
}
