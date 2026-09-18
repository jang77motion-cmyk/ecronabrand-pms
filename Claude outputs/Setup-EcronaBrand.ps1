# Ecronabrand PMS Docker Setup Script
# Windows PowerShell 스크립트
# 실행 방법: Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process; .\Setup-EcronaBrand.ps1

param(
    [string]$ProjectPath = "D:\ecronabrand"
)

Write-Host "🐳 Ecronabrand PMS Docker 설정 시작..." -ForegroundColor Cyan
Write-Host "프로젝트 경로: $ProjectPath" -ForegroundColor Yellow

# 디렉토리 생성
Write-Host "📁 디렉토리 구조 생성 중..." -ForegroundColor Cyan
$dirs = @(
    $ProjectPath,
    "$ProjectPath\backend",
    "$ProjectPath\backend\src",
    "$ProjectPath\backend\prisma",
    "$ProjectPath\frontend",
    "$ProjectPath\frontend\src",
    "$ProjectPath\frontend\src\pages",
    "$ProjectPath\frontend\src\styles",
    "$ProjectPath\frontend\src\components",
    "$ProjectPath\frontend\src\types",
    "$ProjectPath\frontend\src\utils",
    "$ProjectPath\database"
)

foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "✓ 생성: $dir" -ForegroundColor Green
    }
}

# docker-compose.yml
Write-Host "📝 docker-compose.yml 생성 중..." -ForegroundColor Cyan
$dockerCompose = @'
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: ecronabrand-postgres
    environment:
      POSTGRES_USER: ecronabrand
      POSTGRES_PASSWORD: ecronabrand_dev_password
      POSTGRES_DB: ecronabrand
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ecronabrand"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - ecronabrand-network

  redis:
    image: redis:7-alpine
    container_name: ecronabrand-redis
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - ecronabrand-network

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: ecronabrand-backend
    ports:
      - "3001:3001"
    environment:
      NODE_ENV: development
      DATABASE_URL: postgresql://ecronabrand:ecronabrand_dev_password@postgres:5432/ecronabrand
      REDIS_URL: redis://redis:6379
      PORT: 3001
      JWT_SECRET: your-secret-key-change-in-production
      FRONTEND_URL: http://localhost:3000
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    volumes:
      - ./backend:/app
      - /app/node_modules
    networks:
      - ecronabrand-network

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: ecronabrand-frontend
    ports:
      - "3000:3000"
    environment:
      NEXT_PUBLIC_API_URL: http://localhost:3001/api
    depends_on:
      - backend
    volumes:
      - ./frontend:/app
      - /app/node_modules
    networks:
      - ecronabrand-network

volumes:
  postgres_data:

networks:
  ecronabrand-network:
    driver: bridge
'@
Set-Content -Path "$ProjectPath\docker-compose.yml" -Value $dockerCompose -Encoding UTF8
Write-Host "✓ docker-compose.yml 생성됨" -ForegroundColor Green

# Backend package.json
Write-Host "📝 Backend package.json 생성 중..." -ForegroundColor Cyan
$backendPackage = @'
{
  "name": "ecronabrand-backend",
  "version": "1.0.0",
  "description": "Product Management System Backend",
  "main": "dist/index.js",
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "jest",
    "db:migrate": "prisma migrate dev",
    "db:push": "prisma db push",
    "db:seed": "ts-node prisma/seed.ts",
    "db:studio": "prisma studio"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.0.0",
    "morgan": "^1.10.0",
    "@prisma/client": "^5.3.1",
    "jsonwebtoken": "^9.0.2",
    "bcryptjs": "^2.4.3",
    "zod": "^3.22.4",
    "axios": "^1.5.0",
    "dotenv": "^16.3.1",
    "swagger-ui-express": "^5.0.0",
    "swagger-jsdoc": "^6.2.8",
    "winston": "^3.11.0"
  },
  "devDependencies": {
    "typescript": "^5.2.2",
    "@types/express": "^4.17.17",
    "@types/node": "^20.5.9",
    "@types/cors": "^2.8.14",
    "@types/morgan": "^1.9.5",
    "@types/jsonwebtoken": "^9.0.5",
    "@types/bcryptjs": "^2.4.6",
    "@types/jest": "^29.5.5",
    "ts-node": "^10.9.1",
    "tsx": "^3.13.0",
    "jest": "^29.7.0",
    "ts-jest": "^29.1.1",
    "prisma": "^5.3.1"
  }
}
'@
Set-Content -Path "$ProjectPath\backend\package.json" -Value $backendPackage -Encoding UTF8
Write-Host "✓ Backend package.json 생성됨" -ForegroundColor Green

# Backend tsconfig.json
Write-Host "📝 Backend tsconfig.json 생성 중..." -ForegroundColor Cyan
$backendTsConfig = @'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules"]
}
'@
Set-Content -Path "$ProjectPath\backend\tsconfig.json" -Value $backendTsConfig -Encoding UTF8
Write-Host "✓ Backend tsconfig.json 생성됨" -ForegroundColor Green

# Backend Dockerfile
Write-Host "📝 Backend Dockerfile 생성 중..." -ForegroundColor Cyan
$backendDockerfile = @'
FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json* yarn.lock* pnpm-lock.yaml* ./

RUN npm install

COPY . .

RUN npm run build

FROM node:20-alpine

WORKDIR /app

ENV NODE_ENV=production

COPY package.json package-lock.json* yarn.lock* pnpm-lock.yaml* ./

RUN npm install --omit=dev

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules

EXPOSE 3001

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3001/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

USER node

CMD ["node", "dist/index.js"]
'@
Set-Content -Path "$ProjectPath\backend\Dockerfile" -Value $backendDockerfile -Encoding UTF8
Write-Host "✓ Backend Dockerfile 생성됨" -ForegroundColor Green

# Backend src/index.ts
Write-Host "📝 Backend src/index.ts 생성 중..." -ForegroundColor Cyan
$backendIndex = @'
import express, { Express, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';

dotenv.config();

const app: Express = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(helmet());
app.use(cors({ origin: process.env.FRONTEND_URL || 'http://localhost:3000' }));
app.use(morgan('combined'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/health', (req: Request, res: Response) => {
  res.status(200).json({ status: 'OK', timestamp: new Date().toISOString() });
});

// API Routes
app.get('/api/products', (req: Request, res: Response) => {
  res.json({ message: 'Products endpoint' });
});

app.get('/api/orders', (req: Request, res: Response) => {
  res.json({ message: 'Orders endpoint' });
});

app.get('/api/inventory', (req: Request, res: Response) => {
  res.json({ message: 'Inventory endpoint' });
});

app.get('/api/analytics/sales', (req: Request, res: Response) => {
  res.json({ message: 'Sales analytics endpoint' });
});

// API Documentation
app.get('/api/docs', (req: Request, res: Response) => {
  res.json({
    message: 'API Documentation',
    version: '1.0.0',
    endpoints: [
      '/api/products',
      '/api/orders',
      '/api/inventory',
      '/api/analytics/sales'
    ]
  });
});

// 404 Handler
app.use((req: Request, res: Response) => {
  res.status(404).json({ error: 'Not Found' });
});

// Error handling middleware
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  console.error('Error:', err);
  res.status(500).json({
    error: 'Internal Server Error',
    message: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

const server = app.listen(PORT, () => {
  console.log(`🚀 Server running at http://localhost:${PORT}`);
  console.log(`📚 API Documentation at http://localhost:${PORT}/api/docs`);
});

export default app;
'@
Set-Content -Path "$ProjectPath\backend\src\index.ts" -Value $backendIndex -Encoding UTF8
Write-Host "✓ Backend src/index.ts 생성됨" -ForegroundColor Green

# Backend prisma/schema.prisma
Write-Host "📝 Backend prisma/schema.prisma 생성 중..." -ForegroundColor Cyan
$prismaSchema = @'
// This is your Prisma schema file,
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  password  String
  name      String
  role      String   @default("user")
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([email])
}

model Product {
  id          String   @id @default(cuid())
  sku         String   @unique
  name        String
  description String?
  categoryId  String
  price       Float
  cost        Float
  barcode     String?
  images      Json?
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  @@index([categoryId])
  @@index([sku])
}

model Category {
  id        String   @id @default(cuid())
  name      String
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model Inventory {
  id            String   @id @default(cuid())
  productId     String
  warehouseId   String
  onHand        Int      @default(0)
  reserved      Int      @default(0)
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt

  @@index([productId])
  @@index([warehouseId])
}

model Order {
  id        String   @id @default(cuid())
  orderNo   String   @unique
  customerId String
  status    String   @default("pending")
  totalAmount Float
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([customerId])
  @@index([status])
}

model OrderItem {
  id        String   @id @default(cuid())
  orderId   String
  productId String
  quantity  Int
  price     Float
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([orderId])
  @@index([productId])
}

model Shipment {
  id        String   @id @default(cuid())
  orderId   String
  carrier   String
  trackingNo String?
  status    String   @default("pending")
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([orderId])
}

model SalesAnalytics {
  id        String   @id @default(cuid())
  date      DateTime
  revenue   Float
  quantity  Int
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([date])
}
'@
Set-Content -Path "$ProjectPath\backend\prisma\schema.prisma" -Value $prismaSchema -Encoding UTF8
Write-Host "✓ Backend prisma/schema.prisma 생성됨" -ForegroundColor Green

# Backend .env.example
Set-Content -Path "$ProjectPath\backend\.env.example" -Value @'
DATABASE_URL=postgresql://ecronabrand:ecronabrand_dev_password@postgres:5432/ecronabrand
REDIS_URL=redis://redis:6379
PORT=3001
NODE_ENV=development
JWT_SECRET=your-secret-key-change-in-production
FRONTEND_URL=http://localhost:3000
'@ -Encoding UTF8
Write-Host "✓ Backend .env.example 생성됨" -ForegroundColor Green

# Frontend package.json
Write-Host "📝 Frontend package.json 생성 중..." -ForegroundColor Cyan
$frontendPackage = @'
{
  "name": "ecronabrand-frontend",
  "version": "1.0.0",
  "description": "Ecronabrand PMS Frontend",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "next": "14.0.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "axios": "^1.5.0"
  },
  "devDependencies": {
    "@types/node": "^20.5.9",
    "@types/react": "^18.2.21",
    "@types/react-dom": "^18.2.7",
    "typescript": "^5.2.2",
    "autoprefixer": "^10.4.16",
    "postcss": "^8.4.31",
    "tailwindcss": "^3.3.4"
  }
}
'@
Set-Content -Path "$ProjectPath\frontend\package.json" -Value $frontendPackage -Encoding UTF8
Write-Host "✓ Frontend package.json 생성됨" -ForegroundColor Green

# Frontend tsconfig.json
Write-Host "📝 Frontend tsconfig.json 생성 중..." -ForegroundColor Cyan
$frontendTsConfig = @'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "jsx": "preserve",
    "incremental": true,
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules"]
}
'@
Set-Content -Path "$ProjectPath\frontend\tsconfig.json" -Value $frontendTsConfig -Encoding UTF8
Write-Host "✓ Frontend tsconfig.json 생성됨" -ForegroundColor Green

# Frontend next.config.js
Set-Content -Path "$ProjectPath\frontend\next.config.js" -Value @'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  output: 'standalone',
}

module.exports = nextConfig
'@ -Encoding UTF8
Write-Host "✓ Frontend next.config.js 생성됨" -ForegroundColor Green

# Frontend tailwind.config.js
Set-Content -Path "$ProjectPath\frontend\tailwind.config.js" -Value @'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx}',
    './src/components/**/*.{js,ts,jsx,tsx}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
'@ -Encoding UTF8
Write-Host "✓ Frontend tailwind.config.js 생성됨" -ForegroundColor Green

# Frontend postcss.config.js
Set-Content -Path "$ProjectPath\frontend\postcss.config.js" -Value @'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
'@ -Encoding UTF8
Write-Host "✓ Frontend postcss.config.js 생성됨" -ForegroundColor Green

# Frontend src/styles/globals.css
Write-Host "📝 Frontend src/styles/globals.css 생성 중..." -ForegroundColor Cyan
Set-Content -Path "$ProjectPath\frontend\src\styles\globals.css" -Value @'
@tailwind base;
@tailwind components;
@tailwind utilities;

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: system-ui, -apple-system, sans-serif;
  line-height: 1.5;
  color: #333;
}

a {
  color: #0066cc;
  text-decoration: none;
}

a:hover {
  text-decoration: underline;
}

button {
  cursor: pointer;
}
'@ -Encoding UTF8
Write-Host "✓ Frontend src/styles/globals.css 생성됨" -ForegroundColor Green

# Frontend src/pages/_app.tsx
Write-Host "📝 Frontend src/pages/_app.tsx 생성 중..." -ForegroundColor Cyan
Set-Content -Path "$ProjectPath\frontend\src\pages\_app.tsx" -Value @'
import type { AppProps } from 'next/app';
import '../styles/globals.css';

export default function App({ Component, pageProps }: AppProps) {
  return <Component {...pageProps} />;
}
'@ -Encoding UTF8
Write-Host "✓ Frontend src/pages/_app.tsx 생성됨" -ForegroundColor Green

# Frontend src/pages/index.tsx
Write-Host "📝 Frontend src/pages/index.tsx 생성 중..." -ForegroundColor Cyan
Set-Content -Path "$ProjectPath\frontend\src\pages\index.tsx" -Value @'
import React from 'react';

export default function Home() {
  return (
    <div style={{ padding: '40px', fontFamily: 'system-ui, sans-serif' }}>
      <h1>🚀 Ecronabrand PMS</h1>
      <h2>Product Management System</h2>

      <div style={{ marginTop: '30px', color: '#666' }}>
        <p>Backend API가 정상 작동 중입니다.</p>
        <p>API 문서: <a href="http://localhost:3001/api/docs" target="_blank">http://localhost:3001/api/docs</a></p>
      </div>

      <div style={{ marginTop: '20px', padding: '20px', backgroundColor: '#f5f5f5', borderRadius: '8px' }}>
        <h3>다음 단계</h3>
        <ul>
          <li>재고 관리 모듈 구현</li>
          <li>주문 관리 시스템 개발</li>
          <li>분석 대시보드 구성</li>
        </ul>
      </div>
    </div>
  );
}
'@ -Encoding UTF8
Write-Host "✓ Frontend src/pages/index.tsx 생성됨" -ForegroundColor Green

# Frontend .env.example
Set-Content -Path "$ProjectPath\frontend\.env.example" -Value @'
NEXT_PUBLIC_API_URL=http://localhost:3001/api
'@ -Encoding UTF8
Write-Host "✓ Frontend .env.example 생성됨" -ForegroundColor Green

# Frontend Dockerfile (수정된 버전)
Write-Host "📝 Frontend Dockerfile 생성 중..." -ForegroundColor Cyan
$frontendDockerfile = @'
FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json* yarn.lock* pnpm-lock.yaml* ./

RUN npm install

COPY . .

RUN npm run build

FROM node:20-alpine

WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/public ./public 2>/dev/null || true
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static 2>/dev/null || true

EXPOSE 3000

CMD ["node", "server.js"]
'@
Set-Content -Path "$ProjectPath\frontend\Dockerfile" -Value $frontendDockerfile -Encoding UTF8
Write-Host "✓ Frontend Dockerfile 생성됨" -ForegroundColor Green

# 완료 메시지
Write-Host "`n✅ 모든 파일이 성공적으로 생성되었습니다!`n" -ForegroundColor Green
Write-Host "📍 프로젝트 경로: $ProjectPath`n" -ForegroundColor Cyan

# Docker Compose 실행
Write-Host "🐳 Docker Compose 서비스 시작 중..." -ForegroundColor Cyan
Write-Host "(이 작업은 2-3분 소요될 수 있습니다)`n" -ForegroundColor Yellow

Set-Location $ProjectPath

# 이전 컨테이너 정리
Write-Host "정리 중..." -ForegroundColor Yellow
docker-compose down -v 2>$null

# 서비스 시작
Write-Host "서비스 빌드 및 시작 중..." -ForegroundColor Cyan
docker-compose up -d

# 상태 확인
Write-Host "`n서비스 상태 확인:` -ForegroundColor Cyan
Start-Sleep -Seconds 5
docker-compose ps

Write-Host "`n✅ 완료!`n" -ForegroundColor Green
Write-Host "📱 프론트엔드: http://localhost:3000" -ForegroundColor Green
Write-Host "🔌 백엔드 API: http://localhost:3001/api" -ForegroundColor Green
Write-Host "📚 API 문서: http://localhost:3001/api/docs`n" -ForegroundColor Green

Write-Host "💡 서비스 관리 명령어:" -ForegroundColor Cyan
Write-Host "  로그 확인: docker-compose logs -f" -ForegroundColor Gray
Write-Host "  서비스 중지: docker-compose down" -ForegroundColor Gray
Write-Host "  서비스 재시작: docker-compose restart" -ForegroundColor Gray
Write-Host "  프로세스 확인: docker-compose ps`n" -ForegroundColor Gray

Read-Host "아무 키나 눌러서 종료..."
