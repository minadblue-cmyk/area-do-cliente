# Extrair arquivo
cd /root
tar -xzf area-cliente-docker.tar.gz -C /root/area-do-cliente-app || mkdir -p /root/area-do-cliente-app && tar -xzf area-cliente-docker.tar.gz -C /root/area-do-cliente-app

# Navegar para o diretÃ³rio
cd /root/area-do-cliente-app

# Parar containers existentes
docker-compose down || true

# Remover imagens antigas
docker rmi -f \ || true

# Build da nova imagem
docker-compose build

# Iniciar containers
docker-compose up -d

# Verificar status
docker-compose ps

# Limpar arquivo tar
rm -f /root/area-cliente-docker.tar.gz

echo ""
echo "âœ… Deploy concluÃ­do!"
echo "Teste: http://212.85.12.183:3001"
