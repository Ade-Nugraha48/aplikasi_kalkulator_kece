// lib/core/config/supabase_config.dart
import 'package:flutter/foundation.dart';

/// Config & Inisialisasi Supabase Client untuk Aplikasi.
/// 
/// Kebutuhan:
/// - Mengatur URL Supabase dan Anon Key.
/// - Menyediakan instance Supabase Client global.
/// - Berfungsi untuk autentikasi user (FR-U-01, FR-U-02), 
///   pengambilan data anggota (FR-U-03), dan CRUD KosKu (FR-T2-01 s/d FR-T2-04).
class SupabaseConfig {
  // TODO: Isi dengan URL Supabase project Anda
  static const String supabaseUrl = 'https://YOUR_SUPABASE_PROJECT_ID.supabase.co';

  // TODO: Isi dengan Anon Key Supabase project Anda
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  /// Inisialisasi Supabase sebelum runApp() dipanggil.
  static Future<void> initialize() async {
    debugPrint('SupabaseConfig: Memulai inisialisasi Supabase Client...');
    // TODO: Panggil Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey)
  }
}
