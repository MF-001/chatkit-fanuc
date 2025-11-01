# Dev-first Dockerfile
FROM node:20-alpine

# Disable Next telemetry during builds
ARG NEXT_TELEMETRY_DISABLED=1
ENV NEXT_TELEMETRY_DISABLED=${NEXT_TELEMETRY_DISABLED}

WORKDIR /app

# Install dev dependencies (we need typescript, eslint, etc.) and tools for local development
COPY package.json package-lock.json* yarn.lock* ./
RUN apk add --no-cache libc6-compat git bash && \
    if [ -f yarn.lock ]; then yarn --frozen-lockfile; elif [ -f package-lock.json ]; then npm ci; else npm install; fi && \
    # Ensure telemetry is disabled during any npm installs
    npx --yes next telemetry disable || true

# Copy source (mounted in compose for development, but this keeps a fallback)
COPY . .

ENV NODE_ENV=development
ENV PORT=3000

EXPOSE 3000

# Start Next in dev mode on all interfaces
CMD ["npm", "run", "dev", "--", "-H", "0.0.0.0"]
