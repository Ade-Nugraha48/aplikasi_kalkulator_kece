const pool = require('../config/db');

// @route   GET /api/users
// @desc    Get all users
exports.getAllUsers = async (req, res) => {
  try {
    const result = await pool.query('SELECT id, username, email, birth_date, created_at FROM users ORDER BY created_at DESC');
    res.status(200).json({
      status: 'success',
      message: 'Berhasil mengambil daftar pengguna',
      data: result.rows,
    });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
};

// @route   GET /api/users/:id
// @desc    Get user by ID
exports.getUserById = async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('SELECT id, username, email, birth_date, created_at FROM users WHERE id = $1', [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ status: 'error', message: 'Pengguna tidak ditemukan' });
    }
    
    res.status(200).json({
      status: 'success',
      message: 'Berhasil mengambil data pengguna',
      data: result.rows[0],
    });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
};

// @route   POST /api/users
// @desc    Create a new user
exports.createUser = async (req, res) => {
  try {
    const { username, password, email, birth_date } = req.body;
    
    // Asumsi: Validasi input dilakukan di sini (opsional untuk disesuaikan)
    if (!username || !password || !email || !birth_date) {
      return res.status(400).json({ status: 'error', message: 'Semua field (username, password, email, birth_date) wajib diisi' });
    }

    const query = `
      INSERT INTO users (username, password, email, birth_date) 
      VALUES ($1, $2, $3, $4) 
      RETURNING id, username, email, birth_date
    `;
    const values = [username, password, email, birth_date];
    
    const result = await pool.query(query, values);
    
    res.status(201).json({
      status: 'success',
      message: 'Pengguna berhasil didaftarkan',
      data: result.rows[0],
    });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
};

// @route   PUT /api/users/:id
// @desc    Update user
exports.updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const { username, email, birth_date } = req.body;

    const query = `
      UPDATE users 
      SET username = COALESCE($1, username), 
          email = COALESCE($2, email), 
          birth_date = COALESCE($3, birth_date),
          updated_at = CURRENT_TIMESTAMP
      WHERE id = $4
      RETURNING id, username, email, birth_date
    `;
    const values = [username, email, birth_date, id];
    
    const result = await pool.query(query, values);

    if (result.rows.length === 0) {
      return res.status(404).json({ status: 'error', message: 'Pengguna tidak ditemukan' });
    }

    res.status(200).json({
      status: 'success',
      message: 'Data pengguna berhasil diperbarui',
      data: result.rows[0],
    });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
};

// @route   DELETE /api/users/:id
// @desc    Delete user
exports.deleteUser = async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('DELETE FROM users WHERE id = $1 RETURNING id', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ status: 'error', message: 'Pengguna tidak ditemukan' });
    }

    res.status(200).json({
      status: 'success',
      message: 'Pengguna berhasil dihapus',
      data: { id: result.rows[0].id },
    });
  } catch (error) {
    res.status(500).json({ status: 'error', message: error.message });
  }
};
