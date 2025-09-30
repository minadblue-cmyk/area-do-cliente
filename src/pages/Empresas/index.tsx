import React, { useState, useEffect } from 'react'
import { callWebhook } from '../../utils/webhook-client'
import { useToastStore } from '../../store/toast'
import { Plus, Edit, Trash2, Save, X, Search, RefreshCw } from 'lucide-react'

interface EmpresaItem {
  id: number
  nome_empresa: string
  cnpj: string
  created_at?: string
  email?: string
  telefone?: string
  celular?: string
  endereco?: string
  logradouro?: string
  numero?: string
  complemento?: string
  bairro?: string
  cidade?: string
  estado?: string
  cep?: string
  inscricao_estadual?: string
  inscricao_municipal?: string
  regime_tributario?: string
  cnae?: string
  banco?: string
  agencia?: string
  conta_corrente?: string
  descricao?: string
}

interface CreateEmpresaPayload {
  nome: string
  cnpj: string
  email: string
  telefone: string
  celular: string
  logradouro: string
  numero: string
  complemento: string
  bairro: string
  cidade: string
  estado: string
  cep: string
  inscricao_estadual: string
  inscricao_municipal: string
  regime_tributario: string
  cnae: string
  banco: string
  agencia: string
  conta_corrente: string
  descricao: string
  action: string
}

interface EditEmpresaPayload {
  id: number
  nome_empresa: string
  cnpj: string
  email?: string
  telefone?: string
  celular?: string
  logradouro?: string
  numero?: string
  complemento?: string
  bairro?: string
  cidade?: string
  estado?: string
  cep?: string
  inscricao_estadual?: string
  inscricao_municipal?: string
  regime_tributario?: string
  cnae?: string
  banco?: string
  agencia?: string
  conta_corrente?: string
  descricao?: string
}

export default function Empresas() {
  const push = useToastStore((s) => s.push)
  
  // Estados principais
  const [empresas, setEmpresas] = useState<EmpresaItem[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  
  // Estados do formulário de criação
  const [showCreateForm, setShowCreateForm] = useState(false)
  const [formData, setFormData] = useState({
    nome_empresa: '',
    cnpj: '',
    email: '',
    telefone: '',
    celular: '',
    logradouro: '',
    numero: '',
    complemento: '',
    bairro: '',
    cidade: '',
    estado: '',
    cep: '',
    inscricao_estadual: '',
    inscricao_municipal: '',
    regime_tributario: '',
    cnae: '',
    banco: '',
    agencia: '',
    conta_corrente: '',
    descricao: ''
  })
  
  // Estados do formulário de edição
  const [showEditForm, setShowEditForm] = useState(false)
  const [editingEmpresa, setEditingEmpresa] = useState<EmpresaItem | null>(null)

  // Carregar empresas
  async function loadEmpresas() {
    setLoading(true)
    try {
      const { data: empresas } = await callWebhook<EmpresaItem[]>('webhook/list-company')
      
      console.log('Resposta do webhook/list-company:', empresas)
      
      // Verificar se a resposta é HTML (404 do n8n)
      if (typeof empresas === 'string' && (empresas as string).includes('<!DOCTYPE html>')) {
        console.warn('Webhook retornou HTML 404, usando dados mock')
        push({ 
          kind: 'warning', 
          message: 'Webhook de empresas não encontrado. Usando dados de exemplo.' 
        })
        
        // Dados mock para desenvolvimento
        setEmpresas([
          { id: 1, nome_empresa: 'Empresa Teste 1', cnpj: '00.000.000/0001-00' },
          { id: 2, nome_empresa: 'Empresa Teste 2', cnpj: '11.111.111/0001-11' },
          { id: 3, nome_empresa: 'Empresa Teste 3', cnpj: '22.222.222/0001-22' }
        ])
        return
      }
      
      // Processar resposta real - n8n retorna array direto
      if (Array.isArray(empresas)) {
        console.log('Empresas carregadas:', empresas.length)
        setEmpresas(empresas)
      } else {
        console.warn('Formato de resposta inesperado:', empresas)
        setEmpresas([])
      }
      
    } catch (error: any) {
      console.error('Erro ao carregar empresas:', error)
      
      // Fallback para dados mock em caso de erro
      push({ 
        kind: 'warning', 
        message: 'Erro ao carregar empresas. Usando dados de exemplo.' 
      })
      
      setEmpresas([
        { id: 1, nome_empresa: 'Empresa Teste 1', cnpj: '00.000.000/0001-00' },
        { id: 2, nome_empresa: 'Empresa Teste 2', cnpj: '11.111.111/0001-11' },
        { id: 3, nome_empresa: 'Empresa Teste 3', cnpj: '22.222.222/0001-22' }
      ])
    } finally {
      setLoading(false)
    }
  }

  // Criar empresa
  async function createEmpresa(e: React.FormEvent) {
    e.preventDefault()
    
    if (!formData.nome_empresa.trim() || !formData.cnpj.trim()) {
      push({ kind: 'error', message: 'Preencha todos os campos obrigatórios.' })
      return
    }

    try {
      const payload = {
        // Dados básicos
        nome: formData.nome_empresa.trim(),
        cnpj: formData.cnpj.trim(),
        email: formData.email.trim() || '',
        telefone: formData.telefone.trim() || '',
        celular: formData.celular.trim() || '',
        
        // Endereço completo
        logradouro: formData.logradouro.trim() || '',
        numero: formData.numero.trim() || '',
        complemento: formData.complemento.trim() || '',
        bairro: formData.bairro.trim() || '',
        cidade: formData.cidade.trim() || '',
        estado: formData.estado.trim() || '',
        cep: formData.cep.trim() || '',
        
        // Dados fiscais
        inscricao_estadual: formData.inscricao_estadual.trim() || '',
        inscricao_municipal: formData.inscricao_municipal.trim() || '',
        regime_tributario: formData.regime_tributario.trim() || '',
        cnae: formData.cnae.trim() || '',
        
        // Dados bancários
        banco: formData.banco.trim() || '',
        agencia: formData.agencia.trim() || '',
        conta_corrente: formData.conta_corrente.trim() || '',
        
        // Outros
        descricao: formData.descricao.trim() || '',
        action: "create_company"
      }

      await callWebhook('webhook-criar-empresa', { 
        method: 'POST', 
        data: payload 
      })

      push({ kind: 'success', message: 'Empresa criada com sucesso!' })
      
      // Limpar formulário e fechar
      setFormData({ 
        nome_empresa: '', 
        cnpj: '', 
        email: '', 
        telefone: '', 
        celular: '',
        logradouro: '',
        numero: '',
        complemento: '',
        bairro: '',
        cidade: '',
        estado: '',
        cep: '',
        inscricao_estadual: '',
        inscricao_municipal: '',
        regime_tributario: '',
        cnae: '',
        banco: '',
        agencia: '',
        conta_corrente: '',
        descricao: '' 
      })
      setShowCreateForm(false)
      
      // Recarregar lista
      await loadEmpresas()
      
    } catch (error: any) {
      console.error('Erro ao criar empresa:', error)
      push({ kind: 'error', message: 'Erro ao criar empresa. Tente novamente.' })
    }
  }

  // Editar empresa
  function editEmpresa(empresa: EmpresaItem) {
    setEditingEmpresa(empresa)
    setFormData({
      nome_empresa: empresa.nome_empresa,
      cnpj: empresa.cnpj,
      email: empresa.email || '',
      telefone: empresa.telefone || '',
      celular: empresa.celular || '',
      logradouro: empresa.logradouro || '',
      numero: empresa.numero || '',
      complemento: empresa.complemento || '',
      bairro: empresa.bairro || '',
      cidade: empresa.cidade || '',
      estado: empresa.estado || '',
      cep: empresa.cep || '',
      inscricao_estadual: empresa.inscricao_estadual || '',
      inscricao_municipal: empresa.inscricao_municipal || '',
      regime_tributario: empresa.regime_tributario || '',
      cnae: empresa.cnae || '',
      banco: empresa.banco || '',
      agencia: empresa.agencia || '',
      conta_corrente: empresa.conta_corrente || '',
      descricao: empresa.descricao || ''
    })
    setShowEditForm(true)
  }

  // Atualizar empresa
  async function updateEmpresa(e: React.FormEvent) {
    e.preventDefault()
    
    if (!editingEmpresa) return
    
    if (!formData.nome_empresa.trim() || !formData.cnpj.trim()) {
      push({ kind: 'error', message: 'Preencha todos os campos obrigatórios.' })
      return
    }

    try {
      const payload: EditEmpresaPayload = {
        id: editingEmpresa.id,
        nome_empresa: formData.nome_empresa.trim(),
        cnpj: formData.cnpj.trim(),
        email: formData.email.trim() || undefined,
        telefone: formData.telefone.trim() || undefined,
        celular: formData.celular.trim() || undefined,
        logradouro: formData.logradouro.trim() || undefined,
        numero: formData.numero.trim() || undefined,
        complemento: formData.complemento.trim() || undefined,
        bairro: formData.bairro.trim() || undefined,
        cidade: formData.cidade.trim() || undefined,
        estado: formData.estado.trim() || undefined,
        cep: formData.cep.trim() || undefined,
        inscricao_estadual: formData.inscricao_estadual.trim() || undefined,
        inscricao_municipal: formData.inscricao_municipal.trim() || undefined,
        regime_tributario: formData.regime_tributario.trim() || undefined,
        cnae: formData.cnae.trim() || undefined,
        banco: formData.banco.trim() || undefined,
        agencia: formData.agencia.trim() || undefined,
        conta_corrente: formData.conta_corrente.trim() || undefined,
        descricao: formData.descricao.trim() || undefined
      }

      await callWebhook('webhook/edit-company', { 
        method: 'POST', 
        data: payload 
      })

      push({ kind: 'success', message: 'Empresa atualizada com sucesso!' })
      
      // Limpar e fechar formulário
      setEditingEmpresa(null)
      setFormData({ 
        nome_empresa: '', 
        cnpj: '', 
        email: '', 
        telefone: '', 
        celular: '',
        logradouro: '',
        numero: '',
        complemento: '',
        bairro: '',
        cidade: '',
        estado: '',
        cep: '',
        inscricao_estadual: '',
        inscricao_municipal: '',
        regime_tributario: '',
        cnae: '',
        banco: '',
        agencia: '',
        conta_corrente: '',
        descricao: '' 
      })
      setShowEditForm(false)
      
      // Recarregar lista
      await loadEmpresas()
      
    } catch (error: any) {
      console.error('Erro ao atualizar empresa:', error)
      push({ kind: 'error', message: 'Erro ao atualizar empresa. Tente novamente.' })
    }
  }

  // Cancelar edição
  function cancelEdit() {
    setEditingEmpresa(null)
    setFormData({ 
      nome_empresa: '', 
      cnpj: '', 
      email: '', 
      telefone: '', 
      celular: '',
      logradouro: '',
      numero: '',
      complemento: '',
      bairro: '',
      cidade: '',
      estado: '',
      cep: '',
      inscricao_estadual: '',
      inscricao_municipal: '',
      regime_tributario: '',
      cnae: '',
      banco: '',
      agencia: '',
      conta_corrente: '',
      descricao: '' 
    })
    setShowEditForm(false)
  }

  // Excluir empresa
  async function deleteEmpresa(id: number) {
    if (!confirm('Tem certeza que deseja excluir esta empresa?')) {
      return
    }

    try {
      await callWebhook('webhook/delete-company', { 
        method: 'POST', 
        data: { 
          companyId: id
        } 
      })

      push({ kind: 'success', message: 'Empresa excluída com sucesso!' })
      
      // Recarregar lista
      await loadEmpresas()
      
    } catch (error: any) {
      console.error('Erro ao excluir empresa:', error)
      push({ kind: 'error', message: 'Erro ao excluir empresa. Tente novamente.' })
    }
  }

  // Filtrar empresas
  const filteredEmpresas = empresas.filter(empresa =>
    empresa.nome_empresa.toLowerCase().includes(searchTerm.toLowerCase()) ||
    empresa.cnpj.includes(searchTerm)
  )

  // Carregar dados na inicialização
  useEffect(() => {
    loadEmpresas()
  }, [])

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold text-foreground mb-2">Empresas</h1>
          <p className="text-muted-foreground">Gerencie empresas cadastradas no sistema</p>
        </div>
        <button
          onClick={() => setShowCreateForm(true)}
          className="btn btn-primary flex items-center gap-2"
        >
          <Plus className="w-4 h-4" />
          Nova Empresa
        </button>
      </div>

      {/* Formulário de Criação */}
      {showCreateForm && (
        <div className="card">
          <div className="card-header">
            <div className="flex items-center justify-between">
              <h2 className="text-lg font-semibold">Criar Nova Empresa</h2>
              <button
                onClick={() => setShowCreateForm(false)}
                className="text-muted-foreground hover:text-foreground"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
          </div>
          <div className="card-content">
            <form onSubmit={createEmpresa} className="space-y-6">
              {/* Dados Básicos */}
              <div className="space-y-4">
                <h3 className="text-md font-semibold text-primary">Dados Básicos</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Razão Social *
                    </label>
                    <input
                      type="text"
                      value={formData.nome_empresa}
                      onChange={(e) => setFormData({ ...formData, nome_empresa: e.target.value })}
                      className="input w-full"
                      placeholder="Digite a razão social da empresa"
                      required
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      CNPJ *
                    </label>
                    <input
                      type="text"
                      value={formData.cnpj}
                      onChange={(e) => setFormData({ ...formData, cnpj: e.target.value })}
                      className="input w-full"
                      placeholder="00.000.000/0001-00"
                      required
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Email *
                    </label>
                    <input
                      type="email"
                      value={formData.email}
                      onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                      className="input w-full"
                      placeholder="empresa@exemplo.com"
                      required
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Telefone
                    </label>
                    <input
                      type="tel"
                      value={formData.telefone}
                      onChange={(e) => setFormData({ ...formData, telefone: e.target.value })}
                      className="input w-full"
                      placeholder="(11) 99999-9999"
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Celular
                    </label>
                    <input
                      type="tel"
                      value={formData.celular}
                      onChange={(e) => setFormData({ ...formData, celular: e.target.value })}
                      className="input w-full"
                      placeholder="(11) 99999-9999"
                    />
                  </div>
                </div>
              </div>

              {/* Endereço Completo */}
              <div className="space-y-4">
                <h3 className="text-md font-semibold text-primary">Endereço Completo</h3>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div className="md:col-span-2">
                    <label className="block text-sm font-medium mb-2">
                      Logradouro *
                    </label>
                    <input
                      type="text"
                      value={formData.logradouro}
                      onChange={(e) => setFormData({ ...formData, logradouro: e.target.value })}
                      className="input w-full"
                      placeholder="Rua, Avenida, Alameda, etc."
                      required
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Número *
                    </label>
                    <input
                      type="text"
                      value={formData.numero}
                      onChange={(e) => setFormData({ ...formData, numero: e.target.value })}
                      className="input w-full"
                      placeholder="123"
                      required
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Complemento
                    </label>
                    <input
                      type="text"
                      value={formData.complemento}
                      onChange={(e) => setFormData({ ...formData, complemento: e.target.value })}
                      className="input w-full"
                      placeholder="Sala, Andar, Bloco"
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Bairro *
                    </label>
                    <input
                      type="text"
                      value={formData.bairro}
                      onChange={(e) => setFormData({ ...formData, bairro: e.target.value })}
                      className="input w-full"
                      placeholder="Centro, Vila Nova, etc."
                      required
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Cidade *
                    </label>
                    <input
                      type="text"
                      value={formData.cidade}
                      onChange={(e) => setFormData({ ...formData, cidade: e.target.value })}
                      className="input w-full"
                      placeholder="São Paulo"
                      required
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Estado (UF) *
                    </label>
                    <select
                      value={formData.estado}
                      onChange={(e) => setFormData({ ...formData, estado: e.target.value })}
                      className="input w-full"
                      required
                    >
                      <option value="">Selecione o estado</option>
                      <option value="AC">Acre</option>
                      <option value="AL">Alagoas</option>
                      <option value="AP">Amapá</option>
                      <option value="AM">Amazonas</option>
                      <option value="BA">Bahia</option>
                      <option value="CE">Ceará</option>
                      <option value="DF">Distrito Federal</option>
                      <option value="ES">Espírito Santo</option>
                      <option value="GO">Goiás</option>
                      <option value="MA">Maranhão</option>
                      <option value="MT">Mato Grosso</option>
                      <option value="MS">Mato Grosso do Sul</option>
                      <option value="MG">Minas Gerais</option>
                      <option value="PA">Pará</option>
                      <option value="PB">Paraíba</option>
                      <option value="PR">Paraná</option>
                      <option value="PE">Pernambuco</option>
                      <option value="PI">Piauí</option>
                      <option value="RJ">Rio de Janeiro</option>
                      <option value="RN">Rio Grande do Norte</option>
                      <option value="RS">Rio Grande do Sul</option>
                      <option value="RO">Rondônia</option>
                      <option value="RR">Roraima</option>
                      <option value="SC">Santa Catarina</option>
                      <option value="SP">São Paulo</option>
                      <option value="SE">Sergipe</option>
                      <option value="TO">Tocantins</option>
                    </select>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      CEP *
                    </label>
                    <input
                      type="text"
                      value={formData.cep}
                      onChange={(e) => setFormData({ ...formData, cep: e.target.value })}
                      className="input w-full"
                      placeholder="00000-000"
                      required
                    />
                  </div>
                </div>
              </div>

              {/* Dados Fiscais */}
              <div className="space-y-4">
                <h3 className="text-md font-semibold text-primary">Dados Fiscais</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Inscrição Estadual (IE)
                    </label>
                    <input
                      type="text"
                      value={formData.inscricao_estadual}
                      onChange={(e) => setFormData({ ...formData, inscricao_estadual: e.target.value })}
                      className="input w-full"
                      placeholder="123.456.789.012"
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Inscrição Municipal (IM)
                    </label>
                    <input
                      type="text"
                      value={formData.inscricao_municipal}
                      onChange={(e) => setFormData({ ...formData, inscricao_municipal: e.target.value })}
                      className="input w-full"
                      placeholder="123456"
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Regime Tributário *
                    </label>
                    <select
                      value={formData.regime_tributario}
                      onChange={(e) => setFormData({ ...formData, regime_tributario: e.target.value })}
                      className="input w-full"
                      required
                    >
                      <option value="">Selecione o regime</option>
                      <option value="1">Microempresa Nacional</option>
                      <option value="2">Estimativa</option>
                      <option value="3">Sociedade de Profissionais</option>
                      <option value="4">Cooperativa</option>
                      <option value="5">Microempresário Individual (MEI)</option>
                      <option value="6">Microempresa e Pequena Empresa (ME/EPP)</option>
                    </select>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      CNAE *
                    </label>
                    <input
                      type="text"
                      value={formData.cnae}
                      onChange={(e) => setFormData({ ...formData, cnae: e.target.value })}
                      className="input w-full"
                      placeholder="62.01-5-00"
                      required
                    />
                  </div>
                </div>
              </div>

              {/* Dados Bancários */}
              <div className="space-y-4">
                <h3 className="text-md font-semibold text-primary">Dados Bancários</h3>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Banco
                    </label>
                    <input
                      type="text"
                      value={formData.banco}
                      onChange={(e) => setFormData({ ...formData, banco: e.target.value })}
                      className="input w-full"
                      placeholder="Banco do Brasil, Itaú, etc."
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Agência
                    </label>
                    <input
                      type="text"
                      value={formData.agencia}
                      onChange={(e) => setFormData({ ...formData, agencia: e.target.value })}
                      className="input w-full"
                      placeholder="1234"
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Conta Corrente
                    </label>
                    <input
                      type="text"
                      value={formData.conta_corrente}
                      onChange={(e) => setFormData({ ...formData, conta_corrente: e.target.value })}
                      className="input w-full"
                      placeholder="12345-6"
                    />
                  </div>
                </div>
              </div>

              {/* Descrição */}
              <div className="space-y-4">
                <h3 className="text-md font-semibold text-primary">Informações Adicionais</h3>
                <div>
                  <label className="block text-sm font-medium mb-2">
                    Descrição da Empresa
                  </label>
                  <textarea
                    value={formData.descricao}
                    onChange={(e) => setFormData({ ...formData, descricao: e.target.value })}
                    className="input w-full min-h-[100px] resize-none"
                    placeholder="Descrição da empresa, atividades principais, histórico, etc."
                  />
                </div>
              </div>
              
              <div className="md:col-span-2 flex gap-2">
                <button type="submit" className="btn btn-primary flex items-center gap-2">
                  <Save className="w-4 h-4" />
                  Criar Empresa
                </button>
                <button
                  type="button"
                  onClick={() => setShowCreateForm(false)}
                  className="btn btn-secondary"
                >
                  Cancelar
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Formulário de Edição */}
      {showEditForm && editingEmpresa && (
        <div className="card">
          <div className="card-header">
            <div className="flex items-center justify-between">
              <h2 className="text-lg font-semibold">
                Editar Empresa: {editingEmpresa.nome_empresa}
              </h2>
              <button
                onClick={cancelEdit}
                className="text-muted-foreground hover:text-foreground"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
          </div>
          <div className="card-content">
            <form onSubmit={updateEmpresa} className="space-y-6">
              {/* Informações Básicas */}
              <div className="space-y-4">
                <h3 className="text-md font-semibold text-primary">Informações Básicas</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Nome da Empresa *
                    </label>
                    <input
                      type="text"
                      value={formData.nome_empresa}
                      onChange={(e) => setFormData({ ...formData, nome_empresa: e.target.value })}
                      className="input w-full"
                      placeholder="Digite o nome da empresa"
                      required
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      CNPJ *
                    </label>
                    <input
                      type="text"
                      value={formData.cnpj}
                      onChange={(e) => setFormData({ ...formData, cnpj: e.target.value })}
                      className="input w-full"
                      placeholder="00.000.000/0001-00"
                      required
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Email
                    </label>
                    <input
                      type="email"
                      value={formData.email}
                      onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                      className="input w-full"
                      placeholder="empresa@exemplo.com"
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Telefone
                    </label>
                    <input
                      type="tel"
                      value={formData.telefone}
                      onChange={(e) => setFormData({ ...formData, telefone: e.target.value })}
                      className="input w-full"
                      placeholder="(11) 99999-9999"
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Celular
                    </label>
                    <input
                      type="tel"
                      value={formData.celular}
                      onChange={(e) => setFormData({ ...formData, celular: e.target.value })}
                      className="input w-full"
                      placeholder="(11) 99999-9999"
                    />
                  </div>
                </div>
              </div>

              {/* Endereço */}
              <div className="space-y-4">
                <h3 className="text-md font-semibold text-primary">Endereço</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="md:col-span-2">
                    <label className="block text-sm font-medium mb-2">
                      Logradouro
                    </label>
                    <input
                      type="text"
                      value={formData.logradouro}
                      onChange={(e) => setFormData({ ...formData, logradouro: e.target.value })}
                      className="input w-full"
                      placeholder="Rua, Avenida, etc."
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Número
                    </label>
                    <input
                      type="text"
                      value={formData.numero}
                      onChange={(e) => setFormData({ ...formData, numero: e.target.value })}
                      className="input w-full"
                      placeholder="123"
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Complemento
                    </label>
                    <input
                      type="text"
                      value={formData.complemento}
                      onChange={(e) => setFormData({ ...formData, complemento: e.target.value })}
                      className="input w-full"
                      placeholder="Sala, Andar, etc."
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Bairro
                    </label>
                    <input
                      type="text"
                      value={formData.bairro}
                      onChange={(e) => setFormData({ ...formData, bairro: e.target.value })}
                      className="input w-full"
                      placeholder="Centro, Vila, etc."
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Cidade
                    </label>
                    <input
                      type="text"
                      value={formData.cidade}
                      onChange={(e) => setFormData({ ...formData, cidade: e.target.value })}
                      className="input w-full"
                      placeholder="São Paulo"
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Estado
                    </label>
                    <input
                      type="text"
                      value={formData.estado}
                      onChange={(e) => setFormData({ ...formData, estado: e.target.value })}
                      className="input w-full"
                      placeholder="SP"
                      maxLength={2}
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      CEP
                    </label>
                    <input
                      type="text"
                      value={formData.cep}
                      onChange={(e) => setFormData({ ...formData, cep: e.target.value })}
                      className="input w-full"
                      placeholder="00000-000"
                    />
                  </div>
                </div>
              </div>

              {/* Dados Fiscais */}
              <div className="space-y-4">
                <h3 className="text-md font-semibold text-primary">Dados Fiscais</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Inscrição Estadual
                    </label>
                    <input
                      type="text"
                      value={formData.inscricao_estadual}
                      onChange={(e) => setFormData({ ...formData, inscricao_estadual: e.target.value })}
                      className="input w-full"
                      placeholder="123.456.789.012"
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Inscrição Municipal
                    </label>
                    <input
                      type="text"
                      value={formData.inscricao_municipal}
                      onChange={(e) => setFormData({ ...formData, inscricao_municipal: e.target.value })}
                      className="input w-full"
                      placeholder="987654321"
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Regime Tributário
                    </label>
                    <select
                      value={formData.regime_tributario}
                      onChange={(e) => setFormData({ ...formData, regime_tributario: e.target.value })}
                      className="input w-full"
                    >
                      <option value="">Selecione o regime</option>
                      <option value="Simples Nacional">Simples Nacional</option>
                      <option value="Lucro Real">Lucro Real</option>
                      <option value="Lucro Presumido">Lucro Presumido</option>
                      <option value="Microempresa Nacional">Microempresa Nacional</option>
                      <option value="Estimativa">Estimativa</option>
                      <option value="Sociedade de Profissionais">Sociedade de Profissionais</option>
                      <option value="Cooperativa">Cooperativa</option>
                      <option value="Microempresário Individual (MEI)">Microempresário Individual (MEI)</option>
                      <option value="Microempresa e Pequena Empresa (ME/EPP)">Microempresa e Pequena Empresa (ME/EPP)</option>
                    </select>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      CNAE
                    </label>
                    <input
                      type="text"
                      value={formData.cnae}
                      onChange={(e) => setFormData({ ...formData, cnae: e.target.value })}
                      className="input w-full"
                      placeholder="62.01-5-00"
                    />
                  </div>
                </div>
              </div>

              {/* Dados Bancários */}
              <div className="space-y-4">
                <h3 className="text-md font-semibold text-primary">Dados Bancários</h3>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Banco
                    </label>
                    <input
                      type="text"
                      value={formData.banco}
                      onChange={(e) => setFormData({ ...formData, banco: e.target.value })}
                      className="input w-full"
                      placeholder="Banco do Brasil, Itaú, etc."
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Agência
                    </label>
                    <input
                      type="text"
                      value={formData.agencia}
                      onChange={(e) => setFormData({ ...formData, agencia: e.target.value })}
                      className="input w-full"
                      placeholder="1234"
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium mb-2">
                      Conta Corrente
                    </label>
                    <input
                      type="text"
                      value={formData.conta_corrente}
                      onChange={(e) => setFormData({ ...formData, conta_corrente: e.target.value })}
                      className="input w-full"
                      placeholder="12345-6"
                    />
                  </div>
                </div>
              </div>

              {/* Descrição */}
              <div className="space-y-4">
                <h3 className="text-md font-semibold text-primary">Informações Adicionais</h3>
                <div>
                  <label className="block text-sm font-medium mb-2">
                    Descrição da Empresa
                  </label>
                  <textarea
                    value={formData.descricao}
                    onChange={(e) => setFormData({ ...formData, descricao: e.target.value })}
                    className="input w-full min-h-[100px] resize-none"
                    placeholder="Descrição da empresa, atividades principais, histórico, etc."
                  />
                </div>
              </div>
              
              <div className="flex gap-2">
                <button type="submit" className="btn btn-primary flex items-center gap-2">
                  <Save className="w-4 h-4" />
                  Atualizar Empresa
                </button>
                <button
                  type="button"
                  onClick={cancelEdit}
                  className="btn btn-secondary"
                >
                  Cancelar
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Barra de Busca */}
      <div className="card">
        <div className="card-content">
          <div className="flex items-center gap-4">
            <div className="flex-1 relative">
              <Search className="w-5 h-5 text-muted-foreground absolute left-3 top-1/2 transform -translate-y-1/2" />
              <input
                type="text"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="input pl-10 w-full"
                placeholder="Buscar empresas por nome ou CNPJ..."
              />
            </div>
            <button
              onClick={loadEmpresas}
              className="btn btn-secondary flex items-center gap-2"
              disabled={loading}
            >
              <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
              Atualizar
            </button>
          </div>
        </div>
      </div>

      {/* Lista de Empresas */}
      <div className="card">
        <div className="card-header">
          <div className="flex items-center justify-between">
            <h2 className="text-lg font-semibold">Empresas</h2>
            <span className="text-sm text-muted-foreground">
              {filteredEmpresas.length} empresa(s) encontrada(s)
            </span>
          </div>
        </div>
        <div className="card-content">
          {loading ? (
            <div className="flex items-center justify-center py-8">
              <RefreshCw className="w-6 h-6 animate-spin text-primary" />
              <span className="ml-2 text-muted-foreground">Carregando empresas...</span>
            </div>
          ) : filteredEmpresas.length === 0 ? (
            <div className="text-center py-8">
              <p className="text-muted-foreground">
                {searchTerm ? 'Nenhuma empresa encontrada para a busca.' : 'Nenhuma empresa cadastrada.'}
              </p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead className="text-left text-muted-foreground border-b">
                  <tr>
                    <th className="py-3 px-4">Nome</th>
                    <th className="py-3 px-4">CNPJ</th>
                    <th className="py-3 px-4">Email</th>
                    <th className="py-3 px-4 text-right">Ações</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredEmpresas.map(empresa => (
                    <tr key={empresa.id} className="border-b hover:bg-muted/50">
                      <td className="py-3 px-4">
                        <div className="font-medium">{empresa.nome_empresa}</div>
                        {empresa.descricao && (
                          <div className="text-xs text-muted-foreground mt-1 truncate max-w-xs">
                            {empresa.descricao}
                          </div>
                        )}
                      </td>
                      <td className="py-3 px-4 text-muted-foreground">{empresa.cnpj}</td>
                      <td className="py-3 px-4 text-muted-foreground">{empresa.email || '-'}</td>
                      <td className="py-3 px-4 text-right">
                        <div className="flex items-center justify-end gap-2">
                          <button
                            onClick={() => editEmpresa(empresa)}
                            className="btn btn-secondary flex items-center gap-1 text-xs"
                          >
                            <Edit className="w-3 h-3" />
                            Editar
                          </button>
                          <button
                            onClick={() => deleteEmpresa(empresa.id)}
                            className="btn btn-outline flex items-center gap-1 text-xs"
                          >
                            <Trash2 className="w-3 h-3" />
                            Excluir
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}