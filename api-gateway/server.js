const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const axios = require('axios');
const jwt = require('jsonwebtoken');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(compression());
app.use(morgan('combined'));
app.use(cors({
  origin: ['http://localhost:3000', 'http://localhost:8080', 'http://localhost:9001'],
  credentials: true
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.'
});
app.use('/api/', limiter);

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Service URLs
const SERVICES = {
  AUTH: process.env.AUTH_SERVICE_URL || 'http://localhost:8081',
  HASURA: process.env.HASURA_URL || 'http://localhost:8080',
  MINIO: process.env.MINIO_URL || 'http://localhost:9000'
};

// JWT Secret
const JWT_SECRET = process.env.JWT_SECRET || 'exfin_jwt_secret_2024';

// Authentication middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid or expired token' });
    }
    req.user = user;
    next();
  });
};

// Role-based authorization middleware
const authorizeRole = (roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }

    next();
  };
};

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'api-gateway',
    timestamp: new Date().toISOString(),
    services: {
      auth: SERVICES.AUTH,
      hasura: SERVICES.HASURA,
      minio: SERVICES.MINIO
    }
  });
});

// Auth service proxy
app.post('/api/auth/login', async (req, res) => {
  try {
    const response = await axios.post(`${SERVICES.AUTH}/login`, req.body);
    res.json(response.data);
  } catch (error) {
    console.error('Auth service error:', error.response?.data || error.message);
    res.status(error.response?.status || 500).json({
      error: 'Authentication failed',
      details: error.response?.data || error.message
    });
  }
});

app.post('/api/auth/verify', async (req, res) => {
  try {
    const response = await axios.post(`${SERVICES.AUTH}/verify`, req.body);
    res.json(response.data);
  } catch (error) {
    console.error('Token verification error:', error.response?.data || error.message);
    res.status(error.response?.status || 500).json({
      error: 'Token verification failed',
      details: error.response?.data || error.message
    });
  }
});

app.post('/api/auth/refresh', async (req, res) => {
  try {
    const response = await axios.post(`${SERVICES.AUTH}/refresh`, req.body);
    res.json(response.data);
  } catch (error) {
    console.error('Token refresh error:', error.response?.data || error.message);
    res.status(error.response?.status || 500).json({
      error: 'Token refresh failed',
      details: error.response?.data || error.message
    });
  }
});

// Hasura GraphQL proxy
app.post('/api/graphql', authenticateToken, async (req, res) => {
  try {
    const response = await axios.post(`${SERVICES.HASURA}/v1/graphql`, req.body, {
      headers: {
        'Content-Type': 'application/json',
        'x-hasura-admin-secret': process.env.HASURA_ADMIN_SECRET || 'exfin_admin_secret_2024',
        'Authorization': req.headers.authorization
      }
    });
    res.json(response.data);
  } catch (error) {
    console.error('Hasura GraphQL error:', error.response?.data || error.message);
    res.status(error.response?.status || 500).json({
      error: 'GraphQL query failed',
      details: error.response?.data || error.message
    });
  }
});

// MinIO file upload proxy
app.post('/api/files/upload', authenticateToken, async (req, res) => {
  try {
    // Bu endpoint MinIO ile dosya yükleme işlemlerini yönetecek
    // Gerçek implementasyonda MinIO SDK kullanılacak
    res.json({
      success: true,
      message: 'File upload endpoint - MinIO integration pending'
    });
  } catch (error) {
    console.error('File upload error:', error.message);
    res.status(500).json({
      error: 'File upload failed',
      details: error.message
    });
  }
});

// Restaurant specific endpoints
app.get('/api/tables', authenticateToken, async (req, res) => {
  try {
    const response = await axios.post(`${SERVICES.HASURA}/v1/graphql`, {
      query: `
        query GetTables {
          tables {
            id
            table_number
            capacity
            status
            location
            is_active
          }
        }
      `
    }, {
      headers: {
        'Content-Type': 'application/json',
        'x-hasura-admin-secret': process.env.HASURA_ADMIN_SECRET || 'exfin_admin_secret_2024'
      }
    });
    
    res.json(response.data);
  } catch (error) {
    console.error('Tables query error:', error.response?.data || error.message);
    res.status(500).json({
      error: 'Failed to fetch tables',
      details: error.response?.data || error.message
    });
  }
});

app.get('/api/products', authenticateToken, async (req, res) => {
  try {
    const response = await axios.post(`${SERVICES.HASURA}/v1/graphql`, {
      query: `
        query GetProducts {
          products {
            id
            name
            description
            price
            image_url
            is_available
            category {
              id
              name
            }
          }
        }
      `
    }, {
      headers: {
        'Content-Type': 'application/json',
        'x-hasura-admin-secret': process.env.HASURA_ADMIN_SECRET || 'exfin_admin_secret_2024'
      }
    });
    
    res.json(response.data);
  } catch (error) {
    console.error('Products query error:', error.response?.data || error.message);
    res.status(500).json({
      error: 'Failed to fetch products',
      details: error.response?.data || error.message
    });
  }
});

// Admin only endpoints
app.get('/api/admin/reports', authenticateToken, authorizeRole(['admin']), async (req, res) => {
  try {
    // Admin raporları için endpoint
    res.json({
      success: true,
      message: 'Admin reports endpoint - implementation pending'
    });
  } catch (error) {
    console.error('Admin reports error:', error.message);
    res.status(500).json({
      error: 'Failed to generate reports',
      details: error.message
    });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Endpoint not found',
    path: req.originalUrl
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`API Gateway server running on port ${PORT}`);
  console.log('Service URLs:');
  console.log(`  Auth Service: ${SERVICES.AUTH}`);
  console.log(`  Hasura GraphQL: ${SERVICES.HASURA}`);
  console.log(`  MinIO: ${SERVICES.MINIO}`);
});

module.exports = app; 