/// ============================================================================
/// FILE: lib/core/database/supabase_config.dart
/// FUNGSI: Konfigurasi Sentral URL & Anon Key Online Database Supabase.
/// MANAJEMEN HANDLES: Kredensial Supabase untuk Flutter Web & Cross-platform.
/// LOKASI LOGIC: Tempat pengguna meletakkan SUPABASE_URL & SUPABASE_ANON_KEY dari Dashboard.
/// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String keySupabaseUrl = 'supabase_config_url';
  static const String keySupabaseAnonKey = 'supabase_config_anon_key';

  // Default credentials (Pengguna dapat mengganti via Modal Pengaturan Database)
  static String _url = 'https://safmvkmvqlphykusxmul.supabase.co';
  static String _anonKey = 'sb_publishable_GPJMPklcBY5Ysutkf8gBsQ_06tpXPUj';

  /// Returns cleaned Base URL (menghapus akhiran /rest/v1/ jika ada)
  static String get url {
    var raw = _url.trim();
    if (raw.endsWith('/')) raw = raw.substring(0, raw.length - 1);
    if (raw.endsWith('/rest/v1')) raw = raw.substring(0, raw.length - '/rest/v1'.length);
    if (raw.endsWith('/')) raw = raw.substring(0, raw.length - 1);
    return raw;
  }

  static String get anonKey => _anonKey.trim();

  /// Memuat kredensial tersimpan dari SharedPreferences
  static Future<void> loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString(keySupabaseUrl);
      final savedKey = prefs.getString(keySupabaseAnonKey);
      if (savedUrl != null && savedUrl.isNotEmpty) _url = savedUrl;
      if (savedKey != null && savedKey.isNotEmpty) _anonKey = savedKey;
    } catch (_) {}
  }

  /// Menyimpan kredensial kustom jika diubah secara dinamis
  static Future<void> saveConfig({required String url, required String anonKey}) async {
    _url = url.trim();
    _anonKey = anonKey.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keySupabaseUrl, _url);
      await prefs.setString(keySupabaseAnonKey, _anonKey);
    } catch (_) {}
  }

  /// Menguji koneksi ke Supabase secara langsung menggunakan instance SupabaseClient independen
  static Future<bool> testConnection({required String testUrl, required String testAnonKey}) async {
    var formattedUrl = testUrl.trim();
    if (formattedUrl.endsWith('/')) formattedUrl = formattedUrl.substring(0, formattedUrl.length - 1);
    if (formattedUrl.endsWith('/rest/v1')) formattedUrl = formattedUrl.substring(0, formattedUrl.length - '/rest/v1'.length);
    if (formattedUrl.endsWith('/')) formattedUrl = formattedUrl.substring(0, formattedUrl.length - 1);

    try {
      final testClient = SupabaseClient(formattedUrl, testAnonKey.trim());
      await testClient.from('users').select('id').limit(1);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Test Supabase connection error: $e');
      }
      rethrow;
    }
  }
}
