# ====== Build Stage (Node) ======
FROM node:20-alpine AS build
WORKDIR /app

# Copiar arquivos de dependências
COPY package*.json ./

# Instalar dependências
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi

# Copiar código fonte
COPY . .

# Build da aplicação
RUN npm run build

# Verificar se o build foi bem-sucedido
RUN test -f dist/index.html

# ====== Runtime Stage (Nginx) ======
FROM nginx:alpine

# Copiar configuração customizada do Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiar arquivos estáticos do build
COPY --from=build /app/dist /usr/share/nginx/html

# Criar diretório para volumes persistentes
RUN mkdir -p /data/uploads && \
    chmod -R 755 /data && \
    chown -R nginx:nginx /data

# Expor porta 80
EXPOSE 80

# Iniciar Nginx
CMD ["nginx", "-g", "daemon off;"]
