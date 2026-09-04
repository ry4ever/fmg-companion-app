# Railway deployment for FMG Parent Portal (Next.js + Tailwind)
# Build: next build || vercel build
# Start: next start

# ---- Stage 1: Build ----
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies (with lock file for reproducibility)
COPY package*.json ./
RUN npm ci --omit dev

# Copy source files
COPY . .

# Build optimized production build
RUN npm run build

# ---- Stage 2: Runtime ----
FROM node:20-alpine AS runner

WORKDIR /app

# Create non-root user for security
RUN addgroup -g 1001 nodejs && \
    adduser -S nextjs -u 1001

# Copy built output from builder
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/next.config.js ./
COPY --from=builder /app/postcss.config.js ./
COPY --from=builder /app/tailwind.config.ts ./
COPY --from=builder /app/tsconfig.json ./
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

# Install production dependencies
RUN npm ci --omit dev --production

# Switch to non-root user
USER nextjs

# Expose port that Next.js expects
EXPOSE 3000

# Environment variable for Next.js standalone server
ENV PORT=3000
ENV HOSTNAME=0.0.0.0

# Start server
CMD ["node", "server.js"]