# EXFIN REST - Tümleşik Kurulum, Kaldırma ve Servis Kontrol Scripti
# PowerShell'i yönetici olarak çalıştırın

function Remove-ExfinServices {
    Write-Host "Tüm EXFIN servisleri ve dosyaları kaldırılıyor..." -ForegroundColor Yellow
    # Servisi durdur ve sil
    if (Get-Service -Name Exfin_dbservices -ErrorAction SilentlyContinue) {
        Stop-Service Exfin_dbservices -Force
        sc.exe delete Exfin_dbservices
    }
    # NSSM ve binary'leri sil
    $installDir = Read-Host "Kaldırılacak ana dizini girin (örn: C:\EXFIN\dbServis)"
    if (Test-Path $installDir) {
        Remove-Item -Path $installDir -Recurse -Force
        Write-Host "$installDir dizini ve tüm içeriği silindi." -ForegroundColor Green
    }
    Write-Host "Kaldırma işlemi tamamlandı." -ForegroundColor Green
}

function Install-ExfinServices {
    # 1. Kurulum dizini sor
    $installDir = Read-Host "Kurulum yapılacak dizini girin (örn: C:\EXFIN\dbServis)"
    if (-not (Test-Path $installDir)) { New-Item -ItemType Directory -Path $installDir | Out-Null }

    # 2. NSSM'yi indir ve çıkar
    $nssmZip = "$installDir\nssm.zip"
    $nssmDir = "$installDir\nssm"
    $nssmExe = "$nssmDir\nssm.exe"
    if (-not (Test-Path $nssmExe)) {
        Invoke-WebRequest -Uri "https://nssm.cc/release/nssm-2.24.zip" -OutFile $nssmZip
        Expand-Archive -Path $nssmZip -DestinationPath $nssmDir
        $nssmExe = Get-ChildItem -Path $nssmDir -Recurse -Filter nssm.exe | Select-Object -First 1 | % { $_.FullName }
    }

    # 3. Gerekli binary dosyalarını indir
    $binDir = "$installDir\bin"
    if (-not (Test-Path $binDir)) { New-Item -ItemType Directory -Path $binDir | Out-Null }
    $hasuraExe = "$binDir\hasura.exe"
    if (-not (Test-Path $hasuraExe)) {
        Invoke-WebRequest -Uri "https://github.com/hasura/graphql-engine/releases/latest/download/cli-hasura-windows-amd64.exe" -OutFile $hasuraExe
    }
    $minioExe = "$binDir\minio.exe"
    if (-not (Test-Path $minioExe)) {
        Invoke-WebRequest -Uri "https://dl.min.io/server/minio/release/windows-amd64/minio.exe" -OutFile $minioExe
    }
    # Diğer servis binary'leri ve config dosyalarını da burada ekleyin

    # 4. Tüm backend servislerini başlatan bir toplu script oluştur
    $allScript = "$installDir\run-all-backend.ps1"
    @"
Start-Process -FilePath '$hasuraExe' -ArgumentList 'serve --database-url postgres://postgres:exfin2024@localhost:5432/postgres --admin-secret exfin2024 --server-port 8880' -WindowStyle Hidden
Start-Process -FilePath '$minioExe' -ArgumentList 'server $installDir\minio_data --console-address :9001' -WindowStyle Hidden
# Diğer servisler için benzer satırlar ekleyin (auth-service, api-gateway, nhost vs.)
"@ | Set-Content $allScript

    # 5. NSSM ile tek bir Windows servisi olarak ekle
    & $nssmExe install Exfin_dbservices "powershell.exe" "-ExecutionPolicy Bypass -File `"$allScript`""
    & $nssmExe set Exfin_dbservices Start SERVICE_AUTO_START

    # 6. Servisi başlat
    Start-Service Exfin_dbservices

    Write-Host "`n🎉 Exfin_dbservices Windows servisi olarak eklendi ve başlatıldı!"
    Write-Host "Services.msc panelinden yönetebilirsiniz."
    Write-Host "Sunucu açıldığında otomatik başlar."
    Write-Host "Kurulum tamamlandı. Erişim adresleri README.md'de!"
}

function Check-ExfinServices {
    Write-Host "EXFIN servis durumu kontrol ediliyor..." -ForegroundColor Cyan
    if (Get-Service -Name Exfin_dbservices -ErrorAction SilentlyContinue) {
        $svc = Get-Service -Name Exfin_dbservices
        Write-Host "Servis adı: $($svc.Name) - Durum: $($svc.Status)" -ForegroundColor Green
    } else {
        Write-Host "Exfin_dbservices servisi bulunamadı." -ForegroundColor Red
    }
    # Port ve process kontrolü
    netstat -ano | findstr :8880
    netstat -ano | findstr :9001
    # Diğer servis portlarını da ekleyebilirsiniz
}

# Ana Menü
Write-Host "EXFIN REST Kurulum ve Yönetim Scripti" -ForegroundColor Cyan
Write-Host "1. Kurulum"
Write-Host "2. Kaldır (Tüm dosya ve servisleri sil)"
Write-Host "3. Servis Durumunu Kontrol Et"
$secim = Read-Host "Bir işlem seçin (1/2/3)"

switch ($secim) {
    "1" { Install-ExfinServices }
    "2" { Remove-ExfinServices }
    "3" { Check-ExfinServices }
    default { Write-Host "Geçersiz seçim!" -ForegroundColor Red }
} 