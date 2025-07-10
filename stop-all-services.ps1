# EXFIN REST - Tüm Servisleri Durdur (Windows)
# PowerShell'i yönetici olarak çalıştırın

Write-Host "Tüm servisler durduruluyor..." -ForegroundColor Yellow
$processes = @('hasura', 'minio', 'auth-service', 'node')
foreach ($proc in $processes) {
    Get-Process -Name $proc -ErrorAction SilentlyContinue | Stop-Process -Force
}
Write-Host "Tüm servisler durduruldu!" -ForegroundColor Green 