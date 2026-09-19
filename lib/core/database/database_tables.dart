/// ============================================================================
/// FILE: lib/core/database/database_tables.dart
/// FUNGSI: Menyimpan DDL Schema SQL & Nama Tabel PostgreSQL serta Seed Data untuk Tugas 2.
/// MANAJEMEN HANDLES: Database Schema Definition & Seeding Initialization
/// LOKASI LOGIC: Tempat penulisan skrip CREATE TABLE, Enum, & Query inisialisasi DDL/DML.
/// ============================================================================

class DatabaseTables {
  // Nama Tabel
  static const String tableUsers = 'users';
  static const String tableMembers = 'members';
  static const String tableCategories = 'categories';
  static const String tableFinancialRecords = 'financial_records';

  // Enum Type
  static const String enumRecordType = 'record_type';

  /// DDL SQL Schema untuk inisialisasi database PostgreSQL jika belum ada
  static const String createSchemaSql = '''
    -- 1. Create Enum record_type
    DO \$\$ BEGIN
      CREATE TYPE record_type AS ENUM ('pemasukan', 'pengeluaran');
    EXCEPTION
      WHEN duplicate_object THEN null;
    END \$\$;

    -- 2. Table users
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      username VARCHAR(50) UNIQUE NOT NULL,
      password VARCHAR(255) NOT NULL,
      email VARCHAR(100) UNIQUE NOT NULL,
      birth_date DATE NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    -- 3. Table members (Tugas 1 Data Kelompok -> DB)
    CREATE TABLE IF NOT EXISTS members (
      id SERIAL PRIMARY KEY,
      nim VARCHAR(20) UNIQUE NOT NULL,
      name VARCHAR(100) NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    -- 4. Table categories
    CREATE TABLE IF NOT EXISTS categories (
      id SERIAL PRIMARY KEY,
      user_id INT REFERENCES users(id) ON DELETE CASCADE,
      name VARCHAR(50) NOT NULL,
      type record_type NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    -- 5. Table financial_records (KosKu)
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
  ''';

  /// Seed SQL Script untuk memasukkan data tes awal jika tabel masih kosong
  static const String seedInitialDataSql = '''
    -- Seed User Admin Default (password: password123 -> SHA-256)
    INSERT INTO users (username, password, email, birth_date)
    VALUES (
      'admin',
      'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f',
      'admin@gmail.com',
      '2002-05-15'
    ) ON CONFLICT (username) DO NOTHING;

    -- Seed Data Anggota Kelompok
    INSERT INTO members (nim, name)
    VALUES
      ('123220001', 'Ade Nugraha'),
      ('123220002', 'Anggota Kelompok 2'),
      ('123220003', 'Anggota Kelompok 3')
    ON CONFLICT (nim) DO NOTHING;
  ''';
}
