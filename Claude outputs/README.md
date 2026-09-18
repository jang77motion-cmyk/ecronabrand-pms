# Ecronabrand PMS - Product Management System

통합 제품 관리 시스템 (Inventory, Orders, Analytics)

## ⚡ 빠른 시작 (Quick Start) ⭐

**Windows PowerShell 관리자 모드에서:**

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\Setup-EcronaBrand.ps1
```

완료되면 접속 가능:
- 🌐 Frontend: http://localhost:3000
- 🔌 API: http://localhost:3001/api  
- 📚 API Docs: http://localhost:3001/api/docs

**소요 시간:** 약 2-3분

> 💡 **Setup-EcronaBrand.ps1** 스크립트가 모든 파일을 자동으로 생성하고 Docker를 시작합니다!

## 🚀 기술 스택

### Backend
- **Framework**: Express.js (Node.js)
- **Language**: TypeScript
- **Database**: PostgreSQL 15
- **ORM**: Prisma
- **Auth**: JWT
- **Cache**: Redis
- **API Docs**: Swagger/OpenAPI

### Frontend
- **Framework**: Next.js 14
- **UI Library**: React 18
- **Styling**: Tailwind CSS
- **State Management**: Zustand
- **Data Fetching**: TanStack Query (React Query)
- **Charts**: Recharts
- **Validation**: Zod

### Infrastructure
- **Containerization**: Docker & Docker Compose
- **Version Control**: Git

## 📁 프로젝트 구조

```
ecronabrand-pms/
├── backend/              # Express 백엔드 서버
│   ├── src/
│   │   ├── index.ts     # 메인 서버 파일
│   │   ├── config/      # 설정 파일
│   │   ├── middleware/  # Express 미들웨어
│   │   ├── modules/     # 기능별 모듈
│   │   ├── utils/       # 유틸리티 함수
│   │   └── types/       # TypeScript 타입
│   ├── prisma/
│   │   └── schema.prisma # 데이터베이스 스키마
│   ├── package.json
│   ├── tsconfig.json
│   └── Dockerfile
├── frontend/            # Next.js 프론트엔드
│   ├── src/
│   │   ├── pages/      # 페이지 컴포넌트
│   │   ├── components/ # 재사용 컴포넌트
│   │   ├── hooks/      # 커스텀 훅
│   │   ├── utils/      # 유틸리티
│   │   └── types/      # TypeScript 타입
│   ├── public/         # 정적 파일
│   ├── package.json
│   ├── next.config.js
│   ├── tailwind.config.js
│   └── Dockerfile
├── database/           # 데이터베이스 초기화 스크립트
│   └── schema.sql
├── docker-compose.yml  # Docker Compose 설정
├── .env.example        # 환경 변수 템플릿
├── .gitignore
└── README.md
```

## 🔧 개발 환경 설정

### 필수 조건
- Docker & Docker Compose
- Node.js 20+ (로컬 개발 시)

### 설치 & 실행

1. **프로젝트 폴더로 이동**
   ```bash
   cd D:\ecronabrand
   ```

2. **Docker로 전체 서비스 시작**
   ```bash
   docker-compose up -d
   ```

3. **서비스 접속**
   - **Frontend**: http://localhost:3000
   - **Backend API**: http://localhost:3001/api
   - **API Docs**: http://localhost:3001/api/docs
   - **Database**: localhost:5432

### 환경 변수 설정

1. 루트 폴더의 `.env.example` 파일을 복사하여 `.env` 생성
2. 각 폴더의 `.env.example` 파일도 동일하게 설정

```bash
# 루트 .env
DATABASE_URL="postgresql://ecronabrand:ecronabrand_dev_password@localhost:5432/ecronabrand"
JWT_SECRET="your-secret-key"
FRONTEND_URL="http://localhost:3000"

# backend/.env
NODE_ENV="development"
PORT=3001
DATABASE_URL="postgresql://ecronabrand:ecronabrand_dev_password@localhost:5432/ecronabrand"

# frontend/.env
NEXT_PUBLIC_API_URL="http://localhost:3001/api"
```

## 📚 개발 가이드

### 백엔드 개발

```bash
cd backend

# 의존성 설치
npm install

# 개발 모드 실행
npm run dev

# 데이터베이스 마이그레이션
npm run db:migrate

# 데이터 시드 삽입
npm run db:seed

# 빌드
npm run build
```

### 프론트엔드 개발

```bash
cd frontend

# 의존성 설치
npm install

# 개발 모드 실행
npm run dev

# 빌드
npm run build

# 프로덕션 시작
npm start
```

## 🗄️ 데이터베이스

### 주요 테이블
- **Users**: 사용자 및 권한 관리
- **Products**: 상품 정보
- **Inventory**: 재고 관리
- **Orders**: 주문 관리
- **OrderItems**: 주문 상세
- **Shipments**: 배송 추적
- **SalesAnalytics**: 판매 분석

### Prisma 명령어

```bash
# 마이그레이션 생성
npx prisma migrate dev --name <name>

# 스키마 동기화
npx prisma db push

# Prisma Studio (GUI)
npx prisma studio
```

## 🧪 테스팅

```bash
# 테스트 실행
npm test

# 커버리지
npm test -- --coverage
```

## 📦 배포

### Docker로 프로덕션 빌드

```bash
# 이미지 빌드
docker-compose -f docker-compose.yml build

# 프로덕션 실행
docker-compose up -d
```

## 🔐 보안

- JWT 기반 인증
- CORS 설정으로 안전한 크로스 도메인 요청
- Helmet으로 HTTP 헤더 보호
- 입력 유효성 검사 (Zod)
- 비밀번호 암호화 (bcryptjs)
- 환경 변수로 민감한 정보 관리

## 📝 API 문서

API 문서는 Swagger UI에서 확인 가능합니다:
- 주소: http://localhost:3001/api/docs

## 🚀 개발 로드맵

### Phase 1: MVP (현재)
- ✅ 프로젝트 초기 구조 설정
- ✅ 데이터베이스 스키마 설계
- ⏳ 기본 API 엔드포인트 구현

### Phase 2: 재고 관리
- 상품 CRUD 작업
- 재고 레벨 추적
- 자동 알람 시스템

### Phase 3: 주문 & 배송
- 주문 처리 워크플로우
- 배송 추적
- 반품 및 환불

### Phase 4: 분석 & 대시보드
- 판매 분석
- KPI 대시보드
- 리포트 생성

### Phase 5: 고급 기능
- 카페24 API 연동
- 다중 채널 판매
- AI 기반 재고 최적화

## 🤝 기여

코드 컨벤션:
- TypeScript 사용
- ESLint/Prettier 준수
- 커밋 메시지: Conventional Commits
- PR 전 테스트 실행

## 📞 지원

문제 발생 시:
1. `.env` 파일 설정 확인
2. Docker 서비스 상태 확인: `docker-compose ps`
3. 로그 확인: `docker-compose logs`
4. 컨테이너 재시작: `docker-compose restart`

## 📄 라이선스

MIT

---

**마지막 업데이트**: 2026년 9월 18일
**버전**: 1.0.0-alpha
