/// ============================================================================
/// FILE: lib/core/session/session_manager.dart
/// FUNGSI: Mengelola Persistent Session pengguna & Timer Inaktivitas 1 Jam (Auto Logout).
/// MANAJEMEN HANDLES: FR-U-06 (Session Management Auto-logout 1 jam inaktif & Persistence)
/// LOKASI LOGIC: Penyimpanan session di SharedPreferences, reset timer inaktivitas,
///               pemeriksaan status login saat startup, & handler auto-logout.
/// ============================================================================

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  // Durasi timeout inaktivitas: 1 Jam (60 menit)
  static const Duration sessionTimeout = Duration(hours: 1);

  // Key SharedPreferences
  static const String keyUserId = 'session_user_id';
  static const String keyUsername = 'session_username';
  static const String keyEmail = 'session_email';
  static const String keyBirthDate = 'session_birth_date';
  static const String keyLastActivity = 'session_last_activity';

  Timer? _inactivityTimer;
  DateTime? _lastActivityTime;
  Map<String, dynamic>? _currentUser;

  /// Callback yang dipanggil ketika session expired (auto-logout)
  void Function()? onSessionExpired;

  /// Inisialisasi session dari SharedPreferences saat aplikasi pertama kali dibuka
  Future<bool> initSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(keyUserId);
    final username = prefs.getString(keyUsername);
    final email = prefs.getString(keyEmail);
    final birthDateStr = prefs.getString(keyBirthDate);
    final lastActivityMs = prefs.getInt(keyLastActivity);

    if (userId != null && username != null && lastActivityMs != null) {
      final lastActivity = DateTime.fromMillisecondsSinceEpoch(lastActivityMs);
      final isExpired = DateTime.now().difference(lastActivity) > sessionTimeout;

      if (!isExpired) {
        _currentUser = {
          'id': userId,
          'username': username,
          'email': email ?? '',
          'birth_date': birthDateStr ?? '',
        };
        _lastActivityTime = DateTime.now();
        resetInactivityTimer();
        return true;
      } else {
        await clearSession();
        return false;
      }
    }
    return false;
  }

  /// Inisialisasi session baru setelah pengguna berhasil Login/Registrasi
  Future<void> startSession(Map<String, dynamic> user) async {
    _currentUser = user;
    _lastActivityTime = DateTime.now();

    final prefs = await SharedPreferences.getInstance();
    if (user['id'] != null) await prefs.setInt(keyUserId, user['id'] as int);
    await prefs.setString(keyUsername, user['username'].toString());
    if (user['email'] != null) await prefs.setString(keyEmail, user['email'].toString());
    if (user['birth_date'] != null) {
      await prefs.setString(keyBirthDate, user['birth_date'].toString());
    }
    await prefs.setInt(keyLastActivity, _lastActivityTime!.millisecondsSinceEpoch);

    resetInactivityTimer();
  }

  /// Mereset timer inaktivitas setiap ada interaksi gestur pengguna
  void resetInactivityTimer() {
    if (_currentUser == null) return;
    _lastActivityTime = DateTime.now();
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(sessionTimeout, _handleSessionTimeout);

    // Update timestamp inaktivitas di SharedPreferences
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt(keyLastActivity, _lastActivityTime!.millisecondsSinceEpoch);
    });
  }

  /// Handler internal saat timer inaktivitas 1 jam habis
  void _handleSessionTimeout() async {
    await clearSession();
    if (onSessionExpired != null) {
      onSessionExpired!();
    }
  }

  /// Memeriksa apakah session aktif dan belum expired (>1 jam)
  bool isSessionValid() {
    if (_currentUser == null || _lastActivityTime == null) return false;
    final isExpired = DateTime.now().difference(_lastActivityTime!) > sessionTimeout;
    return !isExpired;
  }

  /// Menghapus data session (Logout)
  Future<void> clearSession() async {
    _inactivityTimer?.cancel();
    _currentUser = null;
    _lastActivityTime = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyUserId);
    await prefs.remove(keyUsername);
    await prefs.remove(keyEmail);
    await prefs.remove(keyBirthDate);
    await prefs.remove(keyLastActivity);
  }

  /// Getter user aktif yang sedang login
  Map<String, dynamic>? get currentUser => _currentUser;
}
