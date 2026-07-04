FROM node:20-alpine AS base
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm ci --only=production

FROM base AS builder
COPY . .
ARG DATABASE_URL
ENV DATABASE_URL=$DATABASE_URL
RUN npx prisma generate

FROM node:20-alpine AS production
WORKDIR /usr/src/app
ENV NODE_ENV=production
COPY --from=builder /usr/src/app/package*.json ./
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/src ./src
COPY --from=builder /usr/src/app/prisma ./prisma
RUN mkdir -p uploads
EXPOSE 8001
CMD ["node", "src/server.js"]
