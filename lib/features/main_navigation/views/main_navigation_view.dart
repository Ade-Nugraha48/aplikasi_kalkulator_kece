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
