@echo off
title EXFIN REST - Tek Komut Kurulum
color 0A

echo.
echo  ███████╗██╗  ██╗███████╗██╗███╗   ██╗██████╗ 
echo  ██╔════╝╚██╗██╔╝██╔════╝██║████╗  ██║██╔══██╗
echo  █████╗   ╚███╔╝ █████╗  ██║██╔██╗ ██║██████╔╝
echo  ██╔══╝   ██╔██╗ ██╔══╝  ██║██║╚██╗██║██╔══██╗
echo  ███████╗██╔╝ ██╗██║     ██║██║ ╚████║██║  ██║
echo  ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝
echo.
echo  RESTAURANT MANAGEMENT SYSTEM
echo  =============================
echo.

echo [1/4] Docker kontrol ediliyor...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker kurulu degil!
    echo 📥 Docker Desktop'i indirin: https://www.docker.com/products/docker-desktop/
    echo 💡 Kurduktan sonra bu scripti tekrar calistirin.
    pause
    exit /b 1
)
echo ✅ Docker kurulu

echo.
echo [2/4] Servisler baslatiliyor...
docker-compose up -d --quiet-pull

echo.
echo [3/4] Servislerin hazir olmasini bekleniyor...
timeout /t 10 /nobreak >nul

echo.
echo [4/4] Durum kontrol ediliyor...
docker-compose ps

echo.
echo 🎉 KURULUM TAMAMLANDI!
echo =======================
echo.
echo 📱 Flutter uygulamasinda API adresini guncelleyin:
echo    http://localhost:8080
echo.
echo 🌐 Erisim adresleri:
echo    • Hasura Console: http://localhost:8080
echo    • API Gateway: http://localhost:3000
echo    • MinIO Console: http://localhost:9001
echo.
echo 📋 Komutlar:
echo    • Durum: docker-compose ps
echo    • Loglar: docker-compose logs
echo    • Durdur: docker-compose down
echo.
pause 