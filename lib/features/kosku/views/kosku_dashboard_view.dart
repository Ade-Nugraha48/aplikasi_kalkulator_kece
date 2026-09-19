/// ============================================================================
/// FILE: lib/features/kosku/views/kosku_dashboard_view.dart
/// FUNGSI: Tampilan Dashboard Keuangan Anak Kos "KosKu".
/// MANAJEMEN HANDLES: FR-T2-01 (Ringkasan Pemasukan/Pengeluaran DB) & FR-T2-03 (Hapus Transaksi DB)
/// LOKASI LOGIC: UI Card Ringkasan Pemasukan, Pengeluaran, & Saldo Bersih,
///               serta ListView transaksi dengan tombol aksi Edit & Hapus.
/// ============================================================================

import 'package:flutter/material.dart';
import '../services/kosku_service.dart';
import 'kosku_form_view.dart';

class KoskuDashboardView extends StatefulWidget {
  const KoskuDashboardView({super.key});

  @override
  State<KoskuDashboardView> createState() => _KoskuDashboardViewState();
}

class _KoskuDashboardViewState extends State<KoskuDashboardView> {
  final KoskuService _koskuService = KoskuService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KosKu - Catatan Keuangan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Handles FR-T2-01: Ringkasan Total Pemasukan/Pengeluaran
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text('Total Saldo', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    const Text('Rp 0', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        Column(
                          children: [
                            Text('Pemasukan', style: TextStyle(color: Colors.green)),
                            Text('Rp 0', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            Text('Pengeluaran', style: TextStyle(color: Colors.red)),
                            Text('Rp 0', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // TODO: ListView daftar transaksi dengan fitur Hapus (FR-T2-03)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Handles FR-T2-02: Buka Form Tambah Transaksi
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const KoskuFormView()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Transaksi'),
      ),
    );
  }
}
