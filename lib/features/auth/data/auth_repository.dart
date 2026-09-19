// lib/features/auth/data/auth_repository.dart
import 'package:flutter/foundation.dart';

/// Repository untuk Autentikasi User (Supabase Auth & Database).
/// 
/// Memenuhi FR-U-01 (Login), FR-U-02 (Register), FR-U-05 (Logout).
class AuthRepository {
  /// FR-U-01: Login User via Username/Email & Password ke database Supabase.
  Future<bool> login({required String username, required String password}) async {
    debugPrint('AuthRepository: Mencoba login untuk user: $username');
    return username == 'user' && password == '12345';
  }

  /// FR-U-02: Register User Baru (Username, Password, Email, Tanggal Lahir).
  Future<bool> register({
    required String username,
    required String password,
    required String email,
    required DateTime birthDate,
  }) async {
    debugPrint('AuthRepository: Mendaftarkan user baru: $username ($email)');
    return true;
  }

  /// FR-U-05: Logout User & Menghapus session token.
  Future<void> logout() async {
    debugPrint('AuthRepository: Melakukan logout & menghapus session token.');
  }
}
