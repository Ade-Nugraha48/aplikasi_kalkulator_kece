// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../../calculator_t1/screens/kalkulator_screen.dart';
import '../../calculator_t1/screens/ganjil_genap_screen.dart';
import '../../calculator_t1/screens/statistik_screen.dart';
import '../../finance_t2/screens/dashboard_kosku_screen.dart';
import '../../conversions_t2/screens/hijriah_screen.dart';
import '../../conversions_t2/screens/umur_screen.dart';
import '../../conversions_t2/screens/weton_screen.dart';
import '../../conversions_t2/screens/saka_bali_screen.dart';
import '../../utilities/screens/anggota_screen.dart';
import '../../utilities/screens/panduan_screen.dart';

// TODO: Implementasi Home Dashboard Screen (Grid/List Menu Navigasi)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF2D2D44), const Color(0xFF1E1E2E)]
                        : [const Color(0xFF6C5CE7), const Color(0xFFA29BFE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C5CE7).withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selamat Datang! 👋',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Aplikasi Kalkulator Presisi, Manajemen KosKu & Konversi Waktu',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.calculate_outlined,
                      size: 56,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Section 1: Task 1 - Kalkulator Presisi
              Text(
                'Task 1 - Fitur Kalkulator',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 550 ? 3 : 2;
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.2,
                    children: [
                      _buildMenuCard(
                        context,
                        title: 'Kalkulator Presisi',
                        subtitle: 'BigInt Multi-digit',
                        icon: Icons.calculate,
                        color: Colors.deepPurple,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KalkulatorScreen())),
                      ),
                      _buildMenuCard(
                        context,
                        title: 'Cek Ganjil Genap',
                        subtitle: 'Deteksi Bilangan',
                        icon: Icons.numbers,
                        color: Colors.indigo,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GanjilGenapScreen())),
                      ),
                      _buildMenuCard(
                        context,
                        title: 'Deret & Statistik',
                        subtitle: 'Hitung Sum & Avg',
                        icon: Icons.analytics,
                        color: Colors.blue,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatistikScreen())),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),

              // Section 2: Task 2 - KosKu & Konversi Waktu
              Text(
                'Task 2 - KosKu & Konversi Waktu',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 550 ? 3 : 2;
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.2,
                    children: [
                      _buildMenuCard(
                        context,
                        title: 'Dashboard KosKu',
                        subtitle: 'Pemasukan & Pengeluaran',
                        icon: Icons.account_balance_wallet,
                        color: Colors.teal,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardKoskuScreen())),
                      ),
                      _buildMenuCard(
                        context,
                        title: 'Tanggal Hijriah',
                        subtitle: 'Konversi Kalender',
                        icon: Icons.calendar_month,
                        color: Colors.green,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HijriahScreen())),
                      ),
                      _buildMenuCard(
                        context,
                        title: 'Umur Rinci',
                        subtitle: 'Tahun, Bulan, Jam',
                        icon: Icons.cake,
                        color: Colors.orange,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UmurScreen())),
                      ),
                      _buildMenuCard(
                        context,
                        title: 'Kalender Weton',
                        subtitle: 'Pasaran Jawa',
                        icon: Icons.auto_awesome,
                        color: Colors.amber.shade800,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WetonScreen())),
                      ),
                      _buildMenuCard(
                        context,
                        title: 'Saka Bali',
                        subtitle: 'Kalender Bali',
                        icon: Icons.temple_hindu,
                        color: Colors.deepOrange,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SakaBaliScreen())),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),

              // Section 3: Informasi & Utilitas
              Text(
                'Informasi & Utilitas',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMenuCard(
                      context,
                      title: 'Daftar Anggota',
                      subtitle: 'Nama & NIM Tim',
                      icon: Icons.group,
                      color: Colors.pink,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnggotaScreen())),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildMenuCard(
                      context,
                      title: 'Panduan Fitur',
                      subtitle: 'Cara Penggunaan',
                      icon: Icons.help_outline,
                      color: Colors.purple,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PanduanScreen())),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
