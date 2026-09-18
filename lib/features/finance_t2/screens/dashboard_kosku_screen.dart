// lib/features/finance_t2/screens/dashboard_kosku_screen.dart
import 'package:flutter/material.dart';
import '../models/transaksi_model.dart';
import 'form_transaksi_screen.dart';

// TODO: Implementasi FR-T2-01 Dashboard KosKu (Hitung Pemasukan & Pengeluaran) & FR-T2-03 Hapus Transaksi
class DashboardKoskuScreen extends StatefulWidget {
  const DashboardKoskuScreen({super.key});

  @override
  State<DashboardKoskuScreen> createState() => _DashboardKoskuScreenState();
}

class _DashboardKoskuScreenState extends State<DashboardKoskuScreen> {
  // TODO: Sambungkan ke DatabaseHelper untuk mengambil & menyimpan transaksi
  final List<TransaksiModel> _daftarTransaksi = [
    TransaksiModel(
      id: '1',
      judul: 'Uang Saku Bulanan',
      jumlah: 1500000,
      tipe: TipeTransaksi.pemasukan,
      tanggal: DateTime.now().subtract(const Duration(days: 2)),
      kategori: 'Transfer Orang Tua',
    ),
    TransaksiModel(
      id: '2',
      judul: 'Bayar Sewa Kos Bulan Ini',
      jumlah: 750000,
      tipe: TipeTransaksi.pengeluaran,
      tanggal: DateTime.now().subtract(const Duration(days: 1)),
      kategori: 'Sewa Kos',
    ),
  ];

  double get _totalPemasukan {
    return _daftarTransaksi
        .where((t) => t.tipe == TipeTransaksi.pemasukan)
        .fold(0, (sum, item) => sum + item.jumlah);
  }

  double get _totalPengeluaran {
    return _daftarTransaksi
        .where((t) => t.tipe == TipeTransaksi.pengeluaran)
        .fold(0, (sum, item) => sum + item.jumlah);
  }

  double get _saldoAkhir => _totalPemasukan - _totalPengeluaran;

  void _hapusTransaksi(String id) {
    // TODO: FR-T2-03 Hapus (Delete) Pemasukan/Pengeluaran di database
    setState(() {
      _daftarTransaksi.removeWhere((t) => t.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi berhasil dihapus.')),
    );
  }

  void _bukaFormTambah() async {
    final result = await Navigator.push<TransaksiModel>(
      context,
      MaterialPageRoute(builder: (context) => const FormTransaksiScreen()),
    );
    if (result != null) {
      setState(() {
        _daftarTransaksi.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard KosKu'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _bukaFormTambah,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Transaksi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Saldo Ringkasan
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: theme.colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Saldo KosKu',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Rp ${_saldoAkhir.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Colors.white24,
                                child: Icon(Icons.arrow_downward, color: Colors.greenAccent),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Pemasukan', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  Text(
                                    'Rp ${_totalPemasukan.toStringAsFixed(0)}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Colors.white24,
                                child: Icon(Icons.arrow_upward, color: Colors.redAccent),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Pengeluaran', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  Text(
                                    'Rp ${_totalPengeluaran.toStringAsFixed(0)}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Riwayat Transaksi',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_daftarTransaksi.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('Belum ada transaksi kos.'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _daftarTransaksi.length,
                itemBuilder: (context, index) {
                  final item = _daftarTransaksi[index];
                  final isIncome = item.tipe == TipeTransaksi.pemasukan;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isIncome ? Colors.green.shade100 : Colors.red.shade100,
                        child: Icon(
                          isIncome ? Icons.add_circle_outline : Icons.remove_circle_outline,
                          color: isIncome ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(item.judul, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${item.kategori} • ${item.tanggal.day}/${item.tanggal.month}/${item.tanggal.year}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${isIncome ? '+' : '-'} Rp ${item.jumlah.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isIncome ? Colors.green : Colors.red,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.grey),
                            onPressed: () => _hapusTransaksi(item.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
