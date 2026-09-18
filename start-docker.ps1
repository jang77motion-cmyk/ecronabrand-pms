# Ecronabrand Docker Compose 자동 시작 스크립트

# 프로젝트 폴더로 이동
cd D:\ecronabrand

Write-Host "🐳 Docker Compose 서비스 시작 중..." -ForegroundColor Cyan

# 기존 컨테이너 중지 및 제거
Write-Host "이전 컨테이너 정리 중..." -ForegroundColor Yellow
docker-compose down -v 2>$null

# 모든 서비스 시작
Write-Host "서비스 빌드 및 시작 중... (약 2-3분 소요)" -ForegroundColor Cyan
docker-compose up -d

# 서비스 상태 확인
Write-Host "`n서비스 상태 확인 중..." -ForegroundColor Cyan
Start-Sleep -Seconds 5

docker-compose ps

Write-Host "`n✅ 완료!" -ForegroundColor Green
Write-Host "📱 프론트엔드: http://localhost:3000" -ForegroundColor Green
Write-Host "🔌 백엔드 API: http://localhost:3001/api" -ForegroundColor Green
Write-Host "📚 API 문서: http://localhost:3001/api/docs" -ForegroundColor Green
