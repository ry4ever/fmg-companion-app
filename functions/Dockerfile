# Railway deployment for FMG Cloud Functions
# Already compiled JS output in lib/

FROM node:20-alpine AS runtime

WORKDIR /app

# Install production dependencies only
COPY package*.json ./
RUN npm ci --production

# Copy compiled JavaScript and source types
COPY lib ./lib
COPY src ./src
COPY tsconfig.json ./
COPY package.json ./

# Create non-root user for security
RUN addgroup -g 1001 nodejs && \
    adduser -S firebase -u 1001
USER firebase

# Expose port for Firebase Functions emulator runtime
EXPOSE 8080

ENV NODE_ENV=production
ENV FUNCTION_TARGET=lib/index.js
ENV PORT=8080

# Start the Cloud Functions server
# Firebase functions v2 uses onRequest which serves on the specified port
CMD ["node", "lib/index.js"]