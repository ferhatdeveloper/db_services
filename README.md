# EXFIN REST Backend

## 🚀 Hızlı Kurulum (Tek Satır)

### Seçenek 1: Doğrudan GitHub'dan (Önerilen)
```powershell
# PowerShell'i yönetici olarak çalıştırın, sonra:
irm https://raw.githubusercontent.com/ferhatdeveloper/db_services/main/install.ps1 | iex
```

### Seçenek 2: Manuel İndirme
```powershell
# 1. Scripti indirin
irm https://raw.githubusercontent.com/ferhatdeveloper/db_services/main/install.ps1 -OutFile install.ps1

# 2. Çalıştırın
.\install.ps1
```

### Seçenek 3: Git Clone
```powershell
# 1. Projeyi klonlayın
git clone https://github.com/ferhatdeveloper/db_services.git
cd db_services

# 2. Scripti çalıştırın
.\install.ps1
```

### Seçenek 4: Quick Start (Batch)
```powershell
# Batch dosyası ile hızlı başlatma
irm https://raw.githubusercontent.com/ferhatdeveloper/db_services/main/quick-start.bat -OutFile quick-start.bat
.\quick-start.bat
```

### Seçenek 5: Deploy Script
```powershell
# Deploy scripti ile kurulum
irm https://raw.githubusercontent.com/ferhatdeveloper/db_services/main/deploy-windows.ps1 | iex
```

## 📋 Manuel Kurulum

### Gereksinimler
- Windows Server 2019/2022 veya Windows 10/11
- PowerShell 5.1+
- Yönetici hakları
- İnternet bağlantısı

### Kurulum Adımları

1. **PowerShell'i yönetici olarak açın**
2. **Kurulum dizinine gidin:**
   ```powershell
   cd C:\EXFIN\dbServis
   ```

3. **Scripti çalıştırın:**
   ```powershell
   .\install.ps1
   ```

4. **Menüden "1" seçin (Kurulum)**

### Kurulum İçeriği

Script otomatik olarak şunları yapar:

- ✅ **NSSM** (Windows servis yöneticisi) indirir
- ✅ **Hasura CLI** (GraphQL engine) indirir  
- ✅ **MinIO Server** (Object storage) indirir
- ✅ **PostgreSQL** (Veritabanı) portable olarak indirir
- ✅ **Config dosyaları** oluşturur
- ✅ **Windows servisi** (Exfin_dbservices) oluşturur
- ✅ **Tüm servisleri** otomatik başlatır

## 🌐 Erişim Adresleri

Kurulum tamamlandıktan sonra:

| Servis | URL | Açıklama |
|--------|-----|----------|
| **Hasura Console** | http://localhost:8880 | GraphQL API yönetimi |
| **MinIO Console** | http://localhost:9001 | Dosya depolama yönetimi |
| **API Gateway** | http://localhost:3000 | REST API gateway |
| **PostgreSQL** | localhost:5432 | Veritabanı |

## 🔧 Yönetim

### Servis Kontrolü
```powershell
# Servis durumunu kontrol et
.\install.ps1
# Menüden "3" seçin

# Veya doğrudan:
Get-Service Exfin_dbservices

# Özel kontrol scripti
irm https://raw.githubusercontent.com/ferhatdeveloper/db_services/main/check-status-windows.ps1 | iex
```

### Servis Başlatma/Durdurma
```powershell
# Servis başlat
Start-Service Exfin_dbservices

# Servis durdur  
Stop-Service Exfin_dbservices

# Servis yeniden başlat
Restart-Service Exfin_dbservices

# Özel başlatma scripti
irm https://raw.githubusercontent.com/ferhatdeveloper/db_services/main/start-all-services.ps1 | iex

# Özel durdurma scripti
irm https://raw.githubusercontent.com/ferhatdeveloper/db_services/main/stop-all-services.ps1 | iex
```

### Log Görüntüleme
```powershell
# Log görüntüleme scripti
irm https://raw.githubusercontent.com/ferhatdeveloper/db_services/main/logs-view.ps1 | iex
```

### Windows Servis Yöneticisi
```powershell
# Servis yöneticisini aç
services.msc
# "Exfin_dbservices" servisini bulun
```

## 📁 Dizin Yapısı

```
C:\EXFIN\dbServis\
├── bin\                    # Binary dosyalar
│   ├── hasura.exe         # Hasura CLI
│   ├── minio.exe          # MinIO Server
│   └── postgresql\        # PostgreSQL portable
├── config\                 # Konfigürasyon dosyaları
│   └── hasura-config.yaml
├── data\                   # Veri dosyaları
│   └── minio\             # MinIO verileri
├── logs\                   # Log dosyaları
└── run-all-backend.ps1    # Servis başlatma scripti
```

## 🗑️ Kaldırma

```powershell
# Scripti çalıştırın
.\install.ps1
# Menüden "2" seçin (Kaldır)
```

## 🔍 Sorun Giderme

### Kısa Link Sorunu
**Not:** `https://t.ly/exfindb` linki Cloudflare koruması altında olduğu için PowerShell'de çalışmaz. Bunun yerine doğrudan GitHub linklerini kullanın:

1. **Doğrudan GitHub linkini kullanın:**
   ```powershell
   irm https://raw.githubusercontent.com/ferhatdeveloper/db_services/main/install.ps1 | iex
   ```

2. **Manuel indirme yapın:**
   ```powershell
   irm https://raw.githubusercontent.com/ferhatdeveloper/db_services/main/install.ps1 -OutFile install.ps1
   .\install.ps1
   ```

3. **Script güncelleme özelliğini kullanın:**
   ```powershell
   .\install.ps1
   # Menüden "4" seçin (Script Güncelle)
   ```

4. **Alternatif scriptler:**
   ```powershell
   # Deploy scripti
   irm https://raw.githubusercontent.com/ferhatdeveloper/db_services/main/deploy-windows.ps1 | iex
   
   # Manuel kurulum
   irm https://raw.githubusercontent.com/ferhatdeveloper/db_services/main/install-windows.ps1 | iex
   ```

### Servis Başlamıyor
1. **Logları kontrol edin:**
   ```powershell
   Get-Content C:\EXFIN\dbServis\logs\*.log
   ```

2. **Portları kontrol edin:**
   ```powershell
   netstat -ano | findstr ":8880"
   netstat -ano | findstr ":9001"
   ```

3. **Process'leri kontrol edin:**
   ```powershell
   Get-Process | Where-Object {$_.ProcessName -like "*hasura*"}
   Get-Process | Where-Object {$_.ProcessName -like "*minio*"}
   ```

### Yaygın Hatalar

| Hata | Çözüm |
|------|-------|
| **"Access Denied"** | PowerShell'i yönetici olarak çalıştırın |
| **"Port already in use"** | Eski servisleri durdurun: `Stop-Service Exfin_dbservices` |
| **"Download failed"** | İnternet bağlantınızı kontrol edin |
| **"Service not found"** | Kurulumu tekrar çalıştırın |
| **"Cloudflare protection"** | Doğrudan GitHub linkini kullanın |

## 📞 Destek

- **GitHub Repository:** [ferhatdeveloper/db_services](https://github.com/ferhatdeveloper/db_services)
- **GitHub Issues:** [Proje sayfası](https://github.com/ferhatdeveloper/db_services/issues)
- **Dokümantasyon:** [Wiki](https://github.com/ferhatdeveloper/db_services/wiki)
- **E-posta:** support@exfin.com

## 📄 Lisans

MIT License - Detaylar için [LICENSE](LICENSE) dosyasına bakın.

---

**Not:** Bu script Windows Server 2019/2022 ve Windows 10/11'de test edilmiştir. Diğer Windows sürümlerinde sorun yaşayabilirsiniz.

**Kaynak:** [ferhatdeveloper/db_services](https://github.com/ferhatdeveloper/db_services.git) repository'sinden alınmıştır. 