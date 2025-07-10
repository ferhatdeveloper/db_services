# EXFIN REST - Manuel Docker Desktop Kurulumu
# PowerShell'i yönetici olarak çalıştırın

Write-Host "🚀 EXFIN REST - Manuel Docker Kurulumu" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Manuel kurulum adımları:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. WSL2 Kurulumu:" -ForegroundColor Yellow
Write-Host "   • Windows Features'da 'Windows Subsystem for Linux' etkinleştirin" -ForegroundColor White
Write-Host "   • Windows Features'da 'Virtual Machine Platform' etkinleştirin" -ForegroundColor White
Write-Host "   • Bilgisayarı yeniden başlatın" -ForegroundColor White
Write-Host ""
Write-Host "2. WSL2 Kernel Güncellemesi:" -ForegroundColor Yellow
Write-Host "   • https://aka.ms/wsl2kernel adresinden indirin" -ForegroundColor White
Write-Host "   • wsl_update_x64.msi dosyasını kurun" -ForegroundColor White
Write-Host ""
Write-Host "3. Ubuntu WSL2 Kurulumu:" -ForegroundColor Yellow
Write-Host "   • PowerShell'de: wsl --install -d Ubuntu" -ForegroundColor White
Write-Host "   • Ubuntu'yu başlatın ve kullanıcı oluşturun" -ForegroundColor White
Write-Host ""
Write-Host "4. Docker Desktop Kurulumu:" -ForegroundColor Yellow
Write-Host "   • https://www.docker.com/products/docker-desktop/ adresinden indirin" -ForegroundColor White
Write-Host "   • Kurulum sırasında 'Use WSL 2 instead of Hyper-V' seçin" -ForegroundColor White
Write-Host "   • Docker Desktop'ı başlatın" -ForegroundColor White
Write-Host ""
Write-Host "5. Docker Desktop Ayarları:" -ForegroundColor Yellow
Write-Host "   • Settings > General > Use WSL 2 based engine" -ForegroundColor White
Write-Host "   • Settings > Resources > WSL Integration" -ForegroundColor White
Write-Host "   • Ubuntu'yu etkinleştirin" -ForegroundColor White
Write-Host ""
Write-Host "6. Kurulum Kontrolü:" -ForegroundColor Yellow
Write-Host "   • PowerShell'de: docker --version" -ForegroundColor White
Write-Host "   • PowerShell'de: docker-compose --version" -ForegroundColor White
Write-Host ""
Write-Host "7. Proje Kurulumu:" -ForegroundColor Yellow
Write-Host "   • .env.production dosyasını oluşturun" -ForegroundColor White
Write-Host "   • .\deploy-windows.ps1 komutunu çalıştırın" -ForegroundColor White
Write-Host ""

# Environment dosyasını hazırla
Write-Host "📝 Environment dosyası hazırlanıyor..." -ForegroundColor Yellow
if (Test-Path "env.production.example") {
    if (-not (Test-Path ".env.production")) {
        Copy-Item "env.production.example" ".env.production"
        Write-Host "✅ .env.production dosyası oluşturuldu" -ForegroundColor Green
        Write-Host "🔐 Dosyayı düzenleyin ve şifreleri değiştirin" -ForegroundColor Yellow
    } else {
        Write-Host "✅ .env.production dosyası zaten mevcut" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "🎯 Manuel kurulum tamamlandı!" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Sonraki adımlar:" -ForegroundColor Cyan
Write-Host "1. Yukarıdaki adımları takip edin" -ForegroundColor White
Write-Host "2. Docker'ın çalıştığını kontrol edin" -ForegroundColor White
Write-Host "3. .env.production dosyasını düzenleyin" -ForegroundColor White
Write-Host "4. .\deploy-windows.ps1 komutunu çalıştırın" -ForegroundColor White
Write-Host "" 