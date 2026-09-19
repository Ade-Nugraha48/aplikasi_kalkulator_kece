// lib/features/home/presentation/screens/home_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../widgets/menu_card_item.dart';
import '../../members/presentation/screens/team_screen.dart';
import '../../financial_kos/presentation/screens/financial_dashboard_screen.dart';
import '../../math_tools/presentation/screens/calculator_screen.dart';
import '../../math_tools/presentation/screens/odd_even_screen.dart';
import '../../math_tools/presentation/screens/statistics_screen.dart';
import '../../calendar_converters/presentation/screens/hijriah_converter_screen.dart';
import '../../calendar_converters/presentation/screens/age_calculator_screen.dart';
import '../../calendar_converters/presentation/screens/weton_calendar_screen.dart';
import '../../calendar_converters/presentation/screens/saka_bali_screen.dart';

/// Screen Home / Dashboard Menu Utama (Tab 1 pada Bottom Navigation).
/// 
/// Memenuhi Alur Aplikasi (Tab 1: Home Menu):
/// Menampilkan Grid/List Menu vertikal yang dapat di-scroll dengan ikon modern untuk 9 Fitur Utama:
/// 1. Daftar Anggota Kelompok (Data dari DB) - FR-U-03
/// 2. Catatan Keuangan KosKu (Dashboard & CRUD) - FR-T2-01 s/d 04
/// 3. Kalkulator Presisi BigInteger - FR-T1-01
/// 4. Cek Ganjil / Genap - FR-T1-02 (Diperbarui dengan Icon Icons.functions / matematika)
/// 5. Deret & Statistik Angka - FR-T1-03
/// 6. Konversi Tanggal Hijriah - FR-T2-05
/// 7. Konversi Tanggal Lahir (Detail Umur) - FR-T2-06
/// 8. Kalender Weton Jawa - FR-T2-07
/// 9. Kalender Saka Bali - FR-T2-08
class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Daftar Anggota Kelompok',
        'subtitle': 'Melihat daftar anggota kelompok pengembang dari DB',
        'icon': Icons.group,
        'color': const Color(0xFF6C5CE7),
        'screen': const ViewDataKelompok(),
      },
      {
        'title': 'Catatan Keuangan KosKu',
        'subtitle': 'Kelola pemasukan & pengeluaran anak kos',
        'icon': Icons.account_balance_wallet,
        'color': const Color(0xFF00B894),
        'screen': const FinancialDashboardScreen(),
      },
      {
        'title': 'Kalkulator Presisi',
        'subtitle': 'Hitung angka presisi tinggi & desimal besar',
        'icon': Icons.calculate,
        'color': const Color(0xFF0984E3),
        'screen': const ViewKalkulator(),
      },
      {
        'title': 'Cek Ganjil / Genap',
        'subtitle': 'Periksa status ganjil genap suatu bilangan',
        'icon': Icons.functions, // Icon disesuaikan lebih representatif
        'color': const Color(0xFFE17055),
        'screen': const ViewGanjilGenap(),
      },
      {
        'title': 'Deret & Statistik Angka',
        'subtitle': 'Hitung total, rata-rata, min, max deret angka',
        'icon': Icons.analytics,
        'color': const Color(0xFFFDCB6E),
        'screen': const ViewTotalAngka(),
      },
      {
        'title': 'Konversi Tanggal Hijriah',
        'subtitle': 'Konversi tanggal Masehi ke Hijriah',
        'icon': Icons.calendar_month,
        'color': const Color(0xFF00CEC9),
        'screen': const HijriahConverterScreen(),
      },
      {
        'title': 'Konversi Tanggal Lahir',
        'subtitle': 'Hitung detail umur hingga jam, menit, & detik',
        'icon': Icons.cake,
        'color': const Color(0xFFE84393),
        'screen': const AgeCalculatorScreen(),
      },
      {
        'title': 'Kalender Weton Jawa',
        'subtitle': 'Hitung hari pasaran dan weton Jawa',
        'icon': Icons.event_note,
        'color': const Color(0xFF6C5CE7),
        'screen': const WetonCalendarScreen(),
      },
      {
        'title': 'Kalender Saka Bali',
        'subtitle': 'Hitung penanggalan Saka Bali dari Masehi',
        'icon': Icons.auto_awesome,
        'color': const Color(0xFFD63031),
        'screen': const SakaBaliScreen(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard Utama',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return MenuCardItem(
              title: item['title'],
              subtitle: item['subtitle'],
              icon: item['icon'],
              color: item['color'],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => item['screen']),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
