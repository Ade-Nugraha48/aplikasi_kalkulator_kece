// lib/core/config/app_constants.dart

/// Konstant Global Aplikasi (Nama App, Route Names, Config Timeout, dll.)
class AppConstants {
  static const String appName = 'Kalkulator & KosKu Kece';
  
  /// Durasi Idle Timeout (FR-U-06: 1 Jam)
  static const Duration sessionTimeoutDuration = Duration(hours: 1);

  // TODO: Tambahkan constant lain seperti nama tabel Supabase ('users', 'members', 'categories', 'financial_records')
}
