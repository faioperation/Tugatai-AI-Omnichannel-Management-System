############################
# Stage 1 - Dependencies
############################
FROM node:20-alpine AS deps

WORKDIR /usr/src/app

COPY package*.json ./

# Install dependencies without running Prisma postinstall yet
RUN npm ci --ignore-scripts


############################
# Stage 2 - Build
############################
FROM node:20-alpine AS builder

WORKDIR /usr/src/app

# Required for building bcrypt native module
RUN apk add --no-cache python3 make g++

COPY --from=deps /usr/src/app/node_modules ./node_modules
COPY . .

ARG DATABASE_URL
ENV DATABASE_URL=${DATABASE_URL}

# Build bcrypt native binary
RUN npm rebuild bcrypt --build-from-source

# Generate Prisma client
RUN npx prisma generate


############################
# Stage 3 - Runtime
############################
FROM node:20-alpine

WORKDIR /usr/src/app

ENV NODE_ENV=production

RUN apk add --no-cache \
    postgresql-client \
    tini \
    curl

COPY --from=builder /usr/src/app ./

RUN chmod +x docker-entrypoint.sh \
    && mkdir -p uploads \
    && chown -R node:node /usr/src/app

USER node

EXPOSE 8001

ENTRYPOINT ["/sbin/tini","--","./docker-entrypoint.sh"]

CMD ["node","src/server.js"]