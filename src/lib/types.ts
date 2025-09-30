export type UUID = string

export interface LoginRequest {
  email: string
  password: string
  ativo: boolean
}

export interface LoginResponse {
  token: string
  name: string
}

export interface DashboardKpis {
  totalUsers: number
  activeCompanies: number
  uploads: number
  leadsProspected: number
}

export interface DashboardRecentActivityItem {
  id: string
  description: string
  timestamp: string
}

export interface DashboardWeeklyPoint {
  date: string
  value: number
}

export interface DashboardResponse extends DashboardKpis {
  recent: DashboardRecentActivityItem[]
  weeklySeries: DashboardWeeklyPoint[]
}

export interface SaudacaoItem {
  id: UUID
  title: string
  content: string
  active?: boolean
  createdAt?: string
}

export interface CreateSaudacaoPayload {
  title: string
  content: string
}

export interface ToggleSaudacaoPayload {
  id: UUID
  active: boolean
}

export interface DeleteByIdPayload {
  id: UUID
}

export interface UsuarioItem {
  id: UUID
  name: string
  email: string
}

export interface CreateUsuarioPayload {
  name: string
  email: string
  senha: string
}

export interface EmpresaItem {
  id: UUID
  name: string
  cnpj: string
}

export interface CreateEmpresaPayload {
  name: string
  cnpj: string
}

export interface EditEmpresaPayload extends Partial<CreateEmpresaPayload> {
  id: UUID
}
