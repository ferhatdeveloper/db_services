@echo off
title EXFIN REST - Servisleri Durdur
color 0C

echo.
echo  ███████╗██╗  ██╗███████╗██╗███╗   ██╗██████╗ 
echo  ██╔════╝╚██╗██╔╝██╔════╝██║████╗  ██║██╔══██╗
echo  █████╗   ╚███╔╝ █████╗  ██║██╔██╗ ██║██████╔╝
echo  ██╔══╝   ██╔██╗ ██╔══╝  ██║██║╚██╗██║██╔══██╗
echo  ███████╗██╔╝ ██╗██║     ██║██║ ╚████║██║  ██║
echo  ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝
echo.
echo  SERVISLERI DURDUR
echo  ==================
echo.

echo [1/3] Servislerin durumu kontrol ediliyor...
docker-compose ps

echo.
echo [2/3] Servisler durduruluyor...
docker-compose down

echo.
echo [3/3] Durum kontrol ediliyor...
docker-compose ps

echo.
echo ✅ Servisler durduruldu!
echo.
echo 📋 Komutlar:
echo    • Baslat: quick-start.bat
echo    • Durum: check-status.bat
echo    • Loglar: docker-compose logs
echo.
pause 