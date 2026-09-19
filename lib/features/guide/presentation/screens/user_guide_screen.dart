// lib/features/guide/presentation/screens/user_guide_screen.dart
import 'package:flutter/material.dart';
import '../../auth/presentation/screens/login_screen.dart';

/// Screen Panduan Pengguna & Profil / Logout (FR-U-04, FR-U-05 Tab 3)
class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  void _konfirmasiLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.redAccent),
            SizedBox(width: 10),
            Text('Konfirmasi Keluar'),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi dan mengakhiri sesi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HalamanLogin()),
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
        title: const Text('Panduan & Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Logout',
            onPressed: () => _konfirmasiLogout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.menu_book, color: Color(0xFF6C5CE7)),
                        SizedBox(width: 10),
                        Text(
                          'Panduan Pengguna (FR-U-04)',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Divider(height: 20),
                    Text(
                      '1. Dashboard Utama: Berisi 9 menu navigasi fitur lengkap.\n'
                      '2. Catatan Keuangan KosKu: Kelola pemasukan, pengeluaran, dan kategori.\n'
                      '3. Fitur Matematika: Kalkulator Presisi, Ganjil/Genap, dan Statistik.\n'
                      '4. Fitur Kalender: Konversi Masehi ke Hijriah, Umur Detail, Weton Jawa, & Saka Bali.\n'
                      '5. Stopwatch: Fitur hitung waktu interaktif di Tab 2.\n'
                      '6. Session Timeout: Otomatis logout jika idle selama 1 jam (FR-U-06).',
                      style: TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () => _konfirmasiLogout(context),
                icon: const Icon(Icons.logout),
                label: const Text('LOGOUT / KELUAR SESI (FR-U-05)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
