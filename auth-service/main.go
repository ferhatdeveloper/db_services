package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/gorilla/mux"
	"golang.org/x/crypto/bcrypt"
)

type User struct {
	ID       string `json:"id"`
	Username string `json:"username"`
	Email    string `json:"email"`
	Role     string `json:"role"`
	Password string `json:"password,omitempty"`
}

type LoginRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

type LoginResponse struct {
	Token     string `json:"token"`
	User      User   `json:"user"`
	ExpiresAt int64  `json:"expires_at"`
}

type Claims struct {
	UserID   string `json:"user_id"`
	Username string `json:"username"`
	Role     string `json:"role"`
	jwt.RegisteredClaims
}

var jwtSecret = []byte("exfin_jwt_secret_2024")

// Örnek kullanıcı veritabanı (gerçek uygulamada PostgreSQL kullanılacak)
var users = map[string]User{
	"admin": {
		ID:       "1",
		Username: "admin",
		Email:    "admin@exfinrest.com",
		Role:     "admin",
		Password: "$2a$10$hashed_password_here", // bcrypt ile hash'lenmiş
	},
	"waiter1": {
		ID:       "2",
		Username: "waiter1",
		Email:    "waiter1@exfinrest.com",
		Role:     "waiter",
		Password: "$2a$10$hashed_password_here",
	},
	"kitchen1": {
		ID:       "3",
		Username: "kitchen1",
		Email:    "kitchen1@exfinrest.com",
		Role:     "kitchen",
		Password: "$2a$10$hashed_password_here",
	},
	"cashier1": {
		ID:       "4",
		Username: "cashier1",
		Email:    "cashier1@exfinrest.com",
		Role:     "cashier",
		Password: "$2a$10$hashed_password_here",
	},
}

func generateToken(user User) (string, int64, error) {
	expirationTime := time.Now().Add(24 * time.Hour)
	expiresAt := expirationTime.Unix()

	claims := &Claims{
		UserID:   user.ID,
		Username: user.Username,
		Role:     user.Role,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expirationTime),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Issuer:    "exfin-rest-auth",
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString(jwtSecret)
	if err != nil {
		return "", 0, err
	}

	return tokenString, expiresAt, nil
}

func verifyPassword(hashedPassword, password string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hashedPassword), []byte(password))
	return err == nil
}

func loginHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var loginReq LoginRequest
	if err := json.NewDecoder(r.Body).Decode(&loginReq); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Kullanıcıyı bul
	user, exists := users[loginReq.Username]
	if !exists {
		http.Error(w, "Invalid credentials", http.StatusUnauthorized)
		return
	}

	// Şifreyi doğrula
	if !verifyPassword(user.Password, loginReq.Password) {
		http.Error(w, "Invalid credentials", http.StatusUnauthorized)
		return
	}

	// Token oluştur
	token, expiresAt, err := generateToken(user)
	if err != nil {
		http.Error(w, "Failed to generate token", http.StatusInternalServerError)
		return
	}

	// Response oluştur
	response := LoginResponse{
		Token:     token,
		User:      user,
		ExpiresAt: expiresAt,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func verifyTokenHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		Token string `json:"token"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Token'ı doğrula
	token, err := jwt.ParseWithClaims(req.Token, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		return jwtSecret, nil
	})

	if err != nil {
		http.Error(w, "Invalid token", http.StatusUnauthorized)
		return
	}

	if claims, ok := token.Claims.(*Claims); ok && token.Valid {
		// Kullanıcı bilgilerini döndür
		user, exists := users[claims.Username]
		if !exists {
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}

		response := struct {
			Valid bool `json:"valid"`
			User  User `json:"user"`
		}{
			Valid: true,
			User:  user,
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(response)
	} else {
		http.Error(w, "Invalid token", http.StatusUnauthorized)
	}
}

func refreshTokenHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req struct {
		Token string `json:"token"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Token'ı doğrula
	token, err := jwt.ParseWithClaims(req.Token, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		return jwtSecret, nil
	})

	if err != nil {
		http.Error(w, "Invalid token", http.StatusUnauthorized)
		return
	}

	if claims, ok := token.Claims.(*Claims); ok && token.Valid {
		// Kullanıcıyı bul
		user, exists := users[claims.Username]
		if !exists {
			http.Error(w, "User not found", http.StatusNotFound)
			return
		}

		// Yeni token oluştur
		newToken, expiresAt, err := generateToken(user)
		if err != nil {
			http.Error(w, "Failed to generate token", http.StatusInternalServerError)
			return
		}

		response := LoginResponse{
			Token:     newToken,
			User:      user,
			ExpiresAt: expiresAt,
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(response)
	} else {
		http.Error(w, "Invalid token", http.StatusUnauthorized)
	}
}

func healthCheckHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"status": "healthy",
		"service": "auth-service",
	})
}

func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8081"
	}

	r := mux.NewRouter()
	r.Use(corsMiddleware)

	// Routes
	r.HandleFunc("/login", loginHandler).Methods("POST")
	r.HandleFunc("/verify", verifyTokenHandler).Methods("POST")
	r.HandleFunc("/refresh", refreshTokenHandler).Methods("POST")
	r.HandleFunc("/health", healthCheckHandler).Methods("GET")

	fmt.Printf("Auth service starting on port %s\n", port)
	log.Fatal(http.ListenAndServe(":"+port, r))
} 