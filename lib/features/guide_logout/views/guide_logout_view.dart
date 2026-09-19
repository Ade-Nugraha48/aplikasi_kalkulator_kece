/// ============================================================================
/// FILE: lib/features/guide_logout/views/guide_logout_view.dart
/// FUNGSI: Tampilan Halaman Panduan Penggunaan Aplikasi & Tombol Logout (Tab 3).
/// MANAJEMEN HANDLES: FR-U-04 (Panduan Penggunaan) & FR-U-05 (Tombol Logout)
/// LOKASI LOGIC: Tempat penulisan dokumentasi/petunjuk cara menggunakan setiap fitur aplikasi,
///               serta dialog konfirmasi logout & penghapusan session aktif (Secure Logout).
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/session/session_manager.dart';
import '../../auth/views/login_view.dart';

class GuideLogoutView extends StatelessWidget {
  const GuideLogoutView({super.key});

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
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi? Session Anda akan diakhiri secara permanen dari perangkat ini.'),
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
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        childrenPadding: const EdgeInsets.all(16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(content, style: const TextStyle(height: 1.5, fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final username = SessionManager().username ?? 'Pengguna Anonim';
    final email = SessionManager().email ?? 'email.tidak.tersedia@kosku.com';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil & Panduan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Profil Ringkas
            Card(
              color: theme.colorScheme.primaryContainer,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.colorScheme.onPrimaryContainer,
                      child: Icon(Icons.person, size: 40, color: theme.colorScheme.primaryContainer),
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
                              color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
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
              'Sistem Keamanan & Session', 
              Icons.security, 
              'Aplikasi dilengkapi dengan Auto-Logout (Session Timeout). Jika Anda tidak menyentuh layar atau berinteraksi sama sekali selama 1 jam, aplikasi akan secara otomatis memutus sesi Anda demi keamanan data.'
            ),
            _buildAccordion(
              'Fitur Komputasi (Tugas 1)', 
              Icons.calculate, 
              '• Kalkulator: Bisa menghitung angka desimal yang luar biasa besar (BigInteger/BigDecimal).\n'
              '• Ganjil Genap: Memeriksa sifat angka secara instan.\n'
              '• Deret & Statistik: Menampilkan deret matematika dan statistik dasar dari kumpulan angka masukan.'
            ),
            _buildAccordion(
              'Catatan Keuangan KosKu', 
              Icons.account_balance_wallet, 
              'Berfungsi mengelola uang Anda.\n'
              '• Tambah Catatan: Catat Pemasukan atau Pengeluaran.\n'
              '• Kategori: Anda bisa menambahkan kategori Anda sendiri (Fleksibel).\n'
              '• Dashboard: Melihat Saldo akhir dan riwayat terurut berdasarkan tanggal terbaru.'
            ),
            _buildAccordion(
              'Konversi Waktu & Kalender', 
              Icons.calendar_month, 
              '• Kalender Hijriah: Merubah Masehi ke kalender umat Islam.\n'
              '• Umur Detail: Menampilkan umur Anda mulai dari Tahun hingga Detik secara real-time!\n'
              '• Weton Jawa: Mencari Hari Pasaran Jawa beserta penjelasan watak/karakternya.\n'
              '• Saka Bali: Sistem kalender kuno Pawukon dan Wewaran.'
            ),
            _buildAccordion(
              'Stopwatch & Navigasi', 
              Icons.timer, 
              'Stopwatch memiliki resolusi tinggi hingga milidetik. Anda bisa menggunakan fungsi Lap Time. Uniknya, Stopwatch akan tetap berjalan di background walau Anda pindah tab di menu navigasi bawah!'
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _konfirmasiLogout(context),
                icon: const Icon(Icons.power_settings_new, size: 24),
                label: const Text('Keluar dari Aplikasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
