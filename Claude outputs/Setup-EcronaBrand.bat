@echo off
REM Ecronabrand PMS Docker Setup Script (Batch version)
REM Run as Administrator

setlocal enabledelayedexpansion
cls

echo.
echo 🐳 Ecronabrand PMS Docker 설정을 시작합니다...
echo.

REM 기본 경로 설정
set PROJECT_PATH=D:\ecronabrand

REM 관리자 권한 확인
openfiles >nul 2>&1
if errorlevel 1 (
    echo ❌ 이 스크립트는 관리자 권한이 필요합니다.
    echo 우클릭으로 "관리자 권한으로 실행"을 선택하세요.
    pause
    exit /b 1
)

REM 디렉토리 생성
echo 📁 디렉토리 구조 생성 중...

if not exist "%PROJECT_PATH%" mkdir "%PROJECT_PATH%"
if not exist "%PROJECT_PATH%\backend" mkdir "%PROJECT_PATH%\backend"
if not exist "%PROJECT_PATH%\backend\src" mkdir "%PROJECT_PATH%\backend\src"
if not exist "%PROJECT_PATH%\backend\prisma" mkdir "%PROJECT_PATH%\backend\prisma"
if not exist "%PROJECT_PATH%\frontend" mkdir "%PROJECT_PATH%\frontend"
if not exist "%PROJECT_PATH%\frontend\src" mkdir "%PROJECT_PATH%\frontend\src"
if not exist "%PROJECT_PATH%\frontend\src\pages" mkdir "%PROJECT_PATH%\frontend\src\pages"
if not exist "%PROJECT_PATH%\frontend\src\styles" mkdir "%PROJECT_PATH%\frontend\src\styles"
if not exist "%PROJECT_PATH%\database" mkdir "%PROJECT_PATH%\database"

echo ✓ 디렉토리 구조 생성 완료

echo.
echo ⚠️  중요: 다음 단계를 수동으로 진행해야 합니다:
echo.
echo 1. 이 스크립트가 생성한 파일들을 %PROJECT_PATH% 로 복사하세요
echo.
echo 2. 다음 주소에서 생성된 모든 파일을 다운로드하세요:
echo    - docker-compose.yml
echo    - backend/package.json, Dockerfile, tsconfig.json
echo    - backend/src/index.ts, prisma/schema.prisma
echo    - frontend/package.json, Dockerfile, tsconfig.json
echo    - frontend/next.config.js, postcss.config.js, tailwind.config.js
echo    - frontend/src/pages/_app.tsx, pages/index.tsx
echo    - frontend/src/styles/globals.css
echo.
echo 3. 파일을 모두 복사한 후 다음 명령어를 실행하세요:
echo.
echo    cd /d %PROJECT_PATH%
echo    docker-compose up -d
echo.
echo 💡 더 간단한 방법: Setup-EcronaBrand.ps1 PowerShell 스크립트를 사용하세요!
echo    이 스크립트는 자동으로 모든 파일을 생성하고 Docker를 시작합니다.
echo.

cd /d "%PROJECT_PATH%"

REM Docker 상태 확인
echo.
echo 🐳 Docker 상태 확인 중...
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker이 설치되어 있지 않거나 실행 중이 아닙니다.
    echo Docker Desktop을 설치하고 실행하세요.
    pause
    exit /b 1
)
echo ✓ Docker이 설치되어 있습니다.

echo.
echo ✅ 준비 완료!
echo.
echo 모든 파일을 %PROJECT_PATH% 에 복사한 후
echo 다음 명령어를 실행하세요:
echo.
echo   cd /d D:\ecronabrand
echo   docker-compose up -d
echo.

pause
