# EXFIN REST - Tümleşik Kurulum, Kaldırma ve Servis Kontrol Scripti
# PowerShell'i yönetici olarak çalıştırın

# Hata yönetimi
$ErrorActionPreference = 'Stop'

# Yönetici yetkisi kontrolü ve yükseltme fonksiyonu
function Test-AdminAndElevate {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-Host "⚠️  PowerShell yönetici yetkisi ile çalıştırılmadı!" -ForegroundColor Yellow
        Write-Host "===============================================" -ForegroundColor Yellow
        Write-Host "Bu script Windows servisleri oluşturmak için yönetici yetkisi gerektirir." -ForegroundColor Cyan
        Write-Host "===============================================" -ForegroundColor Yellow
        
        $response = Read-Host "Yönetici olarak devam etmek istiyor musunuz? (E/H)"
        
        if ($response -eq "E" -or $response -eq "e" -or $response -eq "Y" -or $response -eq "y") {
            Write-Host "🚀 PowerShell yönetici olarak yeniden başlatılıyor..." -ForegroundColor Green
            
            try {
                # Mevcut script parametrelerini al
                $scriptPath = $PSCommandPath
                $arguments = $MyInvocation.BoundParameters.GetEnumerator() | ForEach-Object { "-$($_.Key) $($_.Value)" }
                $argumentString = $arguments -join " "
                
                # Yönetici olarak yeniden başlat
                Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`" $argumentString" -Verb RunAs -Wait
                exit
            }
            catch {
                Write-Host "❌ Yönetici yetkisi yükseltilemedi!" -ForegroundColor Red
                Write-Host "Lütfen PowerShell'i manuel olarak yönetici olarak çalıştırın:" -ForegroundColor Cyan
                Write-Host "1. PowerShell'e sağ tıklayın" -ForegroundColor White
                Write-Host "2. 'Yönetici olarak çalıştır' seçin" -ForegroundColor White
                Write-Host "3. Scripti tekrar çalıştırın" -ForegroundColor White
                Read-Host "Devam etmek için Enter'a basın"
                exit
            }
        } else {
            Write-Host "❌ Yönetici yetkisi gerekli. Script sonlandırılıyor." -ForegroundColor Red
            Read-Host "Çıkmak için Enter'a basın"
            exit
        }
    } else {
        Write-Host "✅ PowerShell yönetici yetkisi ile çalışıyor." -ForegroundColor Green
    }
}

# Yönetici yetkisi kontrolü
Test-AdminAndElevate

# Kısa link çözümleme fonksiyonu
function Resolve-ShortUrl {
    param([string]$ShortUrl)
    
    try {
        # Cloudflare korumalı linkler için alternatif çözümler
        switch ($ShortUrl) {
            "https://t.ly/exfindb" { 
                Write-Host "⚠️  Kısa link Cloudflare koruması altında. Doğrudan GitHub'dan indiriliyor..." -ForegroundColor Yellow
                return "https://raw.githubusercontent.com/ferhatdeveloper/db_services/main/install.ps1"
            }
            "https://bit.ly/exfin-install" {
                Write-Host "⚠️  Kısa link Cloudflare koruması altında. Doğrudan GitHub'dan indiriliyor..." -ForegroundColor Yellow
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
        Write-Host "❌ Kısa link çözümlenemedi. Doğrudan GitHub'dan indiriliyor..." -ForegroundColor Red
        Write-Host "💡 Önerilen: Doğrudan GitHub linkini kullanın:" -ForegroundColor Cyan
        Write-Host "   irm https://raw.githubusercontent.com/ferhatdeveloper/db_services/main/install.ps1 | iex" -ForegroundColor Green
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
        # 1. Önce servisi durdur
        if (Get-Service -Name Exfin_dbservices -ErrorAction SilentlyContinue) {
            Write-Host "🛑 Exfin_dbservices servisi durduruluyor..." -ForegroundColor Yellow
            Stop-Service Exfin_dbservices -Force
            Start-Sleep -Seconds 3
            sc.exe delete Exfin_dbservices
            Write-Host "✅ Exfin_dbservices servisi kaldırıldı." -ForegroundColor Green
        }
        
        # 2. Çalışan process'leri sonlandır
        Write-Host "🛑 Çalışan process'ler sonlandırılıyor..." -ForegroundColor Yellow
        $processes = @("hasura", "minio", "postgres", "pg_ctl")
        foreach ($proc in $processes) {
            $running = Get-Process -Name $proc -ErrorAction SilentlyContinue
            if ($running) {
                Write-Host "   • $proc process'i sonlandırılıyor..." -ForegroundColor Yellow
                Stop-Process -Name $proc -Force -ErrorAction SilentlyContinue
            }
        }
        
        # 3. Port kullanımını kontrol et ve temizle
        Write-Host "🔍 Port kullanımı kontrol ediliyor..." -ForegroundColor Yellow
        $ports = @(8880, 9001, 9000, 3000, 5432)
        foreach ($port in $ports) {
            $connection = netstat -ano | findstr ":${port} "
            if ($connection) {
                Write-Host "   • Port $port kullanımda, temizleniyor..." -ForegroundColor Yellow
                # Port kullanan process'i bul ve sonlandır
                $lines = $connection -split "`n"
                foreach ($line in $lines) {
                    if ($line -match '\s+(\d+)$') {
                        $processId = $matches[1]
                        try {
                            Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
                        } catch {
                            Write-Host "     ⚠️  Process $processId sonlandırılamadı" -ForegroundColor Yellow
                        }
                    }
                }
            }
        }
        
        # 4. Kısa bir bekleme
        Write-Host "⏳ Sistem temizleniyor..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
        
        # 5. NSSM ve binary'leri sil
        $installDir = Read-Host "Kaldırılacak ana dizini girin (örn: C:\EXFIN\dbServis)"
        
        if (Test-Path $installDir) {
            Write-Host "🗑️  Dizin ve dosyalar siliniyor..." -ForegroundColor Yellow
            
            # Alt dizinleri önce sil
            $subDirs = @("bin", "logs", "data", "config", "nssm")
            foreach ($subDir in $subDirs) {
                $fullPath = "$installDir\$subDir"
                if (Test-Path $fullPath) {
                    try {
                        Remove-Item -Path $fullPath -Recurse -Force -ErrorAction SilentlyContinue
                        Write-Host "   ✅ $subDir dizini silindi" -ForegroundColor Green
                    } catch {
                        Write-Host "   ⚠️  $subDir dizini silinemedi: $($_.Exception.Message)" -ForegroundColor Yellow
                    }
                }
            }
            
            # Ana dizini sil
            try {
                Remove-Item -Path $installDir -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host "✅ $installDir dizini ve tüm içeriği silindi." -ForegroundColor Green
            } catch {
                Write-Host "⚠️  Ana dizin silinemedi. Manuel olarak silmeniz gerekebilir." -ForegroundColor Yellow
                Write-Host "   Hata: $($_.Exception.Message)" -ForegroundColor Red
                Write-Host "   Çözüm: Bilgisayarı yeniden başlatın ve tekrar deneyin." -ForegroundColor Cyan
            }
        } else {
            Write-Host "ℹ️  $installDir dizini bulunamadı." -ForegroundColor Yellow
        }
        
        # 6. Registry temizliği (opsiyonel)
        Write-Host "🔧 Registry temizliği yapılıyor..." -ForegroundColor Yellow
        try {
            $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Exfin_dbservices"
            if (Test-Path $regPath) {
                Remove-Item -Path $regPath -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host "✅ Registry kayıtları temizlendi" -ForegroundColor Green
            }
        } catch {
            Write-Host "⚠️  Registry temizliği yapılamadı" -ForegroundColor Yellow
        }
        
        Write-Host "`n🎉 Kaldırma işlemi tamamlandı!" -ForegroundColor Green
        Write-Host "===============================================" -ForegroundColor Green
        Write-Host "📋 Yapılan işlemler:" -ForegroundColor Cyan
        Write-Host "   ✅ Windows servisi kaldırıldı" -ForegroundColor White
        Write-Host "   ✅ Çalışan process'ler sonlandırıldı" -ForegroundColor White
        Write-Host "   ✅ Port kullanımları temizlendi" -ForegroundColor White
        Write-Host "   ✅ Dosyalar silindi" -ForegroundColor White
        Write-Host "   ✅ Registry temizlendi" -ForegroundColor White
        
    }
    catch {
        Write-Host "❌ Kaldırma sırasında hata: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "💡 Çözüm önerileri:" -ForegroundColor Cyan
        Write-Host "   1. Bilgisayarı yeniden başlatın" -ForegroundColor White
        Write-Host "   2. Task Manager'dan ilgili process'leri sonlandırın" -ForegroundColor White
        Write-Host "   3. Dizini manuel olarak silin" -ForegroundColor White
        Write-Host "   4. Antivirus programını geçici olarak devre dışı bırakın" -ForegroundColor White
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

function Change-PortSettings {
    Write-Host "🔧 Port Değişikliği Yönetimi" -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    
    # Mevcut portları göster
    Write-Host "📋 Mevcut Port Ayarları:" -ForegroundColor Yellow
    Write-Host "   • Hasura Console: 8880" -ForegroundColor White
    Write-Host "   • MinIO Console: 9001" -ForegroundColor White
    Write-Host "   • MinIO API: 9000" -ForegroundColor White
    Write-Host "   • API Gateway: 3000" -ForegroundColor White
    Write-Host "   • PostgreSQL: 5432" -ForegroundColor White
    
    Write-Host "`n💡 Öneriler:" -ForegroundColor Cyan
    Write-Host "   • Hasura: 8080, 8880, 8081 (GraphQL API için)" -ForegroundColor Green
    Write-Host "   • MinIO: 9000, 9001, 9002 (Object Storage için)" -ForegroundColor Green
    Write-Host "   • API Gateway: 3000, 3001, 8080 (REST API için)" -ForegroundColor Green
    Write-Host "   • PostgreSQL: 5432, 5433, 5434 (Veritabanı için)" -ForegroundColor Green
    
    Write-Host "`n⚠️  Dikkat:" -ForegroundColor Yellow
    Write-Host "   • Port değişikliği sonrası servisler yeniden başlatılacak" -ForegroundColor Red
    Write-Host "   • Mevcut bağlantılar kesilebilir" -ForegroundColor Red
    Write-Host "   • Firewall ayarları güncellenmeli" -ForegroundColor Red
    
    Write-Host "`n🎯 Hangi servisin portunu değiştirmek istiyorsunuz?" -ForegroundColor Cyan
    Write-Host "1. Hasura Console (Şu an: 8880)"
    Write-Host "2. MinIO Console (Şu an: 9001)"
    Write-Host "3. MinIO API (Şu an: 9000)"
    Write-Host "4. API Gateway (Şu an: 3000)"
    Write-Host "5. PostgreSQL (Şu an: 5432)"
    Write-Host "6. Tümünü Özelleştir"
    Write-Host "7. Geri Dön"
    
    $portSecim = Read-Host "Seçiminizi yapın (1-7)"
    
    switch ($portSecim) {
        "1" { Change-HasuraPort }
        "2" { Change-MinIOConsolePort }
        "3" { Change-MinIOAPIPort }
        "4" { Change-APIGatewayPort }
        "5" { Change-PostgreSQLPort }
        "6" { Change-AllPorts }
        "7" { return }
        default { Write-Host "Geçersiz seçim!" -ForegroundColor Red }
    }
}

function Change-HasuraPort {
    Write-Host "`n🔧 Hasura Console Port Değişikliği" -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    
    Write-Host "💡 Önerilen portlar:" -ForegroundColor Green
    Write-Host "   • 8080 (Standart HTTP)"
    Write-Host "   • 8880 (Mevcut)"
    Write-Host "   • 8081 (Alternatif)"
    Write-Host "   • 3001 (Geliştirme)"
    
    $newPort = Read-Host "Yeni port numarasını girin (örn: 8080)"
    
    if ($newPort -match '^\d+$' -and [int]$newPort -ge 1024 -and [int]$newPort -le 65535) {
        Write-Host "✅ Port değişikliği yapılıyor..." -ForegroundColor Green
        
        # Config dosyasını güncelle
        $configDir = "C:\EXFIN\dbServis\config"
        $hasuraConfig = "$configDir\hasura-config.yaml"
        
        if (Test-Path $hasuraConfig) {
            $content = Get-Content $hasuraConfig -Raw
            $content = $content -replace 'endpoint: http://localhost:\d+', "endpoint: http://localhost:$newPort"
            Set-Content $hasuraConfig $content
            Write-Host "✅ Hasura config güncellendi" -ForegroundColor Green
        }
        
        # Servis başlatma scriptini güncelle
        $installDir = "C:\EXFIN\dbServis"
        $allScript = "$installDir\run-all-backend.ps1"
        
        if (Test-Path $allScript) {
            $content = Get-Content $allScript -Raw
            $content = $content -replace '--server-port \d+', "--server-port $newPort"
            Set-Content $allScript $content
            Write-Host "✅ Servis başlatma scripti güncellendi" -ForegroundColor Green
        }
        
        # Servisi yeniden başlat
        if (Get-Service -Name Exfin_dbservices -ErrorAction SilentlyContinue) {
            Restart-Service Exfin_dbservices
            Write-Host "✅ Servis yeniden başlatıldı" -ForegroundColor Green
        }
        
        Write-Host "`n🎉 Hasura Console portu $newPort olarak değiştirildi!" -ForegroundColor Green
        Write-Host "🌐 Yeni adres: http://localhost:$newPort" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Geçersiz port numarası! 1024-65535 arasında olmalı." -ForegroundColor Red
    }
}

function Change-MinIOConsolePort {
    Write-Host "`n🔧 MinIO Console Port Değişikliği" -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    
    Write-Host "💡 Önerilen portlar:" -ForegroundColor Green
    Write-Host "   • 9001 (Mevcut)"
    Write-Host "   • 9002 (Alternatif)"
    Write-Host "   • 8080 (Standart HTTP)"
    Write-Host "   • 3002 (Geliştirme)"
    
    $newPort = Read-Host "Yeni port numarasını girin (örn: 9002)"
    
    if ($newPort -match '^\d+$' -and [int]$newPort -ge 1024 -and [int]$newPort -le 65535) {
        Write-Host "✅ Port değişikliği yapılıyor..." -ForegroundColor Green
        
        # Servis başlatma scriptini güncelle
        $installDir = "C:\EXFIN\dbServis"
        $allScript = "$installDir\run-all-backend.ps1"
        
        if (Test-Path $allScript) {
            $content = Get-Content $allScript -Raw
            $content = $content -replace '--console-address :\d+', "--console-address :$newPort"
            Set-Content $allScript $content
            Write-Host "✅ Servis başlatma scripti güncellendi" -ForegroundColor Green
        }
        
        # Servisi yeniden başlat
        if (Get-Service -Name Exfin_dbservices -ErrorAction SilentlyContinue) {
            Restart-Service Exfin_dbservices
            Write-Host "✅ Servis yeniden başlatıldı" -ForegroundColor Green
        }
        
        Write-Host "`n🎉 MinIO Console portu $newPort olarak değiştirildi!" -ForegroundColor Green
        Write-Host "🌐 Yeni adres: http://localhost:$newPort" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Geçersiz port numarası! 1024-65535 arasında olmalı." -ForegroundColor Red
    }
}

function Change-MinIOAPIPort {
    Write-Host "`n🔧 MinIO API Port Değişikliği" -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    
    Write-Host "💡 Önerilen portlar:" -ForegroundColor Green
    Write-Host "   • 9000 (Mevcut)"
    Write-Host "   • 9001 (Alternatif)"
    Write-Host "   • 8080 (Standart HTTP)"
    Write-Host "   • 3003 (Geliştirme)"
    
    $newPort = Read-Host "Yeni port numarasını girin (örn: 9001)"
    
    if ($newPort -match '^\d+$' -and [int]$newPort -ge 1024 -and [int]$newPort -le 65535) {
        Write-Host "✅ Port değişikliği yapılıyor..." -ForegroundColor Green
        
        # Servis başlatma scriptini güncelle
        $installDir = "C:\EXFIN\dbServis"
        $allScript = "$installDir\run-all-backend.ps1"
        
        if (Test-Path $allScript) {
            $content = Get-Content $allScript -Raw
            $content = $content -replace '--address :\d+', "--address :$newPort"
            Set-Content $allScript $content
            Write-Host "✅ Servis başlatma scripti güncellendi" -ForegroundColor Green
        }
        
        # Servisi yeniden başlat
        if (Get-Service -Name Exfin_dbservices -ErrorAction SilentlyContinue) {
            Restart-Service Exfin_dbservices
            Write-Host "✅ Servis yeniden başlatıldı" -ForegroundColor Green
        }
        
        Write-Host "`n🎉 MinIO API portu $newPort olarak değiştirildi!" -ForegroundColor Green
        Write-Host "🌐 Yeni adres: http://localhost:$newPort" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Geçersiz port numarası! 1024-65535 arasında olmalı." -ForegroundColor Red
    }
}

function Change-APIGatewayPort {
    Write-Host "`n🔧 API Gateway Port Değişikliği" -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    
    Write-Host "💡 Önerilen portlar:" -ForegroundColor Green
    Write-Host "   • 3000 (Mevcut)"
    Write-Host "   • 3001 (Alternatif)"
    Write-Host "   • 8080 (Standart HTTP)"
    Write-Host "   • 5000 (Geliştirme)"
    
    $newPort = Read-Host "Yeni port numarasını girin (örn: 3001)"
    
    if ($newPort -match '^\d+$' -and [int]$newPort -ge 1024 -and [int]$newPort -le 65535) {
        Write-Host "✅ Port değişikliği yapılıyor..." -ForegroundColor Green
        
        # Config dosyalarını güncelle
        $configDir = "C:\EXFIN\dbServis\config"
        $hasuraConfig = "$configDir\hasura-config.yaml"
        
        if (Test-Path $hasuraConfig) {
            $content = Get-Content $hasuraConfig -Raw
            $content = $content -replace 'handler_webhook_baseurl: http://localhost:\d+', "handler_webhook_baseurl: http://localhost:$newPort"
            Set-Content $hasuraConfig $content
            Write-Host "✅ Hasura config güncellendi" -ForegroundColor Green
        }
        
        Write-Host "`n🎉 API Gateway portu $newPort olarak değiştirildi!" -ForegroundColor Green
        Write-Host "🌐 Yeni adres: http://localhost:$newPort" -ForegroundColor Cyan
        Write-Host "⚠️  API Gateway servisini manuel olarak yeniden başlatmanız gerekebilir." -ForegroundColor Yellow
    } else {
        Write-Host "❌ Geçersiz port numarası! 1024-65535 arasında olmalı." -ForegroundColor Red
    }
}

function Change-PostgreSQLPort {
    Write-Host "`n🔧 PostgreSQL Port Değişikliği" -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    
    Write-Host "💡 Önerilen portlar:" -ForegroundColor Green
    Write-Host "   • 5432 (Standart PostgreSQL)"
    Write-Host "   • 5433 (Alternatif)"
    Write-Host "   • 5434 (Geliştirme)"
    Write-Host "   • 5435 (Test)"
    
    $newPort = Read-Host "Yeni port numarasını girin (örn: 5433)"
    
    if ($newPort -match '^\d+$' -and [int]$newPort -ge 1024 -and [int]$newPort -le 65535) {
        Write-Host "✅ Port değişikliği yapılıyor..." -ForegroundColor Green
        
        # Config dosyalarını güncelle
        $configDir = "C:\EXFIN\dbServis\config"
        $hasuraConfig = "$configDir\hasura-config.yaml"
        
        if (Test-Path $hasuraConfig) {
            $content = Get-Content $hasuraConfig -Raw
            $content = $content -replace 'endpoint: http://localhost:\d+', "endpoint: http://localhost:$newPort"
            Set-Content $hasuraConfig $content
            Write-Host "✅ Hasura config güncellendi" -ForegroundColor Green
        }
        
        # Servis başlatma scriptini güncelle
        $installDir = "C:\EXFIN\dbServis"
        $allScript = "$installDir\run-all-backend.ps1"
        
        if (Test-Path $allScript) {
            $content = Get-Content $allScript -Raw
            $content = $content -replace 'postgres://postgres:exfin2024@localhost:\d+', "postgres://postgres:exfin2024@localhost:$newPort"
            Set-Content $allScript $content
            Write-Host "✅ Servis başlatma scripti güncellendi" -ForegroundColor Green
        }
        
        # Servisi yeniden başlat
        if (Get-Service -Name Exfin_dbservices -ErrorAction SilentlyContinue) {
            Restart-Service Exfin_dbservices
            Write-Host "✅ Servis yeniden başlatıldı" -ForegroundColor Green
        }
        
        Write-Host "`n🎉 PostgreSQL portu $newPort olarak değiştirildi!" -ForegroundColor Green
        Write-Host "🌐 Yeni adres: localhost:$newPort" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Geçersiz port numarası! 1024-65535 arasında olmalı." -ForegroundColor Red
    }
}

function Change-AllPorts {
    Write-Host "`n🔧 Tüm Portları Özelleştir" -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    
    Write-Host "💡 Önerilen port kombinasyonları:" -ForegroundColor Green
    Write-Host "   • Geliştirme: Hasura(8080), MinIO(9000), API(3000), PG(5432)" -ForegroundColor Cyan
    Write-Host "   • Test: Hasura(8081), MinIO(9001), API(3001), PG(5433)" -ForegroundColor Cyan
    Write-Host "   • Üretim: Hasura(8880), MinIO(9000), API(3000), PG(5432)" -ForegroundColor Cyan
    
    $hasuraPort = Read-Host "Hasura Console portu (örn: 8080)"
    $minioConsolePort = Read-Host "MinIO Console portu (örn: 9001)"
    $minioAPIPort = Read-Host "MinIO API portu (örn: 9000)"
    $apiPort = Read-Host "API Gateway portu (örn: 3000)"
    $pgPort = Read-Host "PostgreSQL portu (örn: 5432)"
    
    # Port doğrulama
    $ports = @($hasuraPort, $minioConsolePort, $minioAPIPort, $apiPort, $pgPort)
    $validPorts = $true
    
    foreach ($port in $ports) {
        if ($port -notmatch '^\d+$' -or [int]$port -lt 1024 -or [int]$port -gt 65535) {
            Write-Host "❌ Geçersiz port: $port" -ForegroundColor Red
            $validPorts = $false
        }
    }
    
    if ($validPorts) {
        Write-Host "✅ Tüm portlar geçerli. Değişiklikler uygulanıyor..." -ForegroundColor Green
        
        # Tüm config dosyalarını güncelle
        $configDir = "C:\EXFIN\dbServis\config"
        $installDir = "C:\EXFIN\dbServis"
        $hasuraConfig = "$configDir\hasura-config.yaml"
        $allScript = "$installDir\run-all-backend.ps1"
        
        # Hasura config güncelle
        if (Test-Path $hasuraConfig) {
            $content = Get-Content $hasuraConfig -Raw
            $content = $content -replace 'endpoint: http://localhost:\d+', "endpoint: http://localhost:$hasuraPort"
            $content = $content -replace 'handler_webhook_baseurl: http://localhost:\d+', "handler_webhook_baseurl: http://localhost:$apiPort"
            Set-Content $hasuraConfig $content
        }
        
        # Servis başlatma scriptini güncelle
        if (Test-Path $allScript) {
            $content = Get-Content $allScript -Raw
            $content = $content -replace '--server-port \d+', "--server-port $hasuraPort"
            $content = $content -replace '--console-address :\d+', "--console-address :$minioConsolePort"
            $content = $content -replace '--address :\d+', "--address :$minioAPIPort"
            $content = $content -replace 'postgres://postgres:exfin2024@localhost:\d+', "postgres://postgres:exfin2024@localhost:$pgPort"
            Set-Content $allScript $content
        }
        
        # Servisi yeniden başlat
        if (Get-Service -Name Exfin_dbservices -ErrorAction SilentlyContinue) {
            Restart-Service Exfin_dbservices
        }
        
        Write-Host "`n🎉 Tüm portlar başarıyla değiştirildi!" -ForegroundColor Green
        Write-Host "===============================================" -ForegroundColor Green
        Write-Host "🌐 Yeni Erişim Adresleri:" -ForegroundColor Cyan
        Write-Host "   • Hasura Console: http://localhost:$hasuraPort" -ForegroundColor White
        Write-Host "   • MinIO Console: http://localhost:$minioConsolePort" -ForegroundColor White
        Write-Host "   • MinIO API: http://localhost:$minioAPIPort" -ForegroundColor White
        Write-Host "   • API Gateway: http://localhost:$apiPort" -ForegroundColor White
        Write-Host "   • PostgreSQL: localhost:$pgPort" -ForegroundColor White
    } else {
        Write-Host "❌ Geçersiz port numaraları var! Lütfen 1024-65535 arasında portlar girin." -ForegroundColor Red
    }
}

# Ana Menü
Write-Host "EXFIN REST Kurulum ve Yönetim Scripti" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "1. Kurulum (Tüm servisleri kur ve başlat)"
Write-Host "2. Kaldır (Tüm dosya ve servisleri sil)"
Write-Host "3. Servis Durumunu Kontrol Et"
Write-Host "4. Port Değişikliği"
Write-Host "5. Script Güncelle"
Write-Host "6. Çıkış"
Write-Host "===============================================" -ForegroundColor Cyan
$secim = Read-Host "Bir işlem seçin (1/2/3/4/5/6)"

switch ($secim) {
    "1" { Install-ExfinServices }
    "2" { Remove-ExfinServices }
    "3" { Check-ExfinServices }
    "4" { Change-PortSettings }
    "5" { Update-Script }
    "6" { Write-Host "Çıkılıyor..." -ForegroundColor Yellow; exit }
    default { Write-Host "Geçersiz seçim! Lütfen 1, 2, 3, 4, 5 veya 6 girin." -ForegroundColor Red }
} 