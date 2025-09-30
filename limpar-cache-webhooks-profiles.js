// Script para limpar cache de webhooks e forçar reload
console.log('🧹 Limpando cache de webhooks...')

// Limpar localStorage
localStorage.removeItem('flowhub:webhooks')
console.log('✅ Cache de webhooks removido do localStorage')

// Forçar reload da página
console.log('🔄 Recarregando página...')
window.location.reload()
