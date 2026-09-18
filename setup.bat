@echo off
cd /d D:\ecronabrand
cls

echo.
echo 🐳 Docker Compose 서비스 시작 중...
echo.

REM 이전 컨테이너 정지
echo 이전 컨테이너 정리 중...
docker-compose down -v 2>nul

REM 모든 서비스 시작
echo 서비스 빌드 및 시작 중... (약 2-3분 소요)
docker-compose up -d

REM 잠시 대기
timeout /t 5 /nobreak

REM 상태 확인
echo.
echo 서비스 상태:
docker-compose ps

echo.
echo ✅ 완료!
echo.
echo 📱 프론트엔드: http://localhost:3000
echo 🔌 백엔드 API: http://localhost:3001/api
echo 📚 API 문서: http://localhost:3001/api/docs
echo.
pause
