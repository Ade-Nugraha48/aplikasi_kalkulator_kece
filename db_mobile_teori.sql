-- 1. Tabel Users
-- Mengakomodasi: FR-U-01, FR-U-02, FR-T2-06
CREATE TABLE
    users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(50) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL, -- Hash password
        email VARCHAR(100) NOT NULL UNIQUE,
        birth_date DATE NOT NULL,
        created_at TIMESTAMP
        WITH
            TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP
        WITH
            TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );

-- 2. Tabel Members (Daftar Anggota Kelompok)
-- Mengakomodasi: FR-U-03
CREATE TABLE
    members (
        id SERIAL PRIMARY KEY,
        nim VARCHAR(20) NOT NULL UNIQUE,
        name VARCHAR(100) NOT NULL,
        created_at TIMESTAMP
        WITH
            TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );

-- 3. Enum Tipe Catatan Keuangan
CREATE TYPE record_type AS ENUM ('pemasukan', 'pengeluaran');

-- 4. Tabel Categories (Kategori Keuangan Dinamis)
-- Mengakomodasi pembuatan kategori sesuai kebutuhan user
CREATE TABLE
    categories (
        id SERIAL PRIMARY KEY,
        user_id INT NOT NULL, -- Kategori dibuat oleh user tertentu
        name VARCHAR(50) NOT NULL, -- Contoh: 'Makanan', 'Laundry', 'Kiriman Ortu', 'Kebutuhan Kamar'
        type RECORD_TYPE NOT NULL, -- Menentukan kategori ini untuk pemasukan atau pengeluaran
        created_at TIMESTAMP
        WITH
            TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            CONSTRAINT fk_category_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
    );

-- 5. Tabel Financial Records (Catatan Keuangan KosKu)
-- Mengakomodasi: FR-T2-01 (Dashboard), FR-T2-02 (Input), FR-T2-03 (Hapus), FR-T2-04 (Update)
CREATE TABLE
    financial_records (
        id SERIAL PRIMARY KEY,
        user_id INT NOT NULL,
        category_id INT, -- Menghubungkan ke tabel kategori dinamis
        type RECORD_TYPE NOT NULL, -- 'pemasukan' atau 'pengeluaran'
        amount NUMERIC(15, 2) NOT NULL CHECK (amount > 0), -- Jumlah nominal
        title VARCHAR(100) NOT NULL, -- Catatan singkat, misal: 'Beli Nasi Goreng', 'Kiriman Bulan Ini'
        description TEXT, -- Catatan tambahan/detail (opsional)
        record_date DATE NOT NULL DEFAULT CURRENT_DATE, -- Tanggal alokasi uang
        created_at TIMESTAMP
        WITH
            TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP
        WITH
            TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            -- Foreign Keys
            CONSTRAINT fk_record_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
            CONSTRAINT fk_record_category FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL -- Jika kategori dihapus, catatan tidak ikut hilang (category_id jadi NULL)
    );

-- Indexing untuk kecepatan pencarian/query dashboard berdasarkan user dan tanggal
CREATE INDEX idx_financial_records_user_date ON financial_records (user_id, record_date DESC);