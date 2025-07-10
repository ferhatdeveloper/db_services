# EXFIN REST - Windows Server Durum Kontrolü
# PowerShell'i yönetici olarak çalıştırın

param(
    [string]$ServerIP = "localhost"
)

Write-Host "🔍 EXFIN REST - Windows Server Durum Kontrolü" -ForegroundColor Blue
Write-Host "===============================================" -ForegroundColor Blue
Write-Host ""

# 1. Docker kontrolü
Write-Host "[1/5] Docker kontrol ediliyor..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker kurulu değil!" -ForegroundColor Red
    Write-Host "📥 Docker Desktop'ı indirin: https://www.docker.com/products/docker-desktop/" -ForegroundColor Cyan
    exit 1
}

# 2. Container durumu
Write-Host "[2/5] Container durumu kontrol ediliyor..." -ForegroundColor Yellow
try {
    docker-compose -f docker-compose.prod.yml ps
} catch {
    Write-Host "❌ Docker Compose dosyası bulunamadı!" -ForegroundColor Red
    exit 1
}

# 3. Port kontrolü
Write-Host "[3/5] Port kontrolü yapılıyor..." -ForegroundColor Yellow

$ports = @(8080, 3000, 9000, 9001)
foreach ($port in $ports) {
    $connection = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    if ($connection) {
        Write-Host "✅ Port ${port}: Açık" -ForegroundColor Green
    } else {
        Write-Host "❌ Port ${port}: Kapalı" -ForegroundColor Red
    }
}

# 4. Servis sağlık kontrolü
Write-Host "[4/5] Servis sağlık kontrolü yapılıyor..." -ForegroundColor Yellow

# PostgreSQL kontrol
try {
    docker-compose -f docker-compose.prod.yml exec postgres pg_isready -U exfin_user -d exfin_rest
    Write-Host "✅ PostgreSQL: Çalışıyor" -ForegroundColor Green
} catch {
    Write-Host "❌ PostgreSQL: Sorun var" -ForegroundColor Red
}

# Hasura kontrol
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/healthz" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Hasura: Çalışıyor" -ForegroundColor Green
    } else {
        Write-Host "❌ Hasura: Sorun var" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Hasura: Erişilemiyor" -ForegroundColor Red
}

# API Gateway kontrol
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/health" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ API Gateway: Çalışıyor" -ForegroundColor Green
    } else {
        Write-Host "❌ API Gateway: Sorun var" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ API Gateway: Erişilemiyor" -ForegroundColor Red
}

# MinIO kontrol
try {
    $response = Invoke-WebRequest -Uri "http://localhost:9000/minio/health/live" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ MinIO: Çalışıyor" -ForegroundColor Green
    } else {
        Write-Host "❌ MinIO: Sorun var" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ MinIO: Erişilemiyor" -ForegroundColor Red
}

# 5. Erişim adresleri
Write-Host "[5/5] Erişim adresleri:" -ForegroundColor Yellow
Write-Host ""
Write-Host "🌐 Servis adresleri:" -ForegroundColor Cyan
Write-Host "   • Hasura Console: http://$ServerIP:8080" -ForegroundColor White
Write-Host "   • API Gateway: http://$ServerIP:3000" -ForegroundColor White
Write-Host "   • MinIO Console: http://$ServerIP:9001" -ForegroundColor White
Write-Host ""
Write-Host "📱 Flutter uygulaması için:" -ForegroundColor Cyan
Write-Host "   http://$ServerIP:8080" -ForegroundColor White
Write-Host ""
Write-Host "📋 Yönetim komutları:" -ForegroundColor Cyan
Write-Host "   • Durum: docker-compose -f docker-compose.prod.yml ps" -ForegroundColor White
Write-Host "   • Loglar: docker-compose -f docker-compose.prod.yml logs" -ForegroundColor White
Write-Host "   • Durdur: docker-compose -f docker-compose.prod.yml down" -ForegroundColor White
Write-Host "   • Yeniden başlat: .\deploy-windows.ps1" -ForegroundColor White
Write-Host "" 