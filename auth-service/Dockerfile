FROM golang:1.21-alpine

WORKDIR /app

# Go modüllerini kopyala
COPY go.mod go.sum ./

# Bağımlılıkları yükle
RUN go mod download

# Kaynak kodunu kopyala
COPY . .

# Uygulamayı derle
RUN go build -o auth-service main.go

# Port aç
EXPOSE 8081

# Uygulamayı başlat
CMD ["./auth-service"] 