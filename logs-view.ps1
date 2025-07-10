# EXFIN REST - Servis Loglarını Görüntüle (Windows)
# PowerShell'i yönetici olarak çalıştırın

$logDir = "C:\EXFIN\dbServis\logs"
Write-Host "--- Hasura Log ---" -ForegroundColor Cyan
Get-Content "$logDir\hasura.log" -Tail 30
Write-Host "\n--- MinIO Log ---" -ForegroundColor Cyan
Get-Content "$logDir\minio.log" -Tail 30
Write-Host "\n--- Auth Service Log ---" -ForegroundColor Cyan
Get-Content "$logDir\auth-service.log" -Tail 30
Write-Host "\n--- API Gateway Log ---" -ForegroundColor Cyan
Get-Content "$logDir\api-gateway.log" -Tail 30 