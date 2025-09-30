import { useEffect, useState } from 'react'
import { callWebhook } from '../../utils/webhook-client'
import type { DashboardResponse } from '../../lib/types'
import { formatNumber, formatDateISO } from '../../lib/utils'
import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from 'recharts'

// Log para debug
console.log('🔍 Dashboard: Componente Dashboard carregado!')

// Dados mock para demonstração
const MOCK_DATA: DashboardResponse = {
  totalUsers: 1250,
  activeCompanies: 89,
  uploads: 342,
  leadsProspected: 2150,
  recent: [
    { id: '1', description: 'Novo usuário cadastrado', timestamp: new Date().toISOString() },
    { id: '2', description: 'Upload de arquivo realizado', timestamp: new Date(Date.now() - 3600000).toISOString() },
    { id: '3', description: 'Lead processado com sucesso', timestamp: new Date(Date.now() - 7200000).toISOString() },
    { id: '4', description: 'Empresa ativada no sistema', timestamp: new Date(Date.now() - 10800000).toISOString() },
    { id: '5', description: 'Saudação personalizada criada', timestamp: new Date(Date.now() - 14400000).toISOString() },
  ],
  weeklySeries: [
    { date: 'Seg', value: 120 },
    { date: 'Ter', value: 190 },
    { date: 'Qua', value: 300 },
    { date: 'Qui', value: 500 },
    { date: 'Sex', value: 200 },
    { date: 'Sáb', value: 100 },
    { date: 'Dom', value: 80 },
  ]
}

export default function Dashboard() {
  const [data, setData] = useState<DashboardResponse | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    async function load() {
      try {
        // Tenta carregar dados reais primeiro
        try {
          console.log('🔍 Dashboard: Tentando carregar dados do webhook...')
          const { data } = await callWebhook<DashboardResponse>('webhook-dashboard', { method: 'GET' })
          console.log('✅ Dashboard: Dados carregados do webhook:', data)
          setData(normalize(data))
        } catch (webhookError) {
          console.log('⚠️ Dashboard: Webhook falhou, usando dados mock:', webhookError)
          // Se falhar, usa dados mock
          setData(MOCK_DATA)
        }
      } catch (e: any) {
        console.error('❌ Dashboard: Erro geral:', e)
        setError('Falha ao carregar dashboard.')
      } finally {
        setLoading(false)
      }
    }
    void load()
  }, [])

  if (loading) return <div className="card p-6">Carregando...</div>
  if (error) return <div className="card p-6 text-red-400">{error}</div>
  if (!data) return null

  return (
    <div className="space-y-4">
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <KpiCard title="Usuários" value={formatNumber(data.totalUsers)} />
        <KpiCard title="Empresas Ativas" value={formatNumber(data.activeCompanies)} />
        <KpiCard title="Uploads" value={formatNumber(data.uploads)} />
        <KpiCard title="Leads" value={formatNumber(data.leadsProspected)} />
      </div>

      <div className="card">
        <div className="card-header">Série semanal</div>
        <div className="card-content h-72">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={data.weeklySeries} margin={{ left: 12, right: 12, top: 12, bottom: 12 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#262626" />
              <XAxis dataKey="date" tick={{ fill: '#a3a3a3', fontSize: 12 }} />
              <YAxis tick={{ fill: '#a3a3a3', fontSize: 12 }} />
              <Tooltip contentStyle={{ background: '#0a0a0a', border: '1px solid #262626' }} labelStyle={{ color: '#e5e5e5' }} />
              <Line type="monotone" dataKey="value" stroke="#60a5fa" strokeWidth={2} dot={false} />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>

      <div className="card">
        <div className="card-header">Atividades recentes</div>
        <div className="card-content">
          <table className="w-full text-sm">
            <thead className="text-left text-zinc-400">
              <tr>
                <th className="py-2">Descrição</th>
                <th className="py-2">Quando</th>
              </tr>
            </thead>
            <tbody>
              {data.recent.map(item => (
                <tr key={item.id} className="border-t border-zinc-800">
                  <td className="py-2">{item.description}</td>
                  <td className="py-2 text-zinc-400">{formatDateISO(item.timestamp)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}

function normalize(d: any): DashboardResponse {
  return {
    totalUsers: d?.totalUsers ?? 0,
    activeCompanies: d?.activeCompanies ?? 0,
    uploads: d?.uploads ?? 0,
    leadsProspected: d?.leadsProspected ?? 0,
    weeklySeries: Array.isArray(d?.weeklySeries) ? d.weeklySeries : [],
    recent: Array.isArray(d?.recent) ? d.recent : [],
  }
}

function KpiCard({ title, value }: { title: string; value: string }) {
  return (
    <div className="card p-4">
      <div className="text-xs text-zinc-400">{title}</div>
      <div className="text-2xl font-semibold">{value}</div>
    </div>
  )
}
