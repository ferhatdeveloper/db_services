FROM node:18-alpine

WORKDIR /app

# Package.json ve package-lock.json kopyala
COPY package*.json ./

# Bağımlılıkları yükle
RUN npm ci --only=production

# Uygulama kodunu kopyala
COPY . .

# Port aç
EXPOSE 3000

# Uygulamayı başlat
CMD ["npm", "start"] 