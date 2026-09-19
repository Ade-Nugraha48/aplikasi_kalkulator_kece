/// ============================================================================
/// FILE: lib/features/age_calculator/services/age_calculator_service.dart
/// FUNGSI: Utilitas Perhitungan Umur secara Detail (Tahun, Bulan, Hari, Jam, Menit, Detik).
/// MANAJEMEN HANDLES: Algoritma presisi penanggalan masehi & kabisat.
/// ============================================================================

class AgeCalculatorService {
  /// Menghitung selisih persis umur berdasarkan kalender.
  /// Memperhitungkan jumlah hari per bulan dan tahun kabisat.
  static Map<String, int> calculateAge(DateTime birthDate) {
    DateTime now = DateTime.now();

    // Proteksi: Jika birthDate di masa depan, kembalikan 0
    if (birthDate.isAfter(now)) {
      return {
        'years': 0, 'months': 0, 'days': 0,
        'hours': 0, 'minutes': 0, 'seconds': 0,
      };
    }

    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;
    int hours = now.hour - birthDate.hour;
    int minutes = now.minute - birthDate.minute;
    int seconds = now.second - birthDate.second;

    if (seconds < 0) {
      minutes--;
      seconds += 60;
    }
    if (minutes < 0) {
      hours--;
      minutes += 60;
    }
    if (hours < 0) {
      days--;
      hours += 24;
    }
    if (days < 0) {
      months--;
      // Mendapatkan total hari pada bulan sebelumnya
      int previousMonth = now.month == 1 ? 12 : now.month - 1;
      int yearForPrevMonth = now.month == 1 ? now.year - 1 : now.year;
      // DateTime(year, month + 1, 0) menghasilkan hari terakhir di bulan tsb
      int daysInPrevMonth = DateTime(yearForPrevMonth, previousMonth + 1, 0).day;
      days += daysInPrevMonth;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    return {
      'years': years,
      'months': months,
      'days': days,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
    };
  }
}
