Berikut adalah super prompt untuk melampirkan seluruh Source Code aplikasi OneForAll ke dalam laporan akhir Anda.

Silakan copy seluruh teks di bawah ini dan masukkan ke Gemini di Google Docs (atau gunakan sebagai file Markdown langsung).

=================================================

Bertindaklah sebagai asisten pembuat dokumen teknis. Tugas Anda adalah memformat daftar kode sumber (source code) di bawah ini menjadi sebuah Bab 'Lampiran Kode Sumber' yang sangat rapi untuk laporan akademis. Berikan Heading yang jelas untuk setiap path/nama file, lalu tampilkan kodenya di dalam format Code Block yang terstruktur.

--- KUMPULAN SOURCE CODE APLIKASI ONEFORALL ---


### File: lib\kalkulator_logic.dart
```dart
// lib/kalkulator_logic.dart
import 'services/calculator_service.dart';

export 'models/big_decimal.dart';
export 'models/calculation_result.dart';
export 'services/calculator_service.dart';

typedef Kalkulator = KalkulatorService;
```


### File: lib\main.dart
```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/database/supabase_config.dart';
import 'core/session/session_manager.dart';
import 'core/session/session_listener.dart';
import 'features/auth/views/login_view.dart';
import 'features/main_navigation/views/main_navigation_view.dart';

export 'features/calculator/models/big_decimal.dart';
export 'features/calculator/models/calculation_result.dart';
export 'features/calculator/services/calculator_service.dart';
export 'features/auth/views/login_view.dart';
export 'features/main_navigation/views/main_navigation_view.dart';
export 'features/calculator/views/calculator_view.dart';
export 'features/odd_even/views/odd_even_view.dart';
export 'features/statistics/views/statistics_view.dart';
export 'features/team/views/team_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase Online Cloud Database
  await SupabaseConfig.loadConfig();
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  } catch (e) {
    debugPrint('âš ï¸ Supabase Initialize Warning: $e');
  }

  // Inisialisasi Persistent Session dari SharedPreferences
  await SessionManager().initSession();

  runApp(const AplikasiKalkulatorKece());
}

class AplikasiKalkulatorKece extends StatelessWidget {
  const AplikasiKalkulatorKece({super.key});

  @override
  Widget build(BuildContext context) {
    final bool sessionActive = SessionManager().isSessionValid();

    return SessionListener(
      child: MaterialApp(
        title: 'Aplikasi Tugas 2 Super',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: sessionActive ? const MainNavigationView() : const LoginView(),
      ),
    );
  }
}

```


### File: lib\core\database\supabase_config.dart
```dart
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
        print('âŒ Test Supabase connection error: $e');
      }
      rethrow;
    }
  }
}

```


### File: lib\core\services\storage_service.dart
```dart
/// ============================================================================
/// FILE: lib/core/services/storage_service.dart
/// FUNGSI: Mengelola proses upload foto ke Supabase Storage (Bucket 'avatars')
///         serta pembaruan avatar_url di tabel users.
/// MANAJEMEN HANDLES: Upload file, validasi tipe & ukuran, cleanup file lama.
/// ============================================================================

import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String bucketName = 'avatars';
  static const int maxFileSizeInBytes = 2 * 1024 * 1024; // 2 MB

  /// Mengunggah avatar, menghapus yang lama jika ada, lalu meng-update tabel users.
  Future<String?> uploadAvatar({
    required int userId,
    required Uint8List fileBytes,
    required String fileName,
    required String oldAvatarUrl,
  }) async {
    try {
      // 1. Validasi Ukuran File (Maksimal 2 MB)
      if (fileBytes.lengthInBytes > maxFileSizeInBytes) {
        throw Exception("Ukuran gambar terlalu besar (Maksimal 2 MB)");
      }

      // 2. Validasi Ekstensi/MIME type sederhana
      final String path = fileName.toLowerCase();
      if (!path.endsWith('.jpg') &&
          !path.endsWith('.jpeg') &&
          !path.endsWith('.png') &&
          !path.endsWith('.webp')) {
        throw Exception("Format file tidak didukung (Hanya JPG, PNG, WEBP)");
      }

      // 3. Hapus foto lama di bucket (jika ada) untuk menghemat storage
      if (oldAvatarUrl.isNotEmpty) {
        try {
          // Asumsi oldAvatarUrl adalah public url: 
          // https://[project_id].supabase.co/storage/v1/object/public/avatars/user_1_12345.jpg
          // Kita butuh mengambil relative path-nya saja, yakni nama file-nya.
          final uri = Uri.parse(oldAvatarUrl);
          final pathSegments = uri.pathSegments;
          // Segment format: [storage, v1, object, public, avatars, nama_file.jpg]
          final index = pathSegments.indexOf(bucketName);
          if (index != -1 && index + 1 < pathSegments.length) {
            final fileObj = pathSegments.skip(index + 1).join('/');
            if (fileObj.isNotEmpty) {
              await _client.storage.from(bucketName).remove([fileObj]);
            }
          }
        } catch (e) {
          debugPrint("Gagal menghapus avatar lama (mungkin sudah hilang): $e");
        }
      }

      // 4. Unggah foto baru dengan penamaan unik
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ext = path.split('.').last;
      final newFileName = 'user_${userId}_$timestamp.$ext';

      await _client.storage.from(bucketName).uploadBinary(
            newFileName,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      // 5. Dapatkan Public URL
      final publicUrl = _client.storage.from(bucketName).getPublicUrl(newFileName);

      // 6. Update tabel 'users' kolom 'avatar_url'
      await _client
          .from('users')
          .update({'avatar_url': publicUrl})
          .eq('id', userId);

      return publicUrl;
    } catch (e) {
      debugPrint("StorageService error: $e");
      rethrow;
    }
  }
}

```


### File: lib\core\session\session_listener.dart
```dart
/// ============================================================================
/// FILE: lib/core/session/session_listener.dart
/// FUNGSI: Wrapper Widget untuk mendeteksi interaksi/gestur user di seluruh aplikasi.
/// MANAJEMEN HANDLES: FR-U-06 (Session Management Inactivity Reset)
/// LOKASI LOGIC: Membungkus MaterialApp atau Screen utama dengan Listener/GestureDetector
///               agar setiap sentuhan/klikan otomatis mereset timer session 1 jam.
/// ============================================================================

import 'package:flutter/material.dart';
import 'session_manager.dart';

class SessionListener extends StatelessWidget {
  final Widget child;

  const SessionListener({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        // Reset timer inaktivitas session setiap kali layar disentuh
        SessionManager().resetInactivityTimer();
      },
      child: child,
    );
  }
}

```


### File: lib\core\session\session_manager.dart
```dart
/// ============================================================================
/// FILE: lib/core/session/session_manager.dart
/// FUNGSI: Mengelola Persistent Session pengguna & Timer Inaktivitas 1 Jam (Auto Logout).
/// MANAJEMEN HANDLES: FR-U-06 (Session Management Auto-logout 1 jam inaktif & Persistence)
/// LOKASI LOGIC: Penyimpanan session di SharedPreferences, reset timer inaktivitas,
///               pemeriksaan status login saat startup, & handler auto-logout.
/// ============================================================================

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  // Durasi timeout inaktivitas: 1 Jam (60 menit)
  static const Duration sessionTimeout = Duration(hours: 1);

  // Key SharedPreferences
  static const String keyUserId = 'session_user_id';
  static const String keyUsername = 'session_username';
  static const String keyEmail = 'session_email';
  static const String keyBirthDate = 'session_birth_date';
  static const String keyAvatarUrl = 'session_avatar_url';
  static const String keyLastActivity = 'session_last_activity';

  Timer? _inactivityTimer;
  DateTime? _lastActivityTime;
  Map<String, dynamic>? _currentUser;

  /// Callback yang dipanggil ketika session expired (auto-logout)
  void Function()? onSessionExpired;

  /// Inisialisasi session dari SharedPreferences saat aplikasi pertama kali dibuka
  Future<bool> initSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(keyUserId);
    final username = prefs.getString(keyUsername);
    final email = prefs.getString(keyEmail);
    final birthDateStr = prefs.getString(keyBirthDate);
    final avatarUrlStr = prefs.getString(keyAvatarUrl);
    final lastActivityMs = prefs.getInt(keyLastActivity);

    if (userId != null && username != null && lastActivityMs != null) {
      final lastActivity = DateTime.fromMillisecondsSinceEpoch(lastActivityMs);
      final isExpired = DateTime.now().difference(lastActivity) > sessionTimeout;

      if (!isExpired) {
        _currentUser = {
          'id': userId,
          'username': username,
          'email': email ?? '',
          'birth_date': birthDateStr ?? '',
          'avatar_url': avatarUrlStr ?? '',
        };
        _lastActivityTime = DateTime.now();
        resetInactivityTimer();
        return true;
      } else {
        await clearSession();
        return false;
      }
    }
    return false;
  }

  /// Inisialisasi session baru setelah pengguna berhasil Login/Registrasi
  Future<void> startSession(Map<String, dynamic> user) async {
    _currentUser = user;
    _lastActivityTime = DateTime.now();

    final prefs = await SharedPreferences.getInstance();
    if (user['id'] != null) await prefs.setInt(keyUserId, user['id'] as int);
    await prefs.setString(keyUsername, user['username'].toString());
    if (user['email'] != null) await prefs.setString(keyEmail, user['email'].toString());
    if (user['birth_date'] != null) {
      await prefs.setString(keyBirthDate, user['birth_date'].toString());
    }
    if (user['avatar_url'] != null) {
      await prefs.setString(keyAvatarUrl, user['avatar_url'].toString());
    }
    await prefs.setInt(keyLastActivity, _lastActivityTime!.millisecondsSinceEpoch);

    resetInactivityTimer();
  }

  /// Mereset timer inaktivitas setiap ada interaksi gestur pengguna
  void resetInactivityTimer() {
    if (_currentUser == null) return;
    _lastActivityTime = DateTime.now();
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(sessionTimeout, _handleSessionTimeout);

    // Update timestamp inaktivitas di SharedPreferences
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt(keyLastActivity, _lastActivityTime!.millisecondsSinceEpoch);
    });
  }

  /// Handler internal saat timer inaktivitas 1 jam habis
  void _handleSessionTimeout() async {
    await clearSession();
    if (onSessionExpired != null) {
      onSessionExpired!();
    }
  }

  /// Memeriksa apakah session aktif dan belum expired (>1 jam)
  bool isSessionValid() {
    if (_currentUser == null || _lastActivityTime == null) return false;
    final isExpired = DateTime.now().difference(_lastActivityTime!) > sessionTimeout;
    return !isExpired;
  }

  /// Menghapus data session (Logout)
  Future<void> clearSession() async {
    _inactivityTimer?.cancel();
    _currentUser = null;
    _lastActivityTime = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyUserId);
    await prefs.remove(keyUsername);
    await prefs.remove(keyEmail);
    await prefs.remove(keyBirthDate);
    await prefs.remove(keyAvatarUrl);
    await prefs.remove(keyLastActivity);
  }

  /// Update avatar URL secara real-time
  Future<void> updateAvatarUrl(String url) async {
    if (_currentUser != null) {
      _currentUser!['avatar_url'] = url;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyAvatarUrl, url);
    }
  }

  /// Getter user aktif yang sedang login
  Map<String, dynamic>? get currentUser => _currentUser;
}

```


### File: lib\core\theme\app_theme.dart
```dart
/// ============================================================================
/// FILE: lib/core/theme/app_theme.dart
/// FUNGSI: Mengatur Tema Visual, Skema Warna, Tipografi, & Style Komponen Aplikasi.
/// MANAJEMEN HANDLES: Global UI System & Aesthetic Design
/// LOKASI LOGIC: Pengaturan ThemeData (Light & Dark Theme), Color Scheme Material 3,
///               serta kustomisasi tombol, input field, dan card.
/// ============================================================================

import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6C5CE7);
  static const Color secondaryColor = Color(0xFFA29BFE);
  static const Color accentColor = Color(0xFF00CEC9);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;
  static const Color darkBackgroundColor = Color(0xFF1E1E2E);
  static const Color darkCardColor = Color(0xFF2D2D44);

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: cardColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF3F4F6),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF2D3436),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3436),
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        shadowColor: primaryColor.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: cardColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        labelStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: darkCardColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: darkCardColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF252538),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF3F3F5F), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF3F3F5F), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: secondaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
    );
  }
}

```


### File: lib\core\utils\date_formatter.dart
```dart
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

```


### File: lib\features\age_calculator\services\age_calculator_service.dart
```dart
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

```


### File: lib\features\age_calculator\views\age_calculator_view.dart
```dart
/// ============================================================================
/// FILE: lib/features/age_calculator/views/age_calculator_view.dart
/// FUNGSI: Tampilan Kalkulator Umur Detail (Tahun, Bulan, Hari, Jam, Menit, Detik).
/// MANAJEMEN HANDLES: FR-T2-06 (Konversi Tanggal Lahir ke Umur Detail, default = birth_date user)
/// LOKASI LOGIC: Tempat penulisan kalkulasi selisih DateTime.now() dengan tanggal lahir user,
///               serta timer update real-time detik/jam umur.
/// ============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/session/session_manager.dart';
import '../services/age_calculator_service.dart';

class AgeCalculatorView extends StatefulWidget {
  const AgeCalculatorView({super.key});

  @override
  State<AgeCalculatorView> createState() => _AgeCalculatorViewState();
}

class _AgeCalculatorViewState extends State<AgeCalculatorView> {
  DateTime _birthDate = DateTime(2000, 1, 1);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Handles FR-T2-06: Default input dari birth_date user di Session/DB
    final user = SessionManager().currentUser;
    if (user != null && user['birth_date'] != null) {
      final dbDate = user['birth_date'] is DateTime 
          ? user['birth_date'] 
          : DateTime.tryParse(user['birth_date'].toString());
      if (dbDate != null) {
        // Handle timezone offset (bug prevention)
        _birthDate = dbDate.toLocal();
      }
    }

    // Memulai Timer Real-time setiap 1 detik
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {}); // Memicu re-render UI age secara instan
      }
    });
  }

  @override
  void dispose() {
    // Mematikan timer saat berpindah halaman agar tidak Memory Leak
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _pilihTanggalLahir() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(), // Validasi Bug: Tidak boleh tanggal depan
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_birthDate),
      );
      
      if (pickedTime != null) {
        final newDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Validasi: Waktu kombinasi tidak boleh > waktu sekarang
        if (newDate.isAfter(DateTime.now())) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tanggal lahir tidak boleh melebihi waktu saat ini!'),
                backgroundColor: Colors.red,
              )
            );
          }
          return; // Batalkan
        }

        setState(() {
          _birthDate = newDate;
        });
      }
    }
  }

  Widget _buildAgeBox(String value, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ageMap = AgeCalculatorService.calculateAge(_birthDate);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Umur Anda'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                title: const Text('Tanggal Lahir (Default: Info Akun)', style: TextStyle(fontSize: 13, color: Colors.grey)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    DateFormat('dd MMMM yyyy, HH:mm').format(_birthDate),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                trailing: const Icon(Icons.edit_calendar, size: 30),
                onTap: _pilihTanggalLahir,
              ),
            ),
            const SizedBox(height: 32),
            
            const Text(
              'Umur Akurat Anda:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
              children: [
                _buildAgeBox(ageMap['years'].toString(), 'Tahun', Colors.purple),
                _buildAgeBox(ageMap['months'].toString(), 'Bulan', Colors.blue),
                _buildAgeBox(ageMap['days'].toString(), 'Hari', Colors.teal),
                _buildAgeBox(ageMap['hours'].toString(), 'Jam', Colors.orange),
                _buildAgeBox(ageMap['minutes'].toString(), 'Menit', Colors.brown),
                _buildAgeBox(ageMap['seconds'].toString(), 'Detik', Colors.red),
              ],
            ),
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Umur Anda saat ini adalah ${ageMap['years']} Tahun, ${ageMap['months']} Bulan, ${ageMap['days']} Hari, ${ageMap['hours']} Jam, ${ageMap['minutes']} Menit, dan ${ageMap['seconds']} Detik.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onPrimaryContainer,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

```


### File: lib\features\auth\models\user_model.dart
```dart
/// ============================================================================
/// FILE: lib/features/auth/models/user_model.dart
/// FUNGSI: Model data representasi tabel `users` Supabase.
/// MANAJEMEN HANDLES: Struktur Data Autentikasi Pengguna
/// LOKASI LOGIC: Menyimpan informasi userId, username, password, email, tanggal lahir,
///               serta method toMap() dan fromMap() untuk query Supabase.
/// ============================================================================

class UserModel {
  final int? id;
  final String username;
  final String password;
  final String email;
  final DateTime birthDate;
  final DateTime? createdAt;

  UserModel({
    this.id,
    required this.username,
    required this.password,
    required this.email,
    required this.birthDate,
    this.createdAt,
  });

  /// Mengubah Map dari hasil query Supabase ke objek UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      username: map['username'] as String,
      password: map['password'] as String,
      email: map['email'] as String,
      birthDate: map['birth_date'] is DateTime 
          ? map['birth_date'] 
          : DateTime.parse(map['birth_date'].toString()),
      createdAt: map['created_at'] != null 
          ? (map['created_at'] is DateTime ? map['created_at'] : DateTime.parse(map['created_at'].toString()))
          : null,
    );
  }

  /// Mengubah objek UserModel ke Map untuk query Supabase INSERT/UPDATE
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
      'birth_date': birthDate.toIso8601String(),
    };
  }
}

```


### File: lib\features\auth\services\auth_service.dart
```dart
/// ============================================================================
/// FILE: lib/features/auth/services/auth_service.dart
/// FUNGSI: Menangani logika autentikasi (Login & Registrasi) via Supabase Client.
/// MANAJEMEN HANDLES: FR-U-01 (Login) & FR-U-02 (Registrasi User ke Cloud Supabase)
/// LOKASI LOGIC: Supabase Client Direct Table Access (`Supabase.instance.client.from('users')`)
///               sehingga Flutter Web di Chrome dapat login & registrasi secara online & bebas CORS.
/// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthResult {
  final bool success;
  final String? errorMessage;
  final UserModel? user;

  AuthResult({
    required this.success,
    this.errorMessage,
    this.user,
  });
}

class AuthService {

  /// Helper Hashing Password SHA-256
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  /// Handles FR-U-01: Login User (Online Supabase Cloud)
  Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    final trimmedUsername = username.trim();
    if (trimmedUsername.isEmpty || password.isEmpty) {
      return AuthResult(
        success: false,
        errorMessage: 'Username dan Password tidak boleh kosong.',
      );
    }

    final hashedPassword = hashPassword(password);

    // 1. Coba via Online Supabase Client (Sangat cocok untuk Flutter Web / Chrome)
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('users')
          .select()
          .eq('username', trimmedUsername)
          .maybeSingle();

      if (response != null) {
        final dbPassword = response['password']?.toString() ?? '';
        // Cocokkan password (baik hashed SHA-256 maupun plaintext legacy)
        if (dbPassword == hashedPassword || dbPassword == password) {
          final user = UserModel.fromMap(response);
          return AuthResult(success: true, user: user);
        } else {
          return AuthResult(
            success: false,
            errorMessage: 'Password yang Anda masukkan salah!',
          );
        }
      } else {
        return AuthResult(
          success: false,
          errorMessage: 'Username "$trimmedUsername" tidak ditemukan!',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('â„¹ï¸ Supabase Login Error: $e');
      }
      if (e.toString().contains('YOUR_SUPABASE_PROJECT_ID') || e.toString().contains('Invalid API key')) {
        return AuthResult(
          success: false,
          errorMessage: 'Kredensial Supabase belum diisi! Masukkan SUPABASE_URL dan SUPABASE_ANON_KEY di supabase_config.dart',
        );
      }
    }

    return AuthResult(
      success: false,
      errorMessage: 'Gagal Login. Pastikan koneksi internet aktif dan Supabase URL/Key sudah terkonfigurasi.',
    );
  }

  /// Handles FR-U-02: Registrasi User Baru ke Supabase Cloud
  Future<AuthResult> register(UserModel user) async {
    final trimmedUsername = user.username.trim();
    final trimmedEmail = user.email.trim();

    if (trimmedUsername.isEmpty || user.password.isEmpty || trimmedEmail.isEmpty) {
      return AuthResult(
        success: false,
        errorMessage: 'Seluruh field registrasi wajib diisi.',
      );
    }

    final birthDateStr = user.birthDate.toIso8601String().split('T').first;
    final hashedPassword = hashPassword(user.password);

    // 1. Coba registrasi via Supabase Client
    try {
      final supabase = Supabase.instance.client;

      // Cek apakah username atau email sudah terdaftar
      final existingUser = await supabase
          .from('users')
          .select('id, username, email')
          .or('username.eq.$trimmedUsername,email.eq.$trimmedEmail')
          .maybeSingle();

      if (existingUser != null) {
        final existingUsername = existingUser['username']?.toString();
        final existingEmail = existingUser['email']?.toString();
        if (existingUsername?.toLowerCase() == trimmedUsername.toLowerCase()) {
          return AuthResult(
            success: false,
            errorMessage: 'Username "$trimmedUsername" sudah digunakan!',
          );
        }
        if (existingEmail?.toLowerCase() == trimmedEmail.toLowerCase()) {
          return AuthResult(
            success: false,
            errorMessage: 'Email "$trimmedEmail" sudah terdaftar!',
          );
        }
      }

      // Insert ke tabel users Supabase
      final insertedRows = await supabase.from('users').insert({
        'username': trimmedUsername,
        'password': hashedPassword,
        'email': trimmedEmail,
        'birth_date': birthDateStr,
      }).select();

      if (insertedRows.isNotEmpty) {
        final createdUser = UserModel.fromMap(insertedRows.first);
        return AuthResult(success: true, user: createdUser);
      }
    } catch (e) {
      if (kDebugMode) {
        print('â„¹ï¸ Supabase Register Error: $e');
      }
      if (e.toString().contains('YOUR_SUPABASE_PROJECT_ID') || e.toString().contains('Invalid API key')) {
        return AuthResult(
          success: false,
          errorMessage: 'Kredensial Supabase belum diisi di supabase_config.dart!',
        );
      }
      return AuthResult(
        success: false,
        errorMessage: 'Gagal registrasi di Supabase: ${e.toString()}',
      );
    }

    return AuthResult(
      success: false,
      errorMessage: 'Gagal mendaftar ke database. Pastikan koneksi internet aktif.',
    );
  }
}

```


### File: lib\features\auth\views\login_view.dart
```dart
/// ============================================================================
/// FILE: lib/features/auth/views/login_view.dart
/// FUNGSI: Tampilan Halaman Login Pengguna & Tool Diagnosa/Setting Database Supabase.
/// MANAJEMEN HANDLES: FR-U-01 (Tampilan & Form Login Pengguna)
/// LOKASI LOGIC: Input Username & Password, validasi Kredensial Supabase,
///               penyimpanan Session (FR-U-06), & Dialog Setting/Tes Koneksi Database.
/// ============================================================================

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../../../core/database/supabase_config.dart';
import '../../../core/session/session_manager.dart';
import '../../main_navigation/views/main_navigation_view.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  void _prosesLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final result = await _authService.login(
      username: username,
      password: password,
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (result.success && result.user != null) {
      // Handles FR-U-06: Simpan Session User
      await SessionManager().startSession(result.user!.toMap());

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationView()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(result.errorMessage ?? 'Gagal login.')),
            ],
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _bukaModalPengaturanDatabase() async {
    await SupabaseConfig.loadConfig();

    final supabaseUrlCtrl = TextEditingController(text: SupabaseConfig.url);
    final supabaseAnonKeyCtrl = TextEditingController(text: SupabaseConfig.anonKey);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        bool testingSupabase = false;
        String? testMessage;
        bool? testSuccess;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cloud_sync, color: Color(0xFF6C5CE7), size: 28),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Pengaturan Koneksi Database',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Kelola Kredensial Supabase Cloud Anda.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // SECTION 1: SUPABASE CLOUD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5CE7).withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF6C5CE7).withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.bolt, color: Color(0xFF6C5CE7)),
                              const SizedBox(width: 8),
                              const Text(
                                'ONLINE SUPABASE CLOUD (Cloud Database)',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF6C5CE7)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: supabaseUrlCtrl,
                            decoration: const InputDecoration(
                              labelText: 'SUPABASE URL',
                              hintText: 'https://xyz.supabase.co',
                              prefixIcon: Icon(Icons.link),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: supabaseAnonKeyCtrl,
                            decoration: const InputDecoration(
                              labelText: 'SUPABASE ANON KEY (Public Key)',
                              hintText: 'eyJhbGciOi...',
                              prefixIcon: Icon(Icons.key),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 44,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C5CE7),
                                foregroundColor: Colors.white,
                              ),
                              icon: testingSupabase
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.cloud_done),
                              label: Text(testingSupabase ? 'Menguji Supabase...' : 'TES & SIMPAN KONEKSI SUPABASE'),
                              onPressed: testingSupabase
                                  ? null
                                  : () async {
                                      setModalState(() {
                                        testingSupabase = true;
                                        testMessage = null;
                                      });

                                      try {
                                        final ok = await SupabaseConfig.testConnection(
                                          testUrl: supabaseUrlCtrl.text,
                                          testAnonKey: supabaseAnonKeyCtrl.text,
                                        );
                                        await SupabaseConfig.saveConfig(
                                          url: supabaseUrlCtrl.text,
                                          anonKey: supabaseAnonKeyCtrl.text,
                                        );

                                        setModalState(() {
                                          testingSupabase = false;
                                          testSuccess = ok;
                                          testMessage = 'âœ… KONEKSI SUPABASE BERHASIL! Cloud Database terhubung.';
                                        });
                                      } catch (e) {
                                        setModalState(() {
                                          testingSupabase = false;
                                          testSuccess = false;
                                          testMessage = 'âŒ GAGAL KONEKSI SUPABASE: $e';
                                        });
                                      }
                                    },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (testMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: testSuccess == true ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: testSuccess == true ? Colors.green : Colors.redAccent,
                          ),
                        ),
                        child: Text(
                          testMessage!,
                          style: TextStyle(
                            fontSize: 13,
                            color: testSuccess == true ? Colors.green.shade900 : Colors.red.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Aplikasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_ethernet),
            tooltip: 'Pengaturan Koneksi Supabase & Database',
            onPressed: _bukaModalPengaturanDatabase,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.lock_person, size: 64, color: Color(0xFF6C5CE7)),
                      const SizedBox(height: 16),
                      const Text(
                        'Selamat Datang',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Silakan masuk dengan akun Anda untuk melanjutkan',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Username wajib diisi.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Password wajib diisi.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _prosesLogin,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : const Text('MASUK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text('Belum punya akun?'),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegisterView()),
                              );
                            },
                            child: const Text('Daftar Akun', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

```


### File: lib\features\auth\views\register_view.dart
```dart
/// ============================================================================
/// FILE: lib/features/auth/views/register_view.dart
/// FUNGSI: Tampilan Halaman Registrasi Pengguna Baru.
/// MANAJEMEN HANDLES: FR-U-02 (Tampilan & Form Registrasi User ke Supabase)
/// LOKASI LOGIC: Input Username, Email, Password, DatePicker Tanggal Lahir,
///               validasi form, dan pemanggilan AuthService.register().
/// ============================================================================

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../../../core/utils/date_formatter.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();

  DateTime _selectedBirthDate = DateTime(2002, 1, 1);
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _pilihTanggalLahir() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  void _prosesRegistrasi() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final newUser = UserModel(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      email: _emailController.text.trim(),
      birthDate: _selectedBirthDate,
    );

    final result = await _authService.register(newUser);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Registrasi berhasil! Silakan login.'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Kembali ke LoginScreen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(result.errorMessage ?? 'Gagal mendaftar.')),
            ],
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrasi Akun Baru'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.person_add, size: 54, color: Color(0xFF6C5CE7)),
                      const SizedBox(height: 12),
                      const Text(
                        'Buat Akun Baru',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Buat akun baru untuk mulai menggunakan aplikasi',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Username wajib diisi.';
                          if (val.trim().length < 3) return 'Username minimal 3 karakter.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Email wajib diisi.';
                          final emailStr = val.trim();
                          if (emailStr.contains(' ')) return 'Alamat email tidak valid atau mengandung karakter terlarang';
                          final forbiddenPattern = RegExp(r'[:;()\[\]\"/\\<>?=+,\s]');
                          if (forbiddenPattern.hasMatch(emailStr)) return 'Alamat email tidak valid atau mengandung karakter terlarang';
                          if (!emailStr.contains('@')) return 'Format email tidak valid.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Password wajib diisi.';
                          if (val.contains(' ')) return 'Password minimal 8 karakter, kombinasi huruf besar, huruf kecil, angka, dan simbol tanpa spasi';
                          if (val.length < 8) return 'Password minimal 8 karakter, kombinasi huruf besar, huruf kecil, angka, dan simbol tanpa spasi';
                          if (!RegExp(r'[A-Z]').hasMatch(val) || !RegExp(r'[a-z]').hasMatch(val) || !RegExp(r'[0-9]').hasMatch(val) || !RegExp(r'[^a-zA-Z0-9\s]').hasMatch(val)) {
                            return 'Password minimal 8 karakter, kombinasi huruf besar, huruf kecil, angka, dan simbol tanpa spasi';
                          }
                          const blacklist = ['12345678', 'password', 'qwerty', '123456789', 'admin123'];
                          if (blacklist.contains(val.toLowerCase())) {
                            return 'Password minimal 8 karakter, kombinasi huruf besar, huruf kecil, angka, dan simbol tanpa spasi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _pilihTanggalLahir,
                        borderRadius: BorderRadius.circular(16),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Tanggal Lahir',
                            prefixIcon: Icon(Icons.cake),
                          ),
                          child: Text(
                            DateFormatter.formatDateIndonesia(_selectedBirthDate),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _prosesRegistrasi,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : const Text('DAFTAR AKUN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

```


### File: lib\features\calculator\models\big_decimal.dart
```dart
/// ============================================================================
/// FILE: lib/features/calculator/models/big_decimal.dart
/// FUNGSI: Class high-precision decimal yang didukung oleh BigInt native Dart.
/// MANAJEMEN HANDLES: Model untuk FR-T1-01 (Big Integer / High Precision Arithmetic)
/// LOKASI LOGIC: Operasi aritmatika presisi tinggi (+, -, *, /) tanpa overflow.
/// ============================================================================

class BigDecimal implements Comparable<BigDecimal> {
  final BigInt _unscaled;
  final int _scale;

  BigDecimal._(this._unscaled, this._scale);

  factory BigDecimal(BigInt unscaled, int scale) {
    if (unscaled == BigInt.zero) {
      return BigDecimal._(BigInt.zero, 0);
    }
    int currentScale = scale;
    BigInt currentUnscaled = unscaled;

    while (currentScale > 0 && (currentUnscaled % BigInt.from(10) == BigInt.zero)) {
      currentUnscaled = currentUnscaled ~/ BigInt.from(10);
      currentScale--;
    }

    return BigDecimal._(currentUnscaled, currentScale);
  }

  static final BigDecimal zero = BigDecimal._(BigInt.zero, 0);
  static final BigDecimal one = BigDecimal._(BigInt.one, 0);

  factory BigDecimal.fromInt(int value) => BigDecimal(BigInt.from(value), 0);
  factory BigDecimal.fromBigInt(BigInt value) => BigDecimal(value, 0);

  BigInt get unscaled => _unscaled;
  int get scale => _scale;

  bool get isZero => _unscaled == BigInt.zero;
  bool get isNegative => _unscaled < BigInt.zero;

  bool get isInteger {
    if (_scale == 0) return true;
    BigInt divisor = _pow10(_scale);
    return (_unscaled % divisor) == BigInt.zero;
  }

  BigInt toBigInt() {
    if (_scale == 0) return _unscaled;
    return _unscaled ~/ _pow10(_scale);
  }

  static BigDecimal? tryParse(String input) {
    String str = input.trim();
    if (str.isEmpty) return null;

    if (str.contains(',') && str.contains('.')) {
      str = str.replaceAll(',', '');
    } else if (str.contains(',')) {
      str = str.replaceAll(',', '.');
    }

    int eIndex = str.indexOf(RegExp(r'[eE]'));
    int exponentShift = 0;
    if (eIndex != -1) {
      String expStr = str.substring(eIndex + 1);
      str = str.substring(0, eIndex);
      int? expVal = int.tryParse(expStr);
      if (expVal == null) return null;
      exponentShift = expVal;
    }

    bool isNeg = false;
    if (str.startsWith('-')) {
      isNeg = true;
      str = str.substring(1);
    } else if (str.startsWith('+')) {
      str = str.substring(1);
    }

    if (str.isEmpty) return null;

    List<String> parts = str.split('.');
    if (parts.length > 2) return null;

    String intPart = parts[0];
    String decPart = parts.length == 2 ? parts[1] : '';

    if (!RegExp(r'^\d*$').hasMatch(intPart) || !RegExp(r'^\d*$').hasMatch(decPart)) {
      return null;
    }

    if (intPart.isEmpty && decPart.isEmpty) return null;
    if (intPart.isEmpty) intPart = '0';

    int scale = decPart.length - exponentShift;
    String combinedDigits = intPart + decPart;
    BigInt? unscaled = BigInt.tryParse(combinedDigits);
    if (unscaled == null) return null;

    if (isNeg) {
      unscaled = -unscaled;
    }

    if (scale < 0) {
      unscaled = unscaled * _pow10(-scale);
      scale = 0;
    }

    return BigDecimal(unscaled, scale);
  }

  BigDecimal operator +(BigDecimal other) {
    int targetScale = _scale > other._scale ? _scale : other._scale;
    BigInt aScaled = _unscaled * _pow10(targetScale - _scale);
    BigInt bScaled = other._unscaled * _pow10(targetScale - other._scale);
    return BigDecimal(aScaled + bScaled, targetScale);
  }

  BigDecimal operator -(BigDecimal other) {
    int targetScale = _scale > other._scale ? _scale : other._scale;
    BigInt aScaled = _unscaled * _pow10(targetScale - _scale);
    BigInt bScaled = other._unscaled * _pow10(targetScale - other._scale);
    return BigDecimal(aScaled - bScaled, targetScale);
  }

  BigDecimal operator -() {
    return BigDecimal(-_unscaled, _scale);
  }

  BigDecimal operator *(BigDecimal other) {
    return BigDecimal(_unscaled * other._unscaled, _scale + other._scale);
  }

  BigDecimal divide(BigDecimal divisor, {int maxScale = 50}) {
    if (divisor.isZero) {
      throw ArgumentError('Error! Tidak bisa dibagi dengan nol.');
    }

    int requiredScale = (_scale > divisor._scale ? _scale : divisor._scale) + maxScale;
    int shift = requiredScale + divisor._scale - _scale;

    BigInt numerator = _unscaled;
    if (shift >= 0) {
      numerator = numerator * _pow10(shift);
    } else {
      numerator = numerator ~/ _pow10(-shift);
    }

    BigInt resultUnscaled = numerator ~/ divisor._unscaled;
    return BigDecimal(resultUnscaled, requiredScale);
  }

  @override
  int compareTo(BigDecimal other) {
    int targetScale = _scale > other._scale ? _scale : other._scale;
    BigInt aScaled = _unscaled * _pow10(targetScale - _scale);
    BigInt bScaled = other._unscaled * _pow10(targetScale - other._scale);
    return aScaled.compareTo(bScaled);
  }

  bool operator <(BigDecimal other) => compareTo(other) < 0;
  bool operator >(BigDecimal other) => compareTo(other) > 0;
  bool operator <=(BigDecimal other) => compareTo(other) <= 0;
  bool operator >=(BigDecimal other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BigDecimal && compareTo(other) == 0;
  }

  @override
  int get hashCode => Object.hash(_unscaled, _scale);

  @override
  String toString() {
    if (_unscaled == BigInt.zero) return '0';

    bool isNeg = _unscaled < BigInt.zero;
    String digits = (_unscaled.abs()).toString();

    if (_scale == 0) {
      return (isNeg ? '-' : '') + digits;
    }

    if (digits.length <= _scale) {
      String leadingZeroes = '0' * (_scale - digits.length + 1);
      digits = leadingZeroes + digits;
    }

    int splitIndex = digits.length - _scale;
    String intStr = digits.substring(0, splitIndex);
    String decStr = digits.substring(splitIndex);

    return '${isNeg ? '-' : ''}$intStr.$decStr';
  }

  String toFormattedString() {
    String raw = toString();
    if (raw.contains('Exception') || raw.contains('Error')) return raw;

    List<String> parts = raw.split('.');
    String intPart = parts[0];
    String decPart = parts.length > 1 ? parts[1] : '';

    bool isNeg = intPart.startsWith('-');
    if (isNeg) {
      intPart = intPart.substring(1);
    }

    StringBuffer formattedInt = StringBuffer();
    int len = intPart.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) {
        formattedInt.write('.');
      }
      formattedInt.write(intPart[i]);
    }

    String result = '${isNeg ? '-' : ''}$formattedInt';
    if (decPart.isNotEmpty) {
      result += ',$decPart';
    }
    return result;
  }

  static BigInt _pow10(int exponent) {
    if (exponent <= 0) return BigInt.one;
    BigInt base = BigInt.from(10);
    BigInt result = BigInt.one;
    int exp = exponent;
    while (exp > 0) {
      if (exp % 2 == 1) result *= base;
      base *= base;
      exp ~/= 2;
    }
    return result;
  }
}

```


### File: lib\features\calculator\models\calculation_result.dart
```dart
/// ============================================================================
/// FILE: lib/features/calculator/models/calculation_result.dart
/// FUNGSI: Data model pembungkus hasil eksekusi ekspresi matematika kalkulator.
/// MANAJEMEN HANDLES: Model untuk FR-T1-01 (Super Precision Calculator)
/// LOKASI LOGIC: Menyimpan nilai BigDecimal hasil hitungan atau pesan error jika terjadi kegagalan.
/// ============================================================================

import 'big_decimal.dart';

class HasilKalkulasi {
  final BigDecimal? nilai;
  final String? pesanPesanError;
  final bool sukses;

  HasilKalkulasi.sukses(this.nilai)
      : pesanPesanError = null,
        sukses = true;

  HasilKalkulasi.gagal(this.pesanPesanError)
      : nilai = null,
        sukses = false;
}

```


### File: lib\features\calculator\services\calculator_service.dart
```dart
/// ============================================================================
/// FILE: lib/features/calculator/services/calculator_service.dart
/// FUNGSI: Service pengolah ekspresi matematika kalkulator presisi tinggi.
/// MANAJEMEN HANDLES: Service untuk FR-T1-01 (Kalkulator Presisi Big Integer)
/// LOKASI LOGIC: Evaluasi ekspresi aritmatika dengan algoritma shunting-yard / operator precedence,
///               serta penanganan penambahan/penghapusan token input.
/// ============================================================================

import '../models/big_decimal.dart';
import '../models/calculation_result.dart';

class KalkulatorService {
  final List<String> _tokens = [];

  void tambahInput(String input) {
    String trimmed = input.trim();
    if (trimmed.isEmpty) return;

    RegExp tokenRegExp = RegExp(r'(\d+(?:[\.,]\d*)?(?:[eE][+-]?\d+)?|[\+\-\*/\(\)])');
    Iterable<RegExpMatch> matches = tokenRegExp.allMatches(trimmed);

    for (Match m in matches) {
      String item = m.group(0)!;
      _prosesSingleItem(item);
    }
  }

  void _prosesSingleItem(String item) {
    bool isOp = _isOperator(item);
    bool isParen = item == '(' || item == ')';
    BigDecimal? val = BigDecimal.tryParse(item);

    if (isOp) {
      if (_tokens.isEmpty) {
        if (item == '-' || item == '+') {
          _tokens.add('0');
          _tokens.add(item);
        }
      } else if (_isOperator(_tokens.last)) {
        if (item == '-' && (_tokens.last == '*' || _tokens.last == '/')) {
          _tokens.add(item);
        } else {
          if (_tokens.length >= 2 && _isOperator(_tokens[_tokens.length - 2])) {
            _tokens.removeLast();
            _tokens[_tokens.length - 1] = item;
          } else {
            _tokens[_tokens.length - 1] = item;
          }
        }
      } else {
        _tokens.add(item);
      }
    } else if (isParen) {
      _tokens.add(item);
    } else if (val != null) {
      if (_tokens.isNotEmpty && !_isOperator(_tokens.last) && _tokens.last != '(') {
        _tokens.add('+');
      }
      _tokens.add(val.toString());
    }
  }

  bool hapusTerakhir() {
    if (_tokens.isNotEmpty) {
      _tokens.removeLast();
      return true;
    }
    return false;
  }

  void reset() {
    _tokens.clear();
  }

  void setEkspresi(List<String> newTokens) {
    _tokens.clear();
    _tokens.addAll(newTokens);
  }

  bool get apakahKosong => _tokens.isEmpty;

  String get teksEkspresi {
    if (_tokens.isEmpty) return '';
    return _tokens.join(' ');
  }

  HasilKalkulasi hitung() {
    if (_tokens.isEmpty) return HasilKalkulasi.gagal('Ekspresi masih kosong.');

    List<String> expr = List.from(_tokens);
    while (expr.isNotEmpty && _isOperator(expr.last)) {
      expr.removeLast();
    }

    if (expr.isEmpty) return HasilKalkulasi.gagal('Ekspresi belum lengkap.');

    try {
      BigDecimal result = _evaluateTokens(expr);
      return HasilKalkulasi.sukses(result);
    } catch (e) {
      return HasilKalkulasi.gagal(
        e.toString().replaceAll('Exception: ', '').replaceAll('ArgumentError: ', ''),
      );
    }
  }

  static bool _isOperator(String token) {
    return token == '+' || token == '-' || token == '*' || token == '/';
  }

  static int _precedence(String op) {
    if (op == '+' || op == '-') return 1;
    if (op == '*' || op == '/') return 2;
    return 0;
  }

  static BigDecimal _evaluateTokens(List<String> tokens) {
    List<BigDecimal> values = [];
    List<String> ops = [];

    int i = 0;
    while (i < tokens.length) {
      String t = tokens[i];

      if (t == '(') {
        ops.add(t);
        i++;
      } else if (t == ')') {
        while (ops.isNotEmpty && ops.last != '(') {
          _applyOp(values, ops.removeLast());
        }
        if (ops.isEmpty || ops.last != '(') {
          throw const FormatException('Format ekspresi tidak valid (tanda kurung tidak seimbang).');
        }
        ops.removeLast();
        i++;
      } else if (_isOperator(t)) {
        bool isUnary = (i == 0 || _isOperator(tokens[i - 1]) || tokens[i - 1] == '(');
        if (isUnary) {
          if (t == '-') {
            if (i + 1 < tokens.length) {
              BigDecimal? nextVal = BigDecimal.tryParse(tokens[i + 1]);
              if (nextVal != null) {
                values.add(-nextVal);
                i += 2;
                continue;
              }
            }
            values.add(BigDecimal.zero);
          } else if (t == '+') {
            i++;
            continue;
          }
        }

        while (ops.isNotEmpty && ops.last != '(' && _precedence(ops.last) >= _precedence(t)) {
          _applyOp(values, ops.removeLast());
        }
        ops.add(t);
        i++;
      } else {
        BigDecimal? num = BigDecimal.tryParse(t);
        if (num == null) throw FormatException('Angka tidak valid: "$t"');
        values.add(num);
        i++;
      }
    }

    while (ops.isNotEmpty) {
      if (ops.last == '(' || ops.last == ')') {
        throw const FormatException('Format ekspresi tidak valid (tanda kurung tidak seimbang).');
      }
      _applyOp(values, ops.removeLast());
    }

    if (values.length != 1) throw const FormatException('Format ekspresi tidak valid.');
    return values.first;
  }

  static void _applyOp(List<BigDecimal> values, String op) {
    if (values.length < 2) throw const FormatException('Format ekspresi tidak lengkap.');
    BigDecimal b = values.removeLast();
    BigDecimal a = values.removeLast();

    switch (op) {
      case '+':
        values.add(a + b);
        break;
      case '-':
        values.add(a - b);
        break;
      case '*':
        values.add(a * b);
        break;
      case '/':
        if (b.isZero) throw ArgumentError('Error! Tidak bisa dibagi dengan nol.');
        values.add(a.divide(b, maxScale: 50));
        break;
      default:
        throw FormatException('Operator tidak dikenal: "$op"');
    }
  }
}

```


### File: lib\features\calculator\views\calculator_view.dart
```dart
/// ============================================================================
/// FILE: lib/features/calculator/views/calculator_view.dart
/// FUNGSI: Tampilan Halaman Kalkulator Presisi Super (Big Integer).
/// MANAJEMEN HANDLES: FR-T1-01 (Kalkulator Presisi Super Big Integer UI)
/// LOKASI LOGIC: UI Keypad interaktif, input ekspresi matematika kompleks,
///               preview hasil kalkulasi real-time, serta tombol salin hasil.
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/calculation_result.dart';
import '../services/calculator_service.dart';

class ViewKalkulator extends StatefulWidget {
  const ViewKalkulator({super.key});

  @override
  State<ViewKalkulator> createState() => _ViewKalkulatorState();
}

class _ViewKalkulatorState extends State<ViewKalkulator> {
  final KalkulatorService _kalkulator = KalkulatorService();
  final TextEditingController _inputCtrl = TextEditingController();
  String _hasilPreview = '';
  bool _isError = false;

  void _hitungRealtime(String input) {
    _kalkulator.reset();
    _kalkulator.tambahInput(input);

    if (_kalkulator.apakahKosong) {
      setState(() {
        _hasilPreview = '';
        _isError = false;
      });
      return;
    }

    HasilKalkulasi hasil = _kalkulator.hitung();
    setState(() {
      if (hasil.sukses && hasil.nilai != null) {
        _hasilPreview = hasil.nilai!.toFormattedString();
        _isError = false;
      } else {
        _hasilPreview = hasil.pesanPesanError ?? 'Error';
        _isError = true;
      }
    });
  }

  void _onKeypadTap(String val) {
    String current = _inputCtrl.text;
    if (val == 'C') {
      _inputCtrl.clear();
      _hitungRealtime('');
    } else if (val == 'âŒ«') {
      if (current.isNotEmpty) {
        String updated = current.substring(0, current.length - 1);
        _inputCtrl.text = updated;
        _inputCtrl.selection = TextSelection.fromPosition(TextPosition(offset: updated.length));
        _hitungRealtime(updated);
      }
    } else if (val == '=') {
      _hitungRealtime(_inputCtrl.text);
    } else {
      String updated = current + val;
      _inputCtrl.text = updated;
      _inputCtrl.selection = TextSelection.fromPosition(TextPosition(offset: updated.length));
      _hitungRealtime(updated);
    }
  }

  void _salinHasil() {
    if (_hasilPreview.isNotEmpty && !_isError) {
      Clipboard.setData(ClipboardData(text: _hasilPreview.replaceAll('.', '').replaceAll(',', '.')));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Hasil berhasil disalin ke clipboard!'),
            ],
          ),
          backgroundColor: Color(0xFF6C5CE7),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator Presisi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.calculate, color: theme.colorScheme.primary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Kalkulator Presisi Tinggi',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Mendukung angka super besar & ekspresi matematika kompleks',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _inputCtrl,
                        onChanged: _hitungRealtime,
                        keyboardType: TextInputType.text,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9\+\-\*\/\.\(\)\s]')),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Masukkan angka atau ekspresi matematika',
                          labelText: 'Masukkan Ekspresi',
                          suffixIcon: _inputCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _inputCtrl.clear();
                                    _hitungRealtime('');
                                  },
                                )
                              : const Icon(Icons.edit_note),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (_hasilPreview.isNotEmpty) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: _isError
                      ? Card(
                          color: isDark ? Colors.red.shade900.withValues(alpha: 0.4) : Colors.red.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.error_outline, color: isDark ? Colors.red.shade300 : Colors.red.shade700),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Input Tidak Valid',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                SelectableText(
                                  _hasilPreview,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.red.shade200 : Colors.red.shade900,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Card(
                          color: isDark ? Colors.indigo.shade900.withValues(alpha: 0.4) : theme.colorScheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Hasil Kalkulasi:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isDark ? Colors.purpleAccent : theme.colorScheme.primary,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: _salinHasil,
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.copy, size: 14),
                                            SizedBox(width: 4),
                                            Text('Salin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SelectableText(
                                  _hasilPreview,
                                  style: TextStyle(
                                    fontSize: _hasilPreview.length > 30 ? 18 : 26,
                                    fontWeight: FontWeight.bold,
                                    height: 1.3,
                                    color: isDark ? Colors.white : Colors.deepPurple.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 16),
              ],

              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          'Keypad Interaktif',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                      ),
                      _buildKeypadGrid(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildKeypadGrid() {
    final List<List<String>> layout = [
      ['C', '(', ')', '/'],
      ['7', '8', '9', '*'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['0', '.', 'âŒ«', '='],
    ];

    return Column(
      children: layout.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: row.map((btn) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: _buildKeyButton(btn),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeyButton(String text) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    bool isOp = ['+', '-', '*', '/', '='].contains(text);
    bool isAction = ['C', 'âŒ«', '(', ')'].contains(text);

    Color bgColor;
    Color textColor;

    if (text == '=') {
      bgColor = theme.colorScheme.primary;
      textColor = Colors.white;
    } else if (isOp) {
      bgColor = theme.colorScheme.primary.withValues(alpha: 0.15);
      textColor = theme.colorScheme.primary;
    } else if (isAction) {
      bgColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
      textColor = text == 'C' ? Colors.redAccent : (isDark ? Colors.white : Colors.black87);
    } else {
      bgColor = isDark ? const Color(0xFF2A2A3C) : Colors.grey.shade100;
      textColor = isDark ? Colors.white : Colors.black87;
    }

    return SizedBox(
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 1,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: () => _onKeypadTap(text),
        child: Text(
          text,
          style: TextStyle(
            fontSize: text == 'âŒ«' ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

```


### File: lib\features\guide_logout\views\guide_logout_view.dart
```dart
/// ============================================================================
/// FILE: lib/features/guide_logout/views/guide_logout_view.dart
/// FUNGSI: Tampilan Halaman Panduan Penggunaan Aplikasi & Tombol Logout (Tab 3).
/// MANAJEMEN HANDLES: FR-U-04 (Panduan Penggunaan) & FR-U-05 (Tombol Logout)
/// LOKASI LOGIC: Tempat penulisan dokumentasi/petunjuk cara menggunakan setiap fitur aplikasi,
///               serta dialog konfirmasi logout & penghapusan session aktif (Secure Logout).
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/session/session_manager.dart';
import '../../../core/services/storage_service.dart';
import '../../auth/views/login_view.dart';

class GuideLogoutView extends StatefulWidget {
  const GuideLogoutView({super.key});

  @override
  State<GuideLogoutView> createState() => _GuideLogoutViewState();
}

class _GuideLogoutViewState extends State<GuideLogoutView> {
  bool _isUploadingAvatar = false;
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;

      setState(() {
        _isUploadingAvatar = true;
      });

      final user = SessionManager().currentUser;
      if (user == null || user['id'] == null) {
        throw Exception("Session tidak valid");
      }

      final oldUrl = user['avatar_url']?.toString() ?? '';
      final bytes = await pickedFile.readAsBytes();

      final publicUrl = await _storageService.uploadAvatar(
        userId: user['id'] as int,
        fileBytes: bytes,
        fileName: pickedFile.name,
        oldAvatarUrl: oldUrl,
      );

      if (publicUrl != null) {
        await SessionManager().updateAvatarUrl(publicUrl);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto profil berhasil diperbarui')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
        });
      }
    }
  }

  void _tampilkanOpsiGantiFoto() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _konfirmasiLogout(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Konfirmasi Logout'),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi? Session Anda akan diakhiri secara permanen dari perangkat ini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              // Tutup dialog
              Navigator.pop(dialogContext);

              // 1. Hapus token di server (Supabase)
              try {
                await Supabase.instance.client.auth.signOut();
              } catch (e) {
                // Ignore error if offline, local cleanup is priority
                debugPrint('Supabase sign out error (offline?): $e');
              }

              // 2. Hapus Session Lokal (Secure cleanup)
              SessionManager().clearSession();

              // 3. Clear Back Stack (Route false)
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginView()),
                  (route) => false,
                );
              }
            },
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccordion(String title, IconData icon, String content) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        childrenPadding: const EdgeInsets.all(16),
        expandedAlignment: Alignment.centerLeft,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content,
            style: const TextStyle(height: 1.5, fontSize: 14),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = SessionManager().currentUser;
    final username = user?['username']?.toString() ?? 'Pengguna Anonim';
    final email = user?['email']?.toString() ?? 'email.tidak.tersedia@kosku.com';
    final avatarUrl = user?['avatar_url']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Profil & Panduan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Profil Ringkas
            Card(
              color: theme.colorScheme.primaryContainer,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: theme.colorScheme.onPrimaryContainer,
                          backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                          child: avatarUrl.isEmpty
                              ? Icon(
                                  Icons.person,
                                  size: 40,
                                  color: theme.colorScheme.primaryContainer,
                                )
                              : null,
                        ),
                        if (_isUploadingAvatar)
                          const Positioned.fill(
                            child: CircularProgressIndicator(),
                          ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: _isUploadingAvatar ? null : _tampilkanOpsiGantiFoto,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: theme.colorScheme.primaryContainer, width: 2),
                              ),
                              child: Icon(Icons.camera_alt, size: 14, color: theme.colorScheme.onPrimary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onPrimaryContainer
                                  .withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'Panduan Penggunaan Aplikasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            // 2. Daftar Panduan (Accordion)
            _buildAccordion(
              'Keamanan & Akun',
              Icons.security,
              'â€¢ Login & Registrasi: Divalidasi secara ketat demi keamanan.\n'
              'â€¢ Session Timeout: Aplikasi dilengkapi dengan Auto-Logout. Jika Anda tidak menyentuh layar selama 1 jam, aplikasi akan otomatis memutus sesi Anda demi keamanan data.',
            ),
            _buildAccordion(
              'Fitur Komputasi',
              Icons.calculate,
              'â€¢ Kalkulator: Bisa menghitung angka desimal yang sangat besar.\n'
              'â€¢ Ganjil Genap: Memeriksa sifat angka secara instan.\n'
              'â€¢ Deret Statistik: Menampilkan deret matematika dan statistik dasar dari kumpulan angka masukan.',
            ),
            _buildAccordion(
              'Catatan Keuangan KosKu',
              Icons.account_balance_wallet,
              'Berfungsi mengelola uang Anda.\n'
              'â€¢ Tambah Catatan: Catat Pemasukan atau Pengeluaran.\n'
              'â€¢ Kategori: Anda bisa menambahkan kategori Anda sendiri secara dinamis.\n'
              'â€¢ Dashboard: Melihat Saldo akhir dan riwayat terurut berdasarkan tanggal terbaru.',
            ),
            _buildAccordion(
              'Konversi Penanggalan',
              Icons.calendar_month,
              'â€¢ Hijriah: Mengonversi kalender Masehi ke Hijriah.\n'
              'â€¢ Umur: Menampilkan umur detail Anda secara real-time.\n'
              'â€¢ Weton: Mencari Hari Pasaran Jawa beserta penjelasan wataknya.\n'
              'â€¢ Saka Bali: Menampilkan kalender kuno Pawukon dan Wewaran Bali.',
            ),
            _buildAccordion(
              'Navigasi & Tools',
              Icons.timer,
              'â€¢ Stopwatch: Stopwatch presisi tinggi yang tetap berjalan di latar belakang navigasi.\n'
              'â€¢ Logout: Keluar dari aplikasi dengan aman dan memutus sesi.',
            ),

            const SizedBox(height: 32),

            // 3. Tombol Logout Penuh
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _konfirmasiLogout(context),
                icon: const Icon(Icons.power_settings_new, size: 24),
                label: const Text(
                  'Keluar dari Aplikasi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

```


### File: lib\features\hijri_converter\services\hijri_service.dart
```dart
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

```


### File: lib\features\hijri_converter\views\hijri_converter_view.dart
```dart
/// ============================================================================
/// FILE: lib/features/hijri_converter/views/hijri_converter_view.dart
/// FUNGSI: Tampilan Konversi Tanggal Masehi ke Tanggal Hijriah.
/// MANAJEMEN HANDLES: FR-T2-05 (Konversi Tanggal Hijriah, default input = hari ini)
/// LOKASI LOGIC: Tempat penulisan DatePicker Masehi & algoritma/library konversi
///               ke tanggal, bulan, dan tahun Hijriah Islam.
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/hijri_service.dart';

class HijriConverterView extends StatefulWidget {
  const HijriConverterView({super.key});

  @override
  State<HijriConverterView> createState() => _HijriConverterViewState();
}

class _HijriConverterViewState extends State<HijriConverterView> {
  DateTime _selectedDate = DateTime.now();
  String _hijriResult = '';

  void _konversiKeHijriah() {
    setState(() {
      _hijriResult = HijriService.convertToHijri(_selectedDate);
    });
  }

  void _resetKeHariIni() {
    setState(() {
      _selectedDate = DateTime.now();
    });
    _konversiKeHijriah();
  }

  @override
  void initState() {
    super.initState();
    _konversiKeHijriah();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konversi Tanggal Hijriah'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Pilih tanggal Masehi di bawah ini untuk melihat padanannya dalam penanggalan Hijriah.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                title: const Text('Tanggal Masehi:', style: TextStyle(fontSize: 14)),
                subtitle: Text(
                  DateFormat('dd MMMM yyyy').format(_selectedDate),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.calendar_month, size: 32),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(1900), // Batas aman konversi (FR-T2-05)
                    lastDate: DateTime(2100),
                    helpText: 'Pilih Tanggal Masehi',
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                    _konversiKeHijriah();
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _resetKeHariIni,
              icon: const Icon(Icons.today),
              label: const Text('Kembali ke Hari Ini'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 4,
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
                child: Column(
                  children: [
                    Text(
                      'Hasil Konversi Hijriah',
                      style: TextStyle(
                        fontSize: 14, 
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8)
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _hijriResult,
                      style: TextStyle(
                        fontSize: 26, 
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

```


### File: lib\features\home\views\home_view.dart
```dart
/// ============================================================================
/// FILE: lib/features/home/views/home_view.dart
/// FUNGSI: Tampilan Halaman Utama (Tab 1) berisi Daftar Menu Vertikal Ber-Icon.
/// MANAJEMEN HANDLES: Home Dashboard & Navigasi ke Fitur Tugas 1 + Tugas 2
/// LOKASI LOGIC: Tempat penulisan ListView/GridView menu vertikal ber-icon yang dapat di-scroll
///               menuju 9 sub-fitur utama (Kelompok, Kalkulator, Ganjil/Genap, Statistik, KosKu, Hijriah, Umur, Weton, Saka Bali).
/// ============================================================================

import 'package:flutter/material.dart';
import '../../team/views/team_view.dart';
import '../../calculator/views/calculator_view.dart';
import '../../odd_even/views/odd_even_view.dart';
import '../../statistics/views/statistics_view.dart';
import '../../kosku/views/kosku_dashboard_view.dart';
import '../../hijri_converter/views/hijri_converter_view.dart';
import '../../age_calculator/views/age_calculator_view.dart';
import '../../weton_calendar/views/weton_calendar_view.dart';
import '../../saka_bali_calendar/views/saka_bali_calendar_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Daftar Anggota Kelompok',
        'subtitle': 'Tugas 1 (Daftar Pengembang Aplikasi)',
        'icon': Icons.group_outlined,
        'page': const TeamView(),
      },
      {
        'title': 'Kalkulator Presisi Super',
        'subtitle': 'Tugas 1 (Big Integer)',
        'icon': Icons.calculate_outlined,
        'page': const ViewKalkulator(),
      },
      {
        'title': 'Cek Bilangan Ganjil / Genap',
        'subtitle': 'Tugas 1 (Pemeriksaan Angka)',
        'icon': Icons.exposure_outlined,
        'page': const ViewGanjilGenap(),
      },
      {
        'title': 'Hitung & Statistik Deret Angka',
        'subtitle': 'Tugas 1 (Statistik Deret)',
        'icon': Icons.analytics_outlined,
        'page': const ViewTotalAngka(),
      },
      {
        'title': 'Catatan Keuangan KosKu',
        'subtitle': 'Tugas 2 (Kelola Pemasukan & Pengeluaran)',
        'icon': Icons.account_balance_wallet_outlined,
        'page': const KoskuDashboardView(),
      },
      {
        'title': 'Konversi Tanggal Hijriah',
        'subtitle': 'Tugas 2 (Kalender Islam)',
        'icon': Icons.calendar_month_outlined,
        'page': const HijriConverterView(),
      },
      {
        'title': 'Konversi Tanggal Lahir (Detail Umur)',
        'subtitle': 'Tugas 2 (Tahun, Bulan, Hari, Jam, Detik)',
        'icon': Icons.cake_outlined,
        'page': const AgeCalculatorView(),
      },
      {
        'title': 'Kalender Weton',
        'subtitle': 'Tugas 2 (Kalender Jawa)',
        'icon': Icons.event_repeat_outlined,
        'page': const WetonCalendarView(),
      },
      {
        'title': 'Kalender Saka Bali',
        'subtitle': 'Tugas 2 (Kalender Bali)',
        'icon': Icons.brightness_6_outlined,
        'page': const SakaBaliCalendarView(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Utama'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: ListTile(
              leading: Icon(item['icon'] as IconData, color: Theme.of(context).primaryColor),
              title: Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item['subtitle'] as String),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => item['page'] as Widget),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

```


### File: lib\features\kosku\models\category_model.dart
```dart
/// ============================================================================
/// FILE: lib/features/kosku/models/category_model.dart
/// FUNGSI: Model data representasi tabel `categories` Supabase.
/// MANAJEMEN HANDLES: Struktur Data Kategori Transaksi
/// LOKASI LOGIC: Menyimpan informasi id, userId, name, type (pemasukan/pengeluaran),
///               serta method toMap() dan fromMap() untuk query Supabase.
/// ============================================================================

class CategoryModel {
  final int? id;
  final int userId;
  final String name;
  final String type; // 'pemasukan' atau 'pengeluaran'
  final DateTime? createdAt;

  CategoryModel({
    this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.createdAt,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      name: map['name'] as String,
      type: map['type'].toString(),
      createdAt: map['created_at'] != null 
          ? (map['created_at'] is DateTime ? map['created_at'] : DateTime.parse(map['created_at'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
    };
  }
}

```


### File: lib\features\kosku\models\financial_record_model.dart
```dart
/// ============================================================================
/// FILE: lib/features/kosku/models/financial_record_model.dart
/// FUNGSI: Model data representasi tabel `financial_records` Supabase.
/// MANAJEMEN HANDLES: Struktur Data Transaksi KosKu
/// LOKASI LOGIC: Model yang menampung userId, categoryId, type, 
///               amount, title, description, recordDate, serta converter Map Supabase.
/// ============================================================================

class FinancialRecordModel {
  final int? id;
  final int userId;
  final int? categoryId;
  final String type; // 'pemasukan' / 'pengeluaran'
  final double amount;
  final String title;
  final String? description;
  final DateTime recordDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FinancialRecordModel({
    this.id,
    required this.userId,
    this.categoryId,
    required this.type,
    required this.amount,
    required this.title,
    this.description,
    required this.recordDate,
    this.createdAt,
    this.updatedAt,
  });

  factory FinancialRecordModel.fromMap(Map<String, dynamic> map) {
    return FinancialRecordModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      categoryId: map['category_id'] as int?,
      type: map['type'].toString(),
      amount: (map['amount'] is num) ? (map['amount'] as num).toDouble() : double.parse(map['amount'].toString()),
      title: map['title'] as String,
      description: map['description'] as String?,
      recordDate: map['record_date'] is DateTime 
          ? map['record_date'] 
          : DateTime.parse(map['record_date'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'type': type,
      'amount': amount,
      'title': title,
      'description': description,
      'record_date': recordDate.toIso8601String(),
    };
  }
}

```


### File: lib\features\kosku\services\kosku_service.dart
```dart
/// ============================================================================
/// FILE: lib/features/kosku/services/kosku_service.dart
/// FUNGSI: Service pengolahan CRUD data transaksi keuangan & kategori via Supabase Client.
/// MANAJEMEN HANDLES: FR-T2-01 (Summary Dashboard), FR-T2-02 (Input/Create),
///                    FR-T2-03 (Delete), & FR-T2-04 (Update)
/// LOKASI LOGIC: Supabase direct query (`financial_records` & `categories`).
/// ============================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/financial_record_model.dart';
import '../models/category_model.dart';

class KoskuService {

  /// Handles FR-T2-01: Mengambil ringkasan total pemasukan, total pengeluaran, & saldo
  Future<Map<String, double>> getFinancialSummary(int userId) async {
    try {
      final response = await Supabase.instance.client
          .from('financial_records')
          .select('type, amount')
          .eq('user_id', userId);

      double totalPemasukan = 0.0;
      double totalPengeluaran = 0.0;

      for (var row in response) {
        final type = row['type'].toString();
        final amount = (row['amount'] is num)
            ? (row['amount'] as num).toDouble()
            : double.tryParse(row['amount'].toString()) ?? 0.0;

        if (type == 'pemasukan') {
          totalPemasukan += amount;
        } else if (type == 'pengeluaran') {
          totalPengeluaran += amount;
        }
      }

      return {
        'total_pemasukan': totalPemasukan,
        'total_pengeluaran': totalPengeluaran,
        'saldo': totalPemasukan - totalPengeluaran,
      };
    } catch (e) {
      if (kDebugMode) {
        print('â„¹ï¸ Supabase getFinancialSummary error: $e');
      }
    }

    return {
      'total_pemasukan': 0.0,
      'total_pengeluaran': 0.0,
      'saldo': 0.0,
    };
  }

  /// Handles FR-T2-01: Mengambil daftar seluruh transaksi keuangan user
  Future<List<FinancialRecordModel>> getRecords(int userId) async {
    try {
      final response = await Supabase.instance.client
          .from('financial_records')
          .select()
          .eq('user_id', userId)
          .order('record_date', ascending: false);

      return response
          .map((item) => FinancialRecordModel.fromMap(item))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('â„¹ï¸ Supabase getRecords error: $e');
      }
    }
    return [];
  }

  /// Handles FR-T2-02: Menambah transaksi baru ke database Supabase
  Future<bool> createRecord(FinancialRecordModel record) async {
    try {
      final data = {
        'user_id': record.userId,
        if (record.categoryId != null) 'category_id': record.categoryId,
        'type': record.type,
        'amount': record.amount,
        'title': record.title,
        'description': record.description,
        'record_date': record.recordDate.toIso8601String(),
      };

      await Supabase.instance.client.from('financial_records').insert(data);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('â„¹ï¸ Supabase createRecord error: $e');
      }
      return false;
    }
  }

  /// Handles FR-T2-04: Mengubah/memperbarui data transaksi di Supabase
  Future<bool> updateRecord(FinancialRecordModel record) async {
    if (record.id == null) return false;
    try {
      final data = {
        if (record.categoryId != null) 'category_id': record.categoryId,
        'type': record.type,
        'amount': record.amount,
        'title': record.title,
        'description': record.description,
        'record_date': record.recordDate.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await Supabase.instance.client
          .from('financial_records')
          .update(data)
          .eq('id', record.id!);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('â„¹ï¸ Supabase updateRecord error: $e');
      }
      return false;
    }
  }

  /// Handles FR-T2-03: Menghapus transaksi dari database Supabase
  Future<bool> deleteRecord(int recordId) async {
    try {
      await Supabase.instance.client
          .from('financial_records')
          .delete()
          .eq('id', recordId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('â„¹ï¸ Supabase deleteRecord error: $e');
      }
      return false;
    }
  }

  /// Handles FR-T2-02: Mengambil daftar kategori dinamis user dari DB Supabase
  Future<List<CategoryModel>> getCategories(int userId) async {
    try {
      final response = await Supabase.instance.client
          .from('categories')
          .select()
          .eq('user_id', userId)
          .order('name', ascending: true);

      return response
          .map((item) => CategoryModel.fromMap(item))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('â„¹ï¸ Supabase getCategories error: $e');
      }
    }
    return [];
  }

  /// Handles FR-T2-02: Menambah kategori dinamis baru ke DB Supabase
  Future<bool> createCategory(CategoryModel category) async {
    try {
      await Supabase.instance.client.from('categories').insert({
        'user_id': category.userId,
        'name': category.name,
        'type': category.type,
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('â„¹ï¸ Supabase createCategory error: $e');
      }
      return false;
    }
  }
}

```


### File: lib\features\kosku\views\kosku_dashboard_view.dart
```dart
/// ============================================================================
/// FILE: lib/features/kosku/views/kosku_dashboard_view.dart
/// FUNGSI: Tampilan Dashboard Keuangan Anak Kos "KosKu".
/// MANAJEMEN HANDLES: FR-T2-01 (Ringkasan Pemasukan/Pengeluaran DB) & FR-T2-03 (Hapus Transaksi DB)
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/kosku_service.dart';
import '../models/financial_record_model.dart';
import '../../../core/session/session_manager.dart';
import 'kosku_form_view.dart';

class KoskuDashboardView extends StatefulWidget {
  const KoskuDashboardView({super.key});

  @override
  State<KoskuDashboardView> createState() => _KoskuDashboardViewState();
}

class _KoskuDashboardViewState extends State<KoskuDashboardView> {
  final KoskuService _koskuService = KoskuService();
  
  bool _isLoading = true;
  double _totalPemasukan = 0.0;
  double _totalPengeluaran = 0.0;
  double _saldo = 0.0;
  
  List<FinancialRecordModel> _records = [];
  Map<int, String> _categoryMap = {}; // mapping id -> name
  
  int? _userId;

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  void _initUser() {
    final user = SessionManager().currentUser;
    if (user != null && user['id'] != null) {
      _userId = user['id'] as int;
      _loadData();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadData() async {
    if (_userId == null) return;
    setState(() => _isLoading = true);
    
    final summary = await _koskuService.getFinancialSummary(_userId!);
    final records = await _koskuService.getRecords(_userId!);
    final categories = await _koskuService.getCategories(_userId!);
    
    Map<int, String> catMap = {};
    for (var cat in categories) {
      if (cat.id != null) {
        catMap[cat.id!] = cat.name;
      }
    }

    setState(() {
      _totalPemasukan = summary['total_pemasukan'] ?? 0.0;
      _totalPengeluaran = summary['total_pengeluaran'] ?? 0.0;
      _saldo = summary['saldo'] ?? 0.0;
      _records = records;
      _categoryMap = catMap;
      _isLoading = false;
    });
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  void _hapusCatatan(FinancialRecordModel record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: Text('Anda yakin ingin menghapus catatan "${record.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (record.id != null) {
                final success = await _koskuService.deleteRecord(record.id!);
                if (success) {
                  _loadData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Catatan berhasil dihapus')),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gagal menghapus catatan. Periksa koneksi internet Anda.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('KosKu - Catatan Keuangan')),
        body: const Center(child: Text('Harap Login terlebih dahulu.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('KosKu - Catatan Keuangan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 88.0),
                child: Column(
                  children: [
                    // Ringkasan
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const Text('Sisa Saldo', style: TextStyle(fontSize: 14)),
                            const SizedBox(height: 4),
                            Text(
                              _formatCurrency(_saldo), 
                              style: TextStyle(
                                fontSize: 28, 
                                fontWeight: FontWeight.bold,
                                color: _saldo < 0 ? Colors.red : Colors.blue.shade700
                              )
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Text('Pemasukan', style: TextStyle(color: Colors.green)),
                                    Text(_formatCurrency(_totalPemasukan), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text('Pengeluaran', style: TextStyle(color: Colors.red)),
                                    Text(_formatCurrency(_totalPengeluaran), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Riwayat Catatan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 10),
                    
                    if (_records.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada catatan keuangan.\nYuk, catat pengeluaran nasi bungkus pertamamu!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _records.length,
                        itemBuilder: (context, index) {
                          final record = _records[index];
                          final isPemasukan = record.type == 'pemasukan';
                          final categoryName = record.categoryId != null 
                              ? _categoryMap[record.categoryId!] ?? 'Tanpa Kategori'
                              : 'Tanpa Kategori';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isPemasukan ? Colors.green.shade100 : Colors.red.shade100,
                                child: Icon(
                                  isPemasukan ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: isPemasukan ? Colors.green : Colors.red,
                                ),
                              ),
                              title: Text(record.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('$categoryName â€¢ ${_formatDate(record.recordDate)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatCurrency(record.amount),
                                    style: TextStyle(
                                      color: isPemasukan ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => KoskuFormView(recordToEdit: record)),
                                        ).then((_) => _loadData());
                                      } else if (value == 'hapus') {
                                        _hapusCatatan(record);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                      const PopupMenuItem(value: 'hapus', child: Text('Hapus', style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const KoskuFormView()),
          ).then((_) => _loadData());
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Catatan'),
      ),
    );
  }
}


```


### File: lib\features\kosku\views\kosku_form_view.dart
```dart
/// ============================================================================
/// FILE: lib/features/kosku/views/kosku_form_view.dart
/// FUNGSI: Tampilan Form Tambah & Edit Catatan Keuangan KosKu.
/// MANAJEMEN HANDLES: FR-T2-02 & Validasi Input Standar Industri
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../models/financial_record_model.dart';
import '../models/category_model.dart';
import '../services/kosku_service.dart';
import '../../../core/session/session_manager.dart';

class KoskuFormView extends StatefulWidget {
  final FinancialRecordModel? recordToEdit;

  const KoskuFormView({super.key, this.recordToEdit});

  @override
  State<KoskuFormView> createState() => _KoskuFormViewState();
}

class _KoskuFormViewState extends State<KoskuFormView> {
  final KoskuService _koskuService = KoskuService();
  final _formKey = GlobalKey<FormState>();
  
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedType = 'pengeluaran'; // Default
  DateTime _selectedDate = DateTime.now();
  int? _selectedCategoryId;
  
  bool _isLoading = false;
  List<CategoryModel> _allCategories = [];
  List<CategoryModel> _filteredCategories = [];
  
  int? _userId;

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  void _initUser() {
    final user = SessionManager().currentUser;
    if (user != null && user['id'] != null) {
      _userId = user['id'] as int;
      _loadCategories();
      
      if (widget.recordToEdit != null) {
        final rec = widget.recordToEdit!;
        _titleController.text = rec.title;
        _amountController.text = rec.amount.toInt().toString();
        _descriptionController.text = rec.description ?? '';
        _selectedType = rec.type;
        _selectedDate = rec.recordDate;
        _selectedCategoryId = rec.categoryId;
      }
    }
  }

  Future<void> _loadCategories() async {
    if (_userId == null) return;
    
    final cats = await _koskuService.getCategories(_userId!);
    setState(() {
      _allCategories = cats;
      _filterCategories();
    });
  }

  void _filterCategories() {
    _filteredCategories = _allCategories.where((c) => c.type == _selectedType).toList();
    if (_selectedCategoryId != null) {
      final exists = _filteredCategories.any((c) => c.id == _selectedCategoryId);
      if (!exists) _selectedCategoryId = null;
    }
  }

  Future<void> _pilihTanggalWaktu() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _tambahKategoriBaru() {
    final ctrl = TextEditingController();
    String? localError;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Kategori ${_selectedType == 'pemasukan' ? 'Pemasukan' : 'Pengeluaran'} Baru'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: ctrl,
                    maxLength: 30,
                    decoration: InputDecoration(
                      hintText: _selectedType == 'pemasukan' ? 'Contoh: Bonus Beasiswa' : 'Contoh: Makanan & Minuman',
                      errorText: localError,
                    ),
                    autofocus: true,
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                ElevatedButton(
                  onPressed: () async {
                    final name = ctrl.text.trim();
                    if (name.isEmpty) {
                      setDialogState(() => localError = "Nama kategori tidak boleh kosong");
                      return;
                    }
                    if (name.length > 30) {
                      setDialogState(() => localError = "Maksimal 30 karakter");
                      return;
                    }
                    // Cek duplikasi
                    final isDuplicate = _filteredCategories.any((c) => c.name.toLowerCase() == name.toLowerCase());
                    if (isDuplicate) {
                      setDialogState(() => localError = "Kategori dengan nama tersebut sudah ada");
                      return;
                    }

                    if (_userId != null) {
                      Navigator.pop(context);
                      setState(() => _isLoading = true);
                      final newCat = CategoryModel(userId: _userId!, name: name, type: _selectedType);
                      final success = await _koskuService.createCategory(newCat);
                      
                      if (success) {
                        await _loadCategories();
                        final justAdded = _filteredCategories.where((c) => c.name.toLowerCase() == name.toLowerCase()).toList();
                        if (justAdded.isNotEmpty) {
                          setState(() => _selectedCategoryId = justAdded.last.id);
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membuat kategori')));
                        }
                      }
                      setState(() => _isLoading = false);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  Future<void> _simpanCatatan() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih atau buat kategori terlebih dahulu'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_userId == null) return;
    
    setState(() => _isLoading = true);
    
    final record = FinancialRecordModel(
      id: widget.recordToEdit?.id,
      userId: _userId!,
      categoryId: _selectedCategoryId,
      type: _selectedType,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      recordDate: _selectedDate,
    );

    bool success;
    if (widget.recordToEdit == null) {
      success = await _koskuService.createRecord(record);
    } else {
      success = await _koskuService.updateRecord(record);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan catatan. Periksa koneksi internet Anda.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('KosKu')),
        body: const Center(child: Text('Harap Login terlebih dahulu.')),
      );
    }

    final titlePlaceholder = 'Masukkan judul catatan';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recordToEdit == null ? 'Tambah Catatan' : 'Edit Catatan'),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Segmented Button Tipe
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'pemasukan', label: Text('Pemasukan')),
                  ButtonSegment(value: 'pengeluaran', label: Text('Pengeluaran')),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                    _filterCategories();
                  });
                },
              ),
              const SizedBox(height: 24),
              
              TextFormField(
                controller: _titleController,
                maxLength: 50,
                decoration: InputDecoration(
                  labelText: 'Judul Catatan', 
                  hintText: titlePlaceholder,
                  border: const OutlineInputBorder()
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Judul catatan tidak boleh kosong';
                  if (val.length > 50) return 'Judul terlalu panjang (maksimal 50 karakter)';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Nominal (Rp)', 
                  hintText: 'Masukkan nominal (Rp)',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Nominal wajib diisi';
                  final numVal = double.tryParse(val);
                  if (numVal == null || numVal <= 0) return 'Nominal harus lebih besar dari Rp 0';
                  if (numVal > 999999999) return 'Nominal maksimal Rp 999.999.999';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                      value: _selectedCategoryId,
                      hint: const Text('Pilih Kategori'),
                      items: _filteredCategories.map((cat) {
                        return DropdownMenuItem<int>(
                          value: cat.id,
                          child: Text(cat.name),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedCategoryId = val),
                      validator: (val) => val == null ? 'Pilih atau buat kategori terlebih dahulu' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: IconButton.filledTonal(
                      onPressed: _tambahKategoriBaru,
                      icon: const Icon(Icons.add),
                      tooltip: 'Tambah Kategori Baru',
                      iconSize: 28,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              
              InkWell(
                onTap: _pilihTanggalWaktu,
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Waktu Pencatatan', border: OutlineInputBorder()),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('dd MMM yyyy, HH:mm').format(_selectedDate)),
                      const Icon(Icons.calendar_month, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Tambahan (Opsional)', 
                  hintText: 'Masukkan catatan tambahan (opsional)',
                  border: OutlineInputBorder()
                ),
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: _simpanCatatan,
                child: const Text('Simpan Catatan', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


```


### File: lib\features\main_navigation\views\main_navigation_view.dart
```dart
/// ============================================================================
/// FILE: lib/features/main_navigation/views/main_navigation_view.dart
/// FUNGSI: Main Container View yang membungkus Bottom Navigation Bar (Navbar) 3 Tab.
/// MANAJEMEN HANDLES: FR-T2-09 (Bottom Navbar: Tab 1 Home, Tab 2 Stopwatch, Tab 3 Panduan & Logout)
/// LOKASI LOGIC: Tempat penulisan NavigationBar / BottomNavigationBar, pengatur indeks tab,
///               serta pergantian tampilan antara HomeView, StopwatchView, & GuideLogoutView.
/// ============================================================================

import 'package:flutter/material.dart';
import '../../home/views/home_view.dart';
import '../../stopwatch/views/stopwatch_view.dart';
import '../../guide_logout/views/guide_logout_view.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;

  // Handles FR-T2-09: 3 Tab Utama (Tab 1: Home, Tab 2: Stopwatch, Tab 3: Panduan & Logout)
  final List<Widget> _tabs = const [
    HomeView(),
    StopwatchView(),
    GuideLogoutView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Stopwatch',
          ),
          NavigationDestination(
            icon: Icon(Icons.help_outline),
            selectedIcon: Icon(Icons.help),
            label: 'Panduan & Logout',
          ),
        ],
      ),
    );
  }
}

```


### File: lib\features\odd_even\views\odd_even_view.dart
```dart
/// ============================================================================
/// FILE: lib/features/odd_even/views/odd_even_view.dart
/// FUNGSI: Tampilan Cek Bilangan Ganjil atau Genap.
/// MANAJEMEN HANDLES: FR-T1-02 (Cek Bilangan Ganjil / Genap UI & Logic)
/// LOKASI LOGIC: Input bilangan bulat (BigInt/BigDecimal), pengecekan sisa bagi (modulus 2),
///               serta penanganan error jika input desimal / tidak valid.
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../calculator/models/big_decimal.dart';

class ViewGanjilGenap extends StatefulWidget {
  const ViewGanjilGenap({super.key});

  @override
  State<ViewGanjilGenap> createState() => _ViewGanjilGenapState();
}

class _ViewGanjilGenapState extends State<ViewGanjilGenap> {
  final _angkaCtrl = TextEditingController();
  String _status = '';
  Color _statusColor = Colors.black;
  bool _isGenap = false;
  bool _hasResult = false;

  void _cekAngka() {
    FocusScope.of(context).unfocus();
    String input = _angkaCtrl.text.replaceAll(',', '').trim();
    if (input.isEmpty) {
      setState(() {
        _status = 'Harap masukkan bilangan terlebih dahulu.';
        _statusColor = Colors.red;
        _hasResult = false;
      });
      return;
    }

    BigDecimal? dec = BigDecimal.tryParse(input);
    if (dec == null) {
      setState(() {
        _status = 'Input bukan angka yang valid.';
        _statusColor = Colors.red;
        _hasResult = false;
      });
      return;
    }

    if (!dec.isInteger) {
      setState(() {
        _status = 'Angka adalah desimal (Ganjil/Genap hanya berlaku untuk bilangan bulat).';
        _statusColor = Colors.red;
        _hasResult = false;
      });
      return;
    }

    BigInt angka = dec.toBigInt();
    bool genap = (angka % BigInt.two == BigInt.zero);

    setState(() {
      _hasResult = true;
      _isGenap = genap;
      if (genap) {
        _status = 'Bilangan ${dec.toFormattedString()} adalah GENAP.';
        _statusColor = Colors.green;
      } else {
        _status = 'Bilangan ${dec.toFormattedString()} adalah GANJIL.';
        _statusColor = Colors.blue;
      }
    });
  }

  @override
  void dispose() {
    _angkaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cek Ganjil Genap'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 550),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        ),
                        child: Icon(Icons.numbers, size: 48, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Cek Ganjil / Genap',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Analisis sifat bilangan bulat super besar',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _angkaCtrl,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
                        ],
                        onSubmitted: (_) => _cekAngka(),
                        decoration: const InputDecoration(
                          labelText: 'Masukkan Bilangan Bulat',
                          hintText: 'Masukkan angka',
                          prefixIcon: Icon(Icons.pin),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _cekAngka,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search),
                              SizedBox(width: 8),
                              Text('CEK BILANGAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_status.isNotEmpty) ...[
                const SizedBox(height: 20),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: _hasResult
                      ? Card(
                          color: _isGenap
                              ? (isDark ? Colors.teal.shade900.withValues(alpha: 0.4) : Colors.teal.shade50)
                              : (isDark ? Colors.blue.shade900.withValues(alpha: 0.4) : Colors.blue.shade50),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 40,
                                  color: _statusColor,
                                ),
                                const SizedBox(height: 12),
                                SelectableText(
                                  _status,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    height: 1.4,
                                    color: _statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Card(
                          color: isDark ? Colors.red.shade900.withValues(alpha: 0.4) : Colors.red.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.error_outline, color: isDark ? Colors.red.shade300 : Colors.red.shade700),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Input Tidak Valid',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                Text(
                                  _status,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.red.shade200 : Colors.red.shade900,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
    );
  }
}

```


### File: lib\features\saka_bali_calendar\services\saka_bali_service.dart
```dart
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

```


### File: lib\features\saka_bali_calendar\views\saka_bali_calendar_view.dart
```dart
/// ============================================================================
/// FILE: lib/features/saka_bali_calendar/views/saka_bali_calendar_view.dart
/// FUNGSI: Tampilan Konversi Tanggal Masehi ke Kalender Saka Bali.
/// MANAJEMEN HANDLES: FR-T2-08 (Konversi Kalender Saka Bali, default input = hari ini)
/// LOKASI LOGIC: Tempat penulisan kalkulasi Pawukon, Rahinan, Purnam/Tilem,
///               serta penentuan tahun Saka Bali.
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/saka_bali_service.dart';

class SakaBaliCalendarView extends StatefulWidget {
  const SakaBaliCalendarView({super.key});

  @override
  State<SakaBaliCalendarView> createState() => _SakaBaliCalendarViewState();
}

class _SakaBaliCalendarViewState extends State<SakaBaliCalendarView> {
  DateTime _selectedDate = DateTime.now();
  SakaBaliResult? _sakaResult;

  void _hitungSakaBali() {
    setState(() {
      _sakaResult = SakaBaliService.hitungSakaBali(_selectedDate);
    });
  }

  void _resetKeHariIni() {
    setState(() {
      _selectedDate = DateTime.now();
    });
    _hitungSakaBali();
  }

  @override
  void initState() {
    super.initState();
    _hitungSakaBali();
  }

  Widget _buildWewaranBox(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color.withOpacity(0.8)),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Saka Bali'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Pilih tanggal Masehi di bawah ini untuk melihat padanannya dalam penanggalan Saka Bali dan Siklus Pawukon.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                title: const Text('Tanggal Kelahiran / Masehi:', style: TextStyle(fontSize: 14)),
                subtitle: Text(
                  DateFormat('dd MMMM yyyy').format(_selectedDate),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.brightness_6, size: 32),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                    _hitungSakaBali();
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _resetKeHariIni,
              icon: const Icon(Icons.today),
              label: const Text('Kembali ke Hari Ini'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 32),
            
            if (_sakaResult != null)
              Card(
                elevation: 4,
                color: theme.colorScheme.tertiaryContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Alert Rahinan (Bila ada)
                      if (_sakaResult!.rahinan != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                          ),
                          child: Column(
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.stars, color: Colors.redAccent, size: 20),
                                  SizedBox(width: 8),
                                  Text('RAHINAN / HARI SUCI', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _sakaResult!.rahinan!,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.redAccent),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      Text(
                        'Tahun Saka',
                        style: TextStyle(
                          fontSize: 14, 
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onTertiaryContainer.withOpacity(0.8)
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_sakaResult!.tahunSaka}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 36, 
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onTertiaryContainer
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Wuku & Sasih Badges
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Chip(
                            label: Text('Wuku: ${_sakaResult!.wuku}'),
                            backgroundColor: theme.colorScheme.tertiary,
                            labelStyle: TextStyle(color: theme.colorScheme.onTertiary, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          Chip(
                            label: Text('Sasih: ${_sakaResult!.sasih}'),
                            backgroundColor: theme.colorScheme.secondary,
                            labelStyle: TextStyle(color: theme.colorScheme.onSecondary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      const Text('Siklus Wewaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      
                      // Grid Wewaran
                      Row(
                        children: [
                          _buildWewaranBox('Triwara', _sakaResult!.triwara, Colors.purple),
                          const SizedBox(width: 8),
                          _buildWewaranBox('Sadwara', _sakaResult!.sadwara, Colors.orange),
                          const SizedBox(width: 8),
                          _buildWewaranBox('Saptawara', _sakaResult!.saptawara, Colors.teal),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildWewaranBox('Pancawara', _sakaResult!.pancawara, Colors.brown),
                        ],
                      )
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

```


### File: lib\features\statistics\views\statistics_view.dart
```dart
/// ============================================================================
/// FILE: lib/features/statistics/views/statistics_view.dart
/// FUNGSI: Tampilan Hitung Jumlah & Statistik Deret Angka.
/// MANAJEMEN HANDLES: FR-T1-03 (Deret Jumlah & Statistik Angka UI & Logic)
/// LOKASI LOGIC: Input deret angka dipisah spasi/koma, parsing ke BigDecimal,
///               kalkulasi total penjumlahan, rata-rata, nilai min, dan nilai max.
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../calculator/models/big_decimal.dart';

class ViewTotalAngka extends StatefulWidget {
  const ViewTotalAngka({super.key});

  @override
  State<ViewTotalAngka> createState() => _ViewTotalAngkaState();
}

class _ViewTotalAngkaState extends State<ViewTotalAngka> {
  final _deretCtrl = TextEditingController();
  String _errorMessage = '';
  int _totalValidCount = 0;
  String _sumVal = '';
  String _avgVal = '';
  String _minVal = '';
  String _maxVal = '';
  bool _hasResult = false;

  void _hitungStatistik() {
    FocusScope.of(context).unfocus();
    String input = _deretCtrl.text.trim();
    if (input.isEmpty) {
      setState(() {
        _hasResult = false;
        _errorMessage = 'Harap masukkan deret angka terlebih dahulu.';
      });
      return;
    }

    List<String> rawTokens = input.split(RegExp(r'[\s,]+'));
    List<BigDecimal> validNumbers = [];
    List<String> invalidTokens = [];

    for (String item in rawTokens) {
      if (item.isEmpty) continue;
      BigDecimal? num = BigDecimal.tryParse(item);
      if (num != null) {
        validNumbers.add(num);
      } else {
        invalidTokens.add(item);
      }
    }

    if (invalidTokens.isNotEmpty) {
      setState(() {
        _hasResult = false;
        _errorMessage =
            'Input mengandung data yang bukan angka valid:\n"${invalidTokens.join(', ')}"\n\nHanya angka yang diperbolehkan (pisahkan dengan spasi atau koma).';
      });
      return;
    }

    if (validNumbers.isEmpty) {
      setState(() {
        _hasResult = false;
        _errorMessage = 'Tidak ada angka valid yang dimasukkan.';
      });
      return;
    }

    BigDecimal total = BigDecimal.zero;
    BigDecimal minVal = validNumbers.first;
    BigDecimal maxVal = validNumbers.first;

    for (BigDecimal num in validNumbers) {
      total += num;
      if (num < minVal) minVal = num;
      if (num > maxVal) maxVal = num;
    }

    BigDecimal count = BigDecimal.fromInt(validNumbers.length);
    BigDecimal average = total.divide(count, maxScale: 50);

    setState(() {
      _hasResult = true;
      _errorMessage = '';
      _totalValidCount = validNumbers.length;
      _sumVal = total.toFormattedString();
      _avgVal = average.toFormattedString();
      _minVal = minVal.toFormattedString();
      _maxVal = maxVal.toFormattedString();
    });
  }

  @override
  void dispose() {
    _deretCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hitung Statistik'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.analytics, color: theme.colorScheme.primary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hitung Jumlah & Statistik',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Analisis deret angka (Total, Rata-rata, Min, Max)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _deretCtrl,
                        maxLines: 4,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9\s,\.\-]')),
                        ],
                        decoration: const InputDecoration(
                          hintText: 'Ketik deret angka dipisahkan spasi atau koma',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _hitungStatistik,
                          icon: const Icon(Icons.show_chart),
                          label: const Text('HITUNG STATISTIK', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_hasResult) ...[
                Card(
                  color: isDark ? Colors.teal.shade900.withValues(alpha: 0.3) : Colors.teal.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.assessment, color: Colors.teal),
                            SizedBox(width: 8),
                            Text('Hasil Ringkasan Statistik', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildStatRow('Banyak Angka Valid', '$_totalValidCount data'),
                        _buildStatRow('Total Penjumlahan', _sumVal),
                        _buildStatRow('Rata-Rata (Average)', _avgVal),
                        _buildStatRow('Nilai Terkecil (Min)', _minVal),
                        _buildStatRow('Nilai Terbesar (Max)', _maxVal),
                      ],
                    ),
                  ),
                ),
              ] else if (_errorMessage.isNotEmpty) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Card(
                    color: isDark ? Colors.red.shade900.withValues(alpha: 0.4) : Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.error_outline, color: isDark ? Colors.red.shade300 : Colors.red.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Input Tidak Valid',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Text(
                            _errorMessage,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.red.shade200 : Colors.red.shade900,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          const Text(' :  '),
          Expanded(
            flex: 3,
            child: SelectableText(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

```


### File: lib\features\stopwatch\views\stopwatch_view.dart
```dart
/// ============================================================================
/// FILE: lib/features/stopwatch/views/stopwatch_view.dart
/// FUNGSI: Tampilan Halaman Stopwatch (Tab 2 Bottom Navbar).
/// MANAJEMEN HANDLES: Tab 2 (Stopwatch Application Feature)
/// LOKASI LOGIC: Tempat penulisan Timer Stopwatch (Start, Pause, Reset, Lap Time),
///               serta render tampilan digital timer.
/// ============================================================================

import 'dart:async';
import 'package:flutter/material.dart';

class StopwatchView extends StatefulWidget {
  const StopwatchView({super.key});

  @override
  State<StopwatchView> createState() => _StopwatchViewState();
}

class _StopwatchViewState extends State<StopwatchView> {
  // Gunakan kelas Stopwatch bawaan sistem agar terhindar dari time drift
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  
  final List<int> _laps = [];

  @override
  void dispose() {
    // Mematikan timer untuk mencegah memory leak
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _startTimer() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
      // Update UI setiap 30ms (sekitar 33 fps) agar milidetik terlihat mulus tapi CPU tidak nge-lag
      _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  void _pauseTimer() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _timer?.cancel();
      setState(() {});
    }
  }

  void _resetTimer() {
    _stopwatch.reset();
    _stopwatch.stop();
    _timer?.cancel();
    _laps.clear();
    setState(() {});
  }

  void _addLap() {
    if (_stopwatch.isRunning) {
      setState(() {
        _laps.insert(0, _stopwatch.elapsedMilliseconds);
      });
    }
  }

  String _formatTime(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();

    String hoursStr = (hours % 60).toString().padLeft(2, '0');
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    String hundredsStr = (hundreds % 100).toString().padLeft(2, '0');

    return '$hoursStr:$minutesStr:$secondsStr.$hundredsStr';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRunning = _stopwatch.isRunning;
    final hasStarted = _stopwatch.elapsedMilliseconds > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stopwatch'),
      ),
      body: Column(
        children: [
          // Area Display Timer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Text(
                  _formatTime(_stopwatch.elapsedMilliseconds),
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier', // Monospace font untuk kestabilan angka
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'HH:MM:SS.MS',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Area Tombol Kontrol
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Tombol Reset/Lap
              FloatingActionButton.extended(
                heroTag: 'btn_reset_lap',
                onPressed: (isRunning) 
                    ? _addLap 
                    : (hasStarted ? _resetTimer : null),
                backgroundColor: isRunning 
                    ? theme.colorScheme.secondary 
                    : (hasStarted ? theme.colorScheme.error : theme.colorScheme.surfaceVariant),
                foregroundColor: isRunning 
                    ? theme.colorScheme.onSecondary 
                    : (hasStarted ? theme.colorScheme.onError : theme.colorScheme.onSurfaceVariant),
                icon: Icon(isRunning ? Icons.flag : Icons.refresh),
                label: Text(isRunning ? 'Lap' : 'Reset'),
              ),
              
              // Tombol Start/Pause
              FloatingActionButton.extended(
                heroTag: 'btn_start_pause',
                onPressed: isRunning ? _pauseTimer : _startTimer,
                backgroundColor: isRunning ? theme.colorScheme.tertiary : theme.colorScheme.primary,
                foregroundColor: isRunning ? theme.colorScheme.onTertiary : theme.colorScheme.onPrimary,
                icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                label: Text(isRunning ? 'Pause' : 'Start'),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          const Divider(),
          
          // Area Daftar Lap Time (Mencegah Overflow dengan Expanded + ListView)
          Expanded(
            child: _laps.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada putaran (lap).',
                      style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    ),
                  )
                : ListView.builder(
                    itemCount: _laps.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemBuilder: (context, index) {
                      // Karena list diisi dengan insert(0), index 0 adalah lap terbaru
                      final reversedIndex = _laps.length - index;
                      final currentLapTime = _laps[index];
                      final previousLapTime = (index < _laps.length - 1) ? _laps[index + 1] : 0;
                      final lapDuration = currentLapTime - previousLapTime;

                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.secondaryContainer,
                            child: Text(
                              '$reversedIndex',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSecondaryContainer
                              ),
                            ),
                          ),
                          title: Text(
                            '+ ${_formatTime(lapDuration)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Courier'),
                          ),
                          trailing: Text(
                            _formatTime(currentLapTime),
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                              fontFamily: 'Courier'
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

```


### File: lib\features\team\models\team_member_model.dart
```dart
/// ============================================================================
/// FILE: lib/features/team/models/team_member_model.dart
/// FUNGSI: Model data representasi tabel `members` Supabase (Tugas 1 -> DB).
/// MANAJEMEN HANDLES: Struktur Data Anggota Kelompok
/// LOKASI LOGIC: Atribut nim, name, createdAt, serta converter dari/ke Map.
/// ============================================================================

class AnggotaKelompok {
  final int? id;
  final String nim;
  final String name;
  final DateTime? createdAt;

  const AnggotaKelompok({
    this.id,
    required this.nim,
    required this.name,
    this.createdAt,
  });

  /// Factory untuk konversi dari Map Supabase
  factory AnggotaKelompok.fromMap(Map<String, dynamic> map) {
    return AnggotaKelompok(
      id: map['id'] as int?,
      nim: map['nim'] as String,
      name: map['name'] as String,
      createdAt: map['created_at'] != null 
          ? (map['created_at'] is DateTime ? map['created_at'] : DateTime.parse(map['created_at'].toString()))
          : null,
    );
  }

  /// Konversi ke Map untuk query Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nim': nim,
      'name': name,
    };
  }
}

```


### File: lib\features\team\services\team_service.dart
```dart
/// ============================================================================
/// FILE: lib/features/team/services/team_service.dart
/// FUNGSI: Service pengambil data Anggota Kelompok dari Supabase.
/// MANAJEMEN HANDLES: FR-U-03 (Fetch Anggota Kelompok dari tabel `members` Supabase DB)
/// LOKASI LOGIC: Supabase Direct Query (`Supabase.instance.client.from('members').select()`).
/// ============================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/team_member_model.dart';

class TeamService {

  /// Handles FR-U-03: Membaca daftar anggota kelompok dari tabel `members` Supabase DB
  Future<List<AnggotaKelompok>> fetchMembers() async {
    // 1. Coba via Online Supabase Client
    try {
      final response = await Supabase.instance.client
          .from('members')
          .select()
          .order('id', ascending: true);

      if (response.isNotEmpty) {
        return response
            .map((item) => AnggotaKelompok.fromMap(item))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('â„¹ï¸ Supabase Fetch Members gagal: $e');
      }
    }

    // Fallback data statis jika belum ada koneksi DB
    return [
      const AnggotaKelompok(nim: '123220001', name: 'Ade Nugraha'),
      const AnggotaKelompok(nim: '123220002', name: 'Anggota Kelompok 2'),
      const AnggotaKelompok(nim: '123220003', name: 'Anggota Kelompok 3'),
    ];
  }
}

```


### File: lib\features\team\views\team_view.dart
```dart
/// ============================================================================
/// FILE: lib/features/team/views/team_view.dart
/// FUNGSI: Tampilan Daftar Anggota Kelompok.
/// MANAJEMEN HANDLES: FR-U-03 (UI Anggota Kelompok dari Supabase)
/// LOKASI LOGIC: Tempat penulisan FutureBuilder untuk menampilkan data dari TeamService.fetchMembers().
/// ============================================================================

import 'package:flutter/material.dart';
import '../models/team_member_model.dart';
import '../services/team_service.dart';

class TeamView extends StatefulWidget {
  const TeamView({super.key});

  @override
  State<TeamView> createState() => _TeamViewState();
}

class ViewDataKelompok extends StatelessWidget {
  const ViewDataKelompok({super.key});

  @override
  Widget build(BuildContext context) {
    return const TeamView();
  }
}

class _TeamViewState extends State<TeamView> {
  final TeamService _teamService = TeamService();
  late Future<List<AnggotaKelompok>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _membersFuture = _teamService.fetchMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anggota Kelompok'),
      ),
      body: FutureBuilder<List<AnggotaKelompok>>(
        future: _membersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final members = snapshot.data ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(member.name),
                  subtitle: Text('NIM: ${member.nim}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

```


### File: lib\features\weton_calendar\services\weton_service.dart
```dart
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

```


### File: lib\features\weton_calendar\views\weton_calendar_view.dart
```dart
/// ============================================================================
/// FILE: lib/features/weton_calendar/views/weton_calendar_view.dart
/// FUNGSI: Tampilan Konversi Tanggal Masehi ke Kalender Weton Jawa.
/// MANAJEMEN HANDLES: FR-T2-07 (Konversi Kalender Weton, default input = hari ini)
/// LOKASI LOGIC: Tempat penulisan algoritma pencarian pasaran Jawa (Legi, Pahing,
///               Pon, Wage, Kliwon) & perhitungan Neptu.
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/weton_service.dart';

class WetonCalendarView extends StatefulWidget {
  const WetonCalendarView({super.key});

  @override
  State<WetonCalendarView> createState() => _WetonCalendarViewState();
}

class _WetonCalendarViewState extends State<WetonCalendarView> {
  DateTime _selectedDate = DateTime.now();
  WetonResult? _wetonResult;

  void _hitungWeton() {
    setState(() {
      _wetonResult = WetonService.hitungWeton(_selectedDate);
    });
  }

  void _resetKeHariIni() {
    setState(() {
      _selectedDate = DateTime.now();
    });
    _hitungWeton();
  }

  @override
  void initState() {
    super.initState();
    _hitungWeton();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Weton Jawa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Pilih tanggal Masehi di bawah ini untuk melihat Hari Pasaran Jawa beserta penjelasan wataknya.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                title: const Text('Tanggal Kelahiran / Masehi:', style: TextStyle(fontSize: 14)),
                subtitle: Text(
                  DateFormat('dd MMMM yyyy').format(_selectedDate),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.event_note, size: 32),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(1900), // Batas limit (FR-T2-07)
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                    _hitungWeton();
                  }
                },
              ),
            ),
            
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _resetKeHariIni,
              icon: const Icon(Icons.today),
              label: const Text('Kembali ke Hari Ini'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 32),
            
            if (_wetonResult != null)
              Card(
                elevation: 4,
                color: theme.colorScheme.secondaryContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        'Hasil Weton Jawa',
                        style: TextStyle(
                          fontSize: 14, 
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSecondaryContainer.withOpacity(0.8)
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _wetonResult!.wetonLengkap,
                        style: TextStyle(
                          fontSize: 32, 
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSecondaryContainer
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      
                      // Badge Neptu
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Total Neptu: ${_wetonResult!.totalNeptu} (${_wetonResult!.namaHari}: ${_wetonResult!.neptuHari} + ${_wetonResult!.namaPasaran}: ${_wetonResult!.neptuPasaran})',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 12),
                      
                      // Penjelasan Watak
                      const Text(
                        'Gambaran Karakter/Watak',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _wetonResult!.watak,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

```


### File: lib\models\big_decimal.dart
```dart
/// Re-export file untuk menjaga kompatibilitas mundur dengan unit test dan Tugas 1
export '../features/calculator/models/big_decimal.dart';

```


### File: lib\models\team_member.dart
```dart
/// Re-export file untuk menjaga kompatibilitas mundur dengan unit test dan Tugas 1
export '../features/team/models/team_member_model.dart';

```


### File: lib\services\calculator_service.dart
```dart
/// Re-export file untuk menjaga kompatibilitas mundur dengan unit test dan Tugas 1
export '../features/calculator/services/calculator_service.dart';

```


### File: lib\theme\app_theme.dart
```dart
/// Re-export file untuk menjaga kompatibilitas mundur dengan unit test dan Tugas 1
export '../core/theme/app_theme.dart';

```


### File: lib\views\calculator_view.dart
```dart
/// Re-export file untuk menjaga kompatibilitas mundur dengan unit test dan Tugas 1
export '../features/calculator/views/calculator_view.dart';

```


### File: lib\views\login_screen.dart
```dart
/// Re-export file untuk menjaga kompatibilitas mundur dengan unit test dan Tugas 1
import '../features/auth/views/login_view.dart';
export '../features/auth/views/login_view.dart';

typedef HalamanLogin = LoginView;

```


### File: lib\views\main_navigation_screen.dart
```dart
/// Re-export file untuk menjaga kompatibilitas mundur dengan unit test dan Tugas 1
import '../features/main_navigation/views/main_navigation_view.dart';
export '../features/main_navigation/views/main_navigation_view.dart';

typedef HalamanUtama = MainNavigationView;

```


### File: lib\views\odd_even_view.dart
```dart
/// Re-export file untuk menjaga kompatibilitas mundur dengan unit test dan Tugas 1
export '../features/odd_even/views/odd_even_view.dart';

```


### File: lib\views\statistics_view.dart
```dart
/// Re-export file untuk menjaga kompatibilitas mundur dengan unit test dan Tugas 1
export '../features/statistics/views/statistics_view.dart';

```


### File: lib\views\team_view.dart
```dart
/// Re-export file untuk menjaga kompatibilitas mundur dengan unit test dan Tugas 1
export '../features/team/views/team_view.dart';

```


### File: linux\flutter\ephemeral\.plugin_symlinks\app_links_linux\pubspec.yaml
```dart
name: app_links_linux
description: Linux platform implementation of app_links plugin.
version: 1.0.3
homepage: https://github.com/llfbandit/app_links/tree/master/app_links_linux

environment:
  sdk: ^3.2.0
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter
  
  app_links_platform_interface: ^2.0.0
  # https://pub.dev/packages/gtk
  gtk: ^2.1.0

dev_dependencies:
  flutter_lints: ^4.0.0

flutter:
  plugin:
    implements: app_links
    platforms:
      linux:
        dartPluginClass: AppLinksPluginLinux
        fileName: 'app_links_linux.dart'

```


### File: linux\flutter\ephemeral\.plugin_symlinks\file_selector_linux\example\pubspec.yaml
```dart
name: file_selector_linux_example
description: Local testbed for Linux file_selector implementation.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.10.0
  flutter: ">=3.38.0"

dependencies:
  file_selector_linux:
    path: ../
  file_selector_platform_interface: ^2.7.0
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true

```


### File: linux\flutter\ephemeral\.plugin_symlinks\file_selector_linux\pubspec.yaml
```dart
name: file_selector_linux
description: Liunx implementation of the file_selector plugin.
repository: https://github.com/flutter/packages/tree/main/packages/file_selector/file_selector_linux
issue_tracker: https://github.com/flutter/flutter/issues?q=is%3Aissue+is%3Aopen+label%3A%22p%3A+file_selector%22
version: 0.9.4+1

environment:
  sdk: ^3.10.0
  flutter: ">=3.38.0"

flutter:
  plugin:
    implements: file_selector
    platforms:
      linux:
        pluginClass: FileSelectorPlugin
        dartPluginClass: FileSelectorLinux

dependencies:
  cross_file: ^0.3.1
  file_selector_platform_interface: ^2.7.0
  flutter:
    sdk: flutter
  meta: ^1.10.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  pigeon: ^27.3.2

topics:
  - files
  - file-selection
  - file-selector

```


### File: linux\flutter\ephemeral\.plugin_symlinks\gtk\example\pubspec.yaml
```dart
name: gtk_example
publish_to: 'none'

environment:
  flutter: ^3.38.0
  sdk: '>=2.18.0 <3.0.0'

dependencies:
  flutter:
    sdk: flutter
  gtk: ^2.2.0
  provider: ^6.0.5
  yaru: ^10.1.0

dev_dependencies:
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true

```


### File: linux\flutter\ephemeral\.plugin_symlinks\gtk\pubspec.yaml
```dart
name: gtk
description: GTK+ utilities for Flutter Linux applications.
homepage: https://github.com/ubuntu-flutter-community/gtk.dart
repository: https://github.com/ubuntu-flutter-community/gtk.dart
issue_tracker: https://github.com/ubuntu-flutter-community/gtk.dart/issues
version: 2.2.0

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.10.0"

dependencies:
  ffi: ^2.0.1
  flutter:
    sdk: flutter
  meta: ^1.8.0

dev_dependencies:
  ffigen: ^20.1.1
  flutter_lints: ^2.0.0
  flutter_test:
    sdk: flutter
  mockito: ^5.3.2

flutter:
  plugin:
    platforms:
      linux:
        pluginClass: GtkPlugin

```


### File: linux\flutter\ephemeral\.plugin_symlinks\image_picker_linux\example\pubspec.yaml
```dart
name: example
description: Example for image_picker_linux implementation.
publish_to: 'none'
version: 1.0.0

environment:
  sdk: ^3.6.0
  flutter: ">=3.27.0"

dependencies:
  flutter:
    sdk: flutter
  image_picker_linux:
    # When depending on this package from a real application you should use:
    #   image_picker_linux: ^x.y.z
    # See https://dart.dev/tools/pub/dependencies#version-constraints
    # The example app is bundled with the plugin so we use a path dependency on
    # the parent directory to use the current plugin's version.
    path: ..
  image_picker_platform_interface: ^2.11.0
  mime: ^2.0.0
  video_player: ^2.1.4

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true

```


### File: linux\flutter\ephemeral\.plugin_symlinks\image_picker_linux\pubspec.yaml
```dart
name: image_picker_linux
description: Linux platform implementation of image_picker
repository: https://github.com/flutter/packages/tree/main/packages/image_picker/image_picker_linux
issue_tracker: https://github.com/flutter/flutter/issues?q=is%3Aissue+is%3Aopen+label%3A%22p%3A+image_picker%22
version: 0.2.2

environment:
  sdk: ^3.6.0
  flutter: ">=3.27.0"

flutter:
  plugin:
    implements: image_picker
    platforms:
      linux:
        dartPluginClass: ImagePickerLinux

dependencies:
  file_selector_linux: ^0.9.1+3
  file_selector_platform_interface: ^2.2.0
  flutter:
    sdk: flutter
  image_picker_platform_interface: ^2.11.0

dev_dependencies:
  build_runner: ^2.1.5
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4

topics:
  - image-picker
  - files
  - file-selection

```


### File: linux\flutter\ephemeral\.plugin_symlinks\path_provider_linux\example\pubspec.yaml
```dart
name: pathproviderexample
description: Demonstrates how to use the path_provider_linux plugin.
publish_to: "none"

environment:
  sdk: ^3.10.0
  flutter: ">=3.38.0"

dependencies:
  flutter:
    sdk: flutter

  path_provider_linux:
    # When depending on this package from a real application you should use:
    #   path_provider_linux: ^x.y.z
    # See https://dart.dev/tools/pub/dependencies#version-constraints
    # The example app is bundled with the plugin so we use a path dependency on
    # the parent directory to use the current plugin's version.
    path: ../

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter

flutter:
  uses-material-design: true

```


### File: linux\flutter\ephemeral\.plugin_symlinks\path_provider_linux\pubspec.yaml
```dart
name: path_provider_linux
description: Linux implementation of the path_provider plugin
repository: https://github.com/flutter/packages/tree/main/packages/path_provider/path_provider_linux
issue_tracker: https://github.com/flutter/flutter/issues?q=is%3Aissue+is%3Aopen+label%3A%22p%3A+path_provider%22
version: 2.2.2

environment:
  sdk: ^3.10.0
  flutter: ">=3.38.0"

flutter:
  plugin:
    implements: path_provider
    platforms:
      linux:
        dartPluginClass: PathProviderLinux

dependencies:
  ffi: ">=1.1.2 <3.0.0"
  flutter:
    sdk: flutter
  path: ^1.8.0
  path_provider_platform_interface: ^2.1.0
  xdg_directories: ">=0.2.0 <2.0.0"

dev_dependencies:
  flutter_test:
    sdk: flutter

topics:
  - files
  - path-provider
  - paths

```


### File: linux\flutter\ephemeral\.plugin_symlinks\shared_preferences_linux\example\pubspec.yaml
```dart
name: shared_preferences_linux_example
description: Demonstrates how to use the shared_preferences_linux plugin.
publish_to: none

environment:
  sdk: ^3.3.0
  flutter: ">=3.19.0"

dependencies:
  flutter:
    sdk: flutter
  shared_preferences_linux:
    # When depending on this package from a real application you should use:
    #   shared_preferences_linux: ^x.y.z
    # See https://dart.dev/tools/pub/dependencies#version-constraints
    # The example app is bundled with the plugin so we use a path dependency on
    # the parent directory to use the current plugin's version.
    path: ../
  shared_preferences_platform_interface: ^2.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter

flutter:
  uses-material-design: true

```


### File: linux\flutter\ephemeral\.plugin_symlinks\shared_preferences_linux\pubspec.yaml
```dart
name: shared_preferences_linux
description: Linux implementation of the shared_preferences plugin
repository: https://github.com/flutter/packages/tree/main/packages/shared_preferences/shared_preferences_linux
issue_tracker: https://github.com/flutter/flutter/issues?q=is%3Aissue+is%3Aopen+label%3A%22p%3A+shared_preferences%22
version: 2.4.1

environment:
  sdk: ^3.3.0
  flutter: ">=3.19.0"

flutter:
  plugin:
    implements: shared_preferences
    platforms:
      linux:
        dartPluginClass: SharedPreferencesLinux

dependencies:
  file: ">=6.0.0 <8.0.0"
  flutter:
    sdk: flutter
  path: ^1.8.0
  path_provider_linux: ^2.0.0
  path_provider_platform_interface: ^2.0.0
  shared_preferences_platform_interface: ^2.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter

topics:
  - persistence
  - shared-preferences
  - storage

```


### File: linux\flutter\ephemeral\.plugin_symlinks\url_launcher_linux\example\pubspec.yaml
```dart
name: url_launcher_example
description: Demonstrates how to use the url_launcher plugin.
publish_to: none

environment:
  sdk: ^3.10.0
  flutter: ">=3.38.0"

dependencies:
  flutter:
    sdk: flutter
  url_launcher_linux:
    # When depending on this package from a real application you should use:
    #   url_launcher_linux: ^x.y.z
    # See https://dart.dev/tools/pub/dependencies#version-constraints
    # The example app is bundled with the plugin so we use a path dependency on
    # the parent directory to use the current plugin's version.
    path: ../
  url_launcher_platform_interface: ^2.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter

flutter:
  uses-material-design: true

```


### File: linux\flutter\ephemeral\.plugin_symlinks\url_launcher_linux\pubspec.yaml
```dart
name: url_launcher_linux
description: Linux implementation of the url_launcher plugin.
repository: https://github.com/flutter/packages/tree/main/packages/url_launcher/url_launcher_linux
issue_tracker: https://github.com/flutter/flutter/issues?q=is%3Aissue+is%3Aopen+label%3A%22p%3A+url_launcher%22
version: 3.2.3

environment:
  sdk: ^3.10.0
  flutter: ">=3.38.0"

flutter:
  plugin:
    implements: url_launcher
    platforms:
      linux:
        pluginClass: UrlLauncherPlugin
        dartPluginClass: UrlLauncherLinux

dependencies:
  flutter:
    sdk: flutter
  meta: ^1.10.0
  url_launcher_platform_interface: ^2.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  pigeon: ^27.3.2

topics:
  - links
  - os-integration
  - url-launcher
  - urls

```


### File: windows\flutter\ephemeral\.plugin_symlinks\app_links\example\pubspec.yaml
```dart
name: app_links_example
description: Demonstrates how to use the app_links plugin.
version: 1.0.0

# The following line prevents the package from being accidentally published to
# pub.dev using `pub publish`. This is preferred for private packages.
publish_to: 'none' # Remove this line if you wish to publish to pub.dev

environment:
  sdk: ^3.12.0
  flutter: ">=3.44.0"

resolution: workspace

dependencies:
  flutter:
    sdk: flutter

  app_links: ^7.0.0

  ffi: ^2.1.0
  win32: ^6.3.0

dev_dependencies:
  msix: ^3.16.8
  
  # linter rules (https://pub.dev/packages/flutter_lints)
  flutter_lints: ^6.0.0

# The following section is specific to Flutter.
flutter:
  uses-material-design: true

# Windows only (packaged app)
msix_config:
  display_name: app_links_example
  msix_version: 1.0.0.0
  protocol_activation: https, sample # Add the protocol activation for the app
  app_uri_handler_hosts: www.example.com, example.com # Add the app uri handler hosts

```


### File: windows\flutter\ephemeral\.plugin_symlinks\app_links\pubspec.yaml
```dart
name: app_links
description: Android App Links, Deep Links, iOs Universal Links and Custom URL schemes handler for Flutter (desktop included).
version: 7.2.1
homepage: https://github.com/llfbandit/app_links

environment:
  sdk: ^3.12.0
  flutter: ">=3.44.0"

resolution: workspace

dependencies:
  flutter:
    sdk: flutter
  
  app_links_linux: ^1.0.3
  app_links_platform_interface: ^2.0.4
  app_links_web: ^1.0.4

dev_dependencies:
  flutter_lints: ^6.0.0

flutter:
  plugin:
    platforms:
      android:
        package: com.llfbandit.app_links
        pluginClass: AppLinksPlugin
      ios:
        pluginClass: AppLinksIosPlugin
      linux:
        default_package: app_links_linux
      macos:
        pluginClass: AppLinksMacosPlugin
      web:
        default_package: app_links_web
      windows:
        pluginClass: AppLinksPluginCApi

topics:
  - deeplink
  - app-links
  - universal-links
  - custom-url-schemes
  - web-to-app

```


### File: windows\flutter\ephemeral\.plugin_symlinks\file_selector_windows\example\pubspec.yaml
```dart
name: example
description: Example for file_selector_windows implementation.
publish_to: 'none'
version: 1.0.0

environment:
  sdk: ^3.10.0
  flutter: ">=3.38.0"

dependencies:
  file_selector_platform_interface: ^2.7.0
  file_selector_windows:
    # When depending on this package from a real application you should use:
    #   file_selector_windows: ^x.y.z
    # See https://dart.dev/tools/pub/dependencies#version-constraints
    # The example app is bundled with the plugin so we use a path dependency on
    # the parent directory to use the current plugin's version.
    path: ..
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true

```


### File: windows\flutter\ephemeral\.plugin_symlinks\file_selector_windows\pubspec.yaml
```dart
name: file_selector_windows
description: Windows implementation of the file_selector plugin.
repository: https://github.com/flutter/packages/tree/main/packages/file_selector/file_selector_windows
issue_tracker: https://github.com/flutter/flutter/issues?q=is%3Aissue+is%3Aopen+label%3A%22p%3A+file_selector%22
version: 0.9.3+6

environment:
  sdk: ^3.10.0
  flutter: ">=3.38.0"

flutter:
  plugin:
    implements: file_selector
    platforms:
      windows:
        dartPluginClass: FileSelectorWindows
        pluginClass: FileSelectorWindows

dependencies:
  cross_file: ^0.3.1
  file_selector_platform_interface: ^2.6.0
  flutter:
    sdk: flutter
  meta: ^1.10.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  pigeon: ^27.3.2

topics:
  - files
  - file-selection
  - file-selector

```


### File: windows\flutter\ephemeral\.plugin_symlinks\image_picker_windows\example\pubspec.yaml
```dart
name: example
description: Example for image_picker_windows implementation.
publish_to: 'none'
version: 1.0.0

environment:
  sdk: ^3.6.0
  flutter: ">=3.27.0"

dependencies:
  flutter:
    sdk: flutter
  image_picker_platform_interface: ^2.11.0
  image_picker_windows:
    # When depending on this package from a real application you should use:
    #   image_picker_windows: ^x.y.z
    # See https://dart.dev/tools/pub/dependencies#version-constraints
    # The example app is bundled with the plugin so we use a path dependency on
    # the parent directory to use the current plugin's version.
    path: ..
  mime: ^2.0.0
  video_player: ^2.1.4

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true

```


### File: windows\flutter\ephemeral\.plugin_symlinks\image_picker_windows\pubspec.yaml
```dart
name: image_picker_windows
description: Windows platform implementation of image_picker
repository: https://github.com/flutter/packages/tree/main/packages/image_picker/image_picker_windows
issue_tracker: https://github.com/flutter/flutter/issues?q=is%3Aissue+is%3Aopen+label%3A%22p%3A+image_picker%22
version: 0.2.2

environment:
  sdk: ^3.6.0
  flutter: ">=3.27.0"

flutter:
  plugin:
    implements: image_picker
    platforms:
      windows:
        dartPluginClass: ImagePickerWindows

dependencies:
  file_selector_platform_interface: ^2.2.0
  file_selector_windows: ^0.9.0
  flutter:
    sdk: flutter
  image_picker_platform_interface: ^2.11.0

dev_dependencies:
  build_runner: ^2.1.5
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4

topics:
  - image-picker
  - files
  - file-selection

```


### File: windows\flutter\ephemeral\.plugin_symlinks\path_provider_windows\example\pubspec.yaml
```dart
name: path_provider_example
description: Demonstrates how to use the path_provider plugin.
publish_to: none

environment:
  sdk: ^3.2.0
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter
  path_provider_windows:
    # When depending on this package from a real application you should use:
    #   path_provider_windows: ^x.y.z
    # See https://dart.dev/tools/pub/dependencies#version-constraints
    # The example app is bundled with the plugin so we use a path dependency on
    # the parent directory to use the current plugin's version.
    path: ../

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter

flutter:
  uses-material-design: true

```


### File: windows\flutter\ephemeral\.plugin_symlinks\path_provider_windows\pubspec.yaml
```dart
name: path_provider_windows
description: Windows implementation of the path_provider plugin
repository: https://github.com/flutter/packages/tree/main/packages/path_provider/path_provider_windows
issue_tracker: https://github.com/flutter/flutter/issues?q=is%3Aissue+is%3Aopen+label%3A%22p%3A+path_provider%22
version: 2.3.0

environment:
  sdk: ^3.2.0
  flutter: ">=3.16.0"

flutter:
  plugin:
    implements: path_provider
    platforms:
      windows:
        dartPluginClass: PathProviderWindows

dependencies:
  ffi: ^2.0.0
  flutter:
    sdk: flutter
  path: ^1.8.0
  path_provider_platform_interface: ^2.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter

topics:
  - files
  - path-provider
  - paths

```


### File: windows\flutter\ephemeral\.plugin_symlinks\shared_preferences_windows\example\pubspec.yaml
```dart
name: shared_preferences_windows_example
description: Demonstrates how to use the shared_preferences_windows plugin.
publish_to: none

environment:
  sdk: ^3.3.0
  flutter: ">=3.19.0"

dependencies:
  flutter:
    sdk: flutter
  shared_preferences_platform_interface: ^2.4.0
  shared_preferences_windows:
    # When depending on this package from a real application you should use:
    #   shared_preferences_windows: ^x.y.z
    # See https://dart.dev/tools/pub/dependencies#version-constraints
    # The example app is bundled with the plugin so we use a path dependency on
    # the parent directory to use the current plugin's version.
    path: ../

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter

flutter:
  uses-material-design: true

```


### File: windows\flutter\ephemeral\.plugin_symlinks\shared_preferences_windows\pubspec.yaml
```dart
name: shared_preferences_windows
description: Windows implementation of shared_preferences
repository: https://github.com/flutter/packages/tree/main/packages/shared_preferences/shared_preferences_windows
issue_tracker: https://github.com/flutter/flutter/issues?q=is%3Aissue+is%3Aopen+label%3A%22p%3A+shared_preferences%22
version: 2.4.1

environment:
  sdk: ^3.3.0
  flutter: ">=3.19.0"

flutter:
  plugin:
    implements: shared_preferences
    platforms:
      windows:
        dartPluginClass: SharedPreferencesWindows

dependencies:
  file: ">=6.0.0 <8.0.0"
  flutter:
    sdk: flutter
  path: ^1.8.0
  path_provider_platform_interface: ^2.0.0
  path_provider_windows: ^2.0.0
  shared_preferences_platform_interface: ^2.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter

topics:
  - persistence
  - shared-preferences
  - storage

```


### File: windows\flutter\ephemeral\.plugin_symlinks\url_launcher_windows\example\pubspec.yaml
```dart
name: url_launcher_example
description: Demonstrates the Windows implementation of the url_launcher plugin.
publish_to: none

environment:
  sdk: ^3.10.0
  flutter: ">=3.38.0"

dependencies:
  flutter:
    sdk: flutter
  url_launcher_platform_interface: ^2.2.0
  url_launcher_windows:
    # When depending on this package from a real application you should use:
    #   url_launcher_windows: ^x.y.z
    # See https://dart.dev/tools/pub/dependencies#version-constraints
    # The example app is bundled with the plugin so we use a path dependency on
    # the parent directory to use the current plugin's version.
    path: ../

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter

flutter:
  uses-material-design: true

```


