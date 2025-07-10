# EXFIN REST - Tüm Servisleri Başlat (Windows)
# PowerShell'i yönetici olarak çalıştırın

$baseDir = "C:\EXFIN\dbServis"
$logDir = "$baseDir\logs"
$hasuraExe = "$baseDir\hasura\hasura.exe"
$minioExe = "$baseDir\minio_data\minio.exe"
$authExe = "$baseDir\auth-service\auth-service.exe"
$apiDir = "$baseDir\api-gateway"

Write-Host "Tüm servisler başlatılıyor..." -ForegroundColor Cyan
Start-Process -FilePath $hasuraExe -ArgumentList "serve --database-url postgres://postgres:exfin2024@localhost:5432/postgres --admin-secret exfin2024 --server-port 8880" -WindowStyle Hidden -RedirectStandardOutput "$logDir\hasura.log"
Start-Process -FilePath $minioExe -ArgumentList "server $baseDir\minio_data --console-address :9001" -WindowStyle Hidden -RedirectStandardOutput "$logDir\minio.log"
if (Test-Path $authExe) {
    Start-Process -FilePath $authExe -WindowStyle Hidden -RedirectStandardOutput "$logDir\auth-service.log"
}
if (Test-Path "$apiDir\server.js") {
    Start-Process -FilePath "node" -ArgumentList "$apiDir\server.js" -WindowStyle Hidden -RedirectStandardOutput "$logDir\api-gateway.log"
}
Write-Host "Tüm servisler arka planda başlatıldı!" -ForegroundColor Green 