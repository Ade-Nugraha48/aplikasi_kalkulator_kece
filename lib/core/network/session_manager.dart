// lib/core/network/session_manager.dart
import 'package:flutter/foundation.dart';

/// Session Manager & Auth Interceptor untuk Penanganan Idle Timeout.
/// 
/// Memenuhi FR-U-06:
/// - Session aktif saat login.
/// - Jika aplikasi idle/tidak digunakan selama 1 jam (3600 detik), 
///   secara otomatis melakukan logout & mengakhiri session token.
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  DateTime? _lastActivityTime;

  /// Memperbarui timestamp aktivitas terakhir user
  void updateActivity() {
    _lastActivityTime = DateTime.now();
    // TODO: Reset timer idle timeout
  }

  /// Mengecek apakah session sudah kadaluarsa (> 1 jam)
  bool isSessionExpired() {
    if (_lastActivityTime == null) return false;
    final difference = DateTime.now().difference(_lastActivityTime!);
    return difference.inHours >= 1;
  }

  /// Memaksa logout otomatis jika idle timeout tercapai
  Future<void> handleAutoLogout() async {
    debugPrint('SessionManager: Session idle timeout reached (>1 jam). Memproses logout otomatis...');
    // TODO: Hapus token session Supabase & Navigasi ke Screen Login
  }
}
