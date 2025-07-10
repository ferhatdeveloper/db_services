@echo off
title EXFIN REST - Durum Kontrolu
color 0B

echo.
echo  ███████╗██╗  ██╗███████╗██╗███╗   ██╗██████╗ 
echo  ██╔════╝╚██╗██╔╝██╔════╝██║████╗  ██║██╔══██╗
echo  █████╗   ╚███╔╝ █████╗  ██║██╔██╗ ██║██████╔╝
echo  ██╔══╝   ██╔██╗ ██╔══╝  ██║██║╚██╗██║██╔══██╗
echo  ███████╗██╔╝ ██╗██║     ██║██║ ╚████║██║  ██║
echo  ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝
echo.
echo  DURUM KONTROLU
echo  ===============
echo.

echo [1/4] Docker kontrol ediliyor...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker kurulu degil!
    echo 📥 Docker Desktop'i indirin: https://www.docker.com/products/docker-desktop/
    pause
    exit /b 1
)
echo ✅ Docker kurulu

echo.
echo [2/4] Servislerin durumu kontrol ediliyor...
docker-compose ps

echo.
echo [3/4] Servislerin saglik durumu kontrol ediliyor...

REM PostgreSQL kontrol
docker-compose exec postgres pg_isready -U exfin_user -d exfin_rest >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ PostgreSQL: Calisiyor
) else (
    echo ❌ PostgreSQL: Sorun var
)

REM Hasura kontrol
curl -f http://localhost:8080/healthz >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Hasura: Calisiyor
) else (
    echo ❌ Hasura: Sorun var
)

REM API Gateway kontrol
curl -f http://localhost:3000/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ API Gateway: Calisiyor
) else (
    echo ❌ API Gateway: Sorun var
)

REM MinIO kontrol
curl -f http://localhost:9000/minio/health/live >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ MinIO: Calisiyor
) else (
    echo ❌ MinIO: Sorun var
)

echo.
echo [4/4] Erisim adresleri:
echo.
echo 🌐 Hasura Console: http://localhost:8080
echo 🔌 API Gateway: http://localhost:3000
echo 📁 MinIO Console: http://localhost:9001
echo 🗄️ PostgreSQL: localhost:5432
echo.
echo 📱 Flutter uygulamasinda API adresi:
echo    http://localhost:8080
echo.
pause 