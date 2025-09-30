import React, { useState } from 'react'
import { X, Plus, Loader2 } from 'lucide-react'
import { callWebhook } from '../utils/webhook-client'

interface CreateAgentModalProps {
  isOpen: boolean
  onClose: () => void
  onAgentCreated: (agent: any) => void
  userId?: string
}

interface CreateAgentData {
  agent_name: string
  agent_type: string
  agent_id: string
  user_id: string
  action: 'create'
  icone: string
  cor: string
  descricao?: string
  ativo?: boolean
}

export const CreateAgentModal: React.FC<CreateAgentModalProps> = ({
  isOpen,
  onClose,
  onAgentCreated,
  userId
}) => {
  const [formData, setFormData] = useState<CreateAgentData>({
    agent_name: '',
    agent_type: '',
    agent_id: '',
    user_id: userId || '',
    action: 'create',
    icone: '🤖',
    cor: 'bg-blue-500',
    descricao: '',
    ativo: true
  })
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const generateAgentId = () => {
    // Gerar ID único baseado em timestamp e random
    const timestamp = Date.now().toString(36)
    const random = Math.random().toString(36).substr(2, 5)
    return `${timestamp}${random}`.toUpperCase()
  }

  const generateAgentType = (name: string) => {
    // Converter nome para tipo (ex: "Agente João" -> "agenteJoao")
    return name
      .toLowerCase()
      .replace(/\s+/g, '')
      .replace(/[^a-z0-9]/g, '')
      .substring(0, 20)
  }

  const handleInputChange = (field: keyof CreateAgentData, value: string | boolean) => {
    setFormData(prev => ({
      ...prev,
      [field]: value
    }))

    // Auto-gerar agent_id e agent_type baseado no nome
    if (field === 'agent_name' && typeof value === 'string' && value.trim()) {
      const agentId = generateAgentId()
      const agentType = generateAgentType(value)
      
      setFormData(prev => ({
        ...prev,
        agent_id: agentId,
        agent_type: agentType
      }))
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!formData.agent_name.trim()) {
      setError('Nome do agente é obrigatório')
      return
    }

    if (!formData.user_id.trim()) {
      setError('ID do usuário é obrigatório')
      return
    }

    setIsLoading(true)
    setError(null)

    try {
      console.log('🚀 Criando novo agente:', formData)
      console.log('🔍 Campos icone e cor:', { icone: formData.icone, cor: formData.cor })
      
      // Incluir todos os campos necessários no payload
      const payload = {
        ...formData,
        icone: formData.icone,
        cor: formData.cor
      }
      
      console.log('📦 Payload final:', payload)
      
      const response = await callWebhook('webhook/create-agente', { data: payload })
      
      console.log('✅ Agente criado com sucesso:', response)
      
      // Chamar callback com dados do agente criado
      onAgentCreated({
        id: response.data?.agentId || formData.agent_id,
        name: response.data?.agentName || formData.agent_name,
        type: formData.agent_type,
        status: 'stopped',
        executionId: response.data?.executionId || null,
        workflows: response.data?.workflows || {}
      })

      // Limpar formulário e fechar modal
      setFormData({
        agent_name: '',
        agent_type: '',
        agent_id: '',
        user_id: '',
        action: 'create',
        icone: '🤖',
        cor: 'bg-blue-500',
        descricao: '',
        ativo: true
      })
      onClose()
      
    } catch (error) {
      console.error('❌ Erro ao criar agente:', error)
      setError(error instanceof Error ? error.message : 'Erro ao criar agente')
    } finally {
      setIsLoading(false)
    }
  }

  const handleClose = () => {
    if (!isLoading) {
      setFormData({
        agent_name: '',
        agent_type: '',
        agent_id: '',
        user_id: '',
        action: 'create',
        icone: '🤖',
        cor: 'bg-blue-500',
        descricao: '',
        ativo: true
      })
      setError(null)
      onClose()
    }
  }

  if (!isOpen) return null

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg shadow-xl w-full max-w-md mx-4">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b">
          <h2 className="text-xl font-semibold text-gray-900">
            Criar Novo Agente
          </h2>
          <button
            onClick={handleClose}
            disabled={isLoading}
            className="text-gray-400 hover:text-gray-600 transition-colors"
          >
            <X size={20} />
          </button>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          {/* Nome do Agente */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Nome do Agente *
            </label>
            <input
              type="text"
              value={formData.agent_name}
              onChange={(e) => handleInputChange('agent_name', e.target.value)}
              placeholder="Ex: Agente João"
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              disabled={isLoading}
              required
            />
          </div>

          {/* Tipo do Agente (auto-gerado) */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Tipo do Agente (auto-gerado)
            </label>
            <input
              type="text"
              value={formData.agent_type}
              readOnly
              className="w-full px-3 py-2 border border-gray-300 rounded-md bg-gray-50 text-gray-600"
            />
          </div>

          {/* ID do Agente (auto-gerado) */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              ID do Agente (auto-gerado)
            </label>
            <input
              type="text"
              value={formData.agent_id}
              readOnly
              className="w-full px-3 py-2 border border-gray-300 rounded-md bg-gray-50 text-gray-600"
            />
          </div>

          {/* ID do Usuário */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              ID do Usuário *
            </label>
            <input
              type="text"
              value={formData.user_id}
              onChange={(e) => handleInputChange('user_id', e.target.value)}
              placeholder="Ex: user123"
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              disabled={isLoading || !!userId}
              required
            />
            {userId && (
              <p className="text-xs text-gray-500 mt-1">
                Preenchido automaticamente com seu ID de usuário
              </p>
            )}
          </div>

          {/* Ícone do Agente */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Ícone do Agente
            </label>
            <select
              value={formData.icone}
              onChange={(e) => handleInputChange('icone', e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              disabled={isLoading}
            >
              <option value="🤖">🤖 Robô</option>
              <option value="🧠">🧠 Cérebro</option>
              <option value="⚡">⚡ Raio</option>
              <option value="🚀">🚀 Foguete</option>
              <option value="💼">💼 Maleta</option>
              <option value="🎯">🎯 Alvo</option>
              <option value="🔥">🔥 Fogo</option>
              <option value="⭐">⭐ Estrela</option>
            </select>
          </div>

          {/* Cor do Agente */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Cor do Agente
            </label>
            <select
              value={formData.cor}
              onChange={(e) => handleInputChange('cor', e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              disabled={isLoading}
            >
              <option value="bg-blue-500">🔵 Azul</option>
              <option value="bg-green-500">🟢 Verde</option>
              <option value="bg-red-500">🔴 Vermelho</option>
              <option value="bg-yellow-500">🟡 Amarelo</option>
              <option value="bg-purple-500">🟣 Roxo</option>
              <option value="bg-pink-500">🩷 Rosa</option>
              <option value="bg-indigo-500">🟦 Índigo</option>
              <option value="bg-orange-500">🟠 Laranja</option>
            </select>
          </div>

          {/* Descrição do Agente */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Descrição
            </label>
            <textarea
              value={formData.descricao || ''}
              onChange={(e) => handleInputChange('descricao', e.target.value)}
              placeholder="Descreva o propósito deste agente..."
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              rows={3}
              disabled={isLoading}
            />
          </div>

          {/* Status Ativo */}
          <div className="flex items-center">
            <input
              type="checkbox"
              id="ativo"
              checked={formData.ativo !== undefined ? formData.ativo : true}
              onChange={(e) => handleInputChange('ativo', e.target.checked)}
              className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              disabled={isLoading}
            />
            <label htmlFor="ativo" className="ml-2 block text-sm text-gray-700">
              Agente ativo
            </label>
          </div>

          {/* Error Message */}
          {error && (
            <div className="bg-red-50 border border-red-200 rounded-md p-3">
              <p className="text-sm text-red-600">{error}</p>
            </div>
          )}

          {/* Actions */}
          <div className="flex justify-end space-x-3 pt-4">
            <button
              type="button"
              onClick={handleClose}
              disabled={isLoading}
              className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 border border-gray-300 rounded-md hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-gray-500 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Cancelar
            </button>
            <button
              type="submit"
              disabled={isLoading || !formData.agent_name.trim() || !formData.user_id.trim()}
              className="px-4 py-2 text-sm font-medium text-white bg-blue-600 border border-transparent rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed flex items-center space-x-2"
            >
              {isLoading ? (
                <>
                  <Loader2 size={16} className="animate-spin" />
                  <span>Criando...</span>
                </>
              ) : (
                <>
                  <Plus size={16} />
                  <span>Criar Agente</span>
                </>
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}
