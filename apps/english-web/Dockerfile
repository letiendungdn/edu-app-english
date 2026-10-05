FROM node:22-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json ./
COPY packages/vocab-images ./packages/vocab-images
COPY apps/english-web ./apps/english-web
RUN npm ci
RUN apk add --no-cache libc6-compat
RUN npm run build -w @edu/vocab-images
WORKDIR /app/apps/english-web
ENV API_URL=http://api-gateway:3000
RUN npm run build

FROM node:22-alpine AS runner
RUN apk add --no-cache libc6-compat
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3001
ENV HOSTNAME=0.0.0.0
ENV API_URL=http://api-gateway:3000
COPY --from=builder /app/apps/english-web/.next/standalone ./
COPY --from=builder /app/apps/english-web/.next/static ./apps/english-web/.next/static
COPY --from=builder /app/apps/english-web/public ./apps/english-web/public
EXPOSE 3001
CMD ["node", "apps/english-web/server.js"]
