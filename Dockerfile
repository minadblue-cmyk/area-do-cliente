# ====== Etapa de build (Node) ======
FROM node:20-alpine AS build
WORKDIR /app

# Instale dependências
COPY package*.json ./
# Use npm ci se tiver package-lock; cai para npm install se não tiver
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi

# Copie o restante e faça o build
COPY . .
RUN npm run build

# ====== Etapa de runtime (Nginx servindo estático) ======
FROM nginx:alpine
# Ajuste leve no nginx (opcional)
RUN sed -i 's/keepalive_timeout.*;/keepalive_timeout 15;/' /etc/nginx/nginx.conf

# Substitui configuração padrão pelo nosso conf com fallback de SPA
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# Copia o build do Vite para a pasta pública do Nginx
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
