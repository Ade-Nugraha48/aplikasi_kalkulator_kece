/// ============================================================================
/// FILE: lib/features/hijri_converter/services/hijri_service.dart
/// FUNGSI: Service Utility untuk mengonversi Masehi ke Hijriah.
/// MANAJEMEN HANDLES: Waktu Maghrib / Boundary Midnight bug, dan transliterasi
///                    nama bulan Hijriah ke standar Bahasa Indonesia.
/// ============================================================================

import 'package:hijri/hijri_calendar.dart';

class HijriService {
  static const List<String> _bulanHijriahIndo = [
    'Muharram',
    'Safar',
    'Rabiul Awal',
    'Rabiul Akhir',
    'Jumadil Awal',
    'Jumadil Akhir',
    'Rajab',
    'Sya\'ban',
    'Ramadan',
    'Syawal',
    'Zulkaidah',
    'Zulhijah'
  ];

  /// Mengonversi DateTime (Masehi) ke format String Hijriah
  static String convertToHijri(DateTime? inputDate) {
    if (inputDate == null) {
      inputDate = DateTime.now();
    }

    // 1. Time Stripping: Normalisasi waktu ke 00:00:00 untuk mencegah Bug Boundary Midnight
    final normalizedDate = DateTime(inputDate.year, inputDate.month, inputDate.day);

    // 2. Gunakan package 'hijri' untuk men-generate kalender yang presisi dari tanggal normal
    HijriCalendar hijriDate = HijriCalendar.fromDate(normalizedDate);

    // 3. Translokalisasi / Override nama bulan ke Bahasa Indonesia
    // HijriCalendar.hMonth adalah 1-12
    final monthIndex = hijriDate.hMonth - 1;
    String monthName = 'Tidak Diketahui';
    if (monthIndex >= 0 && monthIndex < 12) {
      monthName = _bulanHijriahIndo[monthIndex];
    }

    // 4. Return format string lengkap
    return '${hijriDate.hDay} $monthName ${hijriDate.hYear} H';
  }
}
