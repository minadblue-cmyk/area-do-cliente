import { useState } from 'react'
import { useAuthStore } from '../../store/auth'
import { useToastStore } from '../../store/toast'
import { useNavigate, useLocation } from 'react-router-dom'
import { LogoWithText } from '../../components/ui/Logo'

export default function Login() {
  const login = useAuthStore((s) => s.login)
  const loading = useAuthStore((s) => s.loading)
  const push = useToastStore((s) => s.push)
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const navigate = useNavigate()
  const location = useLocation() as any
  const from = location.state?.from?.pathname || '/dashboard'

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault()
    
    // Fazer login com validação de usuário ativo
    const ok = await login({ 
      email, 
      password,
      ativo: true  // Sempre enviar como true - o backend deve validar se está ativo
    })
    
    if (!ok) {
      push({ kind: 'error', message: 'Credenciais inválidas ou usuário inativo.' })
    } else {
      push({ kind: 'success', message: 'Login realizado com sucesso.' })
      navigate(from, { replace: true })
    }
  }

  return (
    <div className="flex items-center justify-center min-h-screen px-4 bg-background">
      <form onSubmit={onSubmit} className="card w-full max-w-lg px-8 py-10 space-y-6">
        <div className="flex flex-col items-center text-center space-y-4">
          {/* Logo da empresa */}
          <LogoWithText size={56} className="mb-2" />
          <div>
            <h1 className="text-2xl font-semibold text-foreground">Área do Cliente</h1>
            <p className="text-sm text-muted-foreground">Faça login para acessar o sistema</p>
          </div>
        </div>

        <div className="grid gap-4">
          <div>
            <label className="text-xs text-muted-foreground">Email</label>
            <input 
              className="input mt-1" 
              type="email" 
              placeholder="seu@email.com" 
              value={email} 
              onChange={e => setEmail(e.target.value)} 
              required 
            />
          </div>
          <div>
            <label className="text-xs text-muted-foreground">Senha</label>
            <input 
              className="input mt-1" 
              type="password" 
              placeholder="•••••••" 
              value={password} 
              onChange={e => setPassword(e.target.value)} 
              required 
            />
          </div>
        </div>

        <button
          type="submit"
          disabled={loading}
          className="btn btn-primary w-full"
        >
          {loading ? 'Entrando...' : 'Entrar'}
        </button>
      </form>
    </div>
  )
}
