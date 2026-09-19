// lib/core/widgets/main_bottom_navbar.dart
import 'package:flutter/material.dart';
import '../../features/home/presentation/screens/home_dashboard_screen.dart';
import '../../features/stopwatch/presentation/screens/stopwatch_screen.dart';
import '../../features/guide/presentation/screens/user_guide_screen.dart';

/// Main Layout & Bottom Navigation Bar Permanen (FR-T2-09)
/// 
/// Memiliki 3 Tab Navigasi Bawah:
/// 1. Tab 1: Home / Dashboard Menu (Grid/List Menu Vertikal 9 Fitur)
/// 2. Tab 2: Stopwatch Feature
/// 3. Tab 3: Panduan Pengguna & Logout
class MainBottomNavbar extends StatefulWidget {
  const MainBottomNavbar({super.key});

  @override
  State<MainBottomNavbar> createState() => _MainBottomNavbarState();
}

class _MainBottomNavbarState extends State<MainBottomNavbar> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeDashboardScreen(), // Tab 1: Home Menu Utama
    StopwatchScreen(),     // Tab 2: Stopwatch
    UserGuideScreen(),     // Tab 3: Panduan & Profile / Logout
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        elevation: 8,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view, color: Colors.white),
            label: 'Utama',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer, color: Colors.white),
            label: 'Stopwatch',
          ),
          NavigationDestination(
            icon: Icon(Icons.help_outline),
            selectedIcon: Icon(Icons.help, color: Colors.white),
            label: 'Panduan',
          ),
        ],
      ),
    );
  }
}
