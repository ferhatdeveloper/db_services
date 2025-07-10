# EXFIN REST - Manuel Docker Kurulumu

Bu doküman, EXFIN REST backend'ini Docker ile manuel olarak kurma adımlarını içerir.

## 📋 Gereksinimler

- ✅ Docker Desktop (WSL2 backend ile)
- ✅ PowerShell (Yönetici hakları)
- ✅ Windows Server 2019/2022
- ✅ En az 4GB RAM
- ✅ En az 10GB boş disk alanı

## 🚀 Kurulum Adımları

### Adım 1: Dosya Yapısını Hazırlayın

```powershell
# PowerShell'i yönetici olarak çalıştırın
cd C:\EXFIN\dbServis\backend

# Dosya yapısını kontrol edin
dir
```

### Adım 2: Environment Dosyasını Hazırlayın

```powershell
# Environment dosyasını kopyalayın
Copy-Item "env.manual.example" ".env.manual"

# Dosyayı düzenleyin
notepad .env.manual
```

### Adım 3: Environment Dosyasını Düzenleyin

`.env.manual` dosyasında şu değişiklikleri yapın:

```env
# Database
POSTGRES_PASSWORD=guclu_sifre_2024_manual

# Hasura
HASURA_ADMIN_SECRET=guclu_admin_secret_2024_manual

# JWT
JWT_SECRET=guclu_jwt_secret_2024_manual

# MinIO
MINIO_ACCESS_KEY=exfin_minio_access_manual
MINIO_SECRET_KEY=guclu_minio_secret_2024_manual

# Server IP (Windows Server IP adresinizi buraya yazın)
SERVER_IP=192.168.1.100

# Port Ayarları
HASURA_PORT=8880
API_GATEWAY_PORT=3000
AUTH_SERVICE_PORT=8080
POSTGRES_PORT=5432
MINIO_PORT=9000
MINIO_CONSOLE_PORT=9001
```

### Adım 4: Docker Desktop Ayarlarını Kontrol Edin

1. **Docker Desktop'ı başlatın**
2. **Settings > General > Use WSL 2 based engine** ✅
3. **Settings > Resources > WSL Integration** ✅
4. **Ubuntu'yu etkinleştirin** ✅

### Adım 5: Manuel Deployment'ı Başlatın

```powershell
# Deployment scriptini çalıştırın
.\deploy-manual.ps1
```

### Adım 6: Durumu Kontrol Edin

```powershell
# Durum kontrolü
.\status-manual.ps1
```

## 🌐 Erişim Adresleri

Kurulum tamamlandıktan sonra şu adreslere erişebilirsiniz:

- **Hasura Console**: http://localhost:8880
- **API Gateway**: http://localhost:3000
- **Auth Service**: http://localhost:8080
- **MinIO Console**: http://localhost:9001
- **PostgreSQL**: localhost:5432

## 📱 Flutter Uygulaması

Flutter uygulamasında API adresi otomatik olarak güncellenmiştir:
- **GraphQL Endpoint**: http://localhost:8880/v1/graphql

## 🔧 Yönetim Komutları

### Servisleri Başlatma
```powershell
docker-compose -f docker-compose.manual.yml up -d
```

### Servisleri Durdurma
```powershell
docker-compose -f docker-compose.manual.yml down
```

### Durum Kontrolü
```powershell
docker-compose -f docker-compose.manual.yml ps
```

### Logları Görüntüleme
```powershell
docker-compose -f docker-compose.manual.yml logs
```

### Belirli Servisin Logları
```powershell
docker-compose -f docker-compose.manual.yml logs hasura
docker-compose -f docker-compose.manual.yml logs api-gateway
docker-compose -f docker-compose.manual.yml logs auth-service
```

### Servisleri Yeniden Başlatma
```powershell
docker-compose -f docker-compose.manual.yml restart
```

## 🛠️ Sorun Giderme

### Port Çakışması
```powershell
# Kullanılan portları kontrol edin
netstat -ano | findstr :8880
netstat -ano | findstr :3000
netstat -ano | findstr :8080
```

### Docker Servisleri Başlamıyorsa
```powershell
# Tüm container'ları durdurun
docker-compose -f docker-compose.manual.yml down

# Docker'ı yeniden başlatın
Restart-Service docker

# Servisleri tekrar başlatın
docker-compose -f docker-compose.manual.yml up -d
```

### Disk Alanı Sorunu
```powershell
# Docker disk kullanımını kontrol edin
docker system df

# Eski container'ları temizleyin
docker system prune -a
```

### WSL2 Sorunu
```powershell
# WSL2'yi yeniden başlatın
wsl --shutdown
wsl --start
```

## 📊 Performans İzleme

### Container Kaynak Kullanımı
```powershell
docker stats
```

### Disk Kullanımı
```powershell
docker system df
```

### Network Kullanımı
```powershell
docker network ls
docker network inspect exfin_dbServis_exfin_network
```

## 🔒 Güvenlik

### Firewall Ayarları
```powershell
# Gerekli portları açın
New-NetFirewallRule -DisplayName "EXFIN Hasura" -Direction Inbound -Protocol TCP -LocalPort 8880 -Action Allow
New-NetFirewallRule -DisplayName "EXFIN API Gateway" -Direction Inbound -Protocol TCP -LocalPort 3000 -Action Allow
New-NetFirewallRule -DisplayName "EXFIN Auth Service" -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow
```

### SSL Sertifikası (Opsiyonel)
```powershell
# SSL sertifikası için nginx reverse proxy ekleyin
# Bu adım opsiyoneldir ve production ortamı için önerilir
```

## 📝 Log Dosyaları

Log dosyaları şu konumlarda bulunur:
- **Docker Logs**: `docker-compose -f docker-compose.manual.yml logs`
- **Container Logs**: `docker logs exfin_hasura`

## 🆘 Destek

Sorun yaşarsanız:
1. Logları kontrol edin
2. Port çakışması olup olmadığını kontrol edin
3. Docker Desktop'ın çalıştığından emin olun
4. WSL2'nin etkin olduğunu kontrol edin

---

**Not**: Bu kurulum manuel Docker kurulumu içindir. Production ortamı için ek güvenlik önlemleri alınmalıdır. 