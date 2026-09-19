/// ============================================================================
/// FILE: lib/core/utils/date_formatter.dart
/// FUNGSI: Utility helper untuk format & manipulasi DateTime/Tanggal.
/// MANAJEMEN HANDLES: Utility / Helper System
/// LOKASI LOGIC: Fungsi penformatan tanggal Indonesia, parsing string ke DateTime,
///               serta kalkulasi selisih waktu/umur.
/// ============================================================================

class DateFormatter {
  /// Memformat DateTime ke String (YYYY-MM-DD)
  static String formatDateToDb(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  /// Memformat DateTime ke format tampilan Indonesia (misal: 19 September 2026)
  static String formatDateIndonesia(DateTime date) {
    const List<String> namaBulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return "${date.day} ${namaBulan[date.month - 1]} ${date.year}";
  }
}
