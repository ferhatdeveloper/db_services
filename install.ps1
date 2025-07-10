# EXFIN REST - Tümleşik Kurulum, Kaldırma ve Servis Kontrol Scripti
# PowerShell'i yönetici olarak çalıştırın

# Hata yönetimi
$ErrorActionPreference = 'Stop'

# Kısa link çözümleme fonksiyonu
function Resolve-ShortUrl {
    param([string]$ShortUrl)
    
    try {
        # Cloudflare korumalı linkler için alternatif çözümler
        switch ($ShortUrl) {
            "https://t.ly/exfindb" { 
                return "https://raw.githubusercontent.com/ferhatdeveloper/db_services/main/install.ps1"
            }
            "https://bit.ly/exfin-install" {
                return "https://raw.githubusercontent.com/ferhatdeveloper/db_services/main/install.ps1"
            }
            default {
                # Normal HTTP redirect takibi
                $response = Invoke-WebRequest -Uri $ShortUrl -MaximumRedirection 0 -ErrorAction SilentlyContinue
                if ($response.StatusCode -eq 301 -or $response.StatusCode -eq 302) {
                    return $response.Headers.Location
                }
                return $ShortUrl
            }
        }
    }
    catch {
        Write-Host "Kısa link çözümlenemedi. Doğrudan GitHub'dan indiriliyor..." -ForegroundColor Yellow
        return "https://raw.githubusercontent.com/ferhatdeveloper/db_services/main/install.ps1"
    }
}

# Otomatik güncelleme fonksiyonu
function Update-Script {
    Write-Host "Script güncelleniyor..." -ForegroundColor Cyan
    $scriptUrl = "https://raw.githubusercontent.com/ferhatdeveloper/db_services/main/install.ps1"
    try {
        $newScript = Invoke-RestMethod -Uri $scriptUrl
        $currentScript = Get-Content $PSCommandPath -Raw
        if ($newScript -ne $currentScript) {
            Set-Content -Path $PSCommandPath -Value $newScript
            Write-Host "Script güncellendi. Yeniden başlatılıyor..." -ForegroundColor Green
            & $PSCommandPath
            exit
        }
    }
    catch {
        Write-Host "Güncelleme başarısız. Mevcut script kullanılıyor." -ForegroundColor Yellow
    }
}

function Remove-ExfinServices {
    Write-Host "Tüm EXFIN servisleri ve dosyaları kaldırılıyor..." -ForegroundColor Yellow
    try {
        # Servisi durdur ve sil
        if (Get-Service -Name Exfin_dbservices -ErrorAction SilentlyContinue) {
            Stop-Service Exfin_dbservices -Force
            sc.exe delete Exfin_dbservices
            Write-Host "Exfin_dbservices servisi kaldırıldı." -ForegroundColor Green
        }
        
        # NSSM ve binary'leri sil
        $installDir = Read-Host "Kaldırılacak ana dizini girin (örn: C:\EXFIN\dbServis)"
        if (Test-Path $installDir) {
            Remove-Item -Path $installDir -Recurse -Force
            Write-Host "$installDir dizini ve tüm içeriği silindi." -ForegroundColor Green
        }
        Write-Host "Kaldırma işlemi tamamlandı." -ForegroundColor Green
    }
    catch {
        Write-Host "Kaldırma sırasında hata: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Install-ExfinServices {
    try {
        Write-Host "🚀 EXFIN REST Backend Kurulumu Başlatılıyor..." -ForegroundColor Green
        Write-Host "=====================================================" -ForegroundColor Green
        
        # 1. Kurulum dizini sor
        $installDir = Read-Host "Kurulum yapılacak dizini girin (örn: C:\EXFIN\dbServis)"
        if (-not (Test-Path $installDir)) { 
            New-Item -ItemType Directory -Path $installDir | Out-Null 
            Write-Host "Kurulum dizini oluşturuldu: $installDir" -ForegroundColor Green
        }

        # 2. Alt dizinleri oluştur
        $binDir = "$installDir\bin"
        $logDir = "$installDir\logs"
        $dataDir = "$installDir\data"
        $configDir = "$installDir\config"
        
        @($binDir, $logDir, $dataDir, $configDir) | ForEach-Object {
            if (-not (Test-Path $_)) { New-Item -ItemType Directory -Path $_ | Out-Null }
        }

        # 3. NSSM'yi indir ve çıkar
        Write-Host "[1/5] NSSM indiriliyor..." -ForegroundColor Yellow
        $nssmZip = "$installDir\nssm.zip"
        $nssmDir = "$installDir\nssm"
        $nssmExe = "$nssmDir\nssm.exe"
        
        if (-not (Test-Path $nssmExe)) {
            Invoke-WebRequest -Uri "https://nssm.cc/release/nssm-2.24.zip" -OutFile $nssmZip
            Expand-Archive -Path $nssmZip -DestinationPath $nssmDir -Force
            $nssmExe = Get-ChildItem -Path $nssmDir -Recurse -Filter nssm.exe | Select-Object -First 1 | % { $_.FullName }
            Remove-Item $nssmZip -Force
        }

        # 4. Gerekli binary dosyalarını indir
        Write-Host "[2/5] Binary dosyalar indiriliyor..." -ForegroundColor Yellow
        
        # Hasura CLI
        $hasuraExe = "$binDir\hasura.exe"
        if (-not (Test-Path $hasuraExe)) {
            Invoke-WebRequest -Uri "https://github.com/hasura/graphql-engine/releases/latest/download/cli-hasura-windows-amd64.exe" -OutFile $hasuraExe
        }
        
        # MinIO Server
        $minioExe = "$binDir\minio.exe"
        if (-not (Test-Path $minioExe)) {
            Invoke-WebRequest -Uri "https://dl.min.io/server/minio/release/windows-amd64/minio.exe" -OutFile $minioExe
        }
        
        # PostgreSQL (portable)
        $pgDir = "$binDir\postgresql"
        if (-not (Test-Path $pgDir)) {
            New-Item -ItemType Directory -Path $pgDir | Out-Null
            Invoke-WebRequest -Uri "https://get.enterprisedb.com/postgresql/postgresql-15.6-1-windows-x64-binaries.zip" -OutFile "$installDir\postgresql.zip"
            Expand-Archive -Path "$installDir\postgresql.zip" -DestinationPath $pgDir -Force
            Remove-Item "$installDir\postgresql.zip" -Force
        }

        # 5. Config dosyalarını oluştur
        Write-Host "[3/5] Config dosyaları oluşturuluyor..." -ForegroundColor Yellow
        
        # Hasura config
        $hasuraConfig = "$configDir\hasura-config.yaml"
        @"
version: 3
endpoint: http://localhost:8880
admin_secret: exfin2024
metadata_directory: $configDir\metadata
migrations_directory: $configDir\migrations
seeds_directory: $configDir\seeds
actions:
  kind: synchronous
  handler_webhook_baseurl: http://localhost:3000
"@ | Set-Content $hasuraConfig

        # MinIO config
        $minioDataDir = "$dataDir\minio"
        if (-not (Test-Path $minioDataDir)) { New-Item -ItemType Directory -Path $minioDataDir | Out-Null }

        # 6. Tüm backend servislerini başlatan script oluştur
        Write-Host "[4/5] Servis başlatma scripti oluşturuluyor..." -ForegroundColor Yellow
        $allScript = "$installDir\run-all-backend.ps1"
        @"
# EXFIN REST Backend Servisleri Başlatma Scripti
Set-Location '$installDir'

# PostgreSQL başlat
Start-Process -FilePath '$pgDir\bin\pg_ctl.exe' -ArgumentList 'start -D $dataDir\postgres -l $logDir\postgres.log' -WindowStyle Hidden

# MinIO başlat
Start-Process -FilePath '$minioExe' -ArgumentList 'server $minioDataDir --console-address :9001 --address :9000' -WindowStyle Hidden

# Hasura başlat
Start-Process -FilePath '$hasuraExe' -ArgumentList 'serve --database-url postgres://postgres:exfin2024@localhost:5432/postgres --admin-secret exfin2024 --server-port 8880 --enable-console' -WindowStyle Hidden

Write-Host "EXFIN REST Backend servisleri başlatıldı!" -ForegroundColor Green
Write-Host "Hasura Console: http://localhost:8880" -ForegroundColor Cyan
Write-Host "MinIO Console: http://localhost:9001" -ForegroundColor Cyan
Write-Host "API Gateway: http://localhost:3000" -ForegroundColor Cyan
"@ | Set-Content $allScript

        # 7. NSSM ile Windows servisi olarak ekle
        Write-Host "[5/5] Windows servisi oluşturuluyor..." -ForegroundColor Yellow
        & $nssmExe install Exfin_dbservices "powershell.exe" "-ExecutionPolicy Bypass -File `"$allScript`""
        & $nssmExe set Exfin_dbservices Start SERVICE_AUTO_START
        & $nssmExe set Exfin_dbservices AppDirectory $installDir
        & $nssmExe set Exfin_dbservices Description "EXFIN REST Backend Services"

        # 8. Servisi başlat
        Start-Service Exfin_dbservices

        Write-Host "`n🎉 EXFIN REST Backend kurulumu tamamlandı!" -ForegroundColor Green
        Write-Host "===============================================" -ForegroundColor Green
        Write-Host "`n🌐 Erişim adresleri:" -ForegroundColor Cyan
        Write-Host "   • Hasura Console: http://localhost:8880" -ForegroundColor White
        Write-Host "   • MinIO Console: http://localhost:9001" -ForegroundColor White
        Write-Host "   • API Gateway: http://localhost:3000" -ForegroundColor White
        Write-Host "   • PostgreSQL: localhost:5432" -ForegroundColor White
        Write-Host "`n📋 Yönetim:" -ForegroundColor Cyan
        Write-Host "   • Servis kontrolü: services.msc" -ForegroundColor White
        Write-Host "   • Loglar: $logDir" -ForegroundColor White
        Write-Host "   • Config: $configDir" -ForegroundColor White
        Write-Host "`n🔄 Servis otomatik başlatılacak ve sunucu açıldığında çalışacak." -ForegroundColor Green
        
    }
    catch {
        Write-Host "Kurulum sırasında hata: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Detaylı hata: $($_.Exception.StackTrace)" -ForegroundColor Red
    }
}

function Check-ExfinServices {
    Write-Host "EXFIN servis durumu kontrol ediliyor..." -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    
    # Windows servisi kontrolü
    if (Get-Service -Name Exfin_dbservices -ErrorAction SilentlyContinue) {
        $svc = Get-Service -Name Exfin_dbservices
        Write-Host "✅ Windows Servisi: $($svc.Name) - Durum: $($svc.Status)" -ForegroundColor Green
    } else {
        Write-Host "❌ Exfin_dbservices servisi bulunamadı." -ForegroundColor Red
    }
    
    # Port kontrolü
    Write-Host "`n🔍 Port durumları:" -ForegroundColor Yellow
    $ports = @(8880, 9001, 3000, 5432)
    foreach ($port in $ports) {
        $connection = netstat -ano | findstr ":${port} "
        if ($connection) {
            Write-Host "✅ Port ${port}: Açık" -ForegroundColor Green
        } else {
            Write-Host "❌ Port ${port}: Kapalı" -ForegroundColor Red
        }
    }
    
    # Process kontrolü
    Write-Host "`n🔍 Çalışan process'ler:" -ForegroundColor Yellow
    $processes = @("hasura", "minio", "postgres")
    foreach ($proc in $processes) {
        $running = Get-Process -Name $proc -ErrorAction SilentlyContinue
        if ($running) {
            Write-Host "✅ ${proc}: Çalışıyor" -ForegroundColor Green
        } else {
            Write-Host "❌ ${proc}: Çalışmıyor" -ForegroundColor Red
        }
    }
}

# Ana Menü
Write-Host "EXFIN REST Kurulum ve Yönetim Scripti" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "1. Kurulum (Tüm servisleri kur ve başlat)"
Write-Host "2. Kaldır (Tüm dosya ve servisleri sil)"
Write-Host "3. Servis Durumunu Kontrol Et"
Write-Host "4. Script Güncelle"
Write-Host "5. Çıkış"
Write-Host "===============================================" -ForegroundColor Cyan
$secim = Read-Host "Bir işlem seçin (1/2/3/4/5)"

switch ($secim) {
    "1" { Install-ExfinServices }
    "2" { Remove-ExfinServices }
    "3" { Check-ExfinServices }
    "4" { Update-Script }
    "5" { Write-Host "Çıkılıyor..." -ForegroundColor Yellow; exit }
    default { Write-Host "Geçersiz seçim! Lütfen 1, 2, 3, 4 veya 5 girin." -ForegroundColor Red }
} 