#!/bin/bash

# EXFIN REST - Uzak Sunucu Deployment Scripti
# Kullanım: ./deploy.sh

set -e  # Hata durumunda scripti durdur

echo "🚀 EXFIN REST - Uzak Sunucu Deployment"
echo "========================================"
echo

# 1. Environment dosyasını kontrol et
if [ ! -f .env.production ]; then
    echo "❌ .env.production dosyası bulunamadı!"
    echo "📝 env.production.example dosyasını .env.production olarak kopyalayın"
    echo "🔐 Şifreleri güvenli bir şekilde değiştirin"
    exit 1
fi

# 2. Environment değişkenlerini yükle
source .env.production

# 3. Docker'ın çalıştığını kontrol et
if ! docker --version > /dev/null 2>&1; then
    echo "❌ Docker kurulu değil!"
    echo "📥 Docker kurulumu için: https://docs.docker.com/engine/install/"
    exit 1
fi

# 4. Eski container'ları temizle
echo "🧹 Eski container'lar temizleniyor..."
docker-compose -f docker-compose.prod.yml down --remove-orphans

# 5. Image'ları yeniden oluştur
echo "🔨 Docker image'ları oluşturuluyor..."
docker-compose -f docker-compose.prod.yml build --no-cache

# 6. Servisleri başlat
echo "🚀 Servisler başlatılıyor..."
docker-compose -f docker-compose.prod.yml up -d

# 7. Servislerin hazır olmasını bekle
echo "⏳ Servislerin hazır olması bekleniyor..."
sleep 30

# 8. Durum kontrolü
echo "📊 Servis durumu kontrol ediliyor..."
docker-compose -f docker-compose.prod.yml ps

# 9. Health check
echo "🏥 Health check yapılıyor..."

# PostgreSQL kontrol
if docker-compose -f docker-compose.prod.yml exec postgres pg_isready -U exfin_user -d exfin_rest > /dev/null 2>&1; then
    echo "✅ PostgreSQL: Çalışıyor"
else
    echo "❌ PostgreSQL: Sorun var"
fi

# Hasura kontrol
if curl -f http://localhost:8080/healthz > /dev/null 2>&1; then
    echo "✅ Hasura: Çalışıyor"
else
    echo "❌ Hasura: Sorun var"
fi

# API Gateway kontrol
if curl -f http://localhost:3000/health > /dev/null 2>&1; then
    echo "✅ API Gateway: Çalışıyor"
else
    echo "❌ API Gateway: Sorun var"
fi

# MinIO kontrol
if curl -f http://localhost:9000/minio/health/live > /dev/null 2>&1; then
    echo "✅ MinIO: Çalışıyor"
else
    echo "❌ MinIO: Sorun var"
fi

echo
echo "🎉 Deployment tamamlandı!"
echo "========================"
echo
echo "🌐 Erişim adresleri:"
echo "   • Hasura Console: http://$SERVER_IP:8080"
echo "   • API Gateway: http://$SERVER_IP:3000"
echo "   • MinIO Console: http://$SERVER_IP:9001"
echo
echo "📱 Flutter uygulamasında API adresini güncelleyin:"
echo "   http://$SERVER_IP:8080"
echo
echo "📋 Yönetim komutları:"
echo "   • Durum: docker-compose -f docker-compose.prod.yml ps"
echo "   • Loglar: docker-compose -f docker-compose.prod.yml logs"
echo "   • Durdur: docker-compose -f docker-compose.prod.yml down"
echo "   • Yeniden başlat: ./deploy.sh"
echo 