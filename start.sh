#!/bin/bash

echo "EXFIN REST Backend Baslatiliyor..."
echo

# Docker Compose ile tüm servisleri başlat
docker-compose up -d

echo
echo "Servisler baslatildi!"
echo
echo "Erisim Adresleri:"
echo "- Hasura Console: http://localhost:8080"
echo "- API Gateway: http://localhost:3000"
echo "- MinIO Console: http://localhost:9001"
echo "- PostgreSQL: localhost:5432"
echo
echo "Durum kontrol etmek icin: docker-compose ps"
echo "Loglari gormek icin: docker-compose logs"
echo "Durdurmak icin: docker-compose down"
echo 