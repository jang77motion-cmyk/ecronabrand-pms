# Multi-stage build for Ecronabrand PMS Backend
FROM node:20-alpine AS builder
WORKDIR /app

# Copy backend package files
COPY backend/package*.json ./backend/
COPY backend/tsconfig.json ./backend/

WORKDIR /app/backend

# Install dependencies
RUN npm install

# Copy source code
COPY backend/src ./src
COPY backend/prisma ./prisma

# Build the application
RUN npm run build

# Production stage
FROM node:20-alpine

WORKDIR /app/backend

# Copy package files
COPY --from=builder /app/backend/package*.json ./
# Install production dependencies only
RUN npm ci --omit=dev
# Copy built application from builder
COPY --from=builder /app/backend/dist ./dist
COPY --from=builder /app/backend/node_modules ./node_modules

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3001/api/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Expose port
EXPOSE 3001

# Start the application
CMD ["node", "dist/index.js"]
