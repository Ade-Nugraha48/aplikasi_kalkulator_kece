// lib/views/main_navigation_screen.dart
import 'package:flutter/material.dart';
import 'calculator_view.dart';
import 'odd_even_view.dart';
import 'statistics_view.dart';
import 'team_view.dart';
import 'login_screen.dart';

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  int _indeksMenu = 0;

  final List<Widget> _halaman = const [
    ViewKalkulator(),
    ViewGanjilGenap(),
    ViewTotalAngka(),
    ViewDataKelompok(),
  ];

  void _konfirmasiLogout() {
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
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
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
        title: const Text(
          'Kalkulator Kece',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _konfirmasiLogout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(
          key: ValueKey<int>(_indeksMenu),
          child: _halaman[_indeksMenu],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indeksMenu,
        elevation: 8,
        onDestinationSelected: (index) => setState(() => _indeksMenu = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate, color: Colors.white),
            label: 'Kalkulator',
          ),
          NavigationDestination(
            icon: Icon(Icons.numbers_outlined),
            selectedIcon: Icon(Icons.numbers, color: Colors.white),
            label: 'Ganjil/Genap',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics, color: Colors.white),
            label: 'Statistik',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group, color: Colors.white),
            label: 'Kelompok',
          ),
        ],
      ),
    );
  }
}
