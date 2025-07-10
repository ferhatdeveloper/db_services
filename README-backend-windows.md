# EXFIN REST - Windows Backend Kurulum ve Yönetim Rehberi (Docker'sız)

## Gereksinimler
- Windows Server 2019/2022 veya Windows 10/11
- Yönetici yetkili PowerShell
- İnternet bağlantısı

## Kurulum Adımları

### 1. Ana Scripti Çalıştırın
```powershell
cd C:\EXFIN\dbServis\backend
powershell -ExecutionPolicy Bypass -File install-backend-windows.ps1
```

### 2. Environment Dosyasını Düzenleyin
Kurulumdan sonra `env.backend.example` dosyasını `.env` olarak kopyalayın ve gerekirse şifreleri değiştirin.

### 3. Servisleri Yönetme
- Tüm servisler otomatik başlatılır.
- Loglar `C:\EXFIN\dbServis\logs` klasöründedir.
- Servisleri durdurmak için Görev Yöneticisi'nden ilgili işlemleri sonlandırabilirsiniz.

#### Servisleri Manuel Başlatma/Durdurma
```powershell
# Tüm servisleri başlat
powershell -ExecutionPolicy Bypass -File start-all-services.ps1

# Tüm servisleri durdur
powershell -ExecutionPolicy Bypass -File stop-all-services.ps1

# Logları görüntüle
powershell -ExecutionPolicy Bypass -File logs-view.ps1
```

### 4. Erişim Adresleri
- **Hasura Console**: http://localhost:8880
- **API Gateway**: http://localhost:3000
- **Auth Service**: http://localhost:8080
- **MinIO Console**: http://localhost:9001
- **PostgreSQL**: localhost:5432

### 5. Sorun Giderme
- Port çakışması varsa başka bir uygulama aynı portu kullanıyor olabilir.
- Log dosyalarını kontrol edin: `C:\EXFIN\dbServis\logs`
- Servisler başlamazsa PowerShell'i yönetici olarak çalıştırdığınızdan emin olun.

### 6. Servisleri Manuel Başlatma
Her servisin exe veya komut dosyasını doğrudan çalıştırabilirsiniz:
- Hasura: `hasura.exe serve ...`
- MinIO: `minio.exe server ...`
- Auth Service: `auth-service.exe`
- API Gateway: `node server.js`

### 7. Kaldırma
- Programları ve klasörleri silerek kaldırabilirsiniz.
- PostgreSQL'i Denetim Masası > Programlar'dan kaldırabilirsiniz.

---

**Not:** Tüm servisler arka planda başlatılır ve loglanır. Gelişmiş yönetim için ek scriptler hazırlanmıştır. Ayrıntılar yukarıda! 🚀 