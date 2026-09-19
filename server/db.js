const { Pool } = require('pg');

// Konfigurasi Database PostgreSQL
const dbConfig = {
  host: process.env.PG_HOST || '127.0.0.1',
  port: parseInt(process.env.PG_PORT || '5432'),
  database: process.env.PG_DATABASE || 'db_mobile_teori',
  user: process.env.PG_USER || 'postgres',
  password: process.env.PG_PASSWORD || '12345678', // Sesuaikan jika password PostgreSQL Anda berbeda
};

const pool = new Pool(dbConfig);

// Test koneksi & Inisialisasi DDL Schema + Seed Data Awal
async function initDatabase() {
  let client;
  try {
    client = await pool.connect();
    console.log(`✅ [BACKEND DB] Terhubung ke PostgreSQL: ${dbConfig.host}:${dbConfig.port}/${dbConfig.database}`);

    // DDL Schema
    const createSchemaSql = `
      DO $$ BEGIN
        CREATE TYPE record_type AS ENUM ('pemasukan', 'pengeluaran');
      EXCEPTION
        WHEN duplicate_object THEN null;
      END $$;

      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        birth_date DATE NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS members (
        id SERIAL PRIMARY KEY,
        nim VARCHAR(20) UNIQUE NOT NULL,
        name VARCHAR(100) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS categories (
        id SERIAL PRIMARY KEY,
        user_id INT REFERENCES users(id) ON DELETE CASCADE,
        name VARCHAR(50) NOT NULL,
        type record_type NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS financial_records (
        id SERIAL PRIMARY KEY,
        user_id INT REFERENCES users(id) ON DELETE CASCADE,
        category_id INT REFERENCES categories(id) ON DELETE SET NULL,
        type record_type NOT NULL,
        amount NUMERIC(15, 2) NOT NULL,
        title VARCHAR(100) NOT NULL,
        description TEXT,
        record_date DATE NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `;

    await client.query(createSchemaSql);

    // Seed User Admin (password: password123 -> SHA-256)
    const seedAdminSql = `
      INSERT INTO users (username, password, email, birth_date)
      VALUES (
        'admin',
        'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f',
        'admin@gmail.com',
        '2002-05-15'
      ) ON CONFLICT (username) DO NOTHING;

      INSERT INTO members (nim, name)
      VALUES
        ('123220001', 'Ade Nugraha'),
        ('123220002', 'Anggota Kelompok 2'),
        ('123220003', 'Anggota Kelompok 3')
      ON CONFLICT (nim) DO NOTHING;
    `;

    await client.query(seedAdminSql);
    console.log('✅ [BACKEND DB] DDL Schema & Seed Data berhasil diperbarui!');
    return true;
  } catch (err) {
    console.error('❌ [BACKEND DB ERROR] Gagal terhubung ke PostgreSQL:', err.message);
    console.error('💡 TIP: Pastikan Service PostgreSQL berjalan di PC dan password pada db.js sudah sesuai!');
    return false;
  } finally {
    if (client) client.release();
  }
}

module.exports = {
  pool,
  initDatabase,
  query: (text, params) => pool.query(text, params),
};
