# EXFIN REST - Windows Server Deployment Scripti
# PowerShell'i yönetici olarak çalıştırın

param(
    [string]$ServerIP = "localhost"
)

Write-Host "🚀 EXFIN REST - Windows Server Deployment" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""

# 1. Docker kontrolü
Write-Host "[1/6] Docker kontrol ediliyor..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker kurulu: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker kurulu değil!" -ForegroundColor Red
    Write-Host "📥 Docker Desktop'ı indirin: https://www.docker.com/products/docker-desktop/" -ForegroundColor Cyan
    exit 1
}

# 2. Environment dosyası kontrolü
Write-Host "[2/6] Environment dosyası kontrol ediliyor..." -ForegroundColor Yellow
if (-not (Test-Path ".env.production")) {
    Write-Host "❌ .env.production dosyası bulunamadı!" -ForegroundColor Red
    Write-Host "📝 env.production.example dosyasını .env.production olarak kopyalayın" -ForegroundColor Cyan
    Write-Host "🔐 Şifreleri güvenli bir şekilde değiştirin" -ForegroundColor Cyan
    exit 1
}

# 3. Eski container'ları temizle
Write-Host "[3/6] Eski container'lar temizleniyor..." -ForegroundColor Yellow
docker-compose -f docker-compose.prod.yml down --remove-orphans

# 4. Image'ları yeniden oluştur
Write-Host "[4/6] Docker image'ları oluşturuluyor..." -ForegroundColor Yellow
docker-compose -f docker-compose.prod.yml build --no-cache

# 5. Servisleri başlat
Write-Host "[5/6] Servisler başlatılıyor..." -ForegroundColor Yellow
docker-compose -f docker-compose.prod.yml up -d

# 6. Servislerin hazır olmasını bekle
Write-Host "[6/6] Servislerin hazır olması bekleniyor..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# 7. Durum kontrolü
Write-Host "📊 Servis durumu kontrol ediliyor..." -ForegroundColor Yellow
docker-compose -f docker-compose.prod.yml ps

# 8. Health check
Write-Host "🏥 Health check yapılıyor..." -ForegroundColor Yellow

# PostgreSQL kontrol
try {
    docker-compose -f docker-compose.prod.yml exec postgres pg_isready -U exfin_user -d exfin_rest
    Write-Host "✅ PostgreSQL: Çalışıyor" -ForegroundColor Green
} catch {
    Write-Host "❌ PostgreSQL: Sorun var" -ForegroundColor Red
}

# Hasura kontrol
try {
    Invoke-WebRequest -Uri "http://localhost:8080/healthz" -UseBasicParsing | Out-Null
    Write-Host "✅ Hasura: Çalışıyor" -ForegroundColor Green
} catch {
    Write-Host "❌ Hasura: Sorun var" -ForegroundColor Red
}

# API Gateway kontrol
try {
    Invoke-WebRequest -Uri "http://localhost:3000/health" -UseBasicParsing | Out-Null
    Write-Host "✅ API Gateway: Çalışıyor" -ForegroundColor Green
} catch {
    Write-Host "❌ API Gateway: Sorun var" -ForegroundColor Red
}

# MinIO kontrol
try {
    Invoke-WebRequest -Uri "http://localhost:9000/minio/health/live" -UseBasicParsing | Out-Null
    Write-Host "✅ MinIO: Çalışıyor" -ForegroundColor Green
} catch {
    Write-Host "❌ MinIO: Sorun var" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎉 Deployment tamamlandı!" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Erişim adresleri:" -ForegroundColor Cyan
Write-Host "   • Hasura Console: http://$ServerIP:8080" -ForegroundColor White
Write-Host "   • API Gateway: http://$ServerIP:3000" -ForegroundColor White
Write-Host "   • MinIO Console: http://$ServerIP:9001" -ForegroundColor White
Write-Host ""
Write-Host "📱 Flutter uygulamasında API adresini güncelleyin:" -ForegroundColor Cyan
Write-Host "   http://$ServerIP:8080" -ForegroundColor White
Write-Host ""
Write-Host "📋 Yönetim komutları:" -ForegroundColor Cyan
Write-Host "   • Durum: docker-compose -f docker-compose.prod.yml ps" -ForegroundColor White
Write-Host "   • Loglar: docker-compose -f docker-compose.prod.yml logs" -ForegroundColor White
Write-Host "   • Durdur: docker-compose -f docker-compose.prod.yml down" -ForegroundColor White
Write-Host "   • Yeniden başlat: .\deploy-windows.ps1" -ForegroundColor White
Write-Host "" 