const fs = require('fs');
const path = require('path');

// Função para criar ícone PNG simples
function createIcon(size) {
  // Criar canvas HTML5 (simulado)
  const canvas = {
    width: size,
    height: size,
    getContext: () => ({
      fillStyle: '',
      strokeStyle: '',
      lineWidth: 0,
      beginPath: () => {},
      arc: () => {},
      fill: () => {},
      stroke: () => {},
      moveTo: () => {},
      lineTo: () => {},
      clearRect: () => {},
      fillRect: () => {},
      roundRect: () => {}
    })
  };

  // Para simplificar, vou criar ícones usando caracteres Unicode
  // e depois converter para base64
  return createSimpleIcon(size);
}

function createSimpleIcon(size) {
  // Criar um ícone simples usando SVG
  const svg = `
    <svg width="${size}" height="${size}" viewBox="0 0 ${size} ${size}" xmlns="http://www.w3.org/2000/svg">
      <circle cx="${size/2}" cy="${size/2}" r="${size*0.45}" fill="#1a1a1a" stroke="#3b82f6" stroke-width="${Math.max(1, size/32)}"/>
      <rect x="${size*0.25}" y="${size*0.3}" width="${size*0.5}" height="${size*0.4}" rx="${size*0.06}" fill="#3b82f6"/>
      <circle cx="${size*0.375}" cy="${size*0.45}" r="${size*0.05}" fill="#ffffff"/>
      <circle cx="${size*0.625}" cy="${size*0.45}" r="${size*0.05}" fill="#ffffff"/>
      <rect x="${size*0.4}" y="${size*0.6}" width="${size*0.2}" height="${size*0.03}" rx="${size*0.015}" fill="#ffffff"/>
      <line x1="${size/2}" y1="${size*0.3}" x2="${size/2}" y2="${size*0.2}" stroke="#3b82f6" stroke-width="${Math.max(1, size/40)}"/>
      <circle cx="${size/2}" cy="${size*0.15}" r="${size*0.03}" fill="#10b981"/>
      <circle cx="${size*0.8}" cy="${size*0.25}" r="${size*0.08}" fill="#10b981"/>
      <text x="${size*0.8}" y="${size*0.28}" text-anchor="middle" fill="#ffffff" font-size="${size*0.08}" font-weight="bold">▶</text>
    </svg>
  `;
  
  return svg;
}

// Criar ícones para todas as resoluções
const sizes = [16, 32, 48, 128];

sizes.forEach(size => {
  const svg = createSimpleIcon(size);
  const filename = path.join(__dirname, 'icons', `icon${size}.svg`);
  
  fs.writeFileSync(filename, svg);
  console.log(`✅ Criado: icon${size}.svg`);
});

console.log('🎯 Todos os ícones SVG criados!');
console.log('📝 Agora você pode converter para PNG usando qualquer conversor online.');
