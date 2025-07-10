# EXFIN REST - WSL + Hasura Otomatik Kurulum Scripti (Tek Dosya)
# PowerShell'i yönetici olarak çalıştırın

# 1. WSL ve Ubuntu Kurulumu
Write-Host "WSL ve Ubuntu kurulumu başlatılıyor..." -ForegroundColor Cyan
wsl --install -d Ubuntu

# 2. Ubuntu ilk kurulumdan sonra devam etmek için kullanıcıdan onay al
Read-Host "Ubuntu kurulumu tamamlandıysa ENTER'a basın (ilk açılışta kullanıcı adı/şifre belirleyin ve kapatın)"

# 3. Hasura Server'ı WSL/Ubuntu içinde kur ve başlat
$hasuraInstallScript = @'
#!/bin/bash
set -e
sudo apt update
sudo apt install -y curl postgresql-client
cd ~
curl -L https://github.com/hasura/graphql-engine/releases/latest/download/graphql-engine-linux-amd64 -o hasura
chmod +x hasura
nohup ./hasura serve --database-url postgres://postgres:exfin2024@localhost:5432/postgres --admin-secret exfin2024 --server-port 8880 > hasura.log 2>&1 &
echo "Hasura başlatıldı. Log: $HOME/hasura.log"
'@

# 4. Scripti geçici dosyaya kaydet
$scriptPath = "$env:TEMP\hasura-wsl-install.sh"
Set-Content -Path $scriptPath -Value $hasuraInstallScript -Encoding UTF8

# 5. Scripti WSL'ye kopyala ve çalıştır
wsl cp /mnt/c/Windows/Temp/hasura-wsl-install.sh ~/
wsl bash ~/hasura-wsl-install.sh

Write-Host "`nHasura WSL/Ubuntu içinde başlatıldı! http://localhost:8880 adresinden erişebilirsiniz." -ForegroundColor Green
Write-Host "Log dosyası: Ubuntu home dizininde hasura.log" 