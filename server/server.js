const express = require('express');
const cors = require('cors');
const crypto = require('crypto');
const db = require('./db');

const app = express();
const PORT = process.env.PORT || 3000;

// Enable CORS untuk Flutter Web Chrome Security
app.use(cors({ origin: '*' }));
app.use(express.json());

// Helper Hash Password SHA-256 (Persis dengan hashing Flutter)
function hashPassword(password) {
  return crypto.createHash('sha256').update(password).digest('hex');
}

// 1. Health Check Endpoint
app.get('/api/health', async (req, res) => {
  try {
    const result = await db.query('SELECT NOW()');
    res.json({
      status: 'ok',
      dbConnected: true,
      time: result.rows[0].now,
      message: 'Backend REST API Server PostgreSQL Berjalan Normal!',
    });
  } catch (err) {
    res.status(500).json({
      status: 'error',
      dbConnected: false,
      message: err.message,
    });
  }
});

// 2. FR-U-02: Registrasi User Baru ke PostgreSQL
app.post('/api/auth/register', async (req, res) => {
  try {
    const { username, password, email, birth_date } = req.body;

    if (!username || !password || !email || !birth_date) {
      return res.status(400).json({
        success: false,
        message: 'Seluruh field (username, password, email, birth_date) wajib diisi.',
      });
    }

    const trimmedUsername = username.trim();
    const trimmedEmail = email.trim();

    // Cek duplikasi username atau email
    const existing = await db.query(
      'SELECT id FROM users WHERE username = $1 OR email = $2 LIMIT 1',
      [trimmedUsername, trimmedEmail]
    );

    if (existing.rows.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Username atau Email sudah terdaftar di database PostgreSQL!',
      });
    }

    // Hash password dengan SHA-256
    const hashedPassword = hashPassword(password);

    // Insert user baru ke PostgreSQL
    const inserted = await db.query(
      `INSERT INTO users (username, password, email, birth_date)
       VALUES ($1, $2, $3, $4::date)
       RETURNING id, username, email, birth_date, created_at`,
      [trimmedUsername, hashedPassword, trimmedEmail, birth_date]
    );

    const user = inserted.rows[0];
    res.status(201).json({
      success: true,
      message: 'Registrasi akun berhasil!',
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        birth_date: user.birth_date,
        created_at: user.created_at,
      },
    });
  } catch (err) {
    console.error('Register Error:', err);
    res.status(500).json({
      success: false,
      message: 'Server error saat registrasi: ' + err.message,
    });
  }
});

// 3. FR-U-01: Login User dari PostgreSQL
app.post('/api/auth/login', async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({
        success: false,
        message: 'Username dan Password wajib diisi.',
      });
    }

    const trimmedUsername = username.trim();
    const hashedPassword = hashPassword(password);

    const result = await db.query(
      'SELECT id, username, password, email, birth_date, created_at FROM users WHERE username = $1 AND password = $2 LIMIT 1',
      [trimmedUsername, hashedPassword]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'Username atau Password salah!',
      });
    }

    const user = result.rows[0];
    res.json({
      success: true,
      message: 'Login berhasil!',
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        birth_date: user.birth_date,
        created_at: user.created_at,
      },
    });
  } catch (err) {
    console.error('Login Error:', err);
    res.status(500).json({
      success: false,
      message: 'Server error saat login: ' + err.message,
    });
  }
});

// 4. FR-U-03: Get Anggota Kelompok dari PostgreSQL
app.get('/api/members', async (req, res) => {
  try {
    const result = await db.query('SELECT id, nim, name, created_at FROM members ORDER BY id ASC');
    res.json({
      success: true,
      members: result.rows,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: err.message,
    });
  }
});

// Start Server & Initialize Database Connection
app.listen(PORT, async () => {
  console.log(`=======================================================`);
  console.log(`🚀 [BACKEND REST API SERVER] Berjalan pada http://localhost:${PORT}`);
  console.log(`=======================================================`);
  await db.initDatabase();
});
