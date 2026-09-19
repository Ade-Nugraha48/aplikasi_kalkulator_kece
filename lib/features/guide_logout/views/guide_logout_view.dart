/// ============================================================================
/// FILE: lib/features/guide_logout/views/guide_logout_view.dart
/// FUNGSI: Tampilan Halaman Panduan Penggunaan Aplikasi & Tombol Logout (Tab 3).
/// MANAJEMEN HANDLES: FR-U-04 (Panduan Penggunaan) & FR-U-05 (Tombol Logout)
/// LOKASI LOGIC: Tempat penulisan dokumentasi/petunjuk cara menggunakan setiap fitur aplikasi,
///               serta dialog konfirmasi logout & penghapusan session aktif.
/// ============================================================================

import 'package:flutter/material.dart';
import '../../../core/session/session_manager.dart';
import '../../auth/views/login_view.dart';

class GuideLogoutView extends StatelessWidget {
  const GuideLogoutView({super.key});

  void _konfirmasiLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              // Handles FR-U-05: Logout & Clear Session
              SessionManager().clearSession();
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
              );
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panduan & Logout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Handles FR-U-04: Panduan Penggunaan
            const Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'PANDUAN PENGGUNAAN APLIKASI:\n\n'
                  '1. Home: Berisi daftar seluruh menu fitur Tugas 1 & Tugas 2.\n'
                  '2. Stopwatch: Fitur pengukur waktu hitung maju.\n'
                  '3. KosKu: Catatan transaksi keuangan dengan Supabase Cloud.\n'
                  '4. Konversi Kalender: Hijriah, Umur Detail, Weton, & Saka Bali.\n'
                  '5. Session: Auto-logout otomatis jika 1 jam tidak ada aktivitas.',
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Handles FR-U-05: Tombol Logout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () => _konfirmasiLogout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
