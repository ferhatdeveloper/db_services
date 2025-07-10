# 🐳 EXFIN REST - Docker Kurulum Rehberi

Bu rehber, EXFIN REST backend servislerini Docker kullanarak kolayca kurmanızı sağlar.

## 📋 Gereksinimler

- **Docker Desktop** (Windows/Mac) veya **Docker Engine** (Linux)
- **Docker Compose** (Docker Desktop ile birlikte gelir)
- **Git** (projeyi indirmek için)

## 🚀 Hızlı Kurulum

### 1. Docker Desktop Kurulumu

#### Windows/Mac:
1. [Docker Desktop'ı indirin](https://www.docker.com/products/docker-desktop/)
2. Kurulumu tamamlayın
3. Docker Desktop'ı başlatın

#### Linux (Ubuntu):
```bash
# Docker Engine kurulumu
sudo apt update
sudo apt install docker.io docker-compose
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
# Bilgisayarı yeniden başlatın
```

### 2. Projeyi İndirin
```bash
git clone <repository-url>
cd EXFINREST/backend
```

### 3. Tek Komutla Kurulum

#### Windows:
```bash
quick-start.bat
```

#### Linux/Mac:
```bash
chmod +x start.sh
./start.sh
```

## 🔧 Manuel Kurulum

### 1. Servisleri Başlatın
```bash
# Tüm servisleri başlat
docker-compose up -d

# Durumu kontrol et
docker-compose ps

# Logları görüntüle
docker-compose logs
```

### 2. Servislerin Hazır Olmasını Bekleyin
```bash
# Tüm servislerin hazır olduğunu kontrol et
docker-compose ps
```

## 🌐 Erişim Adresleri

Kurulum tamamlandıktan sonra şu adreslere erişebilirsiniz:

| Servis | URL | Açıklama |
|--------|-----|----------|
| **Hasura Console** | http://localhost:8080 | GraphQL API yönetimi |
| **API Gateway** | http://localhost:3000 | REST API endpoint'leri |
| **MinIO Console** | http://localhost:9001 | Dosya depolama yönetimi |
| **PostgreSQL** | localhost:5432 | Veritabanı |

## 📱 Flutter Uygulaması Yapılandırması

Flutter uygulamanızda API adresini güncelleyin:

```dart
// lib/core/constants/app_constants.dart
class AppConstants {
  // Docker ile çalışan servisler için
  static const String graphqlApiEndpoint = 'http://localhost:8080/v1/graphql';
  static const String apiBaseUrl = 'http://localhost:3000';
  static const String hasuraAdminSecret = 'exfin_admin_secret_2024';
}
```

## 🛠️ Yönetim Komutları

### Servisleri Yönetme
```bash
# Servisleri başlat
docker-compose up -d

# Servisleri durdur
docker-compose down

# Servisleri yeniden başlat
docker-compose restart

# Durumu kontrol et
docker-compose ps

# Logları görüntüle
docker-compose logs

# Belirli servisin loglarını görüntüle
docker-compose logs hasura
docker-compose logs api-gateway
```

### Veritabanı Yönetimi
```bash
# PostgreSQL'e bağlan
docker-compose exec postgres psql -U exfin_user -d exfin_rest

# Veritabanı yedekle
docker-compose exec postgres pg_dump -U exfin_user exfin_rest > backup.sql

# Veritabanı geri yükle
docker-compose exec -T postgres psql -U exfin_user -d exfin_rest < backup.sql
```

### Dosya Depolama Yönetimi
```bash
# MinIO'ya bağlan
docker-compose exec minio mc alias set myminio http://localhost:9000 exfin_minio_access exfin_minio_secret_2024

# Bucket listesi
docker-compose exec minio mc ls myminio

# Dosya yükle
docker-compose exec minio mc cp dosya.jpg myminio/exfin-rest-files/
```

## 🔍 Sorun Giderme

### Servisler Başlamıyor
```bash
# Logları kontrol et
docker-compose logs

# Servisleri yeniden başlat
docker-compose down
docker-compose up -d

# Docker'ı yeniden başlat
# Windows: Docker Desktop'ı restart edin
# Linux: sudo systemctl restart docker
```

### Port Çakışması
Eğer portlar kullanımdaysa:
```bash
# Hangi servislerin portları kullandığını kontrol et
netstat -an | findstr :8080
netstat -an | findstr :3000
netstat -an | findstr :9000

# Çakışan servisleri durdurun veya portları değiştirin
```

### Disk Alanı
```bash
# Docker disk kullanımını kontrol et
docker system df

# Kullanılmayan dosyaları temizle
docker system prune -a
```

## 📊 Monitoring

### Servis Durumu
```bash
# Tüm servislerin durumunu kontrol et
docker-compose ps

# Sağlık kontrolü
docker-compose exec hasura curl -f http://localhost:8080/healthz
docker-compose exec api-gateway curl -f http://localhost:3000/health
```

### Performans İzleme
```bash
# Container kaynak kullanımı
docker stats

# Belirli container'ın detayları
docker-compose exec postgres top
```

## 🔒 Güvenlik

### Environment Değişkenleri
```bash
# Hassas bilgileri değiştirin
# docker-compose.yml dosyasında:
# - JWT_SECRET
# - HASURA_ADMIN_SECRET
# - POSTGRES_PASSWORD
# - MINIO_ROOT_PASSWORD
```

### Firewall Ayarları
```bash
# Windows
netsh advfirewall firewall add rule name="EXFIN Docker" dir=in action=allow protocol=TCP localport=8080,3000,9000,9001

# Linux
sudo ufw allow 8080/tcp
sudo ufw allow 3000/tcp
sudo ufw allow 9000/tcp
sudo ufw allow 9001/tcp
```

## 📈 Production Kurulumu

### Environment Dosyaları
```bash
# Production için environment dosyaları oluşturun
cp .env.example .env.production

# Hassas bilgileri güncelleyin
nano .env.production
```

### SSL Sertifikası
```bash
# Nginx reverse proxy ile SSL
# docker-compose.prod.yml dosyası oluşturun
```

## 🆘 Yardım

### Yaygın Sorunlar

1. **Docker Desktop çalışmıyor**
   - Windows: Hyper-V'yi etkinleştirin
   - Mac: Docker Desktop'ı yeniden başlatın

2. **Port çakışması**
   - `docker-compose down` ile durdurun
   - Çakışan servisleri kapatın
   - `docker-compose up -d` ile yeniden başlatın

3. **Disk alanı yetersiz**
   - `docker system prune -a` ile temizleyin
   - Eski image'ları silin

4. **Servisler başlamıyor**
   - Logları kontrol edin: `docker-compose logs`
   - Bağımlılıkları kontrol edin
   - Docker'ı yeniden başlatın

### Destek
- GitHub Issues: [Repository Issues](https://github.com/your-repo/issues)
- Email: support@exfin.com
- Discord: [EXFIN Community](https://discord.gg/exfin)

---

**🎉 Kurulum tamamlandı!** Artık EXFIN REST backend servisleriniz Docker ile çalışıyor. 