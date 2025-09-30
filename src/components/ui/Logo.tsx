interface LogoProps {
  size?: number
  className?: string
}

export function Logo({ size = 48, className = "" }: LogoProps) {
  // Gerar IDs únicos para evitar conflitos entre múltiplas instâncias
  const gradientId = `logo-gradient-${Math.random().toString(36).substr(2, 9)}`
  const borderGradientId = `logo-border-gradient-${Math.random().toString(36).substr(2, 9)}`

  return (
    <div className={`inline-flex items-center justify-center ${className}`}>
      <svg 
        width={size} 
        height={size} 
        viewBox="0 0 100 100" 
        fill="none" 
        xmlns="http://www.w3.org/2000/svg"
        className="drop-shadow-lg"
      >
        {/* Círculo externo */}
        <circle 
          cx="50" 
          cy="50" 
          r="45" 
          fill={`url(#${gradientId})`}
          stroke={`url(#${borderGradientId})`}
          strokeWidth="2"
        />
        
        {/* Circuitos internos */}
        <g fill="white" opacity="0.9">
          {/* Nó central superior */}
          <circle cx="50" cy="25" r="4" />
          
          {/* Nós laterais */}
          <circle cx="30" cy="45" r="3.5" />
          <circle cx="70" cy="45" r="3.5" />
          
          {/* Nós inferiores */}
          <circle cx="35" cy="70" r="3" />
          <circle cx="65" cy="70" r="3" />
          
          {/* Linhas conectoras */}
          <path 
            d="M50 29 L50 35 M46 35 L54 35 M46 35 L30 45 M54 35 L70 45 M30 49 L30 55 M70 49 L70 55 M30 55 L35 66 M70 55 L65 66" 
            stroke="white" 
            strokeWidth="2" 
            strokeLinecap="round"
            fill="none"
            opacity="0.8"
          />
        </g>
        
        {/* Gradientes com IDs únicos */}
        <defs>
          <linearGradient id={gradientId} x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor="#3b82f6" />
            <stop offset="50%" stopColor="#1d4ed8" />
            <stop offset="100%" stopColor="#1e40af" />
          </linearGradient>
          <linearGradient id={borderGradientId} x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor="#60a5fa" />
            <stop offset="100%" stopColor="#3b82f6" />
          </linearGradient>
        </defs>
      </svg>
    </div>
  )
}

export function LogoWithText({ size = 48, className = "" }: LogoProps) {
  return (
    <div className={`inline-flex items-center gap-3 ${className}`}>
      <Logo size={size} />
      <div className="flex flex-col">
        <span className="text-xl font-bold text-white tracking-tight">Code-IQ</span>
        <span className="text-xs text-zinc-400 tracking-wider">ARTIFICIAL INTELLIGENCE</span>
      </div>
    </div>
  )
}
