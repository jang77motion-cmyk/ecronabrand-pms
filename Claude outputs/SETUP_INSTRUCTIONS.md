# 🐳 Ecronabrand PMS Docker 설정 가이드

## 필수 요구사항

다음이 설치되어 있어야 합니다:
- **Docker Desktop** (Windows 10/11)
- **PowerShell** (Windows 기본 제공)

## 설정 방법

### 1단계: 스크립트 다운로드
- `Setup-EcronaBrand.ps1` 파일을 다운로드하세요
- 바탕화면이나 원하는 폴더에 저장하세요

### 2단계: PowerShell 관리자 모드 실행
1. **Windows 키 + X** 를 눌러 상황 메뉴 열기
2. **"Windows PowerShell (관리자)"** 또는 **"터미널 (관리자)"** 클릭
3. 관리자 권한 확인 (화면 위에 "관리자" 표시)

### 3단계: 스크립트 실행

스크립트를 저장한 디렉토리로 이동한 후 다음 명령어 실행:

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\Setup-EcronaBrand.ps1
```

또는 기본값(D:\ecronabrand 경로)이 아닌 다른 경로를 사용하려면:

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\Setup-EcronaBrand.ps1 -ProjectPath "C:\MyProjects\ecronabrand"
```

### 4단계: 완료 대기
- 스크립트는 자동으로:
  - ✅ 디렉토리 구조 생성
  - ✅ 모든 설정 파일 생성
  - ✅ Docker 이미지 빌드 (약 2-3분)
  - ✅ 모든 서비스 시작

## 접근 가능한 서비스

스크립트 완료 후 다음 주소에서 접근 가능:

| 서비스 | URL | 설명 |
|--------|-----|------|
| **프론트엔드** | http://localhost:3000 | Ecronabrand PMS 메인 페이지 |
| **백엔드 API** | http://localhost:3001/api | REST API 엔드포인트 |
| **API 문서** | http://localhost:3001/api/docs | API 엔드포인트 목록 |

## 유용한 Docker 명령어

스크립트가 완료된 후 사용할 수 있는 명령어들:

```powershell
# 프로젝트 디렉토리로 이동
cd D:\ecronabrand

# 서비스 상태 확인
docker-compose ps

# 실시간 로그 보기
docker-compose logs -f

# 특정 서비스 로그만 보기
docker-compose logs -f backend   # 백엔드 로그
docker-compose logs -f frontend  # 프론트엔드 로그

# 서비스 중지
docker-compose down

# 서비스 재시작
docker-compose restart

# 특정 서비스만 재시작
docker-compose restart backend

# 서비스 재빌드 및 시작
docker-compose up -d --build
```

## 트러블슈팅

### 1. "포트 3000/3001이 이미 사용 중입니다" 오류
```powershell
# 충돌하는 프로세스 찾기
netstat -ano | findstr :3000
netstat -ano | findstr :3001

# 해당 프로세스 종료
taskkill /PID [프로세스ID] /F
```

### 2. Docker 데몬이 실행 중이지 않습니다
- Docker Desktop 애플리케이션 실행
- 시작 표시줄의 Docker 아이콘 확인

### 3. 권한 거부 오류
- PowerShell을 **관리자 모드**로 다시 실행

### 4. 빌드 실패
```powershell
# 캐시 초기화 후 재시도
docker-compose build --no-cache
docker-compose up -d
```

## 프로젝트 구조

스크립트 실행 후 생성되는 구조:

```
D:\ecronabrand\
├── docker-compose.yml          # Docker 서비스 정의
├── backend/                      # Express.js 백엔드
│   ├── src/
│   │   └── index.ts            # 메인 서버 파일
│   ├── prisma/
│   │   └── schema.prisma       # 데이터베이스 스키마
│   ├── package.json            # 백엔드 의존성
│   ├── Dockerfile              # 백엔드 컨테이너 정의
│   └── tsconfig.json           # TypeScript 설정
├── frontend/                     # Next.js 프론트엔드
│   ├── src/
│   │   ├── pages/
│   │   │   ├── _app.tsx
│   │   │   └── index.tsx
│   │   └── styles/
│   │       └── globals.css
│   ├── package.json            # 프론트엔드 의존성
│   ├── Dockerfile              # 프론트엔드 컨테이너 정의
│   └── next.config.js          # Next.js 설정
└── database/                     # 데이터베이스 데이터
```

## 환경 변수 설정

각 서비스의 `.env.example` 파일을 참고하여 필요시 `.env` 파일을 생성하세요:

### Backend (.env)
```
DATABASE_URL=postgresql://ecronabrand:ecronabrand_dev_password@postgres:5432/ecronabrand
REDIS_URL=redis://redis:6379
PORT=3001
NODE_ENV=development
JWT_SECRET=your-secret-key-change-in-production
FRONTEND_URL=http://localhost:3000
```

### Frontend (.env.local)
```
NEXT_PUBLIC_API_URL=http://localhost:3001/api
```

## 다음 단계

1. ✅ Docker 설정 완료
2. 📝 API 엔드포인트 테스트 (http://localhost:3001/api)
3. 🎨 프론트엔드 페이지 커스터마이징 (src/pages/)
4. 🗄️ Prisma 마이그레이션 설정
5. 📦 배포 준비

---

💡 문제가 발생하면 Docker 로그를 먼저 확인하세요:
```powershell
docker-compose logs -f
```
