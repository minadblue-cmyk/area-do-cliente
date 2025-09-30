import { useState } from 'react'

interface AgentDebugPanelProps {
  dynamicAgentTypes: Record<string, any>
  agents: Record<string, any>
}

export function AgentDebugPanel({ 
  dynamicAgentTypes, 
  agents 
}: AgentDebugPanelProps) {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <div className="fixed bottom-4 right-4 z-50">
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="bg-blue-500 text-white px-4 py-2 rounded-lg shadow-lg hover:bg-blue-600"
      >
        {isOpen ? 'Fechar Debug' : 'Abrir Debug'}
      </button>
      
      {isOpen && (
        <div className="absolute bottom-16 right-0 w-96 max-h-96 overflow-y-auto bg-white border border-gray-300 rounded-lg shadow-xl p-4">
          <h3 className="font-bold text-lg mb-4">🔍 Debug de Agentes</h3>
          
          <div className="space-y-4">
            <div>
              <h4 className="font-semibold text-sm text-gray-700">Dynamic Agent Types:</h4>
              <pre className="text-xs bg-gray-100 p-2 rounded overflow-x-auto">
                {JSON.stringify(dynamicAgentTypes, null, 2)}
              </pre>
            </div>
            
            <div>
              <h4 className="font-semibold text-sm text-gray-700">Agents (Status):</h4>
              <pre className="text-xs bg-gray-100 p-2 rounded overflow-x-auto">
                {JSON.stringify(agents, null, 2)}
              </pre>
            </div>
            
            <div>
              <h4 className="font-semibold text-sm text-gray-700">Sistema de Sincronização:</h4>
              <p className="text-xs text-gray-600">
                Os agentes são carregados dinamicamente via webhook list-agentes
              </p>
            </div>
            
            <div>
              <h4 className="font-semibold text-sm text-gray-700">Resumo:</h4>
              <ul className="text-xs space-y-1">
                <li>• Dynamic Agent Types: {Object.keys(dynamicAgentTypes).length} itens</li>
                <li>• Agents (Status): {Object.keys(agents).length} itens</li>
                <li>• Sistema: Dinâmico (via webhook)</li>
                <li>• Status: {Object.keys(dynamicAgentTypes).length > 0 ? 'Ativo' : 'Vazio'}</li>
              </ul>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
