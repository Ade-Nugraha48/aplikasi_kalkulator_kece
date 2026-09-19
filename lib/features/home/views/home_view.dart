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
        'subtitle': 'Tugas 1 (Data dari Supabase Cloud DB)',
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
        'subtitle': 'Tugas 2 (Dashboard & CRUD DB)',
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
