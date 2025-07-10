# EXFIN REST - Otomatik Backend Kurulum Scripti (Windows)
# PowerShell'i yönetici olarak çalıştırın
# Kurulum dizini: C:\EXFIN\dbServis

$ErrorActionPreference = 'Stop'

Write-Host "🚀 EXFIN REST - Otomatik Backend Kurulumu Başlatılıyor..." -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green

# 1. Gerekli klasörleri oluştur
$baseDir = "C:\EXFIN\dbServis"
$binDir = "$baseDir\\bin"
$logDir = "$baseDir\\logs"
$pgDataDir = "$baseDir\\postgres_data"
$minioDataDir = "$baseDir\\minio_data"
$hasuraDir = "$baseDir\\hasura"
$authDir = "$baseDir\\auth-service"
$apiDir = "$baseDir\\api-gateway"

$dirs = @($baseDir, $binDir, $logDir, $pgDataDir, $minioDataDir, $hasuraDir, $authDir, $apiDir)
foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
}

# 2. PostgreSQL Kurulumu
Write-Host "[1/6] PostgreSQL kurulumu..." -ForegroundColor Yellow
$pgInstaller = "$binDir\\postgresql-installer.exe"
if (-not (Test-Path $pgInstaller)) {
    Invoke-WebRequest -Uri "https://get.enterprisedb.com/postgresql/postgresql-15.6-1-windows-x64.exe" -OutFile $pgInstaller
}
# Sessiz kurulum (örnek şifre: exfin2024)
Start-Process -FilePath $pgInstaller -ArgumentList '--mode unattended --unattendedmodeui none --superpassword exfin2024 --servicename exfin_postgres --serviceaccount postgres --servicepassword exfin2024 --datadir', $pgDataDir -Wait

# 3. Node.js Kurulumu
Write-Host "[2/6] Node.js kurulumu..." -ForegroundColor Yellow
$nodeInstaller = "$binDir\\nodejs-setup.exe"
if (-not (Test-Path $nodeInstaller)) {
    Invoke-WebRequest -Uri "https://nodejs.org/dist/v20.11.1/node-v20.11.1-x64.msi" -OutFile $nodeInstaller
}
Start-Process msiexec.exe -ArgumentList "/i $nodeInstaller /qn /norestart" -Wait

# 4. Go Kurulumu
Write-Host "[3/6] Go kurulumu..." -ForegroundColor Yellow
$goInstaller = "$binDir\\go-setup.msi"
if (-not (Test-Path $goInstaller)) {
    Invoke-WebRequest -Uri "https://go.dev/dl/go1.22.3.windows-amd64.msi" -OutFile $goInstaller
}
Start-Process msiexec.exe -ArgumentList "/i $goInstaller /qn /norestart" -Wait

# 5. Hasura Kurulumu
Write-Host "[4/6] Hasura kurulumu..." -ForegroundColor Yellow
$hasuraExe = "$hasuraDir\\hasura.exe"
if (-not (Test-Path $hasuraExe)) {
    Invoke-WebRequest -Uri "https://github.com/hasura/graphql-engine/releases/download/v2.33.4/cli-hasura-windows-amd64.exe" -OutFile $hasuraExe
}

# 6. MinIO Kurulumu
Write-Host "[5/6] MinIO kurulumu..." -ForegroundColor Yellow
$minioExe = "$minioDataDir\\minio.exe"
if (-not (Test-Path $minioExe)) {
    Invoke-WebRequest -Uri "https://dl.min.io/server/minio/release/windows-amd64/minio.exe" -OutFile $minioExe
}

# 7. Auth Service (Go) Derlemesi
Write-Host "[6/6] Auth Service derleniyor..." -ForegroundColor Yellow
if (Test-Path "$authDir\\main.go") {
    Push-Location $authDir
    go build -o auth-service.exe main.go
    Pop-Location
}

# 8. API Gateway (Node.js) Kurulumu
Write-Host "[7/7] API Gateway kurulumu..." -ForegroundColor Yellow
if (Test-Path "$apiDir\\package.json") {
    Push-Location $apiDir
    npm install --legacy-peer-deps
    Pop-Location
}

# 9. Servisleri başlat (arka planda)
Write-Host "Servisler başlatılıyor..." -ForegroundColor Cyan
Start-Process -FilePath "$hasuraExe" -ArgumentList "serve --database-url postgres://postgres:exfin2024@localhost:5432/postgres --admin-secret exfin2024 --server-port 8880" -WindowStyle Hidden -RedirectStandardOutput "$logDir\\hasura.log"
Start-Process -FilePath "$minioExe" -ArgumentList "server $minioDataDir --console-address :9001" -WindowStyle Hidden -RedirectStandardOutput "$logDir\\minio.log"
if (Test-Path "$authDir\\auth-service.exe") {
    Start-Process -FilePath "$authDir\\auth-service.exe" -WindowStyle Hidden -RedirectStandardOutput "$logDir\\auth-service.log"
}
if (Test-Path "$apiDir\\server.js") {
    Start-Process -FilePath "node" -ArgumentList "$apiDir\\server.js" -WindowStyle Hidden -RedirectStandardOutput "$logDir\\api-gateway.log"
}

Write-Host "\n🎉 Tüm servisler başlatıldı!" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host "\n🌐 Erişim adresleri:" -ForegroundColor Cyan
Write-Host "   • Hasura Console: http://localhost:8880" -ForegroundColor White
Write-Host "   • API Gateway: http://localhost:3000" -ForegroundColor White
Write-Host "   • Auth Service: http://localhost:8080" -ForegroundColor White
Write-Host "   • MinIO Console: http://localhost:9001" -ForegroundColor White
Write-Host "   • PostgreSQL: localhost:5432" -ForegroundColor White
Write-Host "\n📋 Yönetim komutları ve loglar için README'yi inceleyin." -ForegroundColor Cyan 