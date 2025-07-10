@echo off
echo EXFIN REST - Otomatik Kurulum
echo ================================
echo.

REM Docker kurulu mu kontrol et
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Docker kurulu degil! Lutfen Docker Desktop'i kurun.
    echo https://www.docker.com/products/docker-desktop/
    pause
    exit /b 1
)

echo Docker kurulu. Kurulum basliyor...
echo.

REM Docker Compose ile kurulum
docker-compose up -d

echo.
echo Kurulum tamamlandi!
echo.
echo Servisler:
echo - PostgreSQL: localhost:5432
echo - Hasura: http://localhost:8080
echo - API Gateway: http://localhost:3000
echo - MinIO: http://localhost:9001
echo.
echo Flutter uygulamasinda API adresini guncelleyin:
echo http://localhost:8080
echo.
pause 