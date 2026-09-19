/// ============================================================================
/// FILE: lib/core/database/database_config.dart
/// FUNGSI: Konfigurasi Koneksi PostgreSQL (Host, Port, Database, User, Password).
/// MANAJEMEN HANDLES: Dynamic & Interactive Host / IP / Password Configuration
/// LOKASI LOGIC: Penyimpanan konfigurasi DB di SharedPreferences agar pengguna dapat
///               mengubah IP / Password secara langsung via UI aplikasi.
/// ============================================================================

import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseConfig {
  static const String keyCustomHost = 'db_config_host';
  static const String keyCustomPort = 'db_config_port';
  static const String keyCustomDb = 'db_config_database';
  static const String keyCustomUser = 'db_config_username';
  static const String keyCustomPass = 'db_config_password';

  static String _customHost = '';
  static int _customPort = 5432;
  static String _customDb = 'db_mobile_teori';
  static String _customUser = 'postgres';
  static String _customPass = '12345678';

  /// Default Host berdasarkan Platform Runtime:
  /// - Android Emulator -> 10.0.2.2
  /// - Windows Desktop / iOS Simulator -> 127.0.0.1
  static String get defaultHost {
    try {
      if (Platform.isAndroid) return '10.0.2.2';
    } catch (_) {}
    return '127.0.0.1';
  }

  static String get host => _customHost.isNotEmpty ? _customHost : defaultHost;
  static int get port => _customPort;
  static String get databaseName => _customDb;
  static String get username => _customUser;
  static String get password => _customPass;

  /// Memuat konfigurasi kustom dari SharedPreferences saat aplikasi pertama dibuka
  static Future<void> loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _customHost = prefs.getString(keyCustomHost) ?? '';
      _customPort = prefs.getInt(keyCustomPort) ?? 5432;
      _customDb = prefs.getString(keyCustomDb) ?? 'db_mobile_teori';
      _customUser = prefs.getString(keyCustomUser) ?? 'postgres';
      _customPass = prefs.getString(keyCustomPass) ?? 'postgres';
    } catch (_) {}
  }

  /// Menyimpan konfigurasi koneksi baru dari UI Diagnosa Database
  static Future<void> saveConfig({
    required String host,
    required int port,
    required String dbName,
    required String user,
    required String pass,
  }) async {
    _customHost = host.trim();
    _customPort = port;
    _customDb = dbName.trim();
    _customUser = user.trim();
    _customPass = pass;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyCustomHost, _customHost);
      await prefs.setInt(keyCustomPort, _customPort);
      await prefs.setString(keyCustomDb, _customDb);
      await prefs.setString(keyCustomUser, _customUser);
      await prefs.setString(keyCustomPass, _customPass);
    } catch (_) {}
  }
}
