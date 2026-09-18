// lib/core/utils/database_helper.dart
import 'package:postgres/postgres.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  Connection? _connection;
  bool _useFallback = false;

  // Konfigurasi Database PostgreSQL
  final String _host = 'localhost';
  final int _port = 5432;
  final String _databaseName = 'db_mobile_teori';
  final String _username = 'postgres';
  final String _password = 'postgres';

  // Local fallback storage (In-memory cache jika PostgreSQL tidak tersedia)
  final List<Map<String, dynamic>> _localUsers = [
    {
      'id': 1,
      'username': 'user',
      'password': '12345',
      'email': 'user@example.com',
      'birth_date': '2000-01-01',
    }
  ];

  final List<Map<String, String>> _localMembers = [
    {
      'nim': '2209106048',
      'name': 'Ade Nugraha',
      'peranan': 'Ketua / Developer Utama',
    },
    {
      'nim': '2209106001',
      'name': 'Anggota Tim 1',
      'peranan': 'Anggota Kelompok',
    },
    {
      'nim': '2209106002',
      'name': 'Anggota Tim 2',
      'peranan': 'Anggota Kelompok',
    },
  ];

  final List<Map<String, dynamic>> _localCategories = [
    {'id': 1, 'user_id': 1, 'name': 'Transfer Orang Tua', 'type': 'pemasukan'},
    {'id': 2, 'user_id': 1, 'name': 'Sewa Kos', 'type': 'pengeluaran'},
    {'id': 3, 'user_id': 1, 'name': 'Makanan & Minuman', 'type': 'pengeluaran'},
    {'id': 4, 'user_id': 1, 'name': 'Kebutuhan Kamar', 'type': 'pengeluaran'},
  ];

  final List<Map<String, dynamic>> _localRecords = [
    {
      'id': '1',
      'user_id': 1,
      'category_id': 1,
      'title': 'Uang Saku Bulanan',
      'amount': 1500000.0,
      'type': 'pemasukan',
      'kategori': 'Transfer Orang Tua',
      'record_date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    },
    {
      'id': '2',
      'user_id': 1,
      'category_id': 2,
      'title': 'Bayar Sewa Kos Bulan Ini',
      'amount': 750000.0,
      'type': 'pengeluaran',
      'kategori': 'Sewa Kos',
      'record_date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
  ];

  Future<Connection?> get connection async {
    if (_useFallback) return null;
    if (_connection != null && _connection!.isOpen) {
      return _connection!;
    }
    
    try {
      _connection = await Connection.open(
        Endpoint(
          host: _host,
          port: _port,
          database: _databaseName,
          username: _username,
          password: _password,
        ),
        settings: const ConnectionSettings(
          sslMode: SslMode.disable,
          connectTimeout: Duration(seconds: 3),
        ),
      );
      return _connection;
    } catch (e) {
      debugPrint('PostgreSQL connection offline/unavailable: $e. Using local fallback database.');
      _useFallback = true;
      return null;
    }
  }

  Future<void> initDatabase() async {
    try {
      final conn = await connection;
      if (conn == null) {
        debugPrint('Using local database fallback mode.');
        return;
      }
      
      // 1. Inisialisasi ENUM record_type jika belum ada
      await conn.execute('''
        DO \$\$
        BEGIN
          IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'record_type') THEN
            CREATE TYPE record_type AS ENUM ('pemasukan', 'pengeluaran');
          END IF;
        END
        \$\$;
      ''');

      // 2. Tabel Users
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id SERIAL PRIMARY KEY,
          username VARCHAR(50) NOT NULL UNIQUE,
          password VARCHAR(255) NOT NULL,
          email VARCHAR(100) NOT NULL UNIQUE,
          birth_date DATE NOT NULL,
          created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
        )
      ''');
      
      // 3. Tabel Members
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS members (
          id SERIAL PRIMARY KEY,
          nim VARCHAR(20) NOT NULL UNIQUE,
          name VARCHAR(100) NOT NULL,
          created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // 4. Tabel Categories
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS categories (
          id SERIAL PRIMARY KEY,
          user_id INT NOT NULL,
          name VARCHAR(50) NOT NULL,
          type RECORD_TYPE NOT NULL,
          created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
          CONSTRAINT fk_category_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');

      // 5. Tabel Financial Records
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS financial_records (
          id SERIAL PRIMARY KEY,
          user_id INT NOT NULL,
          category_id INT,
          type RECORD_TYPE NOT NULL,
          amount NUMERIC(15, 2) NOT NULL CHECK (amount > 0),
          title VARCHAR(100) NOT NULL,
          description TEXT,
          record_date DATE NOT NULL DEFAULT CURRENT_DATE,
          created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
          CONSTRAINT fk_record_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
          CONSTRAINT fk_record_category FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
        )
      ''');

      // 6. Index
      await conn.execute('''
        CREATE INDEX IF NOT EXISTS idx_financial_records_user_date ON financial_records (user_id, record_date DESC)
      ''');

      // 7. Seed Akun Dummy Default (username: user, password: 12345)
      await conn.execute(
        Sql.named('''
          INSERT INTO users (username, password, email, birth_date)
          VALUES ('user', '12345', 'user@example.com', '2000-01-01')
          ON CONFLICT (username) DO NOTHING
        '''),
      );

      debugPrint('Database schema & dummy seed initialized successfully on PostgreSQL.');
    } catch (e) {
      debugPrint('Error initializing database schema on PostgreSQL: $e. Falling back to local storage.');
      _useFallback = true;
    }
  }

  Future<bool> registerUser({
    required String username,
    required String password,
    required String email,
    required String tanggalLahir,
  }) async {
    try {
      final conn = await connection;
      if (conn != null) {
        await conn.execute(
          Sql.named('INSERT INTO users (username, password, email, birth_date) VALUES (@u, @p, @e, @d)'),
          parameters: {
            'u': username,
            'p': password,
            'e': email,
            'd': DateTime.parse(tanggalLahir),
          },
        );
        return true;
      }
    } catch (e) {
      debugPrint('Error registering user in PostgreSQL: $e. Using local fallback.');
      _useFallback = true;
    }

    // Fallback registration
    final exists = _localUsers.any((u) => u['username'] == username || u['email'] == email);
    if (exists) return false;

    _localUsers.add({
      'id': _localUsers.length + 1,
      'username': username,
      'password': password,
      'email': email,
      'birth_date': tanggalLahir,
    });
    return true;
  }

  Future<bool> validateUser(String username, String password) async {
    try {
      final conn = await connection;
      if (conn != null) {
        final result = await conn.execute(
          Sql.named('SELECT * FROM users WHERE username = @u AND password = @p'),
          parameters: {
            'u': username,
            'p': password,
          },
        );
        return result.isNotEmpty;
      }
    } catch (e) {
      debugPrint('Error validating user in PostgreSQL: $e. Using local fallback.');
      _useFallback = true;
    }

    // Fallback login
    return _localUsers.any(
      (u) => u['username'] == username && u['password'] == password,
    );
  }

  Future<List<Map<String, dynamic>>> getMembers() async {
    try {
      final conn = await connection;
      if (conn != null) {
        final result = await conn.execute('SELECT nim, name FROM members ORDER BY id ASC');
        if (result.isNotEmpty) {
          return result.map((row) => {
            'nim': row[0].toString(),
            'name': row[1].toString(),
            'peranan': 'Anggota Kelompok',
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching members from PostgreSQL: $e');
    }
    return _localMembers;
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final conn = await connection;
      if (conn != null) {
        final result = await conn.execute('SELECT id, name, type::text FROM categories ORDER BY id ASC');
        if (result.isNotEmpty) {
          return result.map((row) => {
            'id': row[0],
            'name': row[1].toString(),
            'type': row[2].toString(),
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching categories from PostgreSQL: $e');
    }
    return _localCategories;
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    try {
      final conn = await connection;
      if (conn != null) {
        final result = await conn.execute('''
          SELECT fr.id, fr.title, fr.amount, fr.type::text, c.name as category_name, fr.record_date 
          FROM financial_records fr
          LEFT JOIN categories c ON fr.category_id = c.id
          ORDER BY fr.record_date DESC
        ''');
        if (result.isNotEmpty) {
          return result.map((row) => {
            'id': row[0].toString(),
            'judul': row[1].toString(),
            'jumlah': double.parse(row[2].toString()),
            'tipe': row[3].toString(),
            'kategori': row[4]?.toString() ?? 'Umum',
            'tanggal': DateTime.parse(row[5].toString()),
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching transactions from PostgreSQL: $e');
    }

    return _localRecords.map((r) => {
      'id': r['id'].toString(),
      'judul': r['title'].toString(),
      'jumlah': (r['amount'] as num).toDouble(),
      'tipe': r['type'].toString(),
      'kategori': r['kategori'].toString(),
      'tanggal': DateTime.parse(r['record_date'].toString()),
    }).toList();
  }

  Future<bool> addTransaction({
    required String judul,
    required double jumlah,
    required String tipe,
    required String kategori,
    required DateTime tanggal,
  }) async {
    try {
      final conn = await connection;
      if (conn != null) {
        await conn.execute(
          Sql.named('''
            INSERT INTO financial_records (user_id, title, amount, type, record_date)
            VALUES (1, @t, @a, @type::record_type, @d)
          '''),
          parameters: {
            't': judul,
            'a': jumlah,
            'type': tipe,
            'd': tanggal.toIso8601String().substring(0, 10),
          },
        );
        return true;
      }
    } catch (e) {
      debugPrint('Error adding transaction in PostgreSQL: $e');
    }

    _localRecords.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'user_id': 1,
      'title': judul,
      'amount': jumlah,
      'type': tipe,
      'kategori': kategori,
      'record_date': tanggal.toIso8601String(),
    });
    return true;
  }

  Future<bool> deleteTransaction(String id) async {
    try {
      final conn = await connection;
      if (conn != null && int.tryParse(id) != null) {
        await conn.execute(
          Sql.named('DELETE FROM financial_records WHERE id = @id'),
          parameters: {'id': int.parse(id)},
        );
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting transaction in PostgreSQL: $e');
    }

    _localRecords.removeWhere((r) => r['id'].toString() == id);
    return true;
  }
}
