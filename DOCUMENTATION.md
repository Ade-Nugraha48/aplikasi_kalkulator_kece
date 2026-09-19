# DOKUMENTASI PROYEK: APLIKASI KALKULATOR KECE & KOSKU

Laporan proyek ini merupakan dokumentasi komprehensif dari proses perancangan, pengembangan, serta implementasi akhir aplikasi mobile **Kalkulator Kece & KosKu**. Aplikasi ini dikembangkan untuk memenuhi berbagai kebutuhan utilitas harian dan komputasi mahasiswa, mencakup manajemen keuangan, konversi kalender lokal dan internasional, hingga alat matematika presisi tinggi.

---

## BAB 1: INISIASI & SETUP ENVIRONMENT

### 1.1 Prasyarat & Dependensi
Proyek ini dibangun menggunakan **Flutter** dan **Supabase** (Backend-as-a-Service) dengan dukungan library pihak ketiga yang mutakhir.
- **Flutter SDK:** `^3.13.2`
- **Dart SDK:** Sesuai dengan distribusi Flutter.
- **Supabase SDK:** `supabase_flutter: ^2.8.0`
- **Manajemen State/Sesi Lokal:** `shared_preferences: ^2.5.5`
- **Konversi Penanggalan:** `hijri: ^3.0.1`
- **Formating String & Tanggal:** `intl: ^0.20.3`
- **Media & Avatar:** `image_picker: ^1.2.3`

### 1.2 Langkah Inisiasi Project Flutter
Inisiasi proyek dimulai dengan perintah dasar pembuatan kerangka aplikasi:
```bash
flutter create aplikasi_kalkulator_kece
cd aplikasi_kalkulator_kece
```

### 1.3 Konfigurasi Supabase (Cloud Database & Storage)
Integrasi antara aplikasi Flutter dan Supabase diawali dengan menghubungkan `SUPABASE_URL` dan `SUPABASE_ANON_KEY` pada fungsi `main()`.

**Eksekusi DDL Script SQL (Skema Database Utama):**
```sql
-- Pembuatan tabel users
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  birth_date DATE,
  avatar_url TEXT
);

-- Pembuatan tabel members
CREATE TABLE members (
  id SERIAL PRIMARY KEY,
  npm TEXT NOT NULL,
  name TEXT NOT NULL,
  email TEXT,
  github_url TEXT
);

-- Tipe ENUM untuk transaksi
CREATE TYPE record_type AS ENUM ('income', 'expense');

-- Pembuatan tabel categories
CREATE TABLE categories (
  id SERIAL PRIMARY KEY,
  user_id INT REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type record_type NOT NULL
);

-- Pembuatan tabel financial_records
CREATE TABLE financial_records (
  id SERIAL PRIMARY KEY,
  user_id INT REFERENCES users(id) ON DELETE CASCADE,
  category_id INT REFERENCES categories(id) ON DELETE CASCADE,
  type record_type NOT NULL,
  title TEXT NOT NULL,
  amount DECIMAL(15, 2) NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Penyiapan Supabase Storage Bucket:**
- Pembuatan Bucket bernama `avatars` dan diatur sebagai *Public bucket*.
- Konfigurasi *Row-Level Security* (RLS) via SQL Editor untuk mengizinkan aplikasi mengunggah berkas biner (`Uint8List`):
```sql
CREATE POLICY "Izinkan semua akses ke avatars"
ON storage.objects FOR ALL
USING (bucket_id = 'avatars')
WITH CHECK (bucket_id = 'avatars');
```

---

## BAB 2: ARSITEKTUR PROYEK & STRUKTUR FOLDER

Proyek ini menerapkan **Feature-First Architecture**. Pola ini mengelompokkan *file* berdasarkan **Fungsionalitas / Fitur** (seperti fitur Auth, Kalkulator, Keuangan) ketimbang mengelompokkan berdasarkan **Tipe** (seperti mengumpulkan semua View atau Model di satu folder raksasa). Pola ini membuat kode sangat modular, mudah di-*debug*, dan skalabel.

### Pohon Direktori (Directory Tree)
```text
lib/
├── core/                         # Logika utama (Singleton, Constants)
│   ├── services/                 # Konfigurasi Storage, Supabase
│   └── session/                  # SessionManager (Auto-Logout 1 jam)
├── features/                     # Modul-modul fitur aplikasi
│   ├── auth/                     # Layar Login & Register (Validasi Regex)
│   ├── calendar_converters/      # Logika Konversi Tanggal
│   │   ├── hijri/                # Konversi Masehi ke Hijriah
│   │   ├── age/                  # Kalkulator Umur Real-Time (Live Detik)
│   │   ├── weton/                # Modulo Weton & Pasaran Jawa
│   │   └── saka_bali/            # Wuku, Wewaran, Saptawara Bali
│   ├── financial_kos/            # CRUD Keuangan KosKu & Kategori Dinamis
│   ├── guide_profile/            # Panduan Accordion, Avatar Picker, Logout
│   ├── home/                     # Grid Dashboard & List Menu Vertikal
│   ├── math_tools/               # Kalkulator Presisi BigInt, Ganjil Genap, Deret Statistik
│   ├── stopwatch/                # Stopwatch Presisi dengan fitur Lap Time
│   └── team/                     # Profil Anggota Kelompok
└── main.dart                     # Entry point & Inisialisasi Supabase
```

---

## BAB 3: PERANCANGAN DATABASE (SPESIFIKASI TABEL)

1. **Tabel `users`**  
   Menyimpan profil pengguna yang mendaftar. Memiliki properti sandi (`password`) untuk validasi manual, `birth_date` sebagai *anchor* kalkulasi umur, dan `avatar_url` untuk tautan foto profil (Supabase Storage).
2. **Tabel `members`**  
   Tabel statis yang di-_seed_ secara sepihak untuk menampilkan profil *developer* pembuat aplikasi (Nama, NPM, Email, URL GitHub).
3. **Tabel `categories`**  
   Menampung kategori keuangan (Tipe: `income` / `expense`) yang sifatnya spesifik dan dinamis untuk masing-masing `user_id`. (Sistem menginjeksikan data kategori *default* saat pengguna pertama kali meregistrasi akun).
4. **Tabel `financial_records`**  
   Tabel pencatatan transaksional utama. Memiliki relasi ke tabel `users` (pemilik data) dan tabel `categories` (jenis transaksi). Memuat kolom `amount` presisi 2 angka di belakang koma untuk akurasi nominal, serta *timestamp* rekaman transaksi.

---

## BAB 4: IMPLEMENTASI FITUR & FUNCTIONAL REQUIREMENTS (FR)

### 4.1 Universal Requirements (FR-U)
- **Auth (FR-U-01 & FR-U-02):** Login dan Registrasi dilengkapi peringatan (*Snackbar*) atas kegagalan otentikasi.
- **Session & Auto Logout (FR-U-06):** Menerapkan Singleton `SessionManager` untuk membajak inaktivitas gestur sentuhan (berbasis *SharedPreferences*). Apabila 1 jam berlalu tanpa interaksi fisik layar, sistem menendang pengguna keluar secara sepihak ke halaman Login.
- **Team (FR-U-03):** Menampilkan _ListView_ daftar pengembang dari tabel `members`.
- **Panduan Pengguna (FR-U-04):** Dirangkum rapi menggunakan struktur antarmuka _Accordion/ExpansionTile_ di Tab 3.

### 4.2 Tugas 1 Requirements (FR-T1)
- **Kalkulator Presisi (FR-T1-01):** Modul dirancang secara khusus untuk menangkal _Floating-Point Precision Loss_ pada bilangan besar dengan mengoperasikan teks sebagai array/logika manual.
- **Cek Ganjil Genap (FR-T1-02):** Melakukan validasi angka dan memberikan representasi visual berupa _chip_ Hijau untuk Genap, dan Biru untuk Ganjil.
- **Deret Statistik (FR-T1-03):** Mendapatkan input `N`, menghasilkan Deret Angka, dan secara simultan menghitung Total Sum, Rata-rata, Angka Maksimum, dan Angka Minimum dari deret tersebut.

### 4.3 Tugas 2 Requirements (FR-T2)
- **Catatan Keuangan KosKu (FR-T2-01 s/d FR-T2-04):** Pengguna dapat menciptakan kategori khusus (*custom*), menambah catatan (pendapatan/pengeluaran), merender _Dashboard_ pergerakan saldo akhir, dan membaca rekaman berdasarkan tanggal beserta presisi Menit.
- **Konversi Penanggalan Kalender (FR-T2-05 s/d FR-T2-08):**
  - **Hijriah:** Diadaptasi menggunakan library `hijri`.
  - **Umur (Live Counter):** _State_ Flutter di_refresh_ otomatis tiap 1 detik `Timer.periodic` tanpa membocorkan pemakaian CPU berkat *lifecycle disposal*.
  - **Weton & Saka Bali:** Algoritma tabular kalender kuno berbasis *Anchor Date* (Tahun 1900 Masehi) menggunakan pergeseran Modulo Matematika untuk penentuan Saptawara, Wuku, Pancawara, dst.
- **Navigasi & Stopwatch (FR-T2-09):** Sebuah _Bottom Navigation Bar_ permanen dengan indeks: (0) Menu Utama, (1) Stopwatch Presisi Lap-Time, (2) Profil & Logout.

---

## BAB 5: CATATAN REVISI, TRIALS & ERROR, DAN PERBAIKAN ANOMALI

Pengembangan aplikasi tidak luput dari proses *debugging* dan perbaikan cacat (*Bugs*). Berikut log teknis *issue* yang ditemukan dan solusinya:

1. **Anomali Kalkulator Floating-Point Loss**  
   - *Masalah:* Operasi perkalian angka sangat besar (di atas 15 digit) mengalami pembulatan ganjil dan meleset (misal berujung `...00004`).
   - *Solusi:* Kode dirancang ulang menggunakan metode manipulasi *String* (seperti `BigInt`) dengan parsing aritmatika algoritmis *Carry* ketimbang melempar operasi ke unit FPU (Floating Point Unit) standar bawaan *Dart*.
2. **Back Stack Navigasi Hilang**  
   - *Masalah:* Pada awal pembuatan, ketika user masuk ke menu dari Home (Tab 1), mereka tidak bisa menekan "Back" untuk kembali.
   - *Solusi:* _Navigator_ disesuaikan dari pola `pushReplacement` menjadi murni `push` biasa, sementara `appBar: AppBar()` diinjeksikan secara penuh agar Flutter menggambar ikon kembali (`<-`) bawaan.
3. **Validasi Form Email & Password (Bocor Simbol)**  
   - *Masalah:* Pengguna bisa mendaftar dengan email sembarangan (tanpa titik ekstensi) dan password spasi.
   - *Solusi:* Menulis ulang _Regular Expressions_ (`Regex`) ketat pada `RegisterView`. Password wajib minimal 8 karakter, gabungan huruf/angka/simbol, dan bebas spasi.
4. **Bug Negative Modulo (Wewaran Bali & Weton)**  
   - *Masalah:* Perhitungan kalender tradisional menggunakan selisih hari. Jika pengguna menginput tahun yang jauh *sebelum* tahun Anchor Date (misal 1800 Masehi), selisih hari menjadi Negatif, yang memicu _Index Out of Bounds_ (Batas Array -3).
   - *Solusi:* Menerapkan rumus Modulo Negatif aman: `((selisih % N) + N) % N`.
5. **Memory Leak: Live Age & Stopwatch UI Lag**  
   - *Masalah:* Timer di halaman Umur yang berdetak setiap 1 detik tidak dibuang (*dispose*) saat user pindah layar, berujung penumpukan proses dan aplikasi *crash* karena kehabisan RAM.
   - *Solusi:* Menangani _lifecycle_ ketat. Setiap inisiasi `Timer`, selalu disematkan perintah `timer?.cancel()` di *override method* `dispose()` bawaan Flutter.
6. **Perbedaan Zona Waktu pada Tanggal Hijriah**  
   - *Masalah:* Jika user mengubah tanggal menjadi jam malam, konversi Masehi ke Hijriah melompat +1 hari dikarenakan pergantian hari di perhitungan Arab dimulai pasca Maghrib.
   - *Solusi:* Melakukan strip zona waktu dengan mem-fiksasi jam masukan input Masehi (*Date Picker*) secara merata ke `00:00:00` (*Midnight Fixation*).
7. **Bocornya Penyimpanan File Foto Supabase Storage (Storage Cleanup)**  
   - *Masalah:* Jika user mengganti fotonya 10 kali, maka ada 10 berkas menumpuk di Bucket Supabase dan menghabiskan kuota Server. Opsi akses Native C++ file picker Android juga _crash_ di Flutter Web.
   - *Solusi:* Fitur dikonversi agar mengunggah _Binary Bytes (`Uint8List`)_ demi kompatibilitas Web. Selain itu, sebelum byte di-unggah, aplikasi akan mengirimkan sinyal "Remove Array" API ke Supabase untuk mencabut _(delete)_ nama berkas foto lama pengguna tersebut secara absolut dari _Bucket_ `avatars`.

---

## BAB 6: ATURAN VALIDASI & ERROR HANDLING

Daftar keamanan/validasi yang tertanam di seluruh bagian form aplikasi:

- **Auth Login/Regis:** Form tidak bisa disubmit jika kosong, Email wajib menggunakan sintaksis yang benar (`x@x.x`), Batas karakter maks 255.
- **Validasi Keuangan (KosKu):** 
  - `Amount` > 0. Tidak boleh memasukkan angka Rp 0 atau negatif. 
  - Judul Catatan tidak boleh lebih dari 50 karakter agar antarmuka kartu tidak tumpang tindih.
- **Validasi Tahun Batas Algoritma Kalender:** Kalender Weton dan Saka Bali dibatasi rentangnya dari tahun `1900` hingga `2100` Masehi (Batasan reliabilitas algoritma).
- **Validasi Upload Media (Storage):** Batas maksimum berkas unggahan sebesar **2 Megabytes**. Membaca ekstensi secara harfiah (Hanya `JPG, JPEG, PNG, WEBP`).
- **Logout Secure Terminate:** Pemutusan layar memanggil utilitas `pushAndRemoveUntil` secara rekursif hingga tumpukan layar _(Back Stack)_ terkuras habis untuk mencegah pengguna menekan tombol _Back_ sistem Android dan menembus kembali ke _Dashboard_ secara ilegal setelah _Logout_.
