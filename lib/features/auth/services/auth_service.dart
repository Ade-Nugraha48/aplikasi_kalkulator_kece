/// ============================================================================
/// FILE: lib/features/auth/services/auth_service.dart
/// FUNGSI: Menangani logika autentikasi (Login & Registrasi) via Supabase Client.
/// MANAJEMEN HANDLES: FR-U-01 (Login) & FR-U-02 (Registrasi User ke Cloud Supabase)
/// LOKASI LOGIC: Supabase Client Direct Table Access (`Supabase.instance.client.from('users')`)
///               sehingga Flutter Web di Chrome dapat login & registrasi secara online & bebas CORS.
/// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

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

  /// Helper Hashing Password SHA-256
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  /// Handles FR-U-01: Login User (Online Supabase Cloud)
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

    final hashedPassword = hashPassword(password);

    // 1. Coba via Online Supabase Client (Sangat cocok untuk Flutter Web / Chrome)
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('users')
          .select()
          .eq('username', trimmedUsername)
          .maybeSingle();

      if (response != null) {
        final dbPassword = response['password']?.toString() ?? '';
        // Cocokkan password (baik hashed SHA-256 maupun plaintext legacy)
        if (dbPassword == hashedPassword || dbPassword == password) {
          final user = UserModel.fromMap(response);
          return AuthResult(success: true, user: user);
        } else {
          return AuthResult(
            success: false,
            errorMessage: 'Password yang Anda masukkan salah!',
          );
        }
      } else {
        return AuthResult(
          success: false,
          errorMessage: 'Username "$trimmedUsername" tidak ditemukan!',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('ℹ️ Supabase Login Error: $e');
      }
      if (e.toString().contains('YOUR_SUPABASE_PROJECT_ID') || e.toString().contains('Invalid API key')) {
        return AuthResult(
          success: false,
          errorMessage: 'Kredensial Supabase belum diisi! Masukkan SUPABASE_URL dan SUPABASE_ANON_KEY di supabase_config.dart',
        );
      }
    }

    return AuthResult(
      success: false,
      errorMessage: 'Gagal Login. Pastikan koneksi internet aktif dan Supabase URL/Key sudah terkonfigurasi.',
    );
  }

  /// Handles FR-U-02: Registrasi User Baru ke Supabase Cloud
  Future<AuthResult> register(UserModel user) async {
    final trimmedUsername = user.username.trim();
    final trimmedEmail = user.email.trim();

    if (trimmedUsername.isEmpty || user.password.isEmpty || trimmedEmail.isEmpty) {
      return AuthResult(
        success: false,
        errorMessage: 'Seluruh field registrasi wajib diisi.',
      );
    }

    final birthDateStr = user.birthDate.toIso8601String().split('T').first;
    final hashedPassword = hashPassword(user.password);

    // 1. Coba registrasi via Supabase Client
    try {
      final supabase = Supabase.instance.client;

      // Cek apakah username atau email sudah terdaftar
      final existingUser = await supabase
          .from('users')
          .select('id, username, email')
          .or('username.eq.$trimmedUsername,email.eq.$trimmedEmail')
          .maybeSingle();

      if (existingUser != null) {
        final existingUsername = existingUser['username']?.toString();
        final existingEmail = existingUser['email']?.toString();
        if (existingUsername?.toLowerCase() == trimmedUsername.toLowerCase()) {
          return AuthResult(
            success: false,
            errorMessage: 'Username "$trimmedUsername" sudah digunakan!',
          );
        }
        if (existingEmail?.toLowerCase() == trimmedEmail.toLowerCase()) {
          return AuthResult(
            success: false,
            errorMessage: 'Email "$trimmedEmail" sudah terdaftar!',
          );
        }
      }

      // Insert ke tabel users Supabase
      final insertedRows = await supabase.from('users').insert({
        'username': trimmedUsername,
        'password': hashedPassword,
        'email': trimmedEmail,
        'birth_date': birthDateStr,
      }).select();

      if (insertedRows.isNotEmpty) {
        final createdUser = UserModel.fromMap(insertedRows.first);
        return AuthResult(success: true, user: createdUser);
      }
    } catch (e) {
      if (kDebugMode) {
        print('ℹ️ Supabase Register Error: $e');
      }
      if (e.toString().contains('YOUR_SUPABASE_PROJECT_ID') || e.toString().contains('Invalid API key')) {
        return AuthResult(
          success: false,
          errorMessage: 'Kredensial Supabase belum diisi di supabase_config.dart!',
        );
      }
      return AuthResult(
        success: false,
        errorMessage: 'Gagal registrasi di Supabase: ${e.toString()}',
      );
    }

    return AuthResult(
      success: false,
      errorMessage: 'Gagal mendaftar ke database. Pastikan koneksi internet aktif.',
    );
  }
}
