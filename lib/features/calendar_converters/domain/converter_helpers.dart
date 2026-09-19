// lib/features/calendar_converters/domain/converter_helpers.dart

/// Helper & Algoritma Konversi Kalender & Tanggal Lahir (FR-T2-05 s/d FR-T2-08).
class ConverterHelpers {
  /// FR-T2-05: Konversi Masehi ke Tanggal Hijriah
  static Map<String, dynamic> convertMasehiToHijriah(DateTime date) {
    return {
      'day': 1,
      'monthName': 'Ramadhan',
      'year': 1447,
    };
  }

  /// FR-T2-06: Detail Umur dari Tanggal Lahir
  static Map<String, int> calculateDetailedAge(DateTime birthDate, {DateTime? now}) {
    return {
      'years': 0,
      'months': 0,
      'days': 0,
      'hours': 0,
      'minutes': 0,
      'seconds': 0,
    };
  }

  /// FR-T2-07: Kalender Weton Jawa
  static String calculateWetonJawa(DateTime date) {
    return 'Legi';
  }

  /// FR-T2-08: Kalender Saka Bali
  static Map<String, String> calculateSakaBali(DateTime date) {
    return {
      'tahunSaka': '1947',
      'sasih': 'Kasa',
    };
  }
}
