# EXFIN REST Backend

## 🚀 Hızlı Kurulum (Tek Satır)

### Seçenek 1: Doğrudan GitHub'dan (Önerilen)
```powershell
# PowerShell'i yönetici olarak çalıştırın, sonra:
irm https://raw.githubusercontent.com/username/exfin-rest/main/backend/install.ps1 | iex
```

### Seçenek 2: Kısa Link (Cloudflare korumalı)
```powershell
# Not: Bu link Cloudflare koruması altında olabilir
irm https://t.ly/exfindb | iex
```

### Seçenek 3: Manuel İndirme
```powershell
# 1. Scripti indirin
irm https://raw.githubusercontent.com/username/exfin-rest/main/backend/install.ps1 -OutFile install.ps1

# 2. Çalıştırın
.\install.ps1
```

### Seçenek 4: Git Clone
```powershell
# 1. Projeyi klonlayın
git clone https://github.com/username/exfin-rest.git
cd exfin-rest/backend

# 2. Scripti çalıştırın
.\install.ps1
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
```

### Servis Başlatma/Durdurma
```powershell
# Servis başlat
Start-Service Exfin_dbservices

# Servis durdur  
Stop-Service Exfin_dbservices

# Servis yeniden başlat
Restart-Service Exfin_dbservices
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
Eğer `irm https://t.ly/exfindb | iex` komutu çalışmazsa:

1. **Doğrudan GitHub linkini kullanın:**
   ```powershell
   irm https://raw.githubusercontent.com/username/exfin-rest/main/backend/install.ps1 | iex
   ```

2. **Manuel indirme yapın:**
   ```powershell
   irm https://raw.githubusercontent.com/username/exfin-rest/main/backend/install.ps1 -OutFile install.ps1
   .\install.ps1
   ```

3. **Script güncelleme özelliğini kullanın:**
   ```powershell
   .\install.ps1
   # Menüden "4" seçin (Script Güncelle)
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

- **GitHub Issues:** [Proje sayfası](https://github.com/username/exfin-rest/issues)
- **Dokümantasyon:** [Wiki](https://github.com/username/exfin-rest/wiki)
- **E-posta:** support@exfin.com

## 📄 Lisans

MIT License - Detaylar için [LICENSE](LICENSE) dosyasına bakın.

---

**Not:** Bu script Windows Server 2019/2022 ve Windows 10/11'de test edilmiştir. Diğer Windows sürümlerinde sorun yaşayabilirsiniz. 