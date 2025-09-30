# Ãrea do Cliente - Code-IQ

AplicaÃ§Ã£o React para gerenciamento de clientes com autenticaÃ§Ã£o, permissÃµes e webhooks.

## ðŸš€ Deploy

Esta aplicaÃ§Ã£o estÃ¡ configurada para deploy via EasyPanel com Docker.

### PrÃ©-requisitos

- Node.js 20+
- Docker & Docker Compose

### Deploy Local

\\\ash
npm install
npm run dev
\\\

### Deploy via Docker

\\\ash
docker compose build
docker compose up -d
\\\

### Acesso

- **ProduÃ§Ã£o**: http://212.85.12.183:3001
- **Hostinger**: https://code-iq.com.br/area-do-cliente.html

## ðŸ“‹ Estrutura

- \/src\ - CÃ³digo fonte React/TypeScript
- \/public\ - Assets estÃ¡ticos
- \Dockerfile\ - Build da aplicaÃ§Ã£o
- \docker-compose.yml\ - OrquestraÃ§Ã£o
- \
ginx.conf\ - ConfiguraÃ§Ã£o Nginx

## ðŸ”§ Tecnologias

- React 18
- TypeScript
- Vite
- React Router
- Axios
- Tailwind CSS (ou seu framework)
- Docker + Nginx
