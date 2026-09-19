/// ============================================================================
/// FILE: lib/features/weton_calendar/services/weton_service.dart
/// FUNGSI: Service Utility untuk Perhitungan Weton Jawa & Neptu.
/// MANAJEMEN HANDLES: Negative modulo bug & Leap year UTC stripping.
/// ============================================================================

class WetonResult {
  final String namaHari;
  final String namaPasaran;
  final int neptuHari;
  final int neptuPasaran;
  final String watak;

  int get totalNeptu => neptuHari + neptuPasaran;
  String get wetonLengkap => '$namaHari $namaPasaran';

  WetonResult({
    required this.namaHari,
    required this.namaPasaran,
    required this.neptuHari,
    required this.neptuPasaran,
    required this.watak,
  });
}

class WetonService {
  // Array Pasaran & Hari
  static const List<String> _pasaranList = ['Legi', 'Pahing', 'Pon', 'Wage', 'Kliwon'];
  static const List<String> _hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

  // Kamus Neptu Hari (Senin - Minggu)
  static const Map<String, int> _neptuHari = {
    'Senin': 4, 'Selasa': 3, 'Rabu': 7, 'Kamis': 8, 'Jumat': 6, 'Sabtu': 9, 'Minggu': 5
  };

  // Kamus Neptu Pasaran
  static const Map<String, int> _neptuPasaran = {
    'Legi': 5, 'Pahing': 9, 'Pon': 7, 'Wage': 4, 'Kliwon': 8
  };

  /// Mendapatkan Watak Weton Berdasarkan Total Neptu
  static String _getWatak(int neptu) {
    // Pengelompokan watak dasar secara umum
    if (neptu == 7 || neptu == 11 || neptu == 15) {
      return 'Bumi Kapetak (Suka bekerja keras, ulet, dan tabah, namun terkadang pendendam).';
    } else if (neptu == 8 || neptu == 12 || neptu == 16) {
      return 'Lebu Katiup Angin (Mudah bimbang, sering tidak tetap pendiriannya, namun dermawan).';
    } else if (neptu == 9 || neptu == 13 || neptu == 17) {
      return 'Watu Tumbuk (Penyabar, berpendirian teguh, tapi keras kepala jika marah).';
    } else if (neptu == 10 || neptu == 14 || neptu == 18) {
      return 'Sumur Sinaba (Penuh wawasan, bijaksana, dan sering menjadi tempat orang meminta nasihat).';
    } else {
      return 'Memiliki kepribadian unik dan dinamis, pandai menyesuaikan diri dalam lingkungan baru.';
    }
  }

  /// Kalkulasi Weton dari Tanggal Masehi
  static WetonResult hitungWeton(DateTime inputDate) {
    // 1. Time Stripping: Kunci tanggal ke jam 00:00 UTC (menghindari offset timezone & jam kritis)
    final targetDate = DateTime.utc(inputDate.year, inputDate.month, inputDate.day);
    
    // 2. Anchor Date: 1 Januari 2000 (Sabtu Legi)
    final anchorDate = DateTime.utc(2000, 1, 1);
    
    // 3. Selisih Hari Lengkap
    final diffDays = targetDate.difference(anchorDate).inDays;
    
    // 4. Kalkulasi Pasaran (Bug Fix: (diff % 5 + 5) % 5 mencegah array negatif)
    final pasaranIndex = ((diffDays % 5) + 5) % 5;
    final pasaran = _pasaranList[pasaranIndex];
    
    // 5. Nama Hari (1 = Senin, 7 = Minggu)
    final hariIndex = targetDate.weekday - 1;
    final hari = _hariList[hariIndex];
    
    // 6. Pengambilan Nilai Neptu
    final nHari = _neptuHari[hari]!;
    final nPasaran = _neptuPasaran[pasaran]!;
    
    // 7. Pengambilan Watak
    final watak = _getWatak(nHari + nPasaran);
    
    return WetonResult(
      namaHari: hari,
      namaPasaran: pasaran,
      neptuHari: nHari,
      neptuPasaran: nPasaran,
      watak: watak,
    );
  }
}
