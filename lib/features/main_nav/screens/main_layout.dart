// lib/features/main_nav/screens/main_layout.dart
import 'package:flutter/material.dart';
import '../../home/screens/home_screen.dart';
import '../../utilities/screens/stopwatch_screen.dart';
import '../../utilities/screens/panduan_screen.dart';
import '../../auth/screens/login_screen.dart';
import '../../../core/utils/session_manager.dart';

// TODO: Implementasi FR-T2-09 Bottom Navigation Bar (Menu Utama, Stopwatch, Panduan & Logout)
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    StopwatchScreen(),
    PanduanScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // FR-U-06 Start session timer
    SessionManager.instance.startSession(
      onTimeout: _handleAutoLogout,
    );
  }

  void _handleAutoLogout() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sesi habis karena tidak aktif selama 1 jam. Silakan login kembali.'),
        backgroundColor: Colors.orange,
      ),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

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
              SessionManager.instance.stopSession();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void _onTabTapped(int index) {
    // Reset idle session timer on user activity
    SessionManager.instance.resetTimer();

    if (index == 3) {
      // Menu Logout
      _konfirmasiLogout();
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => SessionManager.instance.resetTimer(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _currentIndex == 0
                ? 'Beranda Utama'
                : _currentIndex == 1
                    ? 'Stopwatch Presisi'
                    : 'Panduan Penggunaan',
            style: const TextStyle(fontWeight: FontWeight.bold),
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
            key: ValueKey<int>(_currentIndex),
            child: _pages[_currentIndex],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          elevation: 8,
          onDestinationSelected: _onTabTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: Colors.white),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.timer_outlined),
              selectedIcon: Icon(Icons.timer, color: Colors.white),
              label: 'Stopwatch',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book, color: Colors.white),
              label: 'Panduan',
            ),
            NavigationDestination(
              icon: Icon(Icons.logout, color: Colors.redAccent),
              selectedIcon: Icon(Icons.logout, color: Colors.redAccent),
              label: 'Logout',
            ),
          ],
        ),
      ),
    );
  }
}
