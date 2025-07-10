# EXFIN REST - Windows Server Otomatik Kurulum
# PowerShell'i yönetici olarak çalıştırın

Write-Host "🚀 EXFIN REST - Windows Server Kurulumu" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

# 1. Windows Features kontrolü
Write-Host "[1/5] Windows Features kontrol ediliyor..." -ForegroundColor Yellow

# Hyper-V kontrolü
$hyperV = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
if ($hyperV.State -eq "Enabled") {
    Write-Host "✅ Hyper-V: Etkin" -ForegroundColor Green
} else {
    Write-Host "⚠️ Hyper-V: Etkin değil, etkinleştiriliyor..." -ForegroundColor Yellow
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
    Write-Host "✅ Hyper-V: Etkinleştirildi" -ForegroundColor Green
}

# Containers kontrolü
$containers = Get-WindowsOptionalFeature -Online -FeatureName Containers
if ($containers.State -eq "Enabled") {
    Write-Host "✅ Containers: Etkin" -ForegroundColor Green
} else {
    Write-Host "⚠️ Containers: Etkin değil, etkinleştiriliyor..." -ForegroundColor Yellow
    Enable-WindowsOptionalFeature -Online -FeatureName Containers -NoRestart
    Write-Host "✅ Containers: Etkinleştirildi" -ForegroundColor Green
}

# 2. Chocolatey kurulumu
Write-Host "[2/5] Chocolatey kontrol ediliyor..." -ForegroundColor Yellow
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "📦 Chocolatey kuruluyor..." -ForegroundColor Yellow
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Write-Host "✅ Chocolatey: Kuruldu" -ForegroundColor Green
} else {
    Write-Host "✅ Chocolatey: Zaten kurulu" -ForegroundColor Green
}

# 3. Docker Desktop kurulumu
Write-Host "[3/5] Docker Desktop kontrol ediliyor..." -ForegroundColor Yellow
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "🐳 Docker Desktop kuruluyor..." -ForegroundColor Yellow
    choco install docker-desktop -y
    Write-Host "✅ Docker Desktop: Kuruldu" -ForegroundColor Green
    Write-Host "⚠️ Docker Desktop'ı manuel olarak başlatın ve yeniden başlatın" -ForegroundColor Yellow
    Write-Host "📥 Docker Desktop: https://www.docker.com/products/docker-desktop/" -ForegroundColor Cyan
} else {
    Write-Host "✅ Docker Desktop: Zaten kurulu" -ForegroundColor Green
}

# 4. Git kurulumu
Write-Host "[4/5] Git kontrol ediliyor..." -ForegroundColor Yellow
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "📝 Git kuruluyor..." -ForegroundColor Yellow
    choco install git -y
    Write-Host "✅ Git: Kuruldu" -ForegroundColor Green
} else {
    Write-Host "✅ Git: Zaten kurulu" -ForegroundColor Green
}

# 5. Proje dosyalarını hazırlama
Write-Host "[5/5] Proje dosyaları hazırlanıyor..." -ForegroundColor Yellow

# Environment dosyasını kopyala
if (Test-Path "env.production.example") {
    if (-not (Test-Path ".env.production")) {
        Copy-Item "env.production.example" ".env.production"
        Write-Host "✅ Environment dosyası oluşturuldu" -ForegroundColor Green
        Write-Host "🔐 .env.production dosyasını düzenleyin ve şifreleri değiştirin" -ForegroundColor Yellow
    } else {
        Write-Host "✅ Environment dosyası zaten mevcut" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "🎉 Kurulum tamamlandı!" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Sonraki adımlar:" -ForegroundColor Cyan
Write-Host "1. Docker Desktop'ı başlatın" -ForegroundColor White
Write-Host "2. Bilgisayarı yeniden başlatın" -ForegroundColor White
Write-Host "3. .env.production dosyasını düzenleyin" -ForegroundColor White
Write-Host "4. .\deploy-windows.ps1 komutunu çalıştırın" -ForegroundColor White
Write-Host ""
Write-Host "🔧 Manuel kurulum için:" -ForegroundColor Cyan
Write-Host "• Docker Desktop: https://www.docker.com/products/docker-desktop/" -ForegroundColor White
Write-Host "• WSL2: https://docs.microsoft.com/en-us/windows/wsl/install" -ForegroundColor White
Write-Host "" 