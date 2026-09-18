require('dotenv').config();
const express = require('express');
const cors = require('cors');

const userRoutes = require('./routes/userRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors()); // Membolehkan aplikasi mobile (origin lain) memanggil API ini
app.use(express.json()); // Parsing body berbentuk JSON

// Base route / Welcome API
app.get('/', (req, res) => {
  res.json({
    status: 'success',
    message: 'Selamat Datang di Backend API Aplikasi Kalkulator Kece'
  });
});

// API Routes
app.use('/api/users', userRoutes);

// Handle 404
app.use((req, res) => {
  res.status(404).json({
    status: 'error',
    message: 'Endpoint tidak ditemukan'
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server Backend berjalan pada http://localhost:${PORT}`);
});
