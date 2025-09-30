import { useEffect } from 'react'

/**
 * Hook para congelar o scroll da página quando um modal estiver aberto
 * @param isLocked - Se o scroll deve estar congelado
 */
export function useScrollLock(isLocked: boolean) {
  useEffect(() => {
    if (!isLocked) return

    // Salvar o scroll atual
    const scrollY = window.scrollY
    const scrollX = window.scrollX
    
    // Salvar estilos originais
    const originalStyle = {
      position: document.body.style.position,
      top: document.body.style.top,
      left: document.body.style.left,
      width: document.body.style.width,
      height: document.body.style.height,
      overflow: document.body.style.overflow,
      overflowX: document.body.style.overflowX,
      overflowY: document.body.style.overflowY,
    }
    
    // Salvar classes originais
    const originalClasses = document.body.className
    
    // Congelar o scroll
    document.body.style.position = 'fixed'
    document.body.style.top = `-${scrollY}px`
    document.body.style.left = `-${scrollX}px`
    document.body.style.width = '100%'
    document.body.style.height = '100%'
    document.body.style.overflow = 'hidden'
    document.body.style.overflowX = 'hidden'
    document.body.style.overflowY = 'hidden'
    
    // Adicionar classe para CSS adicional
    document.body.classList.add('modal-open')
    
    // Cleanup: restaurar o scroll quando modal fechar
    return () => {
      // Remover classe
      document.body.classList.remove('modal-open')
      
      // Restaurar estilos originais
      Object.entries(originalStyle).forEach(([property, value]) => {
        document.body.style[property as any] = value
      })
      
      // Restaurar classes originais
      document.body.className = originalClasses
      
      // Restaurar posição do scroll
      window.scrollTo(scrollX, scrollY)
    }
  }, [isLocked])
}
