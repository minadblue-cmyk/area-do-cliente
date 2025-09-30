// Script para limpar cache de webhooks no navegador
// Execute no console do navegador (F12)

console.log('🧹 Limpando cache de webhooks...');

// Limpar localStorage
localStorage.removeItem('flowhub:webhooks');
console.log('✅ localStorage limpo');

// Recarregar a página
console.log('🔄 Recarregando página...');
window.location.reload();
