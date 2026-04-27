# Estágio 1: Build (Instala dependências)
FROM node:18-slim AS builder
WORKDIR /app
COPY app/package*.json ./
RUN npm install --only=production

# Estágio 2: Runtime (Imagem final leve e segura)
FROM node:20-slim
WORKDIR /app

# Copia apenas o necessário do estágio anterior
COPY --from=builder /app/node_modules ./node_modules
COPY app/server.js .
COPY app/package.json .

# Segurança: Cria um usuário sem privilégios de root
USER node

EXPOSE 3000

CMD ["node", "server.js"]