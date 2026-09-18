// lib/core/utils/database_helper.dart
import 'package:postgres/postgres.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  Connection? _connection;

  // Konfigurasi Database
  final String _host = 'localhost';
  final int _port = 5432;
  final String _databaseName = 'db_mobile_teori';
  final String _username = 'postgres';
  final String _password = 'postgres';

  Future<Connection> get connection async {
    if (_connection != null && _connection!.isOpen) {
      return _connection!;
    }
    
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
      ),
    );
    return _connection!;
  }

  Future<void> initDatabase() async {
    try {
      final conn = await connection;
      
      // Menggunakan struktur tabel baru sesuai db_mobile_teori.sql
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
      
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS members (
          id SERIAL PRIMARY KEY,
          nim VARCHAR(20) NOT NULL UNIQUE,
          name VARCHAR(100) NOT NULL,
          created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // Note: Untuk ENUM dan struktur yang kompleks (seperti record_type, categories, financial_records),
      // sebaiknya di-inisialisasi via file db_mobile_teori.sql secara langsung di database.
      // Jika butuh auto-create, pastikan penanganan Exception saat ENUM sudah ada (duplicate object).
      
      debugPrint('Database schema users & members initialized successfully.');
    } catch (e) {
      debugPrint('Error initializing database schema: $e');
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
    } catch (e) {
      debugPrint('Error registering user: $e');
      return false;
    }
  }

  Future<bool> validateUser(String username, String password) async {
    try {
      final conn = await connection;
      final result = await conn.execute(
        Sql.named('SELECT * FROM users WHERE username = @u AND password = @p'),
        parameters: {
          'u': username,
          'p': password,
        },
      );
      return result.isNotEmpty;
    } catch (e) {
      debugPrint('Error validating user: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    return [];
  }
}
