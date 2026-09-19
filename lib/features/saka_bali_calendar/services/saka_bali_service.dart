/// ============================================================================
/// FILE: lib/features/saka_bali_calendar/services/saka_bali_service.dart
/// FUNGSI: Service Utility untuk Perhitungan Kalender Saka Bali & Pawukon.
/// MANAJEMEN HANDLES: Negative modulo bug, Pawukon Cycle, Saka Approximation.
/// ============================================================================

class SakaBaliResult {
  final int tahunSaka;
  final String sasih;
  final String wuku;
  final String triwara;
  final String sadwara;
  final String saptawara;
  final String pancawara;
  final String? rahinan;

  SakaBaliResult({
    required this.tahunSaka,
    required this.sasih,
    required this.wuku,
    required this.triwara,
    required this.sadwara,
    required this.saptawara,
    required this.pancawara,
    this.rahinan,
  });
}

class SakaBaliService {
  static const List<String> _wukuList = [
    'Sinta', 'Landep', 'Ukir', 'Kurantil', 'Talu', 'Gumbreg', 'Wariga', 'Warigadean',
    'Julungwangi', 'Sungsang', 'Dungulan', 'Kuningan', 'Langkir', 'Medangsia', 'Pujut',
    'Pahang', 'Krulut', 'Merakih', 'Tambir', 'Medangkungan', 'Matal', 'Uye', 'Menail',
    'Prangbakat', 'Bala', 'Ugu', 'Wayang', 'Kelawu', 'Dukut', 'Watugunung'
  ];

  static const List<String> _triwara = ['Pasah', 'Beteng', 'Kajeng'];
  static const List<String> _sadwara = ['Tungleh', 'Aryang', 'Urukung', 'Paniron', 'Was', 'Maulu'];
  static const List<String> _saptawara = ['Redite', 'Soma', 'Anggara', 'Buda', 'Wrespati', 'Sukra', 'Saniscara'];
  static const List<String> _pancawara = ['Umanis', 'Paing', 'Pon', 'Wage', 'Kliwon'];

  // Aproksimasi Kasar Sasih Masehi (Bulan 1-12)
  static const List<String> _sasihList = [
    'Kapitu', 'Kawalu', 'Kasanga', 'Kedasa', 'Jyestha', 'Sadha',
    'Kasa', 'Karo', 'Katiga', 'Kapat', 'Kalima', 'Kanem'
  ];

  /// Menghitung kalender Bali dari Tanggal Masehi
  static SakaBaliResult hitungSakaBali(DateTime inputDate) {
    // 1. Time Stripping & UTC
    final targetDate = DateTime.utc(inputDate.year, inputDate.month, inputDate.day);
    
    // 2. Anchor Date: 16 Januari 2022 = Redite Paing Sinta (Day 0 siklus 210)
    final anchorDate = DateTime.utc(2022, 1, 16);
    
    // 3. Selisih Hari & Modulo 210 positif
    final diffDays = targetDate.difference(anchorDate).inDays;
    final dayIndex = ((diffDays % 210) + 210) % 210;

    // 4. Kalkulasi Pawukon (Wuku, Wewaran)
    final wukuIndex = dayIndex ~/ 7;
    final wuku = _wukuList[wukuIndex];

    final triwara = _triwara[dayIndex % 3];
    final sadwara = _sadwara[dayIndex % 6];
    final saptawara = _saptawara[dayIndex % 7];
    // Karena Redite Sinta = Paing (Index 1), geser +1
    final pancawara = _pancawara[(dayIndex + 1) % 5];

    // 5. Kalkulasi Aproksimasi Tahun Saka & Sasih (Nyepi di Maret)
    int tahunSaka = targetDate.year - 78;
    if (targetDate.month < 3) {
      tahunSaka = targetDate.year - 79;
    } else if (targetDate.month == 3 && targetDate.day < 20) {
      tahunSaka = targetDate.year - 79;
    }
    
    final sasih = _sasihList[targetDate.month - 1];

    // 6. Cek Rahinan Khusus (Fixed on Pawukon 210 days)
    String? rahinan;
    switch (dayIndex) {
      case 0: rahinan = 'Banyu Pinaruh (Redite Paing Sinta)'; break;
      case 1: rahinan = 'Soma Ribek (Soma Pon Sinta)'; break;
      case 2: rahinan = 'Sabuh Mas (Anggara Wage Sinta)'; break;
      case 3: rahinan = 'Pagerwesi (Buda Kliwon Sinta)'; break;
      case 73: rahinan = 'Hari Raya Galungan (Buda Kliwon Dungulan)'; break;
      case 83: rahinan = 'Hari Raya Kuningan (Saniscara Kliwon Kuningan)'; break;
      case 209: rahinan = 'Hari Raya Saraswati (Saniscara Umanis Watugunung)'; break;
    }

    return SakaBaliResult(
      tahunSaka: tahunSaka,
      sasih: sasih,
      wuku: wuku,
      triwara: triwara,
      sadwara: sadwara,
      saptawara: saptawara,
      pancawara: pancawara,
      rahinan: rahinan,
    );
  }
}
