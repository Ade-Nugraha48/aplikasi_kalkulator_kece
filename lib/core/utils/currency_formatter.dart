// lib/core/utils/currency_formatter.dart

/// Helper & Utility untuk Formatting Mata Uang / Rupiah (KosKu Financial).
class CurrencyFormatter {
  /// Mengubah angka (double/num) menjadi format Rupiah (misal: Rp 150.000)
  static String formatRupiah(num amount) {
    return 'Rp ${amount.toStringAsFixed(0)}';
  }
}
