/// ============================================================================
/// FILE: lib/features/auth/services/auth_service.dart
/// FUNGSI: Menangani logika autentikasi (Login & Registrasi) dengan PostgreSQL & Hashing SHA-256.
/// MANAJEMEN HANDLES: FR-U-01 (Login DB) & FR-U-02 (Registrasi DB dengan Hash Password)
/// LOKASI LOGIC: Enkripsi SHA-256 password, Query SELECT (login) & INSERT RETURNING (register) PostgreSQL,
///               serta validasi keunikan username & email.
/// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/user_model.dart';
import '../../../core/database/database_helper.dart';

class AuthResult {
  final bool success;
  final String? errorMessage;
  final UserModel? user;

  AuthResult({
    required this.success,
    this.errorMessage,
    this.user,
  });
}

class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Fungsi Helper Hashing Password menggunakan algoritma SHA-256
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  /// Handles FR-U-01: Login dengan username & password dari DB PostgreSQL
  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    final trimmedUsername = username.trim();
    if (trimmedUsername.isEmpty || password.isEmpty) {
      return AuthResult(
        success: false,
        errorMessage: 'Username dan Password tidak boleh kosong.',
      );
    }

    // Pastikan koneksi DB aktif
    final isConnected = await _dbHelper.initDatabase();
    if (!isConnected) {
      return AuthResult(
        success: false,
        errorMessage: 'Gagal terhubung ke PostgreSQL DB "${_dbHelper.lastErrorDetail ?? 'Cek Server/Password'}"',
      );
    }

    final hashedPassword = hashPassword(password);

    // Dynamic SQL Query ke PostgreSQL
    final rows = await _dbHelper.query(
      'SELECT id, username, password, email, birth_date, created_at FROM users WHERE username = @username AND password = @password LIMIT 1',
      substitutionValues: {
        'username': trimmedUsername,
        'password': hashedPassword,
      },
    );

    if (rows.isNotEmpty) {
      final user = UserModel.fromMap(rows.first);
      return AuthResult(success: true, user: user);
    }

    return AuthResult(
      success: false,
      errorMessage: 'Username atau Password salah!',
    );
  }

  /// Handles FR-U-02: Registrasi user baru (username, password, email, birth_date) ke DB PostgreSQL
  Future<AuthResult> register(UserModel user) async {
    if (user.username.trim().isEmpty || user.password.isEmpty || user.email.trim().isEmpty) {
      return AuthResult(
        success: false,
        errorMessage: 'Seluruh field registrasi wajib diisi.',
      );
    }

    // Pastikan koneksi DB aktif
    final isConnected = await _dbHelper.initDatabase();
    if (!isConnected) {
      return AuthResult(
        success: false,
        errorMessage: 'Tidak terhubung ke database PostgreSQL! Cek koneksi / password DB di tombol Tes DB.',
      );
    }

    // 1. Cek keunikan username atau email di database PostgreSQL
    final existingRows = await _dbHelper.query(
      'SELECT id FROM users WHERE username = @username OR email = @email LIMIT 1',
      substitutionValues: {
        'username': user.username.trim(),
        'email': user.email.trim(),
      },
    );

    if (existingRows.isNotEmpty) {
      return AuthResult(
        success: false,
        errorMessage: 'Username atau Email sudah terdaftar di database!',
      );
    }

    // 2. Hash Password dengan SHA-256
    final hashedPassword = hashPassword(user.password);
    final birthDateStr = user.birthDate.toIso8601String().split('T').first;

    // 3. Simpan ke database PostgreSQL & RETURNING id hasil insert
    final insertedRows = await _dbHelper.query(
      '''
      INSERT INTO users (username, password, email, birth_date)
      VALUES (@username, @password, @email, @birth_date::date)
      RETURNING id, username, email, birth_date, created_at
      ''',
      substitutionValues: {
        'username': user.username.trim(),
        'password': hashedPassword,
        'email': user.email.trim(),
        'birth_date': birthDateStr,
      },
    );

    if (insertedRows.isNotEmpty) {
      final createdUser = UserModel.fromMap(insertedRows.first);
      return AuthResult(success: true, user: createdUser);
    }

    return AuthResult(
      success: false,
      errorMessage: 'Gagal memasukkan data ke tabel users di PostgreSQL.',
    );
  }
}
