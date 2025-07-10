# EXFIN REST - Windows Server WSL2 Backend Kurulumu
# PowerShell'i yönetici olarak çalıştırın

Write-Host "🚀 EXFIN REST - Windows Server WSL2 Kurulumu" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""

# 1. WSL2 kurulumu
Write-Host "[1/6] WSL2 kurulumu kontrol ediliyor..." -ForegroundColor Yellow

# WSL özelliğini etkinleştir
Write-Host "📦 WSL özelliği etkinleştiriliyor..." -ForegroundColor Yellow
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# Virtual Machine Platform özelliğini etkinleştir
Write-Host "🖥️ Virtual Machine Platform etkinleştiriliyor..." -ForegroundColor Yellow
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

Write-Host "✅ WSL2 özellikleri etkinleştirildi" -ForegroundColor Green
Write-Host "⚠️ Bilgisayarı yeniden başlatmanız gerekiyor!" -ForegroundColor Yellow

# 2. WSL2 kernel güncellemesi
Write-Host "[2/6] WSL2 kernel güncellemesi indiriliyor..." -ForegroundColor Yellow
$kernelUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
$kernelPath = "$env:TEMP\wsl_update_x64.msi"

try {
    Invoke-WebRequest -Uri $kernelUrl -OutFile $kernelPath
    Write-Host "✅ WSL2 kernel güncellemesi indirildi" -ForegroundColor Green
    Write-Host "📦 Kernel güncellemesi kuruluyor..." -ForegroundColor Yellow
    Start-Process msiexec.exe -Wait -ArgumentList "/i $kernelPath /quiet"
    Write-Host "✅ WSL2 kernel güncellemesi kuruldu" -ForegroundColor Green
} catch {
    Write-Host "❌ WSL2 kernel güncellemesi indirilemedi" -ForegroundColor Red
    Write-Host "📥 Manuel olarak indirin: https://aka.ms/wsl2kernel" -ForegroundColor Cyan
}

# 3. Ubuntu kurulumu
Write-Host "[3/6] Ubuntu WSL2 dağıtımı kuruluyor..." -ForegroundColor Yellow
try {
    wsl --install -d Ubuntu
    Write-Host "✅ Ubuntu WSL2 kuruldu" -ForegroundColor Green
} catch {
    Write-Host "❌ Ubuntu kurulumu başarısız" -ForegroundColor Red
    Write-Host "📥 Manuel olarak kurun: wsl --install -d Ubuntu" -ForegroundColor Cyan
}

# 4. Chocolatey kurulumu
Write-Host "[4/6] Chocolatey kontrol ediliyor..." -ForegroundColor Yellow
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "📦 Chocolatey kuruluyor..." -ForegroundColor Yellow
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Write-Host "✅ Chocolatey: Kuruldu" -ForegroundColor Green
} else {
    Write-Host "✅ Chocolatey: Zaten kurulu" -ForegroundColor Green
}

# 5. Docker Desktop kurulumu
Write-Host "[5/6] Docker Desktop kontrol ediliyor..." -ForegroundColor Yellow
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "🐳 Docker Desktop kuruluyor..." -ForegroundColor Yellow
    choco install docker-desktop -y
    Write-Host "✅ Docker Desktop: Kuruldu" -ForegroundColor Green
    Write-Host "⚠️ Docker Desktop'ı başlatın ve WSL2 backend'i etkinleştirin" -ForegroundColor Yellow
} else {
    Write-Host "✅ Docker Desktop: Zaten kurulu" -ForegroundColor Green
}

# 6. Proje dosyalarını hazırlama
Write-Host "[6/6] Proje dosyaları hazırlanıyor..." -ForegroundColor Yellow

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
Write-Host "🎉 WSL2 Kurulumu tamamlandı!" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Sonraki adımlar:" -ForegroundColor Cyan
Write-Host "1. Bilgisayarı yeniden başlatın" -ForegroundColor White
Write-Host "2. Docker Desktop'ı başlatın" -ForegroundColor White
Write-Host "3. Docker Desktop Settings > General > Use WSL 2 based engine" -ForegroundColor White
Write-Host "4. .env.production dosyasını düzenleyin" -ForegroundColor White
Write-Host "5. .\deploy-windows.ps1 komutunu çalıştırın" -ForegroundColor White
Write-Host ""
Write-Host "🔧 Docker Desktop WSL2 Ayarları:" -ForegroundColor Cyan
Write-Host "• Settings > General > Use WSL 2 based engine" -ForegroundColor White
Write-Host "• Settings > Resources > WSL Integration" -ForegroundColor White
Write-Host "• Ubuntu'yu etkinleştirin" -ForegroundColor White
Write-Host "" 