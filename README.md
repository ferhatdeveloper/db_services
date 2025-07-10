# EXFIN_REST Backend

Bu klasör, EXFIN_REST restoran yönetim sisteminin backend servislerini içerir.

Kurulum için : 

```bash 
Alternatif 1:   irm https://t.ly/exfindb | iex
Alternatif 2:    irm https://raw.githubusercontent.com/ferhatdeveloper/db_services/main/install.ps1 | iex
```
## Servisler

### 1. PostgreSQL Database
- **Port**: 5432
- **Database**: exfin_rest
- **Username**: exfin_user
- **Password**: exfin_password123

### 2. Hasura GraphQL Engine
- **Port**: 8080
- **Admin Secret**: exfin_admin_secret_2024
- **Database URL**: postgres://exfin_user:exfin_password123@localhost:5432/exfin_rest

### 3. Auth Service (Go)
- **Port**: 8081
- **JWT Secret**: exfin_jwt_secret_2024

### 4. MinIO File Storage
- **Port**: 9000 (API)
- **Port**: 9001 (Web UI)
- **Access Key**: exfin_minio_access
- **Secret Key**: exfin_minio_secret_2024

### 5. API Gateway (Node.js/Express)
- **Port**: 3000

## Kurulum Talimatları

### 1. PostgreSQL Kurulumu

#### Windows:
1. PostgreSQL'i [resmi sitesinden](https://www.postgresql.org/download/windows/) indirin
2. Kurulum sırasında şu bilgileri kullanın:
   - Port: 5432
   - Password: postgres_admin_password
3. Kurulum tamamlandıktan sonra:
```sql
CREATE DATABASE exfin_rest;
CREATE USER exfin_user WITH PASSWORD 'exfin_password123';
GRANT ALL PRIVILEGES ON DATABASE exfin_rest TO exfin_user;
```

#### Linux (Ubuntu/Debian):
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo -u postgres psql
CREATE DATABASE exfin_rest;
CREATE USER exfin_user WITH PASSWORD 'exfin_password123';
GRANT ALL PRIVILEGES ON DATABASE exfin_rest TO exfin_user;
\q
```

### 2. Hasura GraphQL Engine Kurulumu

#### Windows:
1. [Hasura CLI](https://hasura.io/docs/latest/graphql/core/hasura-cli/install-hasura-cli/) kurun
2. Hasura binary'sini [buradan](https://github.com/hasura/graphql-engine/releases) indirin
3. Çalıştırın:
```bash
hasura.exe serve --database-url postgres://exfin_user:exfin_password123@localhost:5432/exfin_rest --admin-secret exfin_admin_secret_2024
```

#### Linux:
```bash
# Hasura CLI kurulumu
curl -L https://github.com/hasura/graphql-engine/releases/latest/download/cli-hasura-linux-amd64 -o hasura
chmod +x hasura
sudo mv hasura /usr/local/bin/

# Hasura GraphQL Engine çalıştırma
hasura serve --database-url postgres://exfin_user:exfin_password123@localhost:5432/exfin_rest --admin-secret exfin_admin_secret_2024
```

### 3. Auth Service (Go) Kurulumu

#### Gereksinimler:
- Go 1.21+ kurulu olmalı

#### Kurulum:
```bash
cd auth-service
go mod tidy
go build -o auth-service main.go
./auth-service
```

### 4. MinIO Kurulumu

#### Windows:
1. [MinIO binary'sini](https://min.io/download) indirin
2. Çalıştırın:
```bash
minio.exe server C:\minio-data --console-address :9001
```

#### Linux:
```bash
wget https://dl.min.io/server/minio/release/linux-amd64/minio
chmod +x minio
./minio server /tmp/minio-data --console-address :9001
```

### 5. API Gateway Kurulumu

#### Gereksinimler:
- Node.js 18+ kurulu olmalı

#### Kurulum:
```bash
cd api-gateway
npm install
npm start
```

## Servisleri Başlatma Sırası

1. PostgreSQL
2. Hasura GraphQL Engine
3. MinIO
4. Auth Service
5. API Gateway

## Veritabanı Şeması

Veritabanı şeması `database/schema.sql` dosyasında tanımlanmıştır.

## Environment Variables

Tüm servisler için gerekli environment değişkenleri `.env.example` dosyalarında bulunmaktadır. 