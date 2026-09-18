// lib/features/utilities/screens/panduan_screen.dart
import 'package:flutter/material.dart';

// TODO: Implementasi FR-U-04 Panduan Penggunaan Aplikasi
class PanduanScreen extends StatelessWidget {
  const PanduanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panduan Penggunaan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGuideCard(
                  context,
                  title: '1. Kalkulator Presisi (BigInt)',
                  icon: Icons.calculate,
                  description:
                      'Mendukung operasi matematika dasar (+, -, *, /) dengan presisi tinggi tanpa batas angka (menggunakan BigInt dan BigDecimal). Masukkan ekspresi di kolom input atau tekan tombol pada keypad.',
                ),
                _buildGuideCard(
                  context,
                  title: '2. Deteksi Ganjil Genap',
                  icon: Icons.numbers,
                  description:
                      'Masukkan sebarang bilangan bulat untuk mendeteksi apakah bilangan tersebut tergolong Ganjil atau Genap. Sangat presisi untuk digit angka yang sangat panjang.',
                ),
                _buildGuideCard(
                  context,
                  title: '3. Deret Jumlah & Statistik',
                  icon: Icons.analytics,
                  description:
                      'Masukkan deret angka yang dipisahkan dengan koma atau spasi untuk menghitung Total Jumlah, Rata-Rata, Nilai Terkecil (Min), dan Nilai Terbesar (Max).',
                ),
                _buildGuideCard(
                  context,
                  title: '4. Dashboard KosKu',
                  icon: Icons.account_balance_wallet,
                  description:
                      'Kelola keuangan anak kos dengan mencatat Pemasukan dan Pengeluaran harian. Pantau sisa saldo secara real-time dan hapus/edit transaksi kapan saja.',
                ),
                _buildGuideCard(
                  context,
                  title: '5. Konversi Tanggal & Waktu',
                  icon: Icons.calendar_month,
                  description:
                      'Fitur konversi waktu lengkap mencakup Konversi Hijriah, Umur Rinci (Tahun, Bulan, Hari, Jam), Weton Jawa, dan Kalender Saka Bali.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuideCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String description,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey.shade700, height: 1.4, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
